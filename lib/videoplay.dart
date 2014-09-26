// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.


/**
 *
 *
 */
library videoplay;


export 'src/videoplayer.dart' show
    VideoPlayer, VideoPlayerEvent, VideoPlayerStatus;

export 'src/youtube/youtube.dart' show
    embedYouTubeVideoPlayer;

export 'src/videoprovider.dart' show
    VideoProviderException, VideoProviderAttributes,
    VideoPlayerProvider;

export 'src/embed.dart' show
    embedVideo, getSupportedVideoProviders,
    getVideoProviderByName;

