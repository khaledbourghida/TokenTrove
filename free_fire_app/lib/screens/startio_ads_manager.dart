import 'package:flutter/services.dart';

class StartIoAds {
  static const MethodChannel _channel = MethodChannel('start_io_ads');

  static Future<void> initSdk() async {
    print('initailizing...');
    await _channel.invokeMethod('initSdk');
    print('initialize done');
  }

  static Future<void> showBanner() async {
    await _channel.invokeMethod('showBanner');
  }

  static Future<void> showInterstitial() async {
    await _channel.invokeMethod('showInterstitial');
  }

  static Future<void> showRewardedVideo() async {
    await _channel.invokeMethod('showRewardedVideo');
  }
}
