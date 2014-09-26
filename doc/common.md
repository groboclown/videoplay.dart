# The Common API for `videoplay.dart`

The `videoplay.dart` library provides a common Dart API for embedding and
interacting with common video players.  This document describes that common
API, while the other pages describe the nuances for each player type.


## Add the library to your project

Like all Dart libraries, the first step to using it is adding it to your
`pubspec.yaml`:

    name: VideoWatcher
    version: 1.2.3
    dependencies:
        videoplay: '>=0.1.1 <1.0.0'

Followed by updating your dependencies:

    $ pub update

Then you can import the library into your Dart sources:

    import 'package:videoplay/videoplay.dart';


## Embed the video

To add the video into your web page, you need to invoke the video player
specific function.  For the moment, only [YouTube](youtube.md) videos are
supported.

_FUTURE WATCH in version 0.2.0, expect this to change.  You should be able to
use a single entry point to load each video player._

Embedding the video will return a `Future<VideoPlayer>` object.  The `Future`
will complete when the `VideoPlayer` object is created, and the video is
added into the web page.


## Querying the video state

The `VideoPlayer` object provides getters for inspecting the state of the
video and the player.

### `hasVideo`

Returns `true` if the player has a video loaded that can be controlled.  Some
players don't have ways to unload a video, but certain states can make the
video unavailable.  For instance, if an invalid video ID was used, or if
`VideoPlayer.destroy()` was called.


### `playbackTime`

Returns a `Duration` describing where in the current video video is playing.
If there isn't a loaded video, or if the video is in an unknown state, then
this should return a 0 time.


### `videoDuration`

The length of the current video.  If no video is loaded or if the video is in
an unknown state, then this can return `null`.


### `status`

Returns a simple `VideoPlayerState` enum object.  The returned value must
be one of these values:

* `VideoPlayerState.PLAYING` - _FIXME_
* `VideoPlayerState.PAUSED` - _FIXME_
* `VideoPlayerState.BUFFERING` - _FIXME_
* `VideoPlayerState.ENDED` - _FIXME_
* `VideoPlayerState.NOT_INITIALIZED` - _FIXME_
* `VideoPlayerState.NOT_STARTED` - _FIXME_
* `VideoPlayerState.ERROR` - _FIXME_


### `percentVideoLoaded`

_FIXME_

a value between 0 and 100 to indicate how much of the video the player has
loaded.  It's not a full picture of the buffer, but it gives the program
a rough estimate.


### `error`

_FIXME_

the current error message.



### `videoId`

_FIXME_

the currently loaded video ID.  This is the value used when initially embedding
the video, or after calling `loadVideo(String)`.



## Controlling the video playback

_FIXME_


### `loadVideo(String videoId)`

_FIXME_

load a new video with the given ID.


### `play()`

_FIXME_

play the current video.


### `pause()`

_FIXME_

pause the video.


### `stop()`

_FIXME_

stop the video.


### `seekTo(Duration time)`

_FIXME_

skip to the given position in the video.


### `destroy()`

_FIXME_

remove the player from the DOM and properly clean itself up.
After this is called, the player can no longer be used.


## Listening to video state changes

_FIXME_

You can also listen to state change events by subscribing to
`statusChangeEvents`.

