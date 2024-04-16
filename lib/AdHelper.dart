import 'dart:io';

class AdHelper {

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5365644610829153/7776105861';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5365644610829153/7776105861';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5365644610829153/7580664743';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5365644610829153/7580664743';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }


}