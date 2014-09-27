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


## Embed the video


To add the video into your web page, you need to invoke the video player
specific function.

Note that embedding the video will return a `Future<VideoPlayer>` object.
The `Future` will complete when the `VideoPlayer` object is created, and
the video is added into the web page.

There are two ways to use the library in your code.  You can use the dynamic
support for video providers to allow the end user to select the videos, or
you can explicitly reference the video providers you want to use.


### You know the video providers

Your site is limited to a few video providers, and you know where to use
that specific provider.

Your code should import the videoplay API and the provider libraries:

    import 'package:videoplay/api.dart';
    import 'package:videoplay/youtube.dart';

You can then use the video provider explicitly:

    var videoDiv = querySelector("#youtube_video_container");
    YouTubeAttributes attr = new YouTubeAttributes();
    attr.width = 640;
    attr.height = 480;
    embedYouTube(videoDiv, "tlcWiP7OLFI", attr)
        .then((VideoPlayer player) {
            ytVideoPlayer = player;
            player.statusChangeEvents.listen(onVideoStatusChange);
        });

All the standard video providers use the same general technique for loading
the videos.  Please see the individual provider documentation to learn more
about the nuances of loading that specific video player.

You can see a site using just the YouTube video provider in the
[video-select](../example/video-select) example.


### Flexible and extensible video providers

If you want to let the end users select from a list of video providers, then
the provider depot is the way to go.  It allows for detection of which
video providers the user's browser supports, and for the site to expand the
number of video providers as the library adds support for them.

Your code imports the provider depot library:

    import 'package:videoplay/depot.dart';

You can dynamically create a list of the supported providers for the end user:

    var videoType = querySelector("#video-type");
    for (VideoPlayerProvider provider in getSupportedVideoProviders()) {
        var oel = new OptionElement();
        oel.value = provider.name;
        oel.text = provider.toString();
        videoType.children.add(oel);
    }

When the end user selects a video provider, you can easily embed it, regardless
of which provider was chosen.

    String vtype = videoType.options[videoType.selectedIndex].value;
    String videoId = querySelector("#video-id").value;
    VideoPlayerProvider provider = getVideoProviderByName(vtype);
    VideoProviderAttributes attributes = videoType.createAttributes();
    attributes.width = 320;
    attributes.height = 200;
    var wrapper = querySelector("#video-wrapper");
    embedVideo(videoType, wrapper, videoId, attributes)
        .then((VideoPlayer videoPlayer) {
            player = videoPlayer;
            player.statusChangeEvents.listen((VideoPlayerEvent e) {
                if (e.errorText != null) {
                    status.text = "Error: ${e.errorText}";
                }
            });
        });

You can see a site using just the YouTube video provider in the
[multiple-videos](../example/multiple-videos) example.



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


### `String errorText`

If the player encountered an error, then the status is set to
`VideoPlayerState.ERROR`, and the `errorText` contains the error message.

If there is no error, then this value returns `null`.

_FUTURE WATCH this value is currently in English.  This will eventually allow
for a localized message.  For the moment, you can use the `errorCode` value._


### `int errorCode`

Returns 0 if there is no error, otherwise a provider-specific error code
is returned.

_FUTURE WATCH this value will eventually have a standardized meaning._


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


