// Use of this source code is governed by the Creative Commons-0 license that
// can be found in the LICENSE file.

library videoplay_example;


import 'dart:html';

import 'package:videoplay/depot.dart';

InputElement videoId;
SelectElement videoType;
DivElement videoList;

void main() {
    videoId = querySelector("#video_id_field");
    videoType = querySelector("#video_type");
    videoList = querySelector("#video_set_list");

    for (VideoPlayerProvider provider in getSupportedVideoProviders()) {
        var oel = new OptionElement();
        oel.value = provider.name;
        oel.text = provider.toString();
        videoType.children.add(oel);
    }

    ButtonElement add = querySelector("#add_video");
    add.onClick.listen((_) {
        String vtype = videoType.options[videoType.selectedIndex].value;
        VideoPlayerProvider provider = getVideoProviderByName(vtype);
        new EmbeddedVideoDom(provider, videoId.value);
    });
}

class EmbeddedVideoDom {
    final VideoPlayerProvider videoType;
    final String videoId;
    DivElement wrapper;
    ParagraphElement status;
    VideoPlayer player;

    EmbeddedVideoDom(this.videoType, this.videoId) {
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

        VideoProviderAttributes attributes = videoType.createAttributes();
        attributes.width = 320;
        attributes.height = 200;

        embedVideo(videoType, wrapper, videoId, attributes)
            .then((VideoPlayer videoPlayer) {
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
