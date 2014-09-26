
library videoplay_example;


import 'dart:html';
import 'dart:async';

import 'package:videoplay/videoplay.dart';

VideoPlayer videoPlayer;
DivElement errorDiv;
InputElement videoId;

void main() {
    videoId = querySelector("#video_id_field");
    errorDiv = querySelector("#video_error");

    var videoDiv = querySelector("#youtube_video_container");
    embedYouTubeVideoPlayer(videoDiv, "tlcWiP7OLFI",
        // Make it as big as the video allows
        width: 640, height: 480)

        // Once the player object is instantiated, perform some actions.
        .then((VideoPlayer player) {
            videoPlayer = player;
            print("Player loaded");

            // Add an event listener
            player.statusChangeEvents.listen(onVideoStatusChange);
        });

    videoId.onChange.listen(changeVideo);
}


void changeVideo(Event e) {
    if (videoPlayer == null) {
        errorDiv.text = "video player not loaded yet";
    } else {
        var vid = videoId.value;
        print("Change request to ${vid}");
        videoPlayer.loadVideo(vid);
    }
}


void onVideoStatusChange(VideoPlayerEvent e) {
    errorDiv.children.clear();
    var p = new ParagraphElement();
    p.text = e.status.toString() +
            (e.errorText == null ? ": " : e.errorText);
    errorDiv.children.add(p);
    print("Video status change! " + e.status.toString());
}
