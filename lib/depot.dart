// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

/**
 * The videoplay library that allows for the client to dynamically choose the
 * video provider to show.
 *
 * Import this library by itself if you have a need to dynamically detect
 * the player providers.  If you know in advance which provider you want to
 * use, then it's more efficient to directly use that provider.
 */
library videoplay.embed;

export 'src/videoplayer.dart' show
    VideoPlayer, VideoPlayerEvent, VideoPlayerStatus;

export 'src/videoprovider.dart' show
    VideoProviderException, VideoProviderAttributes,
    VideoPlayerProvider;

export 'src/embed.dart' show
    embedVideo,
    getSupportedVideoProviders,
    getVideoProviderByName,
    registerVideoProvider;

