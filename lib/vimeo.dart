// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

/**
 * Provides support for the Vimeo video player.
 */
library videoplay.vimeo;

import 'dart:async';
import 'dart:html';

import 'src/players/vimeo.dart';

import 'src/videoprovider.dart';
import 'src/videoplayer.dart';


class VimeoAttributes extends VideoProviderAttributes {
    String swfObjectSrcLocation = null;
    String swfObjectName = null;
}


class VimeoProvider implements VideoPlayerProvider {

    @override
    VideoProviderAttributes createAttributes() {
        return new VimeoAttributes();
    }

    @override
    String get name => "vimeo";

    @override
    String toString() => "Vimeo";
}


bool isVimeoSupported() {
    // FIXME in the future, this should correctly identify if the browser
    // allows for showing HTML 5 videos.
    return true;
}


// a EmbedVideoPlayer
Future<VideoPlayer> embedVimeo(Element wrappingElement,
        String videoId, VimeoAttributes attributes) {
    if (! isVimeoSupported()) {
        throw new VideoProviderException(
            "Vimeo videos are not supported on this browser");
    }

    if (attributes == null) {
        attributes = new VimeoAttributes();
    }

    if (! (attributes is VimeoAttributes)) {
        throw new VideoProviderException(
            "Invalid attribute type: ${attributes}");
    }

    return embedVimeoPlayer(wrappingElement, videoId,
            width: attributes.width,
            height: attributes.height,
            swfObjectSrcLocation: attributes.swfObjectSrcLocation,
            swfObjectName: attributes.swfObjectName);
}
