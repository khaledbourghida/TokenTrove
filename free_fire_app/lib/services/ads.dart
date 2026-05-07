import 'dart:async';

import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityInterstitialScheduler {
  UnityInterstitialScheduler._();
  static final UnityInterstitialScheduler instance =
      UnityInterstitialScheduler._();

  static const String _gameId = '5926795';
  static const String _placementId = 'Rewarded_Android';

  bool _initialized = false;
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _started = false;
  Timer? _timer;

  void start() {
    if (_started) return;
    _started = true;
    _initUnity();
  }

  void _initUnity() {
    UnityAds.init(
      gameId: _gameId,
      onComplete: () {
        _initialized = true;
        _load();
        _startPeriodic();
        // ignore: avoid_print
        print('UnityInterstitialScheduler initialized');
      },
      onFailed: (error, message) {
        // ignore: avoid_print
        print('Unity init failed: $error $message');
        // Retry later
        _scheduleRetryInit();
      },
    );
  }

  void _scheduleRetryInit() {
    Future.delayed(const Duration(seconds: 10), () {
      if (!_initialized) {
        _initUnity();
      }
    });
  }

  void _startPeriodic() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) async {
      if (!_initialized) return;
      if (_isLoaded) {
        _show();
      } else if (!_isLoading) {
        _load();
      }
    });
  }

  void _load() {
    if (_isLoading) return;
    _isLoading = true;
    UnityAds.load(
      placementId: _placementId,
      onComplete: (placementId) {
        _isLoading = false;
        _isLoaded = true;
        // ignore: avoid_print
        print('Unity interstitial loaded: $placementId');
      },
      onFailed: (placementId, error, message) {
        _isLoading = false;
        _isLoaded = false;
        // ignore: avoid_print
        print('Unity interstitial load failed: $error $message');
      },
    );
  }

  void _show() {
    if (!_isLoaded) return;
    UnityAds.showVideoAd(
      placementId: _placementId,
      onStart: (placementId) => print('Interstitial $placementId started'),
      onClick: (placementId) => print('Interstitial $placementId clicked'),
      onSkipped: (placementId) => print('Interstitial $placementId skipped'),
      onComplete: (placementId) {
        _isLoaded = false;
        _load();
        print('Interstitial $placementId completed');
      },
      onFailed: (placementId, error, message) {
        _isLoaded = false;
        _load();
        print('Interstitial $placementId failed: $error $message');
      },
    );
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _started = false;
  }
}
