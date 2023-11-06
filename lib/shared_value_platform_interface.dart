import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'shared_value_method_channel.dart';

abstract class SharedValuePlatform extends PlatformInterface {
  /// Constructs a SharedValuePlatform.
  SharedValuePlatform() : super(token: _token);

  static final Object _token = Object();

  static SharedValuePlatform _instance = MethodChannelSharedValue();

  /// The default instance of [SharedValuePlatform] to use.
  ///
  /// Defaults to [MethodChannelSharedValue].
  static SharedValuePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SharedValuePlatform] when
  /// they register themselves.
  static set instance(SharedValuePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
