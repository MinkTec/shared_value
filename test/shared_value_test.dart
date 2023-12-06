import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_value/shared_value.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences.setMockInitialValues({});
  await SharedValue.setPrefs(await SharedPreferences.getInstance());

  final Serializer<DateTime> dateTimeSerde = (
    serialize: (DateTime x) => x.toIso8601String(),
    deserialize: (String x) => DateTime.parse(x)
  );

  group("basic", () {
    final testVal = Random().nextInt(100000);

    final SharedValue<int> s1 =
        SharedValue(key: "test key 1", initialValue: testVal);
    final SharedValue<int?> s2 = SharedValue(key: "k2", initialValue: null);

    final SharedValue<int> s3 =
        SharedValue(key: "test key 1", initialValue: -testVal);

    final now = DateTime.now();

    final SerdeSharedValue<DateTime> s4 = SerdeSharedValue(
      key: "dt2",
      initialValue: now,
      serializer: dateTimeSerde,
    );

    final SerdeSharedValue<DateTime> s6 = SerdeSharedValue(
      key: "dt3",
      serializer: dateTimeSerde,
    );

    final SharedValue<String?> s5 = SharedValue(key: "k2");

    s1.set(testVal);

    test("retrival <int>", () => expect(s1.get(), testVal));

    test("no double initial value <int>", () => expect(s3.get(), testVal));

    test("retrival <int?>", () => expect(s2.get(), null));

    test("retrival <DateTime>", () => expect(s4.get(), now));

    test("unset retrival <DateTime>", () {
      expect(s6.get(), null);
      s6.set(now);
      expect(s6.get(), now);
    });

    test("get / set String?", () {
      expect(s5.get(), null);

      const val = "ok";
      s5.set(val);
      expect(s5.get(), val);
      s5.set(null);
      expect(s5.get(), null);
    });
  });

  group("observability", () {
    dynamic valSet = 0;
    dynamic valGet = 0;

    final val = SharedValue<int>(
        key: "test int",
        initialValue: 34,
        onSet: (val) => valSet = val,
        onGet: (val) => valGet = val);

    int i = 10;

    test("onSet", () {
      val.set(i);
      expect(valSet, i);
    });

    test("onGet", () {
      val.get();
      expect(valGet, i);
    });

    final now = DateTime.now();

    final serdeVal = SerdeSharedValue<DateTime>(
        key: "test datetime",
        serializer: dateTimeSerde,
        onSet: (val) => valSet = val,
        onGet: (val) => valGet = val);

    test("onSetSerde", () {
      serdeVal.set(now);
      expect(valSet, now);
    });

    test("onGet serde", () {
      serdeVal.get();
      expect(valGet, now);
    });
  });
}
