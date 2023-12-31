import 'package:shared_preferences/shared_preferences.dart';

typedef Serializer<T> = ({
  String Function(T val) serialize,
  T Function(String val) deserialize
});

class SharedValue<T> {
  static late SharedPreferences _prefs;
  final String key;

  /// is called before the value is set in SharedPreferences
  /// any failure in onSet will cause the value not to be stored
  final void Function(String key, T value)? onSet;

  final void Function(String key, T? value)? onGet;

  SharedValue({required this.key, T? initialValue, this.onSet, this.onGet}) {
    if (initialValue != null) {
      setIfUnset(initialValue);
    }
  }

  static Future<void> init() async =>
      setPrefs(await SharedPreferences.getInstance());

  static setPrefs(SharedPreferences prefs) => _prefs = prefs;

  bool get isSet => _prefs.containsKey(key);

  T? get() {
    final value = _prefs.get(key) as T?;
    onGet?.call(key, value);
    return value;
  }

  void set(T value) {
    _prefs.set(key, value);
    onSet?.call(key, value);
  }

  void setIfUnset(T val) {
    if (!isSet) set(val);
  }

  void deleteKey() => _prefs.remove(key);
}

class SerdeSharedValue<T> extends SharedValue<T> {
  final Serializer<T> _serializer;

  SerdeSharedValue(
      {required super.key,
      T? initialValue,
      required Serializer<T> serializer,
      super.onSet,
      super.onGet})
      : _serializer = serializer {
    if (initialValue != null) {
      setIfUnset(initialValue);
    }
  }

  @override
  T? get() {
    final maybeString = SharedValue._prefs.get(key) as String?;
    final value =
        (maybeString != null) ? _serializer.deserialize(maybeString) : null;
    onGet?.call(key, value);
    return value;
  }

  @override
  set(T value) {
    onSet?.call(key, value);
    SharedValue._prefs.set(key, _serializer.serialize(value));
  }
}

typedef _StringList = List<String>;

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

class InvalidSharedPreferencesType implements Exception {
  Type type;

  InvalidSharedPreferencesType(this.type);

  @override
  String toString() {
    return "InvalidSharedPreferencesType: $type";
  }
}
