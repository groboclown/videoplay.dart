# Using Twitch Embedded Video With `videoplay.dart`


Twitch video IDs are the video URLs.  However, the actual video ID is a bit
different, So, if the url is "/smitegame/c/5183949", then the actual video
ID is `c5183949`.  The Twitch provider automatically converts the ID.

The embedder only supports videos right now, not streams.

## Limitations with the implementation

The status updates from Twitch are pretty limited.  The event stream isn't good.
Future versions may need to have a timer to check the state and send event
stream updates.
