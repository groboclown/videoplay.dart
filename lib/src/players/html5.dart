// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

/**
 * Internal implementation of the YouTube embedding and management.
 */
library videoplay.src.players.html5;


import 'dart:async';
import 'dart:html';

import '../videoplayer.dart';
import '../videoprovider.dart' show VideoProviderException;

final Map<String, String> EXTENSION_TO_MIME = {
    "mp4": "video/mp4",                 // MPEG-4
    "ogg": "video/ogg",                 // ogg/vorbis
    "ogv": "video/ogg",                 // ogg/vorbis
    "webm": "video/webm",               //
    "3gp": "video/3gpp",                // 3GP Mobile
    "ts": "video/MP2T",                 // iPhone segment
    "m3u8": "application/x-mpegURL",    // iPhone index
    "flv": "video/x-flv",               // flash video
    "mov": "video/quicktime",           // QuickTime
    "avi": "video/x-msvideo",           // A/V interleave
    "wmv": "video/x-ms-wmv"             // Windows Media video
};



class Html5VideoPlayer implements VideoPlayer {
    VideoElement _element;
    final Map<String, String> _supportedExtensions;
    bool tryExtensions;
    int _customError = null;

    factory Html5VideoPlayer(Element wrapper, String videoId,
            { bool tryExtensions,
            Iterable<String> supportedExtensions,
            Map<String, String> mimeTypes,
            int width, int height }) {
        Map<String, String> extensions = {};
        if (supportedExtensions != null) {
            for (String ext in supportedExtensions) {
                if (EXTENSION_TO_MIME.containsKey(ext)) {
                    extensions[ext] = EXTENSION_TO_MIME[ext];
                } else {
                    throw new VideoProviderException(
                        "no known mime type for ${ext}; use the mimeTypes");
                }
            }
        }
        if (mimeTypes != null) {
            extensions.addAll(mimeTypes);
        }
        if (extensions.isEmpty) {
            extensions.addAll(EXTENSION_TO_MIME);
        }
        VideoElement vid = new VideoElement();

        // Strip out all codecs that aren't supported
        Map<String, String> acceptableExtensions = new Map.from(extensions);
        for (String ext in extensions.keys) {
            String support = vid.canPlayType(extensions[ext]);
            if (support == null || support == '') {
                acceptableExtensions.remove(ext);
            } else {
                print("Browser supports " + extensions[ext] +
                        " (${ext}) video");
            }
        }
        if (acceptableExtensions.isEmpty) {
            throw new VideoProviderException(
                    "Your browser does not support HTML 5 video");
        }

        vid.controls = true;
        vid.autoplay = false;
        vid.loop = false;
        if (width != null) {
            vid.width = width;
        }
        if (height != null) {
            vid.height = height;
        }
        wrapper.children.add(vid);
        var ret = new Html5VideoPlayer._(vid, acceptableExtensions,
                tryExtensions);
        ret.loadVideo(videoId);
        return ret;
    }



    @override
    bool get hasVideo => _element != null && _element.currentSrc != null;


    @override
    int get errorCode =>
        _customError != null ? _customError :
            _element == null ? -1 :
                _element.error == null ? 0 :
                    _element.error.code;

    @override
    String get errorText {
        if (_element == null) {
            return "destroyed";
        }
        int errCode = _customError;

        if (errCode == null && _element.error != null &&
                _element.error.code > 0) {
            errCode = _element.error.code;
        }
        if (errCode == null) {
            return null;
        }
        switch (errCode) {
            case 0:
                return null;
            case MediaError.MEDIA_ERR_ABORTED:
                return "aborted";
            case MediaError.MEDIA_ERR_DECODE:
                return "could not decode video";
            case MediaError.MEDIA_ERR_ENCRYPTED:
                return "video could not be decrypted";
            case MediaError.MEDIA_ERR_NETWORK:
                return "problem downloading the video";
            case MediaError.MEDIA_ERR_SRC_NOT_SUPPORTED:
                return "video encoding not supported";
            default:
                return "unknown video error ${_element.error.code}";
        }
    }

