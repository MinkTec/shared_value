import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_value/shared_value.dart';

class MockSharedSerde with SharedSerde<int> {
  @override
  Serializer<int> get serializer => (
        serialize: (int x) => x.toString(),
        deserialize: (String x) => int.parse(x)
      );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await SharedValue.setPrefs(await SharedPreferences.getInstance());
  group("SharedSerde", () {
    final mockSharedSerde = MockSharedSerde();
    final key = "test key";
    final initialValue = 123;

    test("getSharedValue", () {
      final sharedValue =
          mockSharedSerde.getSharedValue(key: key, initialValue: initialValue);
      expect(sharedValue, isA<SerdeSharedValue<int>>());
      expect(sharedValue.get(), initialValue);
    });
  });
}
