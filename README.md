# videoplay.dart

A video player library for Dart.  Allows for easy embedding of common video
players into your web page.

_Current stable version: 0.1.1_
_Version under development: 0.1.1_



## Supported Video Services

Right now, it supports:

* Flash-based [YouTube videos](https://developers.google.com/youtube/js_api_reference)

Version 0.2.0 plans to support HTML 5 videos.



## Usage

Full documentation can be found under [doc/README.md](doc/README.md).

To add the library to your project, add it as a dependency to your
`pubspec.yaml` file:

    name: VideoWatcher
    version: 1.2.3
    dependencies:
        videoplay: '>=0.1.1 <1.0.0'

then install with `pub install`, followed by importing it into your application:

    import 'package:videoplay/videoplay.dart';

Currently, the only supported video player type is the YouTube embedded flash
player.  When more players are supported, there will be a standardized way to
create these and set various parameters.  For now, though, you only need to
worry about directly referencing the YouTube factory.


### Examples

Check out the [examples](example/README.md) for the library in practice.


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


### Common API

_NOTE: as more video players are added, different capabilities are expected
to become available, and existing ones may not be available on them.  This
list is expected to expand, but not shrink._

With the `VideoPlayer` object that the `embedYouTubeVideoPlayer` function
returns (and other embedders in the future), you have query different aspects
of it:

* `hasVideo` - does the player have a video that it can play?
* `playbackTime` - the current time position in the video playback.
* `videoDuration` - the video length.
* `status` - returns an object that gives some indication about the current
   state of the video: PLAYING, PAUSED, BUFFERING, ENDED, NOT\_INITIALIZED,
   NOT\_STARTED, and ERROR.
* `percentVideoLoaded` - a value between 0 and 100 to indicate how much of the
   video the player has loaded.  It's not a full picture of the buffer, but
   it gives the program a rough estimate.
* `error` - the current error message.
* `videoId` - the currently loaded video ID.

You also have limited control over the player:

* `loadVideo(String videoId)` - load a new video with the given ID.
* `play()` - play the current video.
* `pause()` - pause the video.
* `stop()` - stop the video.
* `seekTo(Duration time)` - skip to the given position in the video.
* `destroy()` - remove the player from the DOM and properly clean itself up.
    After this is called, the player can no longer be used.

You can also listen to state change events by subscribing to
`statusChangeEvents`.



## The Future

Future versions are expected to support multiple video player types.

As the number of supported players grows, an auto-detect method may be added.

Many of the text strings in the library are in English.  These will need to be
localized, or at least a localization pattern will be added.



## Authors

The authors, in order of commits:

 * Groboclown
