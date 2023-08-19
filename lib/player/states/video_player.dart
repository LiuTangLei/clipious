import 'package:better_player/better_player.dart';
import 'package:better_player/src/video_player/video_player_platform_interface.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invidious/downloads/models/downloaded_video.dart';
import 'package:invidious/extensions.dart';
import 'package:invidious/player/models/mediaEvent.dart';
import 'package:invidious/player/views/tv/components/player_controls.dart';
import 'package:invidious/settings/states/settings.dart';
import 'package:invidious/videos/models/base_video.dart';
import 'package:logging/logging.dart';
import 'package:pretty_bytes/pretty_bytes.dart';
import 'package:wakelock/wakelock.dart';

import '../../database.dart';
import '../../globals.dart';
import '../../main.dart';
import '../../settings/models/db/settings.dart';
import '../../videos/models/video.dart';
import '../views/components/player_controls.dart';
import 'interfaces/media_player.dart';
import 'player.dart';

part 'video_player.g.dart';

final log = Logger('VideoPlayer');

class VideoPlayerCubit extends MediaPlayerCubit<VideoPlayerState> {
  final PlayerCubit player;

  VideoPlayerCubit(super.initialState, this.player) {
    onInit();
  }

  void onInit() {
    log.fine("Ready, playing video");
    playVideo(state.offlineVideo != null, startAt: state.startAt);
  }

  @override
  close() async {
    disposeControllers();
    super.close();
  }

  @override
  disposeControllers() {
    Wakelock.disable();
    log.fine("Disposing video controller");
    var state = this.state.copyWith();
    state.videoController?.removeEventsListener(onVideoListener);
    state.videoController?.dispose();
    state.videoController = null;
    if (!isClosed) {
      emit(state);
    }
  }

  forwardEvent(BetterPlayerEvent event) {
    MediaEventType? type;
    MediaState mediaState = MediaState.playing;

    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.setSpeed:
        type = MediaEventType.speedChanged;
        break;
      case BetterPlayerEventType.pause:
        type = MediaEventType.pause;
        break;
      case BetterPlayerEventType.setVolume:
        type = MediaEventType.volumeChanged;
        break;
      case BetterPlayerEventType.play:
        type = MediaEventType.play;
        break;

      case BetterPlayerEventType.progress:
      case BetterPlayerEventType.seekTo:
        // we bypass the rest so we can send the current progress
        player.setEvent(MediaEvent(state: MediaState.playing, type: MediaEventType.progress, value: state.videoController?.videoPlayerController?.value.position ?? Duration.zero));
        return;
      case BetterPlayerEventType.bufferingEnd:
        mediaState = MediaState.playing;
        break;
      case BetterPlayerEventType.bufferingStart:
        mediaState = MediaState.buffering;
        break;
      case BetterPlayerEventType.changedPlayerVisibility:
        break;
      case BetterPlayerEventType.changedPlaylistItem:
        break;
      case BetterPlayerEventType.setupDataSource:
        mediaState = MediaState.loading;
        break;
      case BetterPlayerEventType.pipStop:
        break;
      case BetterPlayerEventType.pipStart:
        break;
      case BetterPlayerEventType.overflowOpened:
        break;
      case BetterPlayerEventType.overflowClosed:
        break;
      case BetterPlayerEventType.openFullscreen:
        break;
      case BetterPlayerEventType.initialized:
        mediaState = MediaState.ready;
        break;
      case BetterPlayerEventType.hideFullscreen:
        break;
      case BetterPlayerEventType.finished:
        mediaState = MediaState.completed;
        break;
      case BetterPlayerEventType.exception:
        mediaState = MediaState.error;
        break;
      case BetterPlayerEventType.controlsVisible:
        break;
      case BetterPlayerEventType.controlsHiddenStart:
        break;
      case BetterPlayerEventType.controlsHiddenEnd:
        break;
      case BetterPlayerEventType.changedTrack:
        break;
      case BetterPlayerEventType.changedSubtitles:
        break;
      case BetterPlayerEventType.changedResolution:
        break;
      default:
        return;
    }