    @override
    double get percentVideoLoaded {
        if (_element == null) {
            return 0.0;
        }
        double total = _element.duration;
        if (total <= 0.0) {
            return 0.0;
        }
        double buffered = 0.0;
        TimeRanges ranges = _element.buffered;
        for (int i = 0; i < ranges.length; ++i) {
            buffered += ranges.end(i) - ranges.start(i);
        }
        return 100.0 * buffered / total;
    }

    @override
    Duration get playbackTime => _secondsToDuration(_element.currentTime);

    @override
    Duration get videoDuration => _secondsToDuration(_element.duration);

    @override
    VideoPlayerStatus get status {
        if (_element == null) {
            return VideoPlayerStatus.NOT_INITIALIZED;
        }
        if (_element.error != null && _element.error.code > 0) {
            return VideoPlayerStatus.ERROR;
        }
        if (_element.ended) {
            return VideoPlayerStatus.ENDED;
        }
        if (_element.seeking) {
            return VideoPlayerStatus.BUFFERING;
        }
        if (_element.paused) {
            return VideoPlayerStatus.PAUSED;
        }

        // From what we can tell, at this point it means that the video
        // is playing
        return VideoPlayerStatus.PLAYING;
    }

    StreamController<VideoPlayerEvent> _events =
            new StreamController<VideoPlayerEvent>.broadcast();
    @override
    Stream<VideoPlayerEvent> get statusChangeEvents => _events.stream;

    @override
    String get videoId => _element == null ? null : _element.currentSrc;

    @override
    void loadVideo(String videoId) {
        //_element.src = null;
        for (Element child in _element.children) {
            if (child is SourceElement) {
                child.remove();
            }
        }

        Uri videoUri = Uri.parse(videoId);
        String videoFileName = videoUri.pathSegments.last;
        String ext = null;
        String videoWithoutExtension = null;
        if (videoFileName.lastIndexOf('.') > 0) {
            // Looks like there's an extension.  May not be, but it looks
            // like it.
            ext = videoFileName.substring(videoFileName.lastIndexOf('.') + 1);

            List<String> segments = new List.from(videoUri.pathSegments);
            segments.removeLast();
            segments.add(videoFileName.
                    substring(0, videoFileName.lastIndexOf('.')));
            videoWithoutExtension = videoUri.
                    replace(pathSegments: segments).toString();
        }

        if (tryExtensions) {
            if (ext != null) {
                // Looks like there's an extension.  Load the file without
                // the extension to load the video in all the supported formats.
                _addSupportedSources(videoWithoutExtension);

                // we can't guarantee that the user stripped off the extension,
                // and the filename might have a period in it, so there's the
                // the chance we have to try with the period.  However, since
                // we already checked for the extension being valid, we can
                // safely asume that the video was given with the correct
                // extension.
            } else {
                // No extension found
                _addSupportedSources(videoId);
            }
        } else {
            if (ext != null) {
                _addSource(videoId, ext);
            } else {
                // We weren't given a file extension.  We'll have to try them
                // all.
                _addSupportedSources(videoId);
            }
        }

        /*
        if (addedVideo) {
            _customError = null;
        } else {
            // Report error
            _customError = MediaError.MEDIA_ERR_SRC_NOT_SUPPORTED;
            _events.sink.add(new VideoPlayerEvent(
                    this, new DateTime.now(), VideoPlayerStatus.ERROR,
                    errorText, errorCode));
        }
        *
         */
    }

    void _addSupportedSources(String basePath) {
        for (String ext in _supportedExtensions.keys) {
            _addSource(basePath + '.' + ext, ext);
        }
    }

