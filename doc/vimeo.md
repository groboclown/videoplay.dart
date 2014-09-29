# Using Vimeo Embedded Video With `videoplay.dart`

The video id is the long number associated with the Vimeo videos.

_TODO add notes as they are discovered._


## Notes on the implementation

This uses the Flash player, rather than the iframe version, because it
doesn't suffer the same drawbacks.  The iframe version uses a message posting
technique, which means that query requests would need to be in the
form of `Future` return values, which simply aren't practical.  The flash
version avoids that.
