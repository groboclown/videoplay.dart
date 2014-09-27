# Extending the `videoplay.dart` library

You can add your own custom video provider to the library by following a few
simple steps.


## Implement `VideoPlayer`

The big API that people will want to use for your new video provider is the
`VideoPlayer` class.  This is the heart of interacting with the underlying
web component that gives the videoplay library its heart.

_TODO complete this documentation.  If you're really interested, I recommend
looking at the existing providers in the library, which are located in the
`lib/src/players/` folder._


## Create the embed function

The next big hurdle is getting the video player dynamically inserted into the
web page DOM.  This will usually involve letting some other code (like a
browser plugin) run outside your Dart code, so you need to return a
`Future` with the final instantiated object.



# Adding a new provider into the real library

If your new video provider is working well, you can contribute it back to the
`videoplay.dart` library.

You'll need to start off by forking the project from
[github](https://github.com/groboclown/videoplay.dart), integrate your changes
into the library, then make a push request to the parent project.  Github
has lots of documentation to help you out here.

In order to integrate the new provider into the library, you'll need to follow
the following guidelines.


## Video interaction code

Let's say your provider is named WackySights.  You'll put the provider code
in the directory `lib/src/players`.  If you have multiple files, you'll want
to put them into their own subdirectory under there, named
`lib/src/players/wackysights/`, otherwise just use the provider name
`lib/src/players/wackysights.dart`.


## Library code

The users of the library will want to directly work with this new video
provider, and they do that by importing the `lib/wackysights.dart` file.  This
should just contain the bare minimum files that allow the user to embed the
video player, and for the provider depot to register the player.

This `lib/wackysights.dart` file needs to contain:

* An extension to `VideoProviderAttributes` with the name
 `WackySightsAttributes`.  This should provide smart defaults for all the
  attributes.  It must have a no-arg public default constructor so that
  the user can skip the Provider class.
* An extension to `VideoPlayerProvider` named `WackySightsProvider`.
* A function that determines if the provider is supported by the browser, named
  `isWackySightsSupported`.  It must take 0 arguments and return a `bool`.
* A `EmbedVideoPlayer` typed function named `embedWackySights` that
  follows the conventions of the `EmbedVideoPlayer` typedef.  Note that it's
  fine (and encouraged) to change the type of the `VideoProviderAttributes`
  argument to be specific subclass for the provider.


## Registering the provider

Now that the provider code is in the right place, the provider needs to be
registered, so that the depot library users
will automatically be able to enjoy viewing videos from the new player.

Import your library at the top:

    import '../wackysights.dart';

then add the registration to the `initializeProviders` function:

    void initializeProviders() {
        if (SUPPORTED_VIDEO_PLAYERS == null) {
            SUPPORTED_VIDEO_PLAYERS = {};

            // WackySights provider
            if (isWackySightsSupported()) {
                registerVideoProvider(
                    new WackySightsProvider(),
                    embedWackySights);
            }
            
            // ...
            // ... all the other providers
            // ...
        }
    }


