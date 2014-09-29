# videoplay.dart

A video player library for Dart.  Allows for easy embedding of common video
players into your web page.

If you're looking to embed videos, and not interact with them, then the
[videopoly.dart](https://pub.dartlang.org/packages/videopoly) could be what
you want - it provides custom Dart Polymer elements on top of this library to
make embedding the supported video player providers easy.

_Current stable version: 0.2.1_

_Version under development: 0.2.2_


## Supported Video Services

Right now, it supports:

* Flash-based
  [YouTube videos](https://developers.google.com/youtube/js_api_reference)
* HTML 5 video
* Flash-based [Vimeo videos](http://developer.vimeo.com/player/js-api)
* Flash-based
  [Twitch videos](https://github.com/justintv/Twitch-API/blob/master/player.md)



## Usage

Full documentation can be found under [doc/README.md](doc/README.md).

To add the library to your project, add it as a dependency to your
`pubspec.yaml` file:

    name: MyVideoWatcherSite
    version: 1.2.3
    dependencies:
        videoplay: '>=0.2.0 <1.0.0'

then use `pub` to install the library.

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

You can see a site using just the YouTube video provider in the
[video-select](example/video-select) example.


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

You can see a site using all the video providers in the
[multiple-videos](example/multiple-videos) example.



## Examples

Check out the [examples](example/README.md) for the library in practice.



## The Future

Future versions are expected to support more video player types.  Looking into:

* Flow Player - looks to be
  [well documented](http://flash.flowplayer.org/documentation/api/)
* Blip.tv - public API is deprecated.
* Screenwave Media - very little documentation.

Many of the text strings in the library are in English.  These will need to be
localized, or at least a localization pattern will be added.

Limited volume control and querying will be added in future versions.


## Authors

The authors, in order of commits:

* Groboclown