    player.setEvent(MediaEvent(state: mediaState, type: type));
  }

  onVideoListener(BetterPlayerEvent event) {
    forwardEvent(event);

    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.bufferingUpdate:
        List<DurationRange> durations = event.parameters?['buffered'] ?? [];
        state.bufferPosition = durations.sortBy((e) => e.end).map((e) => e.end).last;
        break;
      case BetterPlayerEventType.play:
        double speed = 1.0;
        if (db.getSettings(REMEMBER_PLAYBACK_SPEED)?.value == 'true') {
          speed = double.parse(db.getSettings(LAST_SPEED)?.value ?? '1.0');

          log.fine("Setting playback speed to $speed");
          state.videoController?.setSpeed(speed);
        }
        break;
      case BetterPlayerEventType.changedSubtitles:
        db.saveSetting(SettingsValue(LAST_SUBTITLE, state.videoController?.betterPlayerSubtitlesSource?.name ?? ''));
        break;
      case BetterPlayerEventType.setSpeed:
        if (event.parameters?.containsKey("speed") ?? false) {
          db.saveSetting(SettingsValue(LAST_SPEED, event.parameters?["speed"].toString() ?? '1.0'));
        }
        break;
      default:
        break;
    }
  }

  @override
  toggleDash() {
    log.fine('toggle dash');
    var state = this.state.copyWith();
    // saving progress before we reload new video format
    // saveProgress(videoController?.videoPlayerController?.value.position.inSeconds ?? 0);
    player.saveProgress(position().inSeconds);

    disposeControllers();

    db.saveSetting(SettingsValue(USE_DASH, (!state.useDash).toString()));
    state.useDash = !state.useDash;
    emit(state);
    playVideo(false);
  }

  @override
  switchVideo(Video video, {Duration? startAt}) {
    state.videoController?.exitFullScreen();
    state.startAt = startAt;
    disposeControllers();
    state.video = video;
    playVideo(false, startAt: startAt);
  }

  @override
  togglePlaying() {
    if (state.videoController != null) {
      (state.videoController?.isPlaying() ?? false) ? state.videoController?.pause() : state.videoController?.play();
      emit(state.copyWith());
    }
  }

  @override
  toggleControls(bool visible) {
    state.videoController?.setControlsEnabled(visible);
  }

  @override
  playVideo(bool offline, {Duration? startAt}) async {
    var state = this.state.copyWith();
    // only used if the player is currently close because it is onReady that will actually play the video
    // need better way of handling this
    state.startAt = startAt;
    if (state.video != null || state.offlineVideo != null) {
      IdedVideo idedVideo = offline ? state.offlineVideo! : state.video!;
      state.videoController?.dispose();
      state.videoController = null;
      state.bufferPosition = Duration.zero;

      if (startAt == null && !offline) {
        double progress = db.getVideoProgress(idedVideo.videoId);
        if (progress > 0 && progress < 0.90) {
          startAt = Duration(seconds: (offline ? state.offlineVideo!.lengthSeconds : state.video!.lengthSeconds * progress).floor());
        }
      }

      late BetterPlayerDataSource betterPlayerDataSource;

      // getting data sources
      if (offline) {
        String videoPath = await state.offlineVideo!.mediaPath;

        betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.file,
          videoPath,
          videoFormat: BetterPlayerVideoFormat.other,
          liveStream: false,
        );
      } else {
        String baseUrl = db.getCurrentlySelectedServer().url;

        Map<String, String> resolutions = {};

        bool isHls = state.video!.hlsUrl != null;

        var formatStream = isHls ? null : state.video!.formatStreams[state.video!.formatStreams.length - 1];
        String videoUrl = isHls
            ? '${state.video!.hlsUrl!}${service.useProxy() ? '?local=true' : ''}'
            : state.useDash
                ? '${state.video!.dashUrl}${service.useProxy() ? '?local=true' : ''}'
                : formatStream?.url ?? '';
        if (!state.useDash && formatStream != null) {
          state.selectedNonDashTrack = formatStream.resolution;
        }

        log.info('Playing url (dash ${state.useDash},  hasHls ? ${state.video!.hlsUrl != null})  ${videoUrl}');

        state.useDash = db.getSettings(USE_DASH)?.value == 'true';

        BetterPlayerVideoFormat format = isHls
            ? BetterPlayerVideoFormat.hls
            : state.useDash
                ? BetterPlayerVideoFormat.dash
                : BetterPlayerVideoFormat.other;

        if (format == BetterPlayerVideoFormat.other) {
          for (var value in state.video!.formatStreams) {
            resolutions[value.qualityLabel] = value.url;
          }
        }

        String lastSubtitle = '';
        if (db.getSettings(REMEMBER_LAST_SUBTITLE)?.value == 'true') {
          lastSubtitle = db.getSettings(LAST_SUBTITLE)?.value ?? '';
        }

        betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          videoUrl,
          videoFormat: format,
          liveStream: state.video!.liveNow,
          subtitles: state.video!.captions
              .map((s) => BetterPlayerSubtitlesSource(type: BetterPlayerSubtitlesSourceType.network, urls: ['${baseUrl}${s.url}'], name: s.label, selectedByDefault: s.label == lastSubtitle))
              .toList(),
          resolutions: resolutions.isNotEmpty ? resolutions : null,
        );
      }

      Wakelock.enable();

      bool lockOrientation = db.getSettings(LOCK_ORIENTATION_FULLSCREEN)?.value == 'true';
      bool fillVideo = db.getSettings(FILL_FULLSCREEN)?.value == 'true';

      state.videoController = BetterPlayerController(
          BetterPlayerConfiguration(
              overlay: isTv ? const TvPlayerControls() : PlayerControls(mediaPlayerCubit: this),
              deviceOrientationsOnFullScreen: [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight, DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
              deviceOrientationsAfterFullScreen: [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight, DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
              handleLifecycle: false,
              autoDetectFullscreenDeviceOrientation: lockOrientation,
              autoDetectFullscreenAspectRatio: true,
              startAt: startAt,
              autoPlay: true,
              allowedScreenSleep: false,
              fit: fillVideo ? BoxFit.cover : BoxFit.contain,
              subtitlesConfiguration: BetterPlayerSubtitlesConfiguration(
                fontSize: double.parse(db.getSettings(SUBTITLE_SIZE)?.value ?? subtitleDefaultSize),
              ),
              controlsConfiguration: BetterPlayerControlsConfiguration(
                showControls: false,
                // customControlsBuilder: (controller, onPlayerVisibilityChanged) => const PlayerControls(),
                // enablePlayPause: false,
                // overflowModalColor: colors.background,
                // overflowModalTextColor: overFlowTextColor,
                // overflowMenuIconsColor: overFlowTextColor,
                // overflowMenuCustomItems: [BetterPlayerOverflowMenuItem(useDash ? Icons.check_box_outlined : Icons.check_box_outline_blank, locals.useDash, toggleDash)])
              )),
          betterPlayerDataSource: betterPlayerDataSource);
      state.videoController!.addEventsListener(onVideoListener);
      state.videoController!.setBetterPlayerGlobalKey(state.key);
      // isPipSupported = await videoController?.isPictureInPictureSupported() ?? false;

      emit(state);
    }
  }

  @override
  void switchToOfflineVideo(DownloadedVideo v) {
    state.videoController?.exitFullScreen();
    disposeControllers();
    state.offlineVideo = v;
    playVideo(true);
  }

  @override
  bool isPlaying() {
    return state.videoController?.isPlaying() ?? false;
  }

  @override
  void pause() {
    state.videoController?.pause();
  }

  @override
  void play() {
    state.videoController?.play();
  }

  @override
  void seek(Duration position) {
    state.videoController?.seekTo(position);
  }

  @override
  Duration? bufferedPosition() {
    return state.bufferPosition;
  }

  @override
  Duration position() {
    return state.videoController?.videoPlayerController?.value.position ?? Duration.zero;
  }

  @override
  double? speed() {
    return state.videoController?.videoPlayerController?.value.speed ?? 1;
  }

  @override
  FullScreenState isFullScreen() {
    return (state.videoController?.isFullScreen ?? false) ? FullScreenState.fullScreen : FullScreenState.notFullScreen;
  }

  @override
  setFullScreen(bool fullScreen) {
    if (fullScreen) {
      state.videoController?.enterFullScreen();
    } else {
      state.videoController?.exitFullScreen();
    }
  }

  String _videoTrackToString(BetterPlayerAsmsTrack? track) {
    return '${track?.height}p - ${prettyBytes((track?.bitrate ?? 0).toDouble(), bits: true)}/s';
  }

  String _audioTrackToString(BetterPlayerAsmsAudioTrack? track) {
    return '${track?.label} ${track?.language != null ? '- ${track?.language}' : ''}';
  }

  String _subtitleToString(BetterPlayerSubtitlesSource? source) {
    return '${source?.name}';
  }

  @override
  List<String> getVideoTracks() {
    if (state.video != null) {
      if (state.videoController?.betterPlayerAsmsTracks.isNotEmpty ?? false) {
        return state.videoController?.betterPlayerAsmsTracks.map(_videoTrackToString).toList() ?? [];
      } else {
        return state.video?.formatStreams.map((e) => e.resolution).toList() ?? [];
      }
    }
    // for offline video we don't offer video track selection
    return [];
  }

  @override
  int selectedVideoTrack() {
    if (state.video != null) {
      if (state.useDash) {
        var tracks = getVideoTracks();
        var track = _videoTrackToString(state.videoController?.betterPlayerAsmsTrack);
        log.fine("Current track: $track");
        return tracks.indexOf(track);
      } else {
        var tracks = getVideoTracks();

        return tracks.indexOf(state.selectedNonDashTrack);
      }
    }
    // for offline video we don't offer video track selection
    return -1;
  }

  @override
  List<String> getAudioTracks() {
    if (state.video != null) {
      if (state.videoController?.betterPlayerAsmsAudioTracks?.isNotEmpty ?? false) {
        return state.videoController?.betterPlayerAsmsAudioTracks?.map(_audioTrackToString).toList() ?? [];
      }
    }
    // for offline video we don't offer video track selection
    return [];
  }

  @override
  int selectedAudioTrack() {
    if (state.video != null) {
      if (state.useDash) {
        var tracks = getAudioTracks();
        var track = _audioTrackToString(state.videoController?.betterPlayerAsmsAudioTrack);
        log.fine("Current audio track: $track");
        return tracks.indexOf(track);
      }
    }
    // for offline video we don't offer video track selection
    return -1;
  }

  @override
  List<String> getSubtitles() {
    return state.video != null ? state.videoController?.betterPlayerSubtitlesSourceList.map(_subtitleToString).toList() ?? [] : [];
  }

  @override
  int selectedSubtitle() {
    var tracks = getSubtitles();
    var track = _subtitleToString(state.videoController?.betterPlayerSubtitlesSource);
    log.fine("Current subtitle track: $track");
    return tracks.indexOf(track);
  }

  @override
  selectAudioTrack(int index) {
    var betterPlayerAsmsTrack = state.videoController?.betterPlayerAsmsAudioTracks?[index];
    log.fine("Selected audio track, ${betterPlayerAsmsTrack?.label}");
    if (betterPlayerAsmsTrack != null) {
      state.videoController?.setAudioTrack(betterPlayerAsmsTrack);
    }
  }

  @override
  selectSubtitle(int index) {
    var sub = state.videoController?.betterPlayerSubtitlesSourceList[index];
    if (sub != null) {
      state.videoController?.setupSubtitleSource(sub, sourceInitialize: true);
    }
  }

  @override
  selectVideoTrack(int index) {
    var betterPlayerAsmsTrack = state.videoController?.betterPlayerAsmsTracks[index];
    if (betterPlayerAsmsTrack != null) {
      state.videoController?.setTrack(betterPlayerAsmsTrack);
    }
  }

  @override
  bool supportsPip() {
    return isFullScreen() == FullScreenState.notFullScreen;
  }

  @override
  void enterPip() {
    state.videoController?.enablePictureInPicture(state.key);
  }

  @override
  bool isMuted() {
    return state.videoController?.videoPlayerController?.value.volume == 0;
  }

  @override
  void toggleVolume(bool soundOn) {
    state.videoController?.setVolume(soundOn ? 1 : 0);
  }

  @override
  void setSpeed(double d) {
    state.videoController?.setSpeed(d);
  }

  @override
  double getSpeed() {
    return state.videoController?.videoPlayerController?.value.speed ?? 1;
  }

  @override
  bool hasDashToggle() {
    return state.video != null;
  }

  @override
  bool isUsingDash() {
    return state.useDash;
  }

  @override
  Duration duration() {
    return state.videoController?.videoPlayerController?.value.duration ?? const Duration(milliseconds: 1);
  }
}

@CopyWith(constructor: "_")
class VideoPlayerState extends MediaPlayerState {
  BetterPlayerController? videoController;
  bool useDash = db.getSettings(USE_DASH)?.value == 'true';
  final ColorScheme colors;
  final Color overFlowTextColor;
  final GlobalKey key;
  Duration? startAt;
  String selectedNonDashTrack = '';
  Duration? bufferPosition = Duration.zero;

  VideoPlayerState({required this.colors, required this.overFlowTextColor, required this.key, Video? video, DownloadedVideo? offlineVideo, bool? disableControls, this.startAt})
      : super(video: video, offlineVideo: offlineVideo, disableControls: disableControls);

  VideoPlayerState._(this.videoController, this.useDash, this.colors, this.overFlowTextColor, this.key, this.startAt, this.selectedNonDashTrack, this.bufferPosition,
      {Video? video, DownloadedVideo? offlineVideo, bool? disableControls, bool? playNow})
      : super(video: video, offlineVideo: offlineVideo, disableControls: disableControls, playNow: playNow);
}