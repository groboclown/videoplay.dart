# videoplay.dart

A video player library for Dart.  Allows for easy embedding of common video
players into your web page.

_Current version: 0.1.0_

## Supported Video Services

Right now, it supports:
 * Flash-based [YouTube videos](https://developers.google.com/youtube/js_api_reference)


## Usage

To add the library to your project, add it as a dependency to your
`pubspec.yaml` file:

    name: VideoWatcher
    version: 1.2.3
    dependencies:
        videoplay: '>=0.1.0 <1.0.0'

then install with `pub install`, followed by importing it into your application:

    import 'package:videoplay/videoplay.dart';

Currently, you need to know which supported video player you want to
embed, as each player uses its own embed function to add itself to the web page.


### YouTube

The YouTube player requires having a `<div>` in your webpage that will house
the player:

    (index.html)
    <!DOCTYPE html>
    <html>
    <body>
      <p>Here's my video:</p>
      <div id="video_container"></div>
      
      <script type="application/dart" src="main.dart"></script>
      <script type="text/javascript" src="packages/browser/dart.js"></script>
    </body>

From here, it's easy to embed the player.  You need to know how to find the
`<div>` container, and pass that to the `embedYouTubeVideoPlayer` function:

    (main.dart)
    library VideoWatcher;
    
    import 'dart:html';
    import 'package:videoplay/videoplay.dart';
    
    void main() {
        var div = document.querySelector("#video_container");
        embedYouTubeVideoPlayer(div, "tlcWiP7OLFI",
            // Make it as big as the video allows
            width: 640, height: 480);
    }

The `embedYouTubeVideoPlayer` function returns a `Future<VideoPlayer>`, so
you can begin interacting with the player in your code once it's become
embedded.

This particular video player requires adding the custom `swfobject.js` file
into your web site that's supplied with `videoplayer.dart`.  The embed
function expects it to be located at `packages/videoplay/js/swfobject.js`,
but if you need it to be in another location, you can specify it with the
additional named argument `swfObjectSrcLocation`.


## The Future

Future versions are expected to support multiple video player types.

As the number of supported players grows, an auto-detect method may be added.



## Authors

The authors, in order of commits:

 * Groboclown
