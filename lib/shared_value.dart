import 'package:shared_preferences/shared_preferences.dart';

typedef Serializer<T> = ({
  String Function(T val) serialize,
  T Function(String val) deserialize
});

typedef OnSet<T> = void Function(String key, T value);

class SharedValue<T> {
  static late SharedPreferences _prefs;
  final String key;

  /// is called after the value is set in SharedPreferences
  final List<OnSet<T>> _listeners;

  SharedValue({required this.key, T? initialValue, OnSet<T>? onSet})
      : _listeners = onSet != null ? [onSet] : [] {
    if (initialValue != null) {
      setIfUnset(initialValue);
    }
  }

  /// is called when a value is set
  void addListener(OnSet<T> listener) {
    _listeners.add(listener);
  }

  static Future<void> init() async =>
      setPrefs(await SharedPreferences.getInstance());

  static setPrefs(SharedPreferences prefs) => _prefs = prefs;

  bool get isSet => _prefs.containsKey(key);

  T? get() => _prefs.get(key) as T?;

  void set(T value) {
    _prefs.set(key, value);
    _listeners.forEach((f) => f(key, value));
  }

  void setIfUnset(T val) {
    if (!isSet) set(val);
  }

  void deleteKey() => _prefs.remove(key);
}

class SerdeSharedValue<T> extends SharedValue<T> {
  SerdeSharedValue({
    required super.key,
    T? initialValue,
    required Serializer<T> serializer,
    super.onSet,
  })  : parse = serializer.deserialize,
        serialize = serializer.serialize {
    if (initialValue != null) {
      setIfUnset(initialValue);
    }
  }

  T Function(String string) parse;
  String Function(T value) serialize;

  String? getString() => SharedValue._prefs.get(key) as String?;

  @override
  T? get() {
    final maybeString = SharedValue._prefs.get(key) as String?;
    return (maybeString != null) ? parse(maybeString) : null;
  }

  @override
  set(T value) {
    SharedValue._prefs.set(key, serialize(value));
    _listeners.forEach((f) => f(key, value));
  }
}

// is defined because List<String> cannot be used in switch-case
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
