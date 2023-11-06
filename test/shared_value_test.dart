import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_value/shared_value.dart';
import 'package:shared_value/shared_value_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSharedValuePlatform
    with MockPlatformInterfaceMixin
    implements SharedValuePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences.setMockInitialValues({});
  await SharedValue.setPrefs(await SharedPreferences.getInstance());
  group("basic", () {
    final testVal = Random().nextInt(100000);

    final SharedValue<int> s1 =
        SharedValue(key: "test key 1", initialValue: testVal);
    final SharedValue<int?> s2 = SharedValue(key: "k2", initialValue: null);


    final SharedValue<int> s3 =
        SharedValue(key: "test key 1", initialValue: - testVal);

    final now = DateTime.now();

    final SerdeSharedValue<DateTime> s4 = SerdeSharedValue(
      key: "dt2",
      initialValue: now,
      serializer: (
        serialize: (DateTime x) => x.toIso8601String(),
        deserialize: (String x) => DateTime.parse(x)
      ),
    );

    s1.value = testVal;

    test("retrival <int>", () {
      expect(s1.value, testVal);
    });

    test("no double initial value <int>", () {
      expect(s3.value, testVal);
    });

    test("retrival <int?>", () {
      expect(s2.value, null);
    });

    test("retrival <DateTime>", () {
      expect(s4.value, now);
    });
  });
}
