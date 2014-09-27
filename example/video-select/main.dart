// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

library videoplay_example;


import 'dart:html';

import 'package:videoplay/api.dart';
import 'package:videoplay/youtube.dart';

VideoPlayer videoPlayer;
DivElement errorDiv;
InputElement videoId;

void main() {
    videoId = querySelector("#video_id_field");
    errorDiv = querySelector("#video_error");

    var videoDiv = querySelector("#youtube_video_container");
    YouTubeAttributes attr = new YouTubeAttributes();
    attr.width = 640;
    attr.height = 480;
    embedYouTube(videoDiv, "tlcWiP7OLFI", attr)

        // Finish initialization once the player object is loaded
        .then((VideoPlayer player) {
            videoPlayer = player;
            print("Player loaded");

            // Add an event listener
            player.statusChangeEvents.listen(onVideoStatusChange);
        });

    videoId.onChange.listen(changeVideo);

    querySelector("#play_video").onClick.listen((_) {
        if (videoPlayer != null) {
            videoPlayer.play();
        }
    });
    querySelector("#pause_video").onClick.listen((_) {
        if (videoPlayer != null) {
            videoPlayer.pause();
        }
    });
    querySelector("#stop_video").onClick.listen((_) {
        if (videoPlayer != null) {
            videoPlayer.stop();
        }
    });
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
