// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

/**
 * Provides support for the Vimeo video player.
 */
library videoplay.twitch;

import 'dart:async';
import 'dart:html';

import 'src/players/twitch.dart';

import 'src/videoprovider.dart';
import 'src/videoplayer.dart';


class TwitchAttributes extends VideoProviderAttributes {
    String swfObjectSrcLocation = null;
    String swfObjectName = null;
}


class TwitchProvider implements VideoPlayerProvider {

    @override
    VideoProviderAttributes createAttributes() {
        return new TwitchAttributes();
    }

    @override
    String get name => "twitch";

    @override
    String toString() => "Twitch Video";
}


bool isTwitchSupported() {
    // FIXME in the future, this should correctly identify if the browser
    // allows for showing Twitch videos.
    return true;
}


// a EmbedVideoPlayer
Future<VideoPlayer> embedTwitch(Element wrappingElement,
        String videoId, TwitchAttributes attributes) {
    if (! isTwitchSupported()) {
        throw new VideoProviderException(
            "Twitch videos are not supported on this browser");
    }

    if (attributes == null) {
        attributes = new TwitchAttributes();
    }

    if (! (attributes is TwitchAttributes)) {
        throw new VideoProviderException(
            "Invalid attribute type: ${attributes}");
    }

    return embedTwitchPlayer(wrappingElement, videoId,
            width: attributes.width,
            height: attributes.height,
            swfObjectSrcLocation: attributes.swfObjectSrcLocation,
            swfObjectName: attributes.swfObjectName);
}
