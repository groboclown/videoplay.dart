# Example for adding multiple videos on a single page

This `videoplay.dart` example shows how a single web page can contain multiple
video players, all of which can be controlled separately.

The code uses a class, `EmbeddedVideoDom`, to encapsulate the logic for managing
the DOM elements for a single video player.



## Future Notes

In the future (v0.2.0), we expect the `videoplay.dart` library to support
the indirection presented in this example around the discovery and creation
of the `VideoPlayer` object.

When this happens, the `Embedder` typedef and the `getEmbedder` discovery
function should be removed in favor of the new discovery mechanism.