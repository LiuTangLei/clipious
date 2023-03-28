import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invidious/views/channel.dart';

import '../globals.dart';
import '../models/channel.dart';

class ChannelController extends GetxController {
  String channelId;
  bool isSubscribed = false;
  int selectedIndex = 0;
  Channel? channel;
  bool loading = true;
  bool smallHeader = false;
  double barHeight = 200;
  double barOpacity = 1;
  late Animation<Color?>? animation;
  late AnimationController controller;

  ChannelController(this.channelId, Color backgroundColor, TickerProvider vsync) {
    controller = AnimationController(duration: animationDuration, vsync: vsync);
    animation = ColorTween(begin: backgroundColor.withOpacity(0.4), end: backgroundColor).animate(controller)..addListener(() {});
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    bool isSubscribed = await service.isSubscribedToChannel(channelId);
    Channel channel = await service.getChannel(channelId);

    this.channel = channel;
    loading = false;
    this.isSubscribed = isSubscribed;
    update();
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }

  selectIndex(int index){
    selectedIndex = index;
    update();
  }

  toggleSubscription() async {
    if (channel != null) {
      if (this.isSubscribed) {
        await service.unSubscribe(channel!.authorId);
      } else {
        await service.subscribe(channel!.authorId);
      }
      bool isSubscribed = await service.isSubscribedToChannel(channel!.authorId);

      this.isSubscribed = isSubscribed;
      update();
    }
  }

  bool onBodyScroll(ScrollNotification notification) {
    double height = 200 - min(notification.metrics.pixels, 200);
    double opacity = min(1, height / 200);
    height = max(channelMinBarHeight, height);

    barOpacity = opacity;
    barHeight = height;

    update();
    return true;
  }
}