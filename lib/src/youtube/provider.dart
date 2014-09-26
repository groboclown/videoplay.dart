// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

library videoplay.src.youtube.provider;

import 'dart:async';
import 'dart:html';

import 'youtube.dart';

import '../videoprovider.dart';
import '../videoplayer.dart';



class YouTubeAttributes extends VideoProviderAttributes {
    String swfObjectSrcLocation = DEFAULT_SWFOBJECT_LOCATION;
    String swfObjectName = DEFAULT_SWFOBJECT_NAME;

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
Future<VideoPlayer> youTubeProviderEmbedder(Element wrappingElement,
        String videoId, VideoProviderAttributes attributes) {
    if (! (attributes is YouTubeAttributes)) {
        throw new VideoProviderException(
                "Invalid attribute type: ${attributes}");
    }
    YouTubeAttributes yta = attributes;

    return embedYouTubeVideoPlayer(wrappingElement,
            videoId, width: yta.width, height: yta.height,
            swfObjectSrcLocation: yta.swfObjectSrcLocation,
            swfObjectName: yta.swfObjectName);
}

