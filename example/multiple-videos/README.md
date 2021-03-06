# Example for adding multiple videos on a single page

This `videoplay.dart` example shows how a single web page can contain multiple
video players, all of which can be controlled separately.

The code uses a class, `EmbeddedVideoDom`, to encapsulate the logic for managing
the DOM elements for a single video player.

This uses the centralized video provider repository to dynamically populate the
list of supported video types, and to embed the correct video player based
on the selected provider.

If you want to try out some HTML 5 videos ("Web Video"), then you can try
the videos provided here:
[http://techslides.com/sample-webm-ogg-and-mp4-video-files-for-html5/](http://techslides.com/sample-webm-ogg-and-mp4-video-files-for-html5/)