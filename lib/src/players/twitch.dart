// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

/**
 * Internal implementation of the Twitch embedding and management.
 */
library videoplay.src.players.twitch;

import 'dart:async';
import 'dart:html';
import 'dart:js';

import '../util/swfobject.dart';
import '../videoplayer.dart';

// Based upon https://github.com/justintv/Twitch-API/blob/master/player.md
// Help from http://discuss.dev.twitch.tv/t/player-md-is-there-something-like-gettime-or-isended-would-be-nice-with-list-of-functions-available-that-can-be-accessed-with-js/875


/**
 * The Twitch flash player.
 */
class TwitchVideoPlayer implements VideoPlayer {
    final Element wrappingElement;
    TwitchEmbedder _embedder;

    @override
    bool get hasVideo => _embedder != null;

    @override
    Duration get playbackTime {
        num seconds = _embedder.swf.invoke('getVideoTime');
        return _secondsToDuration(seconds);
    }

    @override
    VideoPlayerStatus get status {
        if (_embedder == null) {
            return VideoPlayerStatus.NOT_INITIALIZED;
        }
        if (_embedder.swf.invoke('isPaused')) {
            return VideoPlayerStatus.PAUSED;
        }
        return _embedder.lastStatus;
    }

    @override
    double get percentVideoLoaded => _embedder.percentLoaded;


    @override
    Duration get videoDuration {
        // FIXME need to discover how to find out the current video duration
        //num seconds = _embedder.swf.invoke('getDuration');
        //return _secondsToDuration(seconds);
        return new Duration(seconds: -1);
    }

    @override
    String get errorText => _embedder == null ? null : _embedder.errorText;

    @override
    int get errorCode => _embedder == null ? 0 : _embedder.errorCode;

    @override
    Stream<VideoPlayerEvent> get statusChangeEvents => _embedder.events;

    String _videoId;
    @override
    String get videoId => _videoId;

    @override
    void loadVideo(String videoId) {
        videoId = TwitchEmbedder.parseVideoId(videoId);
        _embedder.swf.invoke('loadVideo', [ videoId ]);
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
        _embedder.swf.invoke('pauseVideo');
    }

    @override
    void seekTo(Duration time) {
        // undocumented
        _embedder.swf.invoke('videoSeek', [
            time.inMilliseconds / 1000.0
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

    TwitchVideoPlayer(TwitchEmbedder embedder, this._videoId) :
        _embedder = embedder,
        wrappingElement = embedder.playerWrappingObject;

    static Duration _secondsToDuration(num seconds) {
        int secs = seconds.floor();
        int milli = ((seconds - secs) * 1000.0).toInt();
        return new Duration(seconds: seconds, milliseconds: milli);
    }
}




Future<VideoPlayer> embedTwitchPlayer(Element wrappingElement,
        String videoId,
        {
            int width: 425,
            int height: 356,
            String swfObjectSrcLocation: null,
            String swfObjectName: null
        }) {
    if (wrappingElement == null) {
        throw new Exception("null arg");
    }
    videoId = TwitchEmbedder.parseVideoId(videoId);

    return createSwfObjectFactory(
            swfScriptUri: swfObjectSrcLocation,
            swfObjName: swfObjectName)
    .then((SwfObjectFactory factory) {
        factory.width = width;
        factory.height = height;
        TwitchEmbedder embedder = new TwitchEmbedder(wrappingElement,
                videoId, factory);
        return embedder.loaded.future.then((_) {
            embedder.instance = new TwitchVideoPlayer(embedder, videoId);
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
class TwitchEmbedder {
    static int _videoCount = 0;

    final Completer loaded = new Completer();
    final Element playerWrappingObject;
    final String initialVideoId;
    TwitchVideoPlayer instance;
    Stream<VideoPlayerEvent> events;
    VideoPlayerStatus lastStatus;

    String _errText;
    int _errCode;

    String get errorText =>
            lastStatus == VideoPlayerStatus.ERROR ? _errText : null;
    int get errorCode =>
            lastStatus == VideoPlayerStatus.ERROR ? _errCode : 0;

    double percentLoaded = 0.0;

    Swf swf;

    TwitchEmbedder(this.playerWrappingObject,
            this.initialVideoId, SwfObjectFactory factory) {
        factory.wrapperElement = playerWrappingObject;
        String readyCallback = factory.createGlobalContextName("api_ready");
        factory.addGlobalCallback(readyCallback, (_) {
            _onPlayerReady();
        });

        // FIXME this is debugging to better understand the events, because
        // they are not well documented.
        String eventsCallback = factory.createGlobalContextName("all_events");
        factory.addGlobalCallback(eventsCallback, (List<JsObject> data) {
            for (JsObject event in data) {
                print("twitch event [" + event['event'] + "]");
            }
        });


        factory.swfUrl =
                "http://www-cdn.jtvnw.net/swflibs/TwitchPlayer.swf";
        factory.swfVersion = "11";
        factory.flashvars = <String, String>{
            'initCallback': readyCallback,
            'embed': '1',
            'auto_play': 'false',
            'videoId': initialVideoId,
            // debugging

            'eventsCallback': eventsCallback

            // There's a bunch of other variables that can be passed:
            // chapter_id
            // channel
            // team
            // hostname (www.twitch.tv)
            // eventsCallback
        };
        factory.params = <String, String>{
            'allowscriptaccess': 'always',

            //'allowNetworking': 'all',
            //'wmode': 'transparent',

            'allowfullscreen': 'true',
            'movie': factory.swfUrl
        };

        swf = factory.embedSwf(swfObjectId: factory.contextPrefix);
    }


    void _onPlayerReady() {
        // DEBUG
        //print("player ${playerId} ready");

        swf.addEventListener('offline', VideoPlayerStatus.ENDED);
        swf.addEventListener('online', VideoPlayerStatus.NOT_STARTED);
        swf.addEventListener('videoLoading', VideoPlayerStatus.BUFFERING);
        swf.addEventListener('videoLoaded', VideoPlayerStatus.NOT_STARTED);
        swf.addEventListener('videoPlaying', VideoPlayerStatus.PLAYING);
        swf.addEventListener('tosViolation', (_) {
            _errText = "terms of service violation";
            _errCode = 10;
            return VideoPlayerStatus.ERROR;
        });
        swf.addEventListener('seekFailed', (_) {
            _errText = "seek failed";
            _errCode = 11;
            return VideoPlayerStatus.ERROR;
        });

        // adCompanionRendered
        // loginRequest
        // mouseScroll
        // playerInit - handled in flashvars
        // popout
        // viewerCount
        // adFeedbackShow
        // adUnfilledStart
        // adUnfilledEnd

        events = swf.events
            .where((SwfEvent e) => e.eventValue != null)
            .map((SwfEvent e) {
                lastStatus = e.eventValue;
                return new VideoPlayerEvent(instance, e.when, e.eventValue);
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


    /**
     * Twitch video IDs are supposed to be [letter][number],
     * but the user could pass in the full video path.
     */
    static String parseVideoId(String id) {
        if (id.indexOf('/') >= 0) {
            List<String> parts = id.split('/');
            return parts[parts.length - 2] + parts[parts.length - 1];
        }
        return id;
    }
}

