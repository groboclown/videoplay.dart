// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

/**
 * Internal implementation of the YouTube embedding and management.
 */
library videoplay.src.players.youtube;

import 'dart:async';
import 'dart:html';
import 'dart:js';

import '../util/embedjs.dart';
import '../util/swfobject.dart';
import '../videoplayer.dart';
import '../videoprovider.dart' show VideoProviderException;


// Based upon https://developers.google.com/youtube/js_api_reference


/**
 * The YouTube video player with all of its native chrome.  This uses the
 * Flash player to show the video.
 */
class YouTubeVideoPlayer implements VideoPlayer {
    YouTubeEmbedder _embedder;

    @override
    bool get hasVideo => videoId != null && errorCode == 0;

    @override
    Duration get playbackTime {
        num seconds = _embedder.swf.invoke('getCurrentTime');
        return _secondsToDuration(seconds);
    }

    VideoPlayerStatus get lastKnownStatus => _embedder.stateChangeStatus;

    @override
    VideoPlayerStatus get status {
        if (_embedder == null) {
            return VideoPlayerStatus.NOT_INITIALIZED;
        }
        int state = _embedder.swf.invoke('getPlayerState');
        return YouTubeEmbedder.convertState(state);
    }

    @override
    double get percentVideoLoaded {
        num fraction = _embedder.swf.invoke('getVideoLoadedFraction');
        return fraction * 100.0;
    }


    @override
    Duration get videoDuration {
        num seconds = _embedder.swf.invoke('getDuration');
        return _secondsToDuration(seconds);
    }

    @override
    String get errorText => _embedder.errorText;

    @override
    int get errorCode => _embedder.errorCode;

    @override
    Stream<VideoPlayerEvent> get statusChangeEvents =>
            _embedder.events;

    String _videoId;
    @override
    String get videoId => _videoId;

    @override
    void loadVideo(String videoId) {
        _videoId = videoId;
        _embedder.swf.invoke('loadVideoById', [ videoId ]);
    }

    @override
    void play() {
        _embedder.swf.invoke('playVideo');
    }

    @override
    void pause() {
        _embedder.swf.invoke('pauseVideo');
    }

    @override
    void stop() {
        _embedder.swf.invoke('stopVideo');
    }

    @override
    void seekTo(Duration time) {
        _embedder.swf.invoke('seekTo', [
            time.inMilliseconds / 1000.0, true
        ]);
    }

    @override
    void destroy() {
        if (_embedder != null) {
            _embedder.destroy();
            _embedder = null;
            _videoId = null;
        }
    }

    YouTubeVideoPlayer(this._embedder, this._videoId);

    static Duration _secondsToDuration(num seconds) {
        int secs = seconds.floor();
        int milli = ((seconds - secs) * 1000.0).toInt();
        return new Duration(seconds: seconds, milliseconds: milli);
    }
}






/**
 * *WARNING* this function is deperecated and will be removed in the near
 * future.  You're encouraged to instead use the method `embedYouTube`
 * found in the `provider.dart` file.
 *
 * Embeds the YouTube video player into the `wrappingElement`.  This player
 * will have all the native YouTube controls (called the "chrome").
 *
 * The YouTube Flash player requires that the video ID be given at
 * embed time (in [ytVideoId]).
 *
 * If you don't have the `swfobject.js` file in the default
 * location (`js/swfobject.js`), then specify it in the
 * [swfObjectSrcLocation] parameter.
 *
 * If you're using a customized version of `swfobject.js` where the name
 * of the object is different, then set the corret name in
 * [swfObjectName].
 */
Future<VideoPlayer> embedYouTubePlayer(Element wrappingElement,
        String videoId,
        {
            int width: 425,
            int height: 356,
            String swfObjectSrcLocation: DEFAULT_SWFOBJECT_LOCATION,
            String swfObjectName: DEFAULT_SWFOBJECT_NAME
        }) {
    if (wrappingElement == null) {
        throw new Exception("null arg");
    }

    return createSwfObjectFactory(
            swfScriptUri: swfObjectSrcLocation,
            swfObjName: swfObjectName)
    .then((SwfObjectFactory factory) {
        factory.width = width;
        factory.height = height;
        YouTubeEmbedder embedder = new YouTubeEmbedder(wrappingElement,
                videoId, factory);
        return embedder.loaded.future.then((_) {
            embedder.instance = new YouTubeVideoPlayer(embedder, videoId);
            return embedder.instance;
        });
    });
}






// ==========================================================================
// All supporting singletons and functions.  These are private to the
// library.


