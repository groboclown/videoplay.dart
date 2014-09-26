# Extending the `videoplay.dart` library

You can add your own custom video provider to the library by following a few
simple steps.



# Adding a new provider into the real library

If your new video provider is working well, you can contribute it back to the
`videoplay.dart` library.

You'll need to start off by forking the project from
[github](https://github.com/groboclown/videoplay.dart), integrate your changes
into the library, then make a push request to the parent project.  Github
has lots of documentation to help you out here.

In order to integrate the new provider into the library, you'll need to follow
these guidelines:


## Provider code

Let's say your provider is named WackySights.  You'll put the provider code
in the directory `lib/src/wackysights`.  You can break out as many Dart source
files in that directory as needed, but there should be a `provider.dart` file
that provides:

* An extension to `VideoProviderAttributes` with the name
 `WackySightsAttributes`.  This should provide smart defaults for all the
  attributes.
* An extension to `VideoPlayerProvider` named `WackySightsProvider`.
* A function that determines if the provider is supported by the browser, named
  `isWackySightsSupported`.  It must take 0 arguments and return a `bool`.
* A `EmbedVideoPlayer` typed function named `embedWackySights` that
  follows the conventions of the `EmbedVideoPlayer` typedef.  Note that it's
  fine (and encouraged) to change the type of the `VideoProviderAttributes`
  argument to be specific subclass for the provider.


## Registering the provider

Now that the provider code is in the right place, the provider needs to be
registered in the `lib/src/embed.dart` file.