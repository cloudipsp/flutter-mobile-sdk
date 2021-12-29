import 'dart:io' show Platform;

class PlatformSpecific {
  bool get isAndroid {
    return Platform.isAndroid;
  }

  bool get isIOS {
    return Platform.isIOS;
  }

  String getOperatingSystem() {
    return Platform.operatingSystem;
  }

  String get operatingSystem {
    return Platform.operatingSystem;
  }
}
