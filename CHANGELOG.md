# Change History for videoplay.dart

## 0.2.0

*Overview* Added HTML 5 video support and a common entry point for embedding
a video.  There was a major backwards compatibility change over the 0.1 line
where the way YouTube videos are embedded has changed, though the changes needed
to use the new architecture are fairly limited.

*Details:*

* The user has two ways to use the library, either directly referencing the
  video providers, or using the provider repository.  The YouTube provider
  isn't imported by default anymore.
* `embedYouTubeVideoPlayer` is no more.  Users of the library must switch to
  either the provider depot, or the direct loading.  The front page
  [README.md](README.md) explains how to do this.
* Added centralized embedding.
    * Added the `videoprovider.dart` file to contain classes and typedefs
      required to support a single embedding source.
        * `VideoPlayerProvider` - providers have a singleton instance of this
          class that describes the provider.  This allows for users of the
          library to make a query to see what video providers are supported on
          the browser.
        * `VideoProviderAttributes` - created by the provider to allow custom
          extensions to the options the user can set.
        * `VideoProviderException` - parent for the exceptions thrown by
          providers.
        * The typedef `EmbedVideoPlayer` has new arguments, and moved into the
          `videoprovider.dart` file.  This isn't backwards incompatible, because
          this was only library visible.
    * Added `embed.dart` to be the central repository for video providers.
        * `embedVideo` - embed a video into the page.
        * `getSupportedVideoProviders` - find the providers that are registered.
        * `getVideoProviderByName` - find providers by their String name.
        * `registerVideoProvider` - (internal) add a provider to the registry.
    * Changed the multiple-videos example to use the new centralized embedding
      infrastructure.
    * Fixed up the documentation to reflect the new usage.


## 0.1.1

*Overview* Updates to the documentation and examples, along with a few bug
fixes.

*Details:*

* Bug fixes:
    * YouTube player does not shut down its event log on `destroy()`.
    * YouTube player does not set `error` field on error state.
    * Actually minified the swfobject.js file.
* *Backwards incompatible change* Changed the `error` field on the
  `VideoPlayer` to now be 2 fields,  `errorText` and `errorCode`, to match the
  `VideoPlayerEvent` class, and to start to allow some limited localization
  capabilities.
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

*Overview* Initial public release.  This was originally in the
[WebRiffs](https://github.com/groboclown/webriffs) project, but it was moved
over here to be a proper stand-alone library.  Supports only YouTube videos.
