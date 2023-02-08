import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:invidious/globals.dart';
import 'package:invidious/models/sponsorSegment.dart';
import 'package:invidious/models/userFeed.dart';
import 'package:invidious/models/video.dart';
import 'package:http/http.dart' as http;
import 'package:invidious/models/videoInList.dart';
import 'package:invidious/views/subscriptions.dart';

import 'models/channel.dart';
import 'models/channelVideos.dart';
import 'models/searchSuggestion.dart';
import 'models/subscription.dart';
import 'models/videoComments.dart';

const GET_VIDEO = '/api/v1/videos/:id';
const GET_TRENDING = '/api/v1/trending';
const GET_POPULAR = '/api/v1/popular';
const GET_USER_FEED = '/api/v1/auth/feed';
const SEARCH_SUGGESTIONS = '/api/v1/search/suggestions?q=:query';
const SEARCH = '/api/v1/search?q=:query';
const STATS = '/api/v1/stats';
const GET_SUBSCIPTIONS = '/api/v1/auth/subscriptions';
const ADD_DELETE_SUBSCRIPTION = '/api/v1/auth/subscriptions/:ucid';
const GET_COMMENTS = '/api/v1/comments/:id';
const GET_CHANNEL = '/api/v1/channels/:id';
const GET_CHANNEL_VIDEOS = '/api/v1/channels/:id/videos';
const GET_SPONSOR_SEGMENTS = 'https://sponsor.ajay.app/api/skipSegments?videoID=:id';

class Service {
  handleResponse(Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<Video> getVideo(String videoId) async {
    String url = db.getCurrentlySelectedServer().url + (GET_VIDEO.replaceAll(":id", videoId));
    print('Calling $url');
    final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json; charset=utf-16'});

    return Video.fromJson(handleResponse(response));
  }

  Future<List<VideoInList>> getTrending() async {
    String url = db.getCurrentlySelectedServer().url + (GET_TRENDING);
    print('Calling $url');
    final response = await http.get(Uri.parse(url));
    Iterable i = handleResponse(response);
    return List<VideoInList>.from(i.map((e) => VideoInList.fromJson(e)));
  }

  Future<List<VideoInList>> getPopular() async {
    String url = db.getCurrentlySelectedServer().url + (GET_POPULAR);
    print('Calling $url');
    final response = await http.get(Uri.parse(url));
    Iterable i = handleResponse(response);
    return List<VideoInList>.from(i.map((e) => VideoInList.fromJson(e)));
  }

  Future<List<VideoInList>> search(String query) async {
    String url = db.getCurrentlySelectedServer().url + SEARCH.replaceAll(":q", query);
    print('Calling $url');
    final response = await http.get(Uri.parse(url));
    Iterable i = handleResponse(response);
    // only getting videos for now
    return List<VideoInList>.from(i.where((e) => e['type'] == 'video').map((e) => VideoInList.fromJson(e)));
  }

  Future<UserFeed> getUserFeed() async {
    var currentlySelectedServer = db.getCurrentlySelectedServer();
    String url = currentlySelectedServer.url + GET_USER_FEED;

    print('Calling $url');
    var headers = {'Authorization': 'Bearer ${currentlySelectedServer.authToken}'};

    final response = await http.get(Uri.parse(url), headers: headers);
    return UserFeed.fromJson(handleResponse(response));
  }

  Future<List<SponsorSegment>> getSponsorSegments(String videoId) async {
    try {
      String url = GET_SPONSOR_SEGMENTS.replaceAll(":id", videoId);
      print('Calling $url');
      final response = await http.get(Uri.parse(url));
      Iterable i = handleResponse(response);
      return List<SponsorSegment>.from(i.map((e) => SponsorSegment.fromJson(e)));
    } catch (err) {
      return [];
    }
  }

  Future<SearchSuggestion> getSearchSuggestion(String query) async {
    var currentlySelectedServer = db.getCurrentlySelectedServer();
    String url = currentlySelectedServer.url + SEARCH_SUGGESTIONS.replaceAll(":query", query);

    print('Calling $url');
    var headers = {'Authorization': 'Bearer ${currentlySelectedServer.authToken}'};

    final response = await http.get(Uri.parse(url), headers: headers);
    return SearchSuggestion.fromJson(handleResponse(response));
  }

  Future<bool> isValidServer(String serverUrl) async {
    String url = serverUrl + STATS;
    print('Calling $url');
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> json = handleResponse(response);

    if (json.containsKey("software")) {
      return json['software']['name'] == 'invidious';
    }

    return false;
  }

  bool isLoggedIn() {
    return db.getCurrentlySelectedServer().authToken != null;
  }

  Future<void> subscribe(String channelId) async {
    if (!isLoggedIn()) return;

    var currentlySelectedServer = db.getCurrentlySelectedServer();
    String url = currentlySelectedServer.url + ADD_DELETE_SUBSCRIPTION.replaceAll(":ucid", channelId);

    print('Calling $url');
    var headers = {'Authorization': 'Bearer ${currentlySelectedServer.authToken}'};

    final response = await http.post(Uri.parse(url), headers: headers);
  }

  Future<void> unSubscribe(String channelId) async {
    if (!isLoggedIn()) return;

    var currentlySelectedServer = db.getCurrentlySelectedServer();
    String url = currentlySelectedServer.url + ADD_DELETE_SUBSCRIPTION.replaceAll(":ucid", channelId);

    print('Calling $url');
    var headers = {'Authorization': 'Bearer ${currentlySelectedServer.authToken}'};

    final response = await http.delete(Uri.parse(url), headers: headers);
    print('${response.statusCode} - ${response.body}');
  }

  Future<bool> isSubscribedToChannel(String channelId) async {
    if (!isLoggedIn()) return false;

    var currentlySelectedServer = db.getCurrentlySelectedServer();
    String url = currentlySelectedServer.url + GET_SUBSCIPTIONS;

    print('Calling $url');
    var headers = {'Authorization': 'Bearer ${currentlySelectedServer.authToken}'};

    final response = await http.get(Uri.parse(url), headers: headers);
    Iterable i = handleResponse(response);

    return List<Subscription>.from(i.map((e) => Subscription.fromJson(e))).indexWhere((element) => element.authorId == channelId) > -1;
  }

  Future<VideoComments> getComments(String videoId, String? continuation) async {
    var currentlySelectedServer = db.getCurrentlySelectedServer();
    String url = currentlySelectedServer.url + GET_COMMENTS.replaceAll(":id", videoId);
    if (continuation != null) {
      url += '?continuation=${continuation}';
    }

    print('Calling $url');
    var headers = {'Authorization': 'Bearer ${currentlySelectedServer.authToken}'};

    final response = await http.get(Uri.parse(url), headers: headers);
    return VideoComments.fromJson(handleResponse(response));
  }

  Future<Channel> getChannel(String channelId) async {
    String url = db.getCurrentlySelectedServer().url + (GET_CHANNEL.replaceAll(":id", channelId));
    print('Calling $url');
    final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json; charset=utf-16'});

    return Channel.fromJson(handleResponse(response));
  }

  Future<ChannelVideos> getChannelVideos(String channelId, String? continuation) async {
    String url = db.getCurrentlySelectedServer().url + (GET_CHANNEL_VIDEOS.replaceAll(":id", channelId)) + (continuation != null ? '?continuation=$continuation' : '');
    print('Calling $url');
    final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json; charset=utf-16'});

    return ChannelVideos.fromJson(handleResponse(response));
  }
}
