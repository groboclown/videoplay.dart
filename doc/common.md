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

### `bool hasVideo`

Returns `true` if the player has a video loaded that can be controlled.  Some
players don't have ways to unload a video, but certain states can make the
video unavailable.  For instance, if an invalid video ID was used, or if
`VideoPlayer.destroy()` was called.


### `Duration playbackTime`

Returns a `Duration` describing where in the current video video is playing.
If there isn't a loaded video, or if the video is in an unknown state, then
this should return a 0 time.


### `Duration videoDuration`

The length of the current video as a `Duration`.  If no video is loaded or if
the video is in an unknown state, then this can return `null`.


### `VideoPlayerState status`

Returns a simple `VideoPlayerState` enum object.  The returned value must
be one of these values:

* `VideoPlayerState.PLAYING` - the player is playing the video.
* `VideoPlayerState.PAUSED` - the player is paused in the video playback.
* `VideoPlayerState.BUFFERING` - the player has suspended playback in order to
  load more of the video from the server.
* `VideoPlayerState.ENDED` - the player reached the end of the video.
* `VideoPlayerState.NOT_INITIALIZED` - the player hasn't been initialized yet.
* `VideoPlayerState.NOT_STARTED` - the player hasn't started playing the
  video yet.
* `VideoPlayerState.ERROR` - the player encountered some kind of error.  This
  will always have the error message in the `VideoPlayer` `error` field.

The status object itself has simple fields:

* `bool playing` - `true` if the player is playing a video, `false` if not.
* `bool waiting` - `true` if the player is not playing a video.
* `String name` - the (English) name of the state; this is the same value as
    what `toString()` returns.  _FUTURE WATCH: this may be localized in the
    future._

Each change in status should trigger a state change.  See the section on
listening to events below.


### `double percentVideoLoaded`

Gives a rough estimate for the amount of the video which has been loaded into
the buffer by returning a value between 0 and 100, inclusive.

A detailed view of the buffer state would require returning a list of the
buffered blocks.  However, most video players don't offer this level of
granularity.


### `String error`

If the player encountered an error, then the status is set to
`VideoPlayerState.ERROR`, and the `error` contains the error message.

If there is no error, then this value returns `null`.

_FUTURE WATCH this value is currently in English.  This will eventually allow
for a localized message._


### `String videoId`

The currently loaded video ID.  This is the value used when initially embedding
the video, or after calling `loadVideo(String)`.



## Controlling the video playback

The `VideoPlayer` instance also allows controlling the playback of the video.
The operation of these methods may change, depending on the current `state` -
they will either perform as expected (if the state allows it), or do
nothing.

If any of these methods cause a state change, then the state listeners will be
alerted to the change.


### `loadVideo(String videoId)`

Load a new video with the given ID.


### `play()`

Play the current video.


### `pause()`

Pause the video playback.


### `stop()`

Stop the video.  The final playback position of the video after calling this
method is up to the specific video player implementation.


### `seekTo(Duration time)`

Skip to the given position in the video.


### `destroy()`

Remove the player from the DOM and properly clean itself up.  The event
stream will be closed when called.

After this is called, the player can no longer be used.  This method can
safely be called multiple times on the same player.


## Listening to video state changes

Changes to the player state are announced by subscribing to
`statusChangeEvents`.  This sends a `VideoPlayerEvent` object to the stream.

The `VideoPlayerEvent` object contains these fields:

* `VideoPlayer videoPlayer` - the player that had the state change.
* `DateTime when` - the time at which the event occurred.
* `VideoPlayerStatus status` - the status that the player switched to at the
  time of the event.
* `String errorText` - the error text at the time of the event.  If the status
  was not an error, then this is `null`.  _FUTURE WATCH this value will
  eventually allow for localization._
* `int errorCode` - the error code at the time of the event.  Its value is
  `0` if there was no error, or a video player dependent code if there was an
  error.  _FUTURE WATCH this value will be standardized, and possibly
  integrated into the message localization._


