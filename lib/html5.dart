// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

/**
 * Provides support for HTML 5 video.
 */
library videoplay.html5;

import 'dart:async';
import 'dart:html';

import 'src/players/html5.dart';

import 'src/videoprovider.dart';
import 'src/videoplayer.dart';


class Html5Attributes extends VideoProviderAttributes {
    /**
     * The mime types that the website supports for the output media.
     * Use this instead of the [supportedExtensions] if your site includes
     * non-standard file extensions, or different video mime types than
     * the standard.
     */
    Map<String, String> supportedMimeTypes;

    /**
     * Video file extensions that the site supports.  Due to issues with HTML 5
     * video codec support, most sites will need to host multiple encodings of
     * the same videos, and give all of them to the browser so that the
     * supported types can be used.  Add the file extensions to this field
     * if the site only hosts a subset of the standard video file types.
     */
    List<String> supportedExtensions;

    /**
     * If the "videoId" loaded does not include a file extension, then add
     * the file once for each supported extension.  That is, if the site
     * hosts both mp4 and ogg/theora files, and the videoId is "birthday",
     * then both "birthday.mp4" and "birthday.ogg" will be added to the
     * source list.
     *
     * It is highly suggested that if this is set to `true` that you also
     * set either [supportedMimeTypes] or [supportedExtensions].
     */
    bool addExtensions = false;
}


class Html5Provider implements VideoPlayerProvider {

    @override
    VideoProviderAttributes createAttributes() {
        return new Html5Attributes();
    }

    @override
    String get name => "html5";

    @override
    String toString() => "Web Video";
}


bool isHtml5Supported() {
    // FIXME in the future, this should correctly identify if the browser
    // allows for showing HTML 5 videos.
    return true;
}


// a EmbedVideoPlayer
Future<VideoPlayer> embedHtml5(Element wrappingElement,
        String videoId, Html5Attributes attributes) {
    if (! isHtml5Supported()) {
        throw new VideoProviderException(
            "HTML 5 videos are not supported on this browser");
    }

    if (attributes == null) {
        attributes = new Html5Attributes();
    }

    if (! (attributes is Html5Attributes)) {
        throw new VideoProviderException(
            "Invalid attribute type: ${attributes}");
    }

    var player = new Html5VideoPlayer(wrappingElement, videoId,
            supportedExtensions: attributes.supportedExtensions,
            mimeTypes: attributes.supportedMimeTypes,
            width: attributes.width,
            height: attributes.height);
    return new Future<VideoPlayer>.value(player);
}
