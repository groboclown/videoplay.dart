// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

library videoplay.src.videoplayer;

import 'dart:async';
import 'dart:html';

class VideoPlayerStatus {
    static const PLAYING = const VideoPlayerStatus._(true);
    static const PAUSED = const VideoPlayerStatus._(false);
    static const BUFFERING = const VideoPlayerStatus._(false);
    static const ENDED = const VideoPlayerStatus._(false);
    static const NOT_INITIALIZED = const VideoPlayerStatus._(false);
    static const NOT_STARTED = const VideoPlayerStatus._(false);
    static const ERROR = const VideoPlayerStatus._(false);

    static get values => [ PLAYING, PAUSED, BUFFERING, ENDED,
                           NOT_INITIALIZED, NOT_STARTED, ERROR ];

    final bool playing;
    final bool waiting;

    const VideoPlayerStatus._(bool play) :
        playing = play,
        waiting = ! play;
}



class VideoPlayerEvent {
    final VideoPlayer videoPlayer;
    final DateTime when;
    final VideoPlayerStatus status;

    VideoPlayerEvent(this.videoPlayer, this.when, this.status);
}



abstract class VideoPlayer {
    bool get hasVideo;

    /**
     * What time the current video is showing.  It may return `null` if the
     * video hasn't started, or has ended.
     */
    Duration get playbackTime;

    /**
     *
     */
    VideoPlayerStatus get status;

    /**
     * Returns a value between 0 and 100 as a rough percentage of the
     * video that has already been downloaded.
     */
    double get percentVideoLoaded;

    /**
     * How long the video is.
     */
    Duration get videoDuration;

    /**
     * The text of the current error message, or `null` if there is no current
     * error.
     */
    String get error;

    /**
     * Event stream for changes to the video player status.
     */
    Stream<VideoPlayerEvent> get statusChangeEvents;

    String get videoId;

    void loadVideo(String videoId);

    void play();

    void pause();

    void stop();

    void seekTo(Duration time);

    /**
     * Destroy the player in the web page.
     */
    void destroy();
}


typedef Future<VideoPlayer> EmbedVideoPlayer(Element wrappingElement);
