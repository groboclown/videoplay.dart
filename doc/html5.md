# Using HTML 5 Video With `videoplay.dart`

With HTML 5, browsers can natively support the playback of video files.  The
html5 video provider gives the `videoplay.dart` library support to show and
control those videos.

_TODO need a deeper description._


## Notes on sources and encodings

The `videoplay.dart` library allows setting only a single source video ID.
However, due to the fragmented nature of HTML 5 video support, there isn't
just one video format that all browsers support.  Therefore, most sites will
need to provide multiple encodings of the same video file.

If you're providing the site that has a set of supported encodings (or you
reference a site that has a set of supported encodings), then you'll want to
define these in the `Html5ProviderAttributes`.

However, if you're letting the user point to any video on the web, and it
could be hosted with any number of encodings, but the user gave a URL with
an extension, then you'll want the option that strips off the extension and
tries to add in all the supported variations.

By default, the system assumes that you're letting the user point to any
video file on the Internet, so it will try to add all supported video file
variations.  This seems to work well even in the situations where you have
hosted files with a limited subset of extensions, and you use URIs without
an extension.

_TODO show how to set this up.  For now, you can look at the Dart code
documentation in `lib/html5.dart`._
