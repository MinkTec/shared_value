import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_value/shared_value.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await SharedValue.init();
  });

  group('CachedSharedValue', () {
    test('caches value after first getCached and stays until set is called', () async {
      const key = 'cached_int_key';
      final cached = CachedSharedValue<int>(key: key);

      // Before any set, cached is null and get() is null
      expect(cached.getCached(), isNull);
      expect(cached.get(), isNull);

      // Set a value via cached instance
      cached.set(42);
      expect(cached.getCached(), 42);
      expect(cached.get(), 42);

      // Change underlying storage via a separate SharedValue instance
      final other = SharedValue<int>(key: key);
      other.set(100);

      // Cached value remains the same until cached.set is called
      expect(cached.getCached(), 42);
      // But direct get() reflects the new persisted value
      expect(cached.get(), 100);

      // Updating via cached updates both cached and storage
      cached.set(7);
      expect(cached.getCached(), 7);
      expect(cached.get(), 7);
    });

    test('onSet listener is invoked with updated values', () async {
      const key = 'cached_int_listener_key';
      int? observed;
      final cached = CachedSharedValue<int>(
        key: key,
      )..addListener((k, v) => observed = v);

      cached.set(5);
      expect(observed, 5);
      cached.set(9);
      expect(observed, 9);
    });
  });

  group('CachedSerdeSharedValue', () {
    ({String Function(DateTime) serialize, DateTime Function(String) deserialize}) _dtSerde() => (
          serialize: (dt) => dt.toIso8601String(),
          deserialize: (s) => DateTime.parse(s),
        );

    test('initialValue is persisted once and read back', () async {
      const key = 'cached_serde_dt_key';
      final initial = DateTime(2020, 1, 2, 3, 4, 5);
      final cached = CachedSerdeSharedValue<DateTime>(
        key: key,
        initialValue: initial,
        serializer: _dtSerde(),
      );

      // First cached read triggers init from storage
      final c1 = cached.getCached();
      expect(c1, initial);
      // Direct get() also returns the stored value
      expect(cached.get(), initial);

      // Underlying storage changed by a different serde value
      final other = SerdeSharedValue<DateTime>(
        key: key,
        serializer: _dtSerde(),
      );
      final updated = DateTime(2021, 6, 7, 8, 9, 10);
      other.set(updated);

      // Cached remains the same until updated through cached.set
      expect(cached.getCached(), initial);
      // But get() reflects the latest persisted value
      expect(cached.get(), updated);

      // Update via cached
      final newer = DateTime(2022, 12, 31, 23, 59, 58);
      cached.set(newer);
      expect(cached.getCached(), newer);
      expect(cached.get(), newer);
    });

    test('onSet listener receives deserialized values', () async {
      const key = 'cached_serde_listener_key';
      DateTime? observed;
      final cached = CachedSerdeSharedValue<DateTime>(
        key: key,
        serializer: (
          serialize: (dt) => dt.toIso8601String(),
          deserialize: (s) => DateTime.parse(s),
        ),
      )..addListener((k, v) => observed = v);

      final val = DateTime(2030, 5, 6, 7, 8, 9);
      cached.set(val);
      expect(observed, val);
    });
  });
}
