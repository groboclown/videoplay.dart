# Using YouTube Embedded Video With `videoplay.dart`


The YouTube player requires having a `<div>` in your webpage that will house
the player:

    (index.html)
    <!DOCTYPE html>
    <html>
    <body>
      <p>Here's my video:</p>
      <div id="video-container"></div>
      
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
        var div = document.querySelector("#video-container");
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
