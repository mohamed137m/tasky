import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tasky/core/services/ad_service.dart';

class TaskyBannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsetsGeometry? margin;

  const TaskyBannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.margin,
  });

  @override
  State<TaskyBannerAdWidget> createState() => _TaskyBannerAdWidgetState();
}

class _TaskyBannerAdWidgetState extends State<TaskyBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    AdService().configurationChanges.addListener(_reloadBanner);
    _loadBanner();
  }

  void _loadBanner() {
    final service = AdService();
    if (!mounted || !service.isSupported || service.bannerAdUnitId.isEmpty) {
      return;
    }
    final banner = BannerAd(
      adUnitId: service.bannerAdUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted || !identical(ad, _bannerAd)) return;
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          _handleFailure(ad);
        },
      ),
    );
    _bannerAd = banner;
    unawaited(
      banner.load().catchError((Object error) {
        debugPrint('Banner request failed: $error');
        _handleFailure(banner);
      }),
    );
  }

  void _handleFailure(Ad ad) {
    if (!mounted || !identical(ad, _bannerAd)) return;
    unawaited(ad.dispose());
    setState(() {
      _bannerAd = null;
      _isLoaded = false;
    });
    // Bounded request frequency; never retry in a tight no-fill loop.
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 30), _loadBanner);
  }

  void _reloadBanner() {
    _retryTimer?.cancel();
    unawaited(_bannerAd?.dispose());
    _bannerAd = null;
    _isLoaded = false;
    if (mounted) setState(() {});
    _loadBanner();
  }

  @override
  void didUpdateWidget(covariant TaskyBannerAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adSize != widget.adSize) _reloadBanner();
  }

  @override
  void dispose() {
    AdService().configurationChanges.removeListener(_reloadBanner);
    _retryTimer?.cancel();
    unawaited(_bannerAd?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1C1C1E) : const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xff2C2C2E) : const Color(0xffE2E8F0),
          width: 0.8,
        ),
      ),
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble() + 8,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
