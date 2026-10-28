import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal() : _platform = null;

  @visibleForTesting
  AdService.forTesting({required TargetPlatform platform})
    : _platform = platform;

  final TargetPlatform? _platform;
  TargetPlatform get platform => _platform ?? defaultTargetPlatform;
  bool get isSupported =>
      !kIsWeb &&
      (platform == TargetPlatform.android || platform == TargetPlatform.iOS);
  bool _isInitialized = false;
  Future<void>? _initializing;
  bool isTestMode = kDebugMode;
  final ValueNotifier<int> configurationChanges = ValueNotifier(0);

  String? prodAndroidBannerId = 'ca-app-pub-4803928008765871/6049670425';
  String? prodIOSBannerId = 'ca-app-pub-4803928008765871/6049670425';
  String? prodAndroidInterstitialId = 'ca-app-pub-4803928008765871/8675833763';
  String? prodIOSInterstitialId = 'ca-app-pub-4803928008765871/8675833763';
  String? prodAndroidRewardedId = const String.fromEnvironment(
    'ADMOB_ANDROID_REWARDED_ID',
  );
  String? prodIOSRewardedId = const String.fromEnvironment(
    'ADMOB_IOS_REWARDED_ID',
  );

  String _unit(
    String androidTest,
    String iosTest,
    String? androidProd,
    String? iosProd,
  ) {
    if (isTestMode) {
      return platform == TargetPlatform.android ? androidTest : iosTest;
    }
    return (platform == TargetPlatform.android ? androidProd : iosProd) ?? '';
  }

  String get bannerAdUnitId => _unit(
    'ca-app-pub-3940256099942544/6300978111',
    'ca-app-pub-3940256099942544/2934735716',
    prodAndroidBannerId,
    prodIOSBannerId,
  );
  String get interstitialAdUnitId => _unit(
    'ca-app-pub-3940256099942544/1033173712',
    'ca-app-pub-3940256099942544/4411468910',
    prodAndroidInterstitialId,
    prodIOSInterstitialId,
  );
  String get rewardedAdUnitId => _unit(
    'ca-app-pub-3940256099942544/5224354917',
    'ca-app-pub-3940256099942544/1712485313',
    prodAndroidRewardedId,
    prodIOSRewardedId,
  );

  Future<void> init() {
    if (_isInitialized || !isSupported) return Future<void>.value();
    return _initializing ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      preloadInterstitial();
      preloadRewarded();
    } catch (error) {
      debugPrint('AdService initialization failed: $error');
    } finally {
      _initializing = null;
    }
  }

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;
  bool _isShowing = false;
  int _generation = 0;
  DateTime? _lastAdShowTime;

  void toggleTestMode(bool value) {
    if (value == isTestMode) return;
    isTestMode = value;
    _clearLoadedAds();
    configurationChanges.value++;
    preloadInterstitial();
    preloadRewarded();
  }

  void _clearLoadedAds() {
    _generation++;
    unawaited(_interstitialAd?.dispose());
    unawaited(_rewardedAd?.dispose());
    _interstitialAd = null;
    _rewardedAd = null;
    _isInterstitialLoading = false;
    _isRewardedLoading = false;
  }

  void preloadInterstitial() {
    if (!_isInitialized ||
        !isSupported ||
        interstitialAdUnitId.isEmpty ||
        _interstitialAd != null ||
        _isInterstitialLoading) {
      return;
    }
    _isInterstitialLoading = true;
    unawaited(_loadInterstitial(_generation));
  }

  Future<void> _loadInterstitial(int generation) async {
    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            if (generation != _generation) {
              unawaited(ad.dispose());
              return;
            }
            _interstitialAd = ad;
            _isInterstitialLoading = false;
          },
          onAdFailedToLoad: (error) {
            if (generation != _generation) return;
            _isInterstitialLoading = false;
            debugPrint('Interstitial failed to load: $error');
          },
        ),
      );
    } catch (error) {
      if (generation == _generation) _isInterstitialLoading = false;
      debugPrint('Interstitial request failed: $error');
    }
  }

  void preloadRewarded() {
    if (!_isInitialized ||
        !isSupported ||
        rewardedAdUnitId.isEmpty ||
        _rewardedAd != null ||
        _isRewardedLoading) {
      return;
    }
    _isRewardedLoading = true;
    unawaited(_loadRewarded(_generation));
  }

  Future<void> _loadRewarded(int generation) async {
    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            if (generation != _generation) {
              unawaited(ad.dispose());
              return;
            }
            _rewardedAd = ad;
            _isRewardedLoading = false;
          },
          onAdFailedToLoad: (error) {
            if (generation != _generation) return;
            _isRewardedLoading = false;
            debugPrint('Rewarded failed to load: $error');
          },
        ),
      );
    } catch (error) {
      if (generation == _generation) _isRewardedLoading = false;
      debugPrint('Rewarded request failed: $error');
    }
  }

  void showInterstitialIfReady({VoidCallback? onComplete}) {
    if (_lastAdShowTime != null &&
        DateTime.now().difference(_lastAdShowTime!).inSeconds < 2) {
      onComplete?.call();
      return;
    }
    showInterstitialAd(onComplete: onComplete);
  }

  void showInterstitialAd({VoidCallback? onComplete}) {
    final ad = _interstitialAd;
    if (_isShowing || ad == null) {
      if (!_isShowing) preloadInterstitial();
      onComplete?.call();
      return;
    }
    // Fullscreen ads are single-use. Remove before calling the native SDK.
    _interstitialAd = null;
    _isShowing = true;
    _lastAdShowTime = DateTime.now();
    var completed = false;
    void finish() {
      if (completed) return;
      completed = true;
      unawaited(ad.dispose());
      _isShowing = false;
      preloadInterstitial();
      onComplete?.call();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) => finish(),
      onAdFailedToShowFullScreenContent: (_, error) => finish(),
    );
    unawaited(ad.show().catchError((Object error) => finish()));
  }

  void showRewardedAd({
    required void Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onComplete,
  }) {
    final ad = _rewardedAd;
    if (_isShowing || ad == null) {
      if (!_isShowing) preloadRewarded();
      onComplete?.call();
      return;
    }
    _rewardedAd = null;
    _isShowing = true;
    var completed = false;
    var rewarded = false;
    void finish() {
      if (completed) return;
      completed = true;
      unawaited(ad.dispose());
      _isShowing = false;
      preloadRewarded();
      onComplete?.call();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) => finish(),
      onAdFailedToShowFullScreenContent: (_, error) => finish(),
    );
    unawaited(
      ad
          .show(
            onUserEarnedReward: (_, reward) {
              if (rewarded) return;
              rewarded = true;
              onUserEarnedReward(reward);
            },
          )
          .catchError((Object error) => finish()),
    );
  }

  @visibleForTesting
  void dispose() => _clearLoadedAds();
}

class AppRouteAdObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (previousRoute != null && route is MaterialPageRoute) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (route.isCurrent) AdService().showInterstitialIfReady();
      });
    }
  }
}