    void _addSource(String uri, String ext) {
        var el = new SourceElement();
        el.src = uri;
        el.type = _supportedExtensions[ext];
        _element.children.add(el);
    }

    @override
    void play() {
        _element.play();
    }

    @override
    void pause() {
        _element.pause();
    }

    @override
    void stop() {
        _element.pause();
        _element.currentTime = 0.0;
    }

    @override
    void seekTo(Duration time) {
        double toTime = time.inMilliseconds / 1000.0;
        _element.currentTime = toTime;
    }

    @override
    void destroy() {
        _events.sink.close();
        _element.remove();
        _element = null;
    }


    Html5VideoPlayer._(this._element, this._supportedExtensions,
            this.tryExtensions) {
        _element.onAbort.listen((_) {
            _events.sink.add(new VideoPlayerEvent(
                    this, new DateTime.now(), VideoPlayerStatus.ENDED));
        });
        _element.onCanPlay.listen((_) {
            _events.sink.add(new VideoPlayerEvent(
                    this, new DateTime.now(), VideoPlayerStatus.NOT_STARTED));
        });
        //_element.onCanPlayThrough.listen((_) {
        //_element.onDurationChange.listen((_) {
        //_element.onEmptied.listen((_) {
        _element.onEnded.listen((_) {
            _events.sink.add(new VideoPlayerEvent(
                    this, new DateTime.now(), VideoPlayerStatus.ENDED));
        });
        _element.onError.listen((_) {
            _events.sink.add(new VideoPlayerEvent(
                    this, new DateTime.now(), VideoPlayerStatus.ERROR,
                    errorText, errorCode));
        });
        _element.onLoadedData.listen((_) {
            _events.sink.add(new VideoPlayerEvent(
                    // A guess at what is needed to happen.
                    this, new DateTime.now(), VideoPlayerStatus.PLAYING,
                    errorText, errorCode));
        });
        //_element.onLoadedMetaData.listen((_) {
        _element.onLoad.listen((_) {
            _events.sink.add(new VideoPlayerEvent(
                    this, new DateTime.now(), VideoPlayerStatus.NOT_STARTED,
                    errorText, errorCode));
        });
        _element.onPause.listen((_) {
            _events.sink.add(new VideoPlayerEvent(
                    this, new DateTime.now(), VideoPlayerStatus.PAUSED,
                    errorText, errorCode));
        });
        _element.onPlay.listen((_) {
            _events.sink.add(new VideoPlayerEvent(
                    this, new DateTime.now(), VideoPlayerStatus.PLAYING,
                    errorText, errorCode));
        });
        _element.onPlaying.listen((_) {
            _events.sink.add(new VideoPlayerEvent(
                    this, new DateTime.now(), VideoPlayerStatus.PLAYING,
                    errorText, errorCode));
        });
        //_element.onProgress.listen((_) {
        //_element.onRateChange.listen((_) {
        //_element.onSeeked.listen((_) {
        //_element.onSeeking.listen((_) {
        _element.onStalled.listen((_) {
            _events.sink.add(new VideoPlayerEvent(
                    this, new DateTime.now(), VideoPlayerStatus.BUFFERING,
                    errorText, errorCode));
        });
        _element.onSuspend.listen((_) {
            _events.sink.add(new VideoPlayerEvent(
                    this, new DateTime.now(), VideoPlayerStatus.BUFFERING,
                    errorText, errorCode));
        });
        //_element.onTimeUpdate.listen((_) {
        //_element.onVolumeChange.listen((_) {
        _element.onWaiting.listen((_) {
            _events.sink.add(new VideoPlayerEvent(
                    this, new DateTime.now(), VideoPlayerStatus.BUFFERING,
                    errorText, errorCode));
        });
    }

    static Duration _secondsToDuration(num seconds) {
        int secs = seconds.floor();
        int milli = ((seconds - secs) * 1000.0).toInt();
        return new Duration(seconds: seconds, milliseconds: milli);
    }
}




