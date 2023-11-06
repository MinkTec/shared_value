import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'shared_value_platform_interface.dart';

/// An implementation of [SharedValuePlatform] that uses method channels.
class MethodChannelSharedValue extends SharedValuePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('shared_value');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
