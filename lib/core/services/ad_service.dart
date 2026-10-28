import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  bool isTestMode = false; // Production Mode ACTIVE

  // Production Ad Unit IDs (Can be set by developer)
  String? prodAndroidBannerId = 'ca-app-pub-4803928008765871/6049670425';
  String? prodIOSBannerId = 'ca-app-pub-4803928008765871/6049670425';
  String? prodAndroidInterstitialId = 'ca-app-pub-4803928008765871/8675833763';
  String? prodIOSInterstitialId = 'ca-app-pub-4803928008765871/8675833763';

  // Google Official Sample Test Ad Unit IDs
  static const String _testAndroidBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testIOSBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testAndroidInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testIOSInterstitial = 'ca-app-pub-3940256099942544/4411468910';

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      preloadInterstitial();
      preloadRewarded();
    } catch (e) {
      debugPrint('AdService initialization failed: $e');
    }
  }

  String get bannerAdUnitId {
    if (isTestMode) {
      return Platform.isAndroid ? _testAndroidBanner : _testIOSBanner;
    }
    if (Platform.isAndroid) {
      return prodAndroidBannerId ?? _testAndroidBanner;
    } else {
      return prodIOSBannerId ?? _testIOSBanner;
    }
  }

  String get interstitialAdUnitId {
    if (isTestMode) {
      return Platform.isAndroid
          ? _testAndroidInterstitial
          : _testIOSInterstitial;
    }
    if (Platform.isAndroid) {
      return prodAndroidInterstitialId ?? _testAndroidInterstitial;
    } else {
      return prodIOSInterstitialId ?? _testIOSInterstitial;
    }
  }

  void toggleTestMode(bool value) {
    isTestMode = value;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    preloadInterstitial();
  }

  /// Preload interstitial ad in the background
  void preloadInterstitial() {
    if (_interstitialAd != null || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              preloadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              preloadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');
          _interstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  DateTime? _lastAdShowTime;

  /// Show interstitial ad on all screen transitions whenever ready
  void showInterstitialIfReady({VoidCallback? onComplete}) {
    final now = DateTime.now();
    if (_lastAdShowTime != null &&
        now.difference(_lastAdShowTime!).inSeconds < 2) {
      onComplete?.call();
      return;
    }

    if (_interstitialAd != null) {
      _lastAdShowTime = now;
      _interstitialAd!.show();
      onComplete?.call();
    } else {
      preloadInterstitial();
      onComplete?.call();
    }
  }

  /// Force show interstitial ad if available
  void showInterstitialAd({VoidCallback? onComplete}) {
    if (_interstitialAd != null) {
      _lastAdShowTime = DateTime.now();
      _interstitialAd!.show();
      onComplete?.call();
    } else {
      preloadInterstitial();
      onComplete?.call();
    }
  }

  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;
  String? prodAndroidRewardedId;
  String? prodIOSRewardedId;

  String get rewardedAdUnitId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }
    return Platform.isAndroid
        ? (prodAndroidRewardedId ?? 'ca-app-pub-3940256099942544/5224354917')
        : (prodIOSRewardedId ?? 'ca-app-pub-3940256099942544/1712485313');
  }

  void preloadRewarded() {
    if (_rewardedAd != null || _isRewardedLoading) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          _rewardedAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              preloadRewarded();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              preloadRewarded();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded failed to load: $error');
          _rewardedAd = null;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onComplete,
  }) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: (_, reward) {
        onUserEarnedReward(reward);
      });
      onComplete?.call();
    } else {
      preloadRewarded();
      onComplete?.call();
    }
  }
}

/// Automatically triggers interstitial ads when navigating to new screens
class AppRouteAdObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (previousRoute != null && route is MaterialPageRoute) {
      Future.delayed(const Duration(milliseconds: 300), () {
        AdService().showInterstitialIfReady();
      });
    }
  }
}
