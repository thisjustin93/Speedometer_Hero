import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9904898746688996/8573262650';
    } else {
      return 'ca-app-pub-9904898746688996/8573262650';
    }
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) {
      debugPrint('Ad Loaded');
    },
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint('Ad failed to load: $error');
    },
    onAdOpened: (ad) {
      debugPrint('Ad opened');
    },
    onAdClosed: (ad) {
      debugPrint('Ad closed');
    },
  );
  static String? get instertitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else {
      return 'ca-app-pub-9904898746688996/8573262650';
    }
  }
}
