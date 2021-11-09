import 'dart:io' show Platform;

class PlatformSpecific {
  bool get isAndroid {
    return Platform.isAndroid;
  }

  bool get isIOS {
    return Platform.isIOS;
  }

  String get operatingSystem {
    return Platform.operatingSystem;
  }
}
