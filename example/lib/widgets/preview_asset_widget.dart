// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_video_player/awesome_video_player.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class PreviewAssetWidget extends StatefulWidget {
  const PreviewAssetWidget(this.asset, {super.key});

  final AssetEntity asset;

  @override
  State<PreviewAssetWidget> createState() => _PreviewAssetWidgetState();
}

class _PreviewAssetWidgetState extends State<PreviewAssetWidget> {
  bool get _isVideo => widget.asset.type == AssetType.video;
  Object? _error;
  BetterPlayerController? _playerController;

  @override
  void initState() {
    super.initState();
    if (_isVideo) {
      _initializeController();
    }
  }

  @override
  void dispose() {
    _playerController?.dispose(forceDispose: true);
    super.dispose();
  }

  Future<void> _initializeController() async {
    final String? url = await widget.asset.getMediaUrl();
    if (url == null) {
      _error = StateError('The media URL of the preview asset is null.');
      return;
    }
    try {
      final BetterPlayerDataSource dataSource;
      final Uri uri = Uri.parse(url);
      if (Platform.isAndroid && uri.scheme == 'content') {
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.file,
          url,
        );
      } else {
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          url,
        );
      }
      final BetterPlayerConfiguration configuration = const BetterPlayerConfiguration(
        fit: BoxFit.contain, // 改为 cover 以填充整个屏幕
        autoPlay: true,
        looping: false,
        fullScreenByDefault: false,
        allowedScreenSleep: false,
        expandToFill: true, // 关键：让播放器扩展填充所有可用空间
        deviceOrientationsOnFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: true,
          showControlsOnInitialize: false, // 初始化时就显示控制栏
          // controlBarColor: Colors.transparent, // 移除控制栏背景
          // backgroundColor: Colors.transparent, // 移除播放按钮的灰色蒙版
          iconsColor: Colors.white,
          progressBarPlayedColor: Color(0xFF2467FF),
          progressBarHandleColor: Color(0xFF2467FF),
          progressBarBufferedColor: Colors.grey,
          progressBarBackgroundColor: Colors.grey,
          textColor: Colors.white,
          enableFullscreen: true,
          enableMute: true,
          enablePlayPause: true,
          enableProgressText: true,
          enableRetry: true,
          enableSubtitles: true,
          enableQualities: true,
          enablePip: false,
          enableOverflowMenu: false,
          enableSkips: false,
          controlBarHeight: 48,
          playIcon: Icons.play_arrow,
          pauseIcon: Icons.pause,
          muteIcon: Icons.volume_up,
          fullscreenEnableIcon: Icons.fullscreen,
          fullscreenDisableIcon: Icons.fullscreen_exit,
          overflowMenuIcon: Icons.more_vert,
          playbackSpeedIcon: Icons.speed,
          subtitlesIcon: Icons.subtitles,
          qualitiesIcon: Icons.high_quality,
          controlsHideTime: Duration(seconds: 0),
        ),
      );
      final controller = BetterPlayerController(
        configuration,
        betterPlayerDataSource: dataSource,
      );
      _playerController = controller;
    } catch (e) {
      _error = e;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildImage(BuildContext context) {
    return AssetEntityImage(widget.asset);
  }

  Widget _buildVideo(BuildContext context) {
    final BetterPlayerController? controller = _playerController;
    if (controller == null) {
      return const CircularProgressIndicator();
    }
    return SizedBox.expand(
      child: BetterPlayer(
        controller: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Text('$_error', style: const TextStyle(color: Colors.white));
    }
    if (_isVideo) {
      return _buildVideo(context);
    }
    return _buildImage(context);
  }
}
