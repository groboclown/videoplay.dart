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

// Based upon https://developers.google.com/youtube/js_api_reference


/**
 * The YouTube video player with all of its native chrome.  This uses the
 * Flash player to show the video.
 */
class YouTubeVideoPlayer implements VideoPlayer {
    final YouTubeEmbedder _embedder;

    @override
    bool get hasVideo => videoId != null && errorCode == 0;

    @override
    Duration get playbackTime {
        num seconds = _embedder.youTubePlayer.callMethod('getCurrentTime');
        return _secondsToDuration(seconds);
    }

    VideoPlayerStatus get lastKnownStatus => _embedder.stateChangeStatus;

    @override
    VideoPlayerStatus get status {
        if (_embedder == null) {
            return VideoPlayerStatus.NOT_INITIALIZED;
        }
        int state = _embedder.youTubePlayer.callMethod('getPlayerState');
        return YouTubeEmbedder.convertState(state);
    }

    @override
    double get percentVideoLoaded {
        num fraction = _embedder.youTubePlayer.callMethod(
                'getVideoLoadedFraction');
        return fraction * 100.0;
    }


    @override
    Duration get videoDuration {
        num seconds = _embedder.youTubePlayer.callMethod('getDuration');
        return _secondsToDuration(seconds);
    }

    @override
    String get errorText => _embedder.errorText;

    @override
    int get errorCode => _embedder.errorCode;

    final StreamController<VideoPlayerEvent> _statusChangeEvents;
    @override
    Stream<VideoPlayerEvent> get statusChangeEvents =>
            _statusChangeEvents.stream;

    String _videoId;
    @override
    String get videoId => _videoId;

    @override
    void loadVideo(String videoId) {
        _videoId = videoId;
        // DEBUG
        //print("loading the video ${videoId}");
        _embedder.youTubePlayer.callMethod('loadVideoById', [ videoId ]);
    }

    @override
    void play() {
        _embedder.youTubePlayer.callMethod('playVideo');
    }

    @override
    void pause() {
        _embedder.youTubePlayer.callMethod('pauseVideo');
    }

    @override
    void stop() {
        _embedder.youTubePlayer.callMethod('stopVideo');
    }

    @override
    void seekTo(Duration time) {
        _embedder.youTubePlayer.callMethod('seekTo', [
            time.inMilliseconds / 1000.0, true
        ]);
    }

    @override
    void destroy() {
        _statusChangeEvents.sink.close();
        _embedder.destroy();
    }

