
library videoplay_example;


import 'dart:html';
import 'dart:async';

import 'package:videoplay/videoplay.dart';

InputElement videoId;
SelectElement videoType;
DivElement videoList;

void main() {
    videoId = querySelector("#video_id_field");
    videoType = querySelector("#video_type");
    videoList = querySelector("#video_set_list");

    ButtonElement add = querySelector("#add_video");
    add.onClick.listen((_) {
        String vtype = videoType.options[videoType.selectedIndex].value;
        new EmbeddedVideoDom(vtype, videoId.value, getEmbedder(vtype));
    });
}

typedef Future<VideoPlayer> Embedder(DivElement wrapper, String videoId);

class EmbeddedVideoDom {
    final String videoType;
    final String videoId;
    DivElement wrapper;
    ParagraphElement status;
    VideoPlayer player;

    EmbeddedVideoDom(this.videoType, this.videoId, Embedder embedder) {
        wrapper = new DivElement();
        var p = new ParagraphElement();
        p.text = "${videoId} - ${videoType}";
        wrapper.children.add(p);

        var b = new ButtonElement();
        b.text = "Close";
        b.onClick.listen((Event e) {
            close();
        });
        wrapper.children.add(b);

        status = new ParagraphElement();
        status.text = "(loading)";
        wrapper.children.add(status);

        videoList.children.add(wrapper);

        embedder(wrapper, videoId).then((VideoPlayer videoPlayer) {
            player = videoPlayer;
            status.text = videoPlayer.status.toString();
            print("Player ${videoId}/${videoType} loaded");

            // Add an event listener
            player.statusChangeEvents.listen((VideoPlayerEvent e) {
                if (e.errorText != null) {
                    status.text = "Error: ${e.errorText}";
                } else {
                    status.text = e.status.toString();
                }
            });
        });
    }

    void close() {
        if (player != null) {
            player.destroy();
            player = null;
        }
        if (wrapper != null) {
            wrapper.remove();
            wrapper = null;
            status = null;
        }
    }
}


Embedder getEmbedder(String videoType) {
    switch (videoType) {
        case 'youtube':
            return (DivElement wrapper, String videoId) {
                return embedYouTubeVideoPlayer(wrapper, videoId,
                    // Make it as big as the video allows
                    width: 640, height: 480);
            };
        case 'html5':
            window.alert("HTML 5 video not supported yet");
            throw new Exception("HTML 5 video not supported yet");
        default:
            throw new Exception("unknown video type ${videoType}");
    }
}

