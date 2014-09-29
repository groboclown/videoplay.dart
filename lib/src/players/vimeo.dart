// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

/**
 * Internal implementation of the Vimeo embedding and management.
 */
library videoplay.src.players.vimeo;

import 'dart:async';
import 'dart:html';
import 'dart:js';

import '../util/swfobject.dart';
import '../videoplayer.dart';

// Based upon http://developer.vimeo.com/player/js-api


/**
 * The Vimeo flash player.
 */
class VimeoVideoPlayer implements VideoPlayer {
    final Element wrappingElement;
    VimeoEmbedder _embedder;

    @override
    bool get hasVideo => _embedder != null;

    @override
    Duration get playbackTime {
        num seconds = _embedder.swf.invoke('getCurrentTime');
        return _secondsToDuration(seconds);
    }

    @override
    VideoPlayerStatus get status {
        if (_embedder == null) {
            return VideoPlayerStatus.NOT_INITIALIZED;
        }
        return _embedder.lastStatus;
    }

    @override
    double get percentVideoLoaded => _embedder.percentLoaded;


    @override
    Duration get videoDuration {
        num seconds = _embedder.swf.invoke('getDuration');
        return _secondsToDuration(seconds);
    }

    @override
    String get errorText => null;

    @override
    int get errorCode => 0;

    @override
    Stream<VideoPlayerEvent> get statusChangeEvents => _embedder.events;

    String _videoId;
    @override
    String get videoId => _videoId;

    @override
    void loadVideo(String videoId) {
        // Vimeo doesn't give us a way to reuse the video player,
        // so we must construct a new one.
        SetupVars vars = _embedder.setupVars;

        destroy();

        _videoId = videoId;

        createSwfObjectFactory(
                swfScriptUri: vars.swfScriptUri,
                swfObjName: vars.swfObjName)
        .then((SwfObjectFactory factory) {
            factory.width = vars.width;
            factory.height = vars.height;
            VimeoEmbedder embedder = new VimeoEmbedder(wrappingElement,
                    videoId, factory, vars);
            embedder.loaded.future.then((VimeoEmbedder e) {
                _embedder = e;
            });
        });
    }

    @override
    void play() {
        _embedder.swf.invoke('play');
    }

    @override
    void pause() {
        _embedder.swf.invoke('pause');
    }

    @override
    void stop() {
        _embedder.swf.invoke('pause');
    }

    @override
    void seekTo(Duration time) {
        _embedder.swf.invoke('seekTo', [
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

    VimeoVideoPlayer(VimeoEmbedder embedder, this._videoId) :
        _embedder = embedder,
        wrappingElement = embedder.playerWrappingObject;

    static Duration _secondsToDuration(num seconds) {
        int secs = seconds.floor();
        int milli = ((seconds - secs) * 1000.0).toInt();
        return new Duration(seconds: seconds, milliseconds: milli);
    }
}




Future<VideoPlayer> embedVimeoPlayer(Element wrappingElement,
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
    SetupVars vars = new SetupVars(width, height, swfObjectSrcLocation,
            swfObjectName);

    return createSwfObjectFactory(
            swfScriptUri: swfObjectSrcLocation,
            swfObjName: swfObjectName)
    .then((SwfObjectFactory factory) {
        factory.width = width;
        factory.height = height;
        VimeoEmbedder embedder = new VimeoEmbedder(wrappingElement,
                videoId, factory, vars);
        return embedder.loaded.future.then((_) {
            embedder.instance = new VimeoVideoPlayer(embedder, videoId);
            return embedder.instance;
        });
    });
}






// ==========================================================================
// All supporting singletons and functions.  These are private to the
// library.


class SetupVars {
    final int width;
    final int height;
    final String swfScriptUri;
    final String swfObjName;

    SetupVars(this.width, this.height, this.swfScriptUri, this.swfObjName);
}


/**
 * Private inner class that manages the wiring up of the DOM and global JS
 * functions.
 */
class VimeoEmbedder {
    static int _videoCount = 0;

    final SetupVars setupVars;
    final Completer loaded = new Completer();
    final Element playerWrappingObject;
    final String initialVideoId;
    VimeoVideoPlayer instance;
    Stream<VideoPlayerEvent> events;
    VideoPlayerStatus lastStatus;

    double percentLoaded = 0.0;

    Swf swf;

    VimeoEmbedder(this.playerWrappingObject,
            this.initialVideoId, SwfObjectFactory factory, this.setupVars) {
        factory.wrapperElement = playerWrappingObject;
        String readyCallback = factory.createGlobalContextName("api_ready");
        factory.addGlobalCallback(readyCallback, (_) {
            _onPlayerReady();
        });
        var vidUrl = initialVideoId == null ? "" :
            ("clip_id=" + initialVideoId + "&");
        factory.swfUrl =
                "http://vimeo.com/moogaloop.swf?${vidUrl}server=vimeo.com";
        factory.flashvars = <String, String>{
            'api': '1',
            'portrait': '0',
            'byline': '0',

            // one doc says 'js_ready', the other says 'api_ready'
            'js_ready': readyCallback,
            'api_ready': readyCallback,

            'player_id': factory.contextPrefix
        };
        factory.params = <String, String>{
            'allowscriptaccess': 'always',
            'allowfullscreen': 'true',
            'movie': vidUrl
        };

        swf = factory.embedSwf(swfObjectId: factory.contextPrefix);
    }


    void _onPlayerReady() {
        // DEBUG
        //print("player ${playerId} ready");

        swf.addEventListener('play', VideoPlayerStatus.PLAYING);
        swf.addEventListener('pause', VideoPlayerStatus.PAUSED);
        swf.addEventListener('finish', VideoPlayerStatus.ENDED);
        swf.addEventListener('loadProgress', (JsObject progress) {
            percentLoaded = double.parse(progress['percent']) * 100.0;
            return null;
        });

        // playProgress - ignore
        // seek - ignore

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
}


