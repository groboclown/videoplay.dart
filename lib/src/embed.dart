// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

library videoplay.src.embed;

import 'dart:async';
import 'dart:html';
import 'videoplayer.dart';
import 'videoprovider.dart';

// For initializing with known video providers
import 'youtube/provider.dart';


/**
 * Local registry of the supported video players.  Access to this should
 * be restricted to this library.  Instead, use the [registerVideoProvider()]
 * and [getSupportedVideoProviders()] and [getVideoProviderByName()]functions.
 */
Map<VideoPlayerProvider, EmbedVideoPlayer> SUPPORTED_VIDEO_PLAYERS = null;


/**
 * Embed a video [videoId], loaded by the [provider], inside the HTML
 * [wrappingElement].  This wrapping element should be empty when calling
 * this function, so that the provider can manage its contents.
 *
 * The [attributes] must be correctly associated with the [provider], as passing
 * a [VideoProviderAttributes] class not associated with the [provider] will
 * result in an [VideoProviderException] exception.
 */
Future<VideoPlayer> embedVideo(VideoPlayerProvider provider,
        Element wrappingElement, String videoId,
        VideoProviderAttributes attributes) {
    initializeProviders();

    if (SUPPORTED_VIDEO_PLAYERS.containsKey(provider)) {
        if (attributes == null) {
            attributes = provider.createAttributes();
        }

        return SUPPORTED_VIDEO_PLAYERS[provider](wrappingElement,
                videoId, attributes);
    } else {
        throw new VideoProviderException("unsupported provider " +
                provider.name);
    }
}


/**
 * Return a collection of the registered [VideoPlayerProvider].
 */
Iterable<VideoPlayerProvider> getSupportedVideoProviders() {
    initializeProviders();

    return SUPPORTED_VIDEO_PLAYERS.keys;
}


/**
 * Find the [VideoPlayerProvider] with the given name.  If no such provider
 * is registered, this will return `null`.
 */
VideoPlayerProvider getVideoProviderByName(String name) {
    initializeProviders();

    for (VideoPlayerProvider provider in getSupportedVideoProviders()) {
        if (provider.name == name) {
            return provider;
        }
    }
    return null;
}


/**
 * Register a [VideoPlayerProvider] with this central registry service.
 */
void registerVideoProvider(VideoPlayerProvider provider,
        EmbedVideoPlayer embedder) {
    initializeProviders();

    SUPPORTED_VIDEO_PLAYERS[provider] = embedder;
}


/**
 * Internal initialization of the built-in video providers.
 */
void initializeProviders() {
    if (SUPPORTED_VIDEO_PLAYERS == null) {
        SUPPORTED_VIDEO_PLAYERS = {};

        // YouTube provider
        if (isYouTubeSupported()) {
            registerVideoProvider(
                new YouTubeProvider(),
                youTubeProviderEmbedder);
        }
    }
}

