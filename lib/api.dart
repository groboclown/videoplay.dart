// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.


/**
 * Library for loading the public videoplay API.  This does not have any
 * video providers, or have the provider depot.
 *
 * Use this library if you want to directly reference a specific video provider.
 */
library videoplay;


export 'src/videoplayer.dart' show
    VideoPlayer, VideoPlayerEvent, VideoPlayerStatus;

export 'src/videoprovider.dart' show
    VideoProviderException, VideoProviderAttributes,
    VideoPlayerProvider;
