import 'package:flutter/material.dart';
import 'package:flutter_native_ad/flutter_native_ad.dart';
import 'ad_config.dart';

class AdsHelper {

  static var adOpenAd = FlutterAdOpenAd();
  static bool isAppOpenAdAdReady = false;

  static loadOpenAd() async{
    await adOpenAd.loadAppOpenAd(adUnitId: AdConfig.openAdId,onAdLoaded:(ad) {
      adOpenAd.appOpenAd = ad;
      isAppOpenAdAdReady = true;
      showOpenAd();
    }, onAdFailedToLoad:   (error) {
      isAppOpenAdAdReady = false;
      print('AppOpenAd failed to load: $error');
    });
  }

  static showOpenAd() async{
    isAppOpenAdAdReady ? await adOpenAd.appOpenAd?.show() : null;
  }

  ValueNotifier bannerAdNotifier = ValueNotifier(null);

  loadBannerAd()async{
    bannerAdNotifier.value = null;
    var ad = FlutterBannerAd();
    await ad.loadBannerAd(
      adUnitId: AdConfig.bannerAdId,
      onAdLoaded: (_) {
        Future.delayed(Duration(milliseconds: 500),() {
          bannerAdNotifier.value = ad;
        },);
      },
      onAdFailedToLoad: (ad, err) {
        print('Failed to load a banner ad: ${err.message}');
        ad.dispose();
      },
    );
  }

  Widget showBannerAd(){
    return ValueListenableBuilder(
        valueListenable: bannerAdNotifier,
        builder: (context,value,child) {
          return (value is FlutterBannerAd) ? Container(
            width: value.bannerAd.size.width.toDouble(),
            height: value.bannerAd.size.height.toDouble(),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.fastLinearToSlowEaseIn,
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(top: 5),
                  width: double.infinity,
                  color: Colors.white,
                  child: Container(
                      width: value.bannerAd.size.width.toDouble(),
                      height: value.bannerAd.size.height.toDouble(),
                      child: value.getBannerAd()
                  ),
                )),
          ) : SizedBox.shrink();
        }
    );
  }

  static bool isInterstitialAdReady = false;
  static var interstitialAd;
  static int adCount = 1;
  static int maxAdCount = 7;

  static showInterstitialAd({bool ignoreCount = false})async{
    if(ignoreCount){
     isInterstitialAdReady ? await interstitialAd.interstitialAd?.show() : null;
     loadInterstitialAd(ignoreCount: ignoreCount);
    } else {
      adCount++;
      if(adCount >= maxAdCount){
        isInterstitialAdReady ? await interstitialAd.interstitialAd?.show() : null;
        adCount = 1;
        await loadInterstitialAd();
      }
    }
  }

  static loadInterstitialAd({bool ignoreCount = false}) async{
    interstitialAd = FlutterInterstitialAd();
    await interstitialAd.loadInterstitialAd(adUnitId:AdConfig.interstitialAdId,onAdLoaded: (ad) {
      interstitialAd.interstitialAd = ad;
      isInterstitialAdReady = true;
    }, onAdFailedToLoad: (err) {
      print('Failed to load an interstitial ad: ${err.message}');
      isInterstitialAdReady = false;
    },);
  }

  ValueNotifier nativeMediumAdNotifier = ValueNotifier(null);
  ValueNotifier<bool> isNativeMediumLoadedNotifier = ValueNotifier<bool>(false);

  loadMediumNativeAd()async{
    nativeMediumAdNotifier.value = null;
    isNativeMediumLoadedNotifier.value = false;
    var ad = FlutterNativeAd();
    await ad.loadmediumNativeAd(adUnitId: AdConfig.nativeAdId,onAdLoaded: (ad) {
      isNativeMediumLoadedNotifier.value = true;
    },onAdFailedToLoad:(ad, error) {
      isNativeMediumLoadedNotifier.value = false;
      ad.dispose();
      print('Ad load failed (code=${error.code} message=${error.message})');
    });
    Future.delayed(Duration(milliseconds: 500),() {
      nativeMediumAdNotifier.value = ad;
    },);
  }

  Widget showNativeMediumAd({double height = 255}){
    return ValueListenableBuilder(
        valueListenable: nativeMediumAdNotifier,
        builder: (context,value,child) {
          return (value is FlutterNativeAd) ? Builder(
              builder: (context) {
                return ValueListenableBuilder<bool>(
                  valueListenable: isNativeMediumLoadedNotifier,
                  builder: (context, val, child) {
                    return val == true ? Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                            duration: Duration(seconds: 1),
                            curve: Curves.fastLinearToSlowEaseIn,
                            alignment: Alignment.bottomCenter,
                            padding: EdgeInsets.only(top: 5),
                            width: double.infinity,
                            color: Colors.white,
                            child: SizedBox(
                              height: height,
                              child: value.getMediumNativeAD(),
                            )
                        )) : Container(height: height,child: Container());
                  },);
              }
          ) : SizedBox.shrink();
        }
    );
  }

  static loadAndShowInterstitialPremium(BuildContext context, {VoidCallback? onDone})async{
    // Utils.showLoading();
    interstitialAd = FlutterInterstitialAd();
    await interstitialAd.loadInterstitialAd(adUnitId:AdConfig.interstitialAdId,onAdLoaded: (ad) async {
      interstitialAd.interstitialAd = ad;
      // Utils.closeLoading();
      await ad.show();
      onDone?.call();
    }, onAdFailedToLoad: (err) {
      // Utils.closeLoading();
    },);
  }

}