/**
 * Private inner class that manages the wiring up of the DOM and global JS
 * functions.
 */
class YouTubeEmbedder {
    static final Map<String, YouTubeEmbedder> _YOUTUBE_PLAYERID_OBJECT_MAP = {};
    static YouTubeEmbedder findEmbedderForPlayerId(String playerId) {
        return _YOUTUBE_PLAYERID_OBJECT_MAP[playerId];
    }

    final Completer loaded = new Completer();
    final Element playerWrappingObject;
    final String playerId;
    final String initialVideoId;
    YouTubeVideoPlayer instance;
    VideoPlayerStatus _status;
    VideoPlayerStatus get stateChangeStatus => _status;
    int _errorCode = 0;
    int get errorCode => _errorCode;
    String _errorText = null;
    String get errorText => _errorText;

    Stream<VideoPlayerEvent> events;

    Swf swf;


    YouTubeEmbedder(this.playerWrappingObject,
            this.initialVideoId, SwfObjectFactory factory) :
            playerId = factory.contextPrefix {

        // YouTube has a single on-ready method whose name can't be
        // changed.  We must register it once, and we can't unregister
        // it due to other YT players potentially being active.
        if (! context.hasProperty('onYouTubePlayerReady')) {
            context['onYouTubePlayerReady'] = YouTubePlayerReady;
        }

        factory.params = <String, String>{
            'allowScriptAccess': "always",
            'allowfullscreen': 'true'
        };

        factory.attribs = <String, String>{
            'id': playerId
        };
        var vidUrl = initialVideoId == null ? "" : initialVideoId;
        factory.swfUrl = "http://www.youtube.com/v/${vidUrl}?enablejsapi=1&playerapiid=${playerId}&version=3";
        factory.swfVersion = "8";

        swf = factory.embedSwf(swfObjectId: playerId);
    }


    void onYouTubePlayerReady() {
        swf.addEventListener('onStateChange', (int state) {
            VideoPlayerStatus status = convertState(state);
            if (status != null) {
                // No longer in an error state
                _errorText = null;
                _errorCode = 0;
            }
            return status;
        });

        // onPlaybackQualityChange - ignore
        // onPlaybackRateChange - ignore

        swf.addEventListener('onError', (int errCode) {
            _errorCode = errCode;
            _errorText = _convertError(errCode);

            // DEBUG
            //print("YT error ${errCode} (${error})");

            if (_errorText != null) {
                return new VideoPlayerEvent(instance,
                        new DateTime.now(), VideoPlayerStatus.ERROR,
                        _errorText, errCode);
            } else {
                return null;
            }
        });

        events = swf.events
            .where((SwfEvent e) => e.eventValue != null)
            .map((SwfEvent e) {
                var val = e.eventValue;
                if (val is VideoPlayerEvent) {
                    _status = val.status;
                    return val;
                } else {
                    _status = e.eventValue;
                    return new VideoPlayerEvent(instance, e.when, _status);
                }
            });

        loaded.complete();
    }


    void destroy() {
        if (swf != null) {
            swf.destroy();
            swf = null;
            instance = null;
        }
    }


    static VideoPlayerStatus convertState(int state) {
        switch (state) {
            case -1:
                return VideoPlayerStatus.NOT_STARTED;
            case 0:
                return VideoPlayerStatus.ENDED;
            case 1:
                return VideoPlayerStatus.PLAYING;
            case 2:
                return VideoPlayerStatus.PAUSED;
            case 3:
                return VideoPlayerStatus.BUFFERING;
            case 5:
                return null;
            default:
                print("Unknown YouTube state change ID: [${state}]");
                return null;
        }
    }


    String _convertError(int errCode) {
        switch (errCode) {
            case 0:
                return null;
            case 2:
                return "The video ID is not valid.";
            case 100:
                return "The video requested was not found. This error occurs when a video has been removed (for any reason) or has been marked as private.";
            case 101:
            case 150:
                return "The owner of the requested video does not allow it to be played in embedded players.";
            default:
                return "Unknown YouTube error ${errCode}";
        }
    }

}


// Called by the SWFObject when any player finishes loading.
void YouTubePlayerReady(String playerId) {
    // DEBUG
    //print("Called the onYouTubeReady function");
    YouTubeEmbedder emb = YouTubeEmbedder.findEmbedderForPlayerId(playerId);
    if (emb == null) {
        print("No such player id ${playerId}");
        throw new VideoProviderException("No such player id: ${playerId}");
    }

    emb.onYouTubePlayerReady();
}


