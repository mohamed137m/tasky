// SDK internals are used only to inject native events without launching an app.
// ignore_for_file: implementation_imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:tasky/core/services/ad_service.dart';
import 'package:tasky/core/widgets/tasky_banner_ad_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  late AdService service;
  String? failMethod;
  Future<void> flush() => Future<void>.delayed(Duration.zero);
  List<MethodCall> requests(String method) =>
      calls.where((call) => call.method == method).toList();
  int idFor(String method) =>
      (requests(method).last.arguments as Map)['adId'] as int;
  InterstitialAd interstitial() =>
      instanceManager.adFor(idFor('loadInterstitialAd'))! as InterstitialAd;
  RewardedAd rewarded() =>
      instanceManager.adFor(idFor('loadRewardedAd'))! as RewardedAd;
  void loadedInterstitial() {
    final ad = interstitial();
    ad.adLoadCallback.onAdLoaded(ad);
  }

  void loadedRewarded() {
    final ad = rewarded();
    ad.rewardedAdLoadCallback.onAdLoaded(ad);
  }

  setUp(() {
    calls.clear();
    failMethod = null;
    instanceManager = AdInstanceManager('plugins.flutter.io/google_mobile_ads');
    service = AdService.forTesting(platform: TargetPlatform.android);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(instanceManager.channel, (call) async {
          calls.add(call);
          if (call.method == failMethod) {
            throw PlatformException(code: 'sdk_error');
          }
          if (call.method == 'MobileAds#initialize') {
            return InitializationStatus({});
          }
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          SystemChannels.platform_views,
          (_) async => null,
        );
  });

  tearDown(() async {
    service.dispose();
    await flush();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(instanceManager.channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform_views, null);
  });

  test('debug builds use correct sample IDs on each mobile platform', () {
    expect(service.bannerAdUnitId, endsWith('/6300978111'));
    expect(service.interstitialAdUnitId, endsWith('/1033173712'));
    expect(service.rewardedAdUnitId, endsWith('/5224354917'));
    final ios = AdService.forTesting(platform: TargetPlatform.iOS);
    expect(ios.bannerAdUnitId, endsWith('/2934735716'));
    expect(ios.interstitialAdUnitId, endsWith('/4411468910'));
    expect(ios.rewardedAdUnitId, endsWith('/1712485313'));
  });

  test('production never silently falls back to sample rewarded IDs', () async {
    service.isTestMode = false;
    await service.init();
    await flush();
    expect(
      service.interstitialAdUnitId,
      startsWith('ca-app-pub-4803928008765871/'),
    );
    expect(service.rewardedAdUnitId, isEmpty);
    expect(requests('loadRewardedAd'), isEmpty);
    service.prodAndroidRewardedId = 'configured-rewarded';
    service.preloadRewarded();
    await flush();
    expect(
      (requests('loadRewardedAd').single.arguments as Map)['adUnitId'],
      'configured-rewarded',
    );
  });

  test('unsupported platforms never call the native ads SDK', () async {
    final desktop = AdService.forTesting(platform: TargetPlatform.macOS);
    await desktop.init();
    desktop.preloadInterstitial();
    desktop.preloadRewarded();
    expect(calls, isEmpty);
  });

  test('initialization and parallel preloads are deduplicated', () async {
    await Future.wait([service.init(), service.init(), service.init()]);
    service.preloadInterstitial();
    service.preloadRewarded();
    await flush();
    expect(requests('MobileAds#initialize'), hasLength(1));
    expect(requests('loadInterstitialAd'), hasLength(1));
    expect(requests('loadRewardedAd'), hasLength(1));
  });

  test('initialization can retry after a native error', () async {
    failMethod = 'MobileAds#initialize';
    await service.init();
    expect(requests('loadInterstitialAd'), isEmpty);
    failMethod = null;
    await service.init();
    expect(requests('MobileAds#initialize'), hasLength(2));
    expect(requests('loadInterstitialAd'), hasLength(1));
  });

  test(
    'interstitial is single-use and completion waits for dismissal',
    () async {
      await service.init();
      loadedInterstitial();
      final ad = interstitial();
      var completions = 0;
      service.showInterstitialAd(onComplete: () => completions++);
      service.showInterstitialAd();
      service.showInterstitialIfReady();
      await flush();
      expect(requests('showAdWithoutView'), hasLength(1));
      expect(completions, 0);
      ad.fullScreenContentCallback!.onAdDismissedFullScreenContent!(ad);
      ad.fullScreenContentCallback!.onAdDismissedFullScreenContent!(ad);
      await flush();
      expect(completions, 1);
      expect(requests('disposeAd'), hasLength(1));
      expect(requests('loadInterstitialAd'), hasLength(2));
      loadedInterstitial();
      service.showInterstitialIfReady();
      expect(requests('showAdWithoutView'), hasLength(1));
    },
  );

  test(
    'fullscreen failure releases the ad and invokes completion once',
    () async {
      await service.init();
      loadedInterstitial();
      final ad = interstitial();
      var completions = 0;
      service.showInterstitialAd(onComplete: () => completions++);
      ad.fullScreenContentCallback!.onAdFailedToShowFullScreenContent!(
        ad,
        AdError(1, 'test', 'failed'),
      );
      await flush();
      expect(completions, 1);
      expect(requests('loadInterstitialAd'), hasLength(2));
    },
  );

  test(
    'native show exception recovers without leaving fullscreen locked',
    () async {
      await service.init();
      loadedInterstitial();
      failMethod = 'showAdWithoutView';
      var completions = 0;
      service.showInterstitialAd(onComplete: () => completions++);
      await flush();
      expect(completions, 1);
      expect(requests('loadInterstitialAd'), hasLength(2));
      failMethod = null;
      loadedInterstitial();
      service.showInterstitialAd();
      expect(requests('showAdWithoutView'), hasLength(2));
    },
  );

  test('no-fill can retry on the next request without a load loop', () async {
    await service.init();
    interstitial().adLoadCallback.onAdFailedToLoad(
      LoadAdError(3, 'test', 'no fill', null),
    );
    await flush();
    expect(requests('loadInterstitialAd'), hasLength(1));
    var completed = false;
    service.showInterstitialAd(onComplete: () => completed = true);
    await flush();
    expect(completed, isTrue);
    expect(requests('loadInterstitialAd'), hasLength(2));
    expect(requests('showAdWithoutView'), isEmpty);
  });

  test('native load exceptions clear loading flags for retry', () async {
    failMethod = 'loadInterstitialAd';
    await service.init();
    await flush();
    failMethod = null;
    service.preloadInterstitial();
    await flush();
    expect(requests('loadInterstitialAd'), hasLength(2));
  });

  test(
    'mode switch discards stale loads for both fullscreen formats',
    () async {
      await service.init();
      final oldInterstitial = interstitial();
      final oldRewarded = rewarded();
      service.toggleTestMode(false);
      oldInterstitial.adLoadCallback.onAdLoaded(oldInterstitial);
      oldRewarded.rewardedAdLoadCallback.onAdLoaded(oldRewarded);
      await flush();
      expect(requests('disposeAd'), hasLength(2));
      service.showInterstitialAd();
      expect(requests('showAdWithoutView'), isEmpty);
      expect(requests('loadInterstitialAd'), hasLength(2));
    },
  );

  test(
    'reward only comes from earned event and cannot be granted twice',
    () async {
      await service.init();
      loadedRewarded();
      loadedInterstitial();
      final ad = rewarded();
      var rewards = 0;
      var completions = 0;
      service.showRewardedAd(
        onUserEarnedReward: (_) => rewards++,
        onComplete: () => completions++,
      );
      service.showInterstitialAd();
      expect(rewards, 0);
      expect(completions, 0);
      expect(requests('showAdWithoutView'), hasLength(1));
      ad.onUserEarnedRewardCallback!(ad, RewardItem(5, 'coins'));
      ad.onUserEarnedRewardCallback!(ad, RewardItem(5, 'coins'));
      ad.fullScreenContentCallback!.onAdDismissedFullScreenContent!(ad);
      await flush();
      expect(rewards, 1);
      expect(completions, 1);
      expect(requests('loadRewardedAd'), hasLength(2));
    },
  );

  test('missing rewarded ad never grants a reward', () async {
    await service.init();
    var rewards = 0;
    var completions = 0;
    service.showRewardedAd(
      onUserEarnedReward: (_) => rewards++,
      onComplete: () => completions++,
    );
    expect(rewards, 0);
    expect(completions, 1);
    expect(requests('showAdWithoutView'), isEmpty);
  });

  testWidgets('banner stays hidden until loaded, displays, then disposes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TaskyBannerAdWidget())),
    );
    expect(find.byType(AdWidget), findsNothing);
    final ad = instanceManager.adFor(idFor('loadBannerAd'))! as BannerAd;
    ad.listener.onAdLoaded!(ad);
    await tester.pump();
    expect(find.byType(AdWidget), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(requests('disposeAd'), hasLength(1));
  });

  testWidgets(
    'banner no-fill retries after 30 seconds and cancels on removal',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TaskyBannerAdWidget())),
      );
      final ad = instanceManager.adFor(idFor('loadBannerAd'))! as BannerAd;
      ad.listener.onAdFailedToLoad!(
        ad,
        LoadAdError(3, 'test', 'no fill', null),
      );
      await tester.pump();
      expect(find.byType(AdWidget), findsNothing);
      await tester.pump(const Duration(seconds: 29));
      expect(requests('loadBannerAd'), hasLength(1));
      await tester.pump(const Duration(seconds: 1));
      expect(requests('loadBannerAd'), hasLength(2));
      final next = instanceManager.adFor(idFor('loadBannerAd'))! as BannerAd;
      next.listener.onAdFailedToLoad!(
        next,
        LoadAdError(3, 'test', 'no fill', null),
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 31));
      expect(requests('loadBannerAd'), hasLength(2));
      // A late native callback must not rebuild a disposed widget.
      next.listener.onAdLoaded!(next);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('banner native load exception is handled and retried', (
    tester,
  ) async {
    failMethod = 'loadBannerAd';
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TaskyBannerAdWidget())),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(AdWidget), findsNothing);
    failMethod = null;
    await tester.pump(const Duration(seconds: 30));
    expect(requests('loadBannerAd'), hasLength(2));
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'banner reloads on mode and size changes and ignores stale callbacks',
    (tester) async {
      final singleton = AdService();
      final original = singleton.isTestMode;
      singleton.toggleTestMode(true);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TaskyBannerAdWidget())),
      );
      final old = instanceManager.adFor(idFor('loadBannerAd'))! as BannerAd;
      singleton.toggleTestMode(false);
      await tester.pump();
      expect(requests('loadBannerAd'), hasLength(2));
      expect(
        (requests('loadBannerAd').last.arguments as Map)['adUnitId'],
        singleton.prodAndroidBannerId,
      );
      old.listener.onAdLoaded!(old);
      await tester.pump();
      expect(find.byType(AdWidget), findsNothing);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TaskyBannerAdWidget(adSize: AdSize.largeBanner)),
        ),
      );
      expect(requests('loadBannerAd'), hasLength(3));
      expect(
        (requests('loadBannerAd').last.arguments as Map)['size'],
        AdSize.largeBanner,
      );
      await tester.pumpWidget(const SizedBox());
      singleton.toggleTestMode(original);
    },
  );
}
