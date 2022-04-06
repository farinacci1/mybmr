import 'dart:math';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mybmr/services/PlatformManager.dart';


class AdService {
  static final AdRequest request = AdRequest(
    keywords: <String>[
      'Culinary',
      'Cuisine',
      "Food",
      "Nutrition",
      "Diets",
      "Meals",
      "MealPlan",
      "game",
      "app",
      "family",
      "friends",
      "gym",
      "hydrate"
    ],
    nonPersonalizedAds: true,
  );
  static InterstitialAd _interstitialAd;

  static int maxFailedLoadAttempts = 3;
  static int _numInterstitialLoadAttempts = 0;

  static String _getAdUnitId({bool isBanner = false, bool isInterstitial = false, bool isNative = false}){

    //ensure that only one condition is true
    if(isBanner && (isInterstitial || isNative)) return "";
    if(isInterstitial && (isBanner || isNative)) return "";
    if(isNative && (isInterstitial || isBanner)) return "";
    if(isNative == false && isInterstitial == false && isBanner == false) return "";

    PlatformType platformType = PlatformManager.getPlatformType();
    if(platformType == PlatformType.IOS){
      if(isBanner) return "ca-app-pub-2220368850686181/3014159115";
      if(isInterstitial) return "ca-app-pub-2220368850686181/9674936235";
      if(isNative) return "ca-app-pub-2220368850686181/5077215670";

    }else if(platformType == PlatformType.ANDROID){
      if(isBanner) return "ca-app-pub-2220368850686181/1848578806";
      if(isInterstitial) return "ca-app-pub-2220368850686181/3057525173";
      if(isNative) return "ca-app-pub-2220368850686181/1840839942";
    }
    return "";
  }


  static bool shouldShowAd({double adProbability = 0.15}) {
    double probabilityNotAd = 1.0 - adProbability;
    Random rand = Random();
    double probability = rand.nextDouble();
    if (probability >= probabilityNotAd) {
      return true;
    }
    return false;
  }

  static void createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: _getAdUnitId(isInterstitial: true),
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;

            _interstitialAd.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ));
  }

  static void showInterstitialAd(Function callback) {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd();
        callback();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd();
      },
    );
    _interstitialAd.show();
    _interstitialAd = null;
  }

  static BannerAd getBannerAD(int width) {
    BannerAd bAd = new BannerAd(
      size: AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(width),
      adUnitId:   _getAdUnitId(isBanner: true),
      request: request,
      listener: BannerAdListener(
          onAdClosed: (Ad ad) {
            print("ad closed");
          },
          onAdLoaded: (Ad ad) {},
          onAdOpened: (Ad ad) {},
          onAdFailedToLoad: (Ad ad, LoadAdError err) {
            ad.dispose();
            getBannerAD(width);
          }),
    );

    return bAd;
  }



}
