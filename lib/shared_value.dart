import 'package:shared_preferences/shared_preferences.dart';

typedef Serializer<T> = ({
  String Function(T val) serialize,
  T Function(String val) deserialize
});

class SharedValue<T> {
  static late SharedPreferences _prefs;
  final String key;

  SharedValue(
      {required this.key, T? initialValue, SharedPreferences? preferences}) {
    if (initialValue != null) {
      setIfUnset(initialValue);
    }
  }

  static Future<void> init() async =>
      setPrefs(await SharedPreferences.getInstance());

  static setPrefs(SharedPreferences prefs) => _prefs = prefs;

  T? get value => _prefs.containsKey(key) ? _prefs.get(key) as T : null;

  set value(T? value) {
    _prefs.set(key, value as T);
  }

  setIfUnset(T val) {
    if (!_prefs.containsKey(key)) {
      value = val;
    }
  }
}

class SerdeSharedValue<T> extends SharedValue<T> {
  final Serializer<T> _serializer;

  SerdeSharedValue({
    required super.key,
    T? initialValue,
    required Serializer<T> serializer,
  }) : _serializer = serializer {
    if (initialValue != null) {
      setIfUnset(initialValue);
    }
  }

  @override
  T? get value =>
      _serializer.deserialize(SharedValue._prefs.get(key) as String);

  @override
  set value(T? val) {
    if (val != null) {
      SharedValue._prefs.set(key, _serializer.serialize(val));
    } else {
      super.value = null;
    }
  }
}

typedef _StringList = List<String>;

class InvalidSharedPreferencesType implements Exception {
  Type type;
  InvalidSharedPreferencesType(this.type);
  @override
  String toString() {
    return "InvalidSharedPreferencesType: $type";
  }
}

extension _GetSetFunction on SharedPreferences {
  void set<T>(String key, T value) {
    if (null is T && value == null) {
      remove(key);
    } else {
      switch (value.runtimeType) {
        case bool:
          setBool(key, value as bool);
        case int:
          setInt(key, value as int);
        case double:
          setDouble(key, value as double);
        case String:
          setString(key, value as String);
        case _StringList:
          setStringList(key, value as List<String>);
        default:
          throw InvalidSharedPreferencesType(T);
      }
    }
  }
}
