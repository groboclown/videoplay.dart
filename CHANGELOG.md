# Change History for videoplay.dart

## 0.1.1

Updates to the documentation and examples, along with a few bug fixes.

* Bug fixes:
    * YouTube player does not shut down its event log on `destroy()`.
    * YouTube player does not set `error` field on error state.
* Changed the `error` field on the `VideoPlayer` to now be 2 fields,
  `errorText` and `errorCode`, to match the `VideoPlayerEvent` class,
  and to start to allow some limited localization capabilities.
* Markdown files created for documentation.
* Cleaned up the front page documentation.
* Split the examples into `video-select` and `multiple-videos`, and made
  the examples easier to read and use.
* Planning on adding HTML 5.  A few parts of the examples and documentation
  have preparation for this, but support won't be added until at least version
  0.2.0.
* Added notes on where the API may change in the future.
* Added this changelog file.


## 0.1.0

Initial public release.  This was originally in the
[WebRiffs](https://github.com/groboclown/webriffs) project, but it was moved
over here to be a proper stand-alone library.

* Supports only YouTube videos.
