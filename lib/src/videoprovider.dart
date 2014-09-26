// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

library videoplay.src.videoprovider;

import 'dart:html';
import 'dart:async';

import 'videoplayer.dart';

class VideoProviderException implements Exception {
    final String message;
    VideoProviderException(this.message);

    @override
    String toString() {
        return message;
    }
}


/**
 * Base class for setting the attributes supported by the `VideoPlayerProvider`.
 * All attributes here are considered optional, in that the user doesn't need
 * to set them.  The `VideoPlayerProvider` can subclass this to include
 * additional attributes specific to that provider.
 */
class VideoProviderAttributes {
    int width = 640;
    int height = 480;
}


/**
 * Describes a video player provider.  These are stored in the central
 * embed repository so the user can query for what players are supported by
 * the browser and library version.
 */
abstract class VideoPlayerProvider {
    /**
     * Name of the provider
     */
    String get name;

    /**
     * Create an attribute instance specific to this provider.
     */
    VideoProviderAttributes createAttributes();
}




typedef Future<VideoPlayer> EmbedVideoPlayer(Element wrappingElement,
    String videoId, VideoProviderAttributes attributes);