    YouTubeVideoPlayer(this._embedder, this._videoId,
        this._statusChangeEvents);

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
Future<VideoPlayer> embedYouTubeVideoPlayer(Element wrappingElement,
        String ytVideoId,
        {
            int width: 425,
            int height: 356,
            String swfObjectSrcLocation: DEFAULT_SWFOBJECT_LOCATION,
            String swfObjectName: DEFAULT_SWFOBJECT_NAME
        }) {
    Completer<VideoPlayer> ret = new Completer<VideoPlayer>();

    if (wrappingElement == null) {
        throw new Exception("null arg");
    }

    YouTubeEmbedder embeder = new YouTubeEmbedder(ret, wrappingElement,
            swfObjectSrcLocation, swfObjectName, ytVideoId, width, height);
    return ret.future;
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

    final Completer<VideoPlayer> player;
    final Element youTubePlayerWrappingObject;
    final String playerId;
    final String initialVideoId;
    YouTubeVideoPlayer _instance;
    JsObject _youTubePlayer;
    Element _youTubeElement;
    VideoPlayerStatus _status;
    VideoPlayerStatus get stateChangeStatus => _status;
    int _errorCode = 0;
    int get errorCode => _errorCode;
    String _errorText = null;
    String get errorText => _errorText;


    JsObject get youTubePlayer => _youTubePlayer;

    factory YouTubeEmbedder(Completer<VideoPlayer> player,
            Element youTubePlayerWrappingObject,
            String swfScriptUri, String swfObjName, String initialVideoId,
            int width, int height) {
        String playerId = '__YOUTUBE__' +
                _YOUTUBE_PLAYERID_OBJECT_MAP.length.toString();
        if (! context.hasProperty('onYouTubePlayerReady')) {
            context['onYouTubePlayerReady'] = YouTubePlayerReady;
        }
        YouTubeEmbedder ret = new YouTubeEmbedder._(player,
                youTubePlayerWrappingObject, swfScriptUri, swfObjName,
                initialVideoId, width, height, playerId);
        _YOUTUBE_PLAYERID_OBJECT_MAP[playerId] = ret;
        return ret;
    }

    YouTubeEmbedder._(this.player, this.youTubePlayerWrappingObject,
            String swfScriptUri, String swfObjName, this.initialVideoId,
            int width, int height, this.playerId) {
        if (swfScriptUri == null) {
            swfScriptUri = DEFAULT_SWFOBJECT_LOCATION;
        }
        if (swfObjName == null) {
            swfObjName = DEFAULT_SWFOBJECT_NAME;
        }

        // Create the inner object that the SWFObject will replace.  This
        // gives us control to find the object later via the parent.
        DivElement element = new DivElement();
        youTubePlayerWrappingObject.append(element);
        embedJsScriptObject(swfScriptUri, swfObjName).then((JsObject obj) {
            var params = <String, String>{ 'allowScriptAccess': "always" };
            var atts = <String, String>{ 'id': playerId };
            var vidUrl = initialVideoId == null ? "" : initialVideoId;
            var url = "http://www.youtube.com/v/${vidUrl}?enablejsapi=1&playerapiid=${playerId}&version=3";

            //print("Youtube player url: " + url);

            obj.callMethod('embedSWF', [
                    url, element,
                    width.toString(), height.toString(), "8",
                    null, null,
                    new  JsObject.jsify(params),
                    new JsObject.jsify(atts)
                ]);

        }).catchError((var e) {
            player.completeError(e);
        });
    }


    void onYouTubePlayerReady() {
        // DEBUG
        //print("player ${playerId} ready");

        // Find the embedded object.  Because we may be in a shadow DOM,
        // we need to just ask the parent wrapping object.
        for (Element el in youTubePlayerWrappingObject.children) {
            if (el.attributes.containsKey('id') &&
                    el.getAttribute('id') == playerId) {
                // DEBUG
                //print("- found its html object");

                _youTubeElement = el;
                _youTubePlayer = new JsObject.fromBrowserObject(el);

                StreamController<VideoPlayerEvent> events =
                        new StreamController<VideoPlayerEvent>.broadcast();
                context["${playerId}_onStateChange"] = (int state) {
                    // DEBUG
                    //print("YT state changed to ${state}");
                    VideoPlayerStatus status = convertState(state);
                    if (status != null) {
                        // No longer in an error state
                        _errorText = null;
                        _errorCode = 0;
                        events.add(new VideoPlayerEvent(_instance,
                                new DateTime.now(), status));
                    }
                };
                _youTubePlayer.callMethod('addEventListener',
                        [ "onStateChange",  "${playerId}_onStateChange"]);

                // onPlaybackQualityChange - ignore
                // onPlaybackRateChange - ignore

                context["${playerId}_onError"] = (int errCode) {
                    _errorCode = errCode;
                    _errorText = _convertError(errCode);

                    // DEBUG
                    //print("YT error ${errCode} (${error})");

                    if (_errorText != null) {
                        events.add(new VideoPlayerEvent(_instance,
                                new DateTime.now(), VideoPlayerStatus.ERROR,
                                _errorText, errCode));
                    }
                };
                _youTubePlayer.callMethod('addEventListener',
                        [ "onError",  "${playerId}_onError"]);

                // onApiChange - ignore


                _instance = new YouTubeVideoPlayer(this, initialVideoId,
                        events);
                player.complete(_instance);

                return;
            }
        }

        print("ERROR: Could not find the YouTube swf object");
    }


    void destroy() {
        if (_youTubePlayer != null) {
            context.deleteProperty("${playerId}_onStateChange");
            context.deleteProperty("${playerId}_onError");
            youTubePlayerWrappingObject.children.remove(_youTubeElement);

            _youTubeElement = null;
            _youTubePlayer = null;
            _instance = null;
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
        throw new Exception("No such player id: ${playerId}");
    }

    emb.onYouTubePlayerReady();
}


