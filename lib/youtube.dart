// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

/**
 * Provides support for adding YouTube videos.
 */
library videoplay.youtube;

import 'dart:async';
import 'dart:html';

import 'src/players/youtube.dart';

import 'src/videoprovider.dart';
import 'src/videoplayer.dart';


class YouTubeAttributes extends VideoProviderAttributes {
    String swfObjectSrcLocation = null;
    String swfObjectName = null;

    YouTubeAttributes() {
        // custom YouTube defaults
        width = 425;
        height = 356;
    }
}


class YouTubeProvider implements VideoPlayerProvider {

    @override
    VideoProviderAttributes createAttributes() {
        return new YouTubeAttributes();
    }

    @override
    String get name => "youtube";

    @override
    String toString() => "YouTube";
}


bool isYouTubeSupported() {
    // FIXME in the future, this should correctly identify if the browser
    // allows for showing YouTube videos.
    return true;
}


// a EmbedVideoPlayer
Future<VideoPlayer> embedYouTube(Element wrappingElement,
        String videoId, YouTubeAttributes attributes) {
    if (! isYouTubeSupported()) {
        throw new VideoProviderException(
            "YouTube videos are not supported on this browser");
    }

    if (attributes == null) {
        attributes = new YouTubeAttributes();
    }

    if (! (attributes is YouTubeAttributes)) {
        throw new VideoProviderException(
            "Invalid attribute type: ${attributes}");
    }

    return embedYouTubeVideoPlayer(wrappingElement,
            videoId, width: attributes.width, height: attributes.height,
            swfObjectSrcLocation: attributes.swfObjectSrcLocation,
            swfObjectName: attributes.swfObjectName);
}

