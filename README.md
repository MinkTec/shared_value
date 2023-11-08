# shared_value

A simple [shared_preferences](https://pub.dev/packages/shared_preferences) wrapper.

## Usage

### Initialize
The SharedValue class has a static references to a
SharedPreferences instance.

Initialize using the init function:

```dart
await SharedValue.init();
```
or use an existing instance of SharedPreferences:
```dart
final prefs = await SharedPreferences.getInstance();
await SharedValue.setPrefs(prefs);
```

### Create Values

There are two main classes.
SharedValue can be used to stare all data types SharedPreferences
itself supports and their nullable counterparts.

To store other data types, the SerdeSharedValue class can be used.

```dart
final sharedValue = SharedValue<int>(key: "unique value key", initialValue: 349);


final serdeSharedValue = SerdeSharedValue<DateTime>(
    key: "another unique key",
    initialValue: DateTime.now(),
    serializer: (
      serialize: (val) => val.toString(),
      deserialize: DateTime.parse
    ));
```

The "initialValue‘ will be set only if the key is not present in
the SharedPreferences instance.

### Access and update values

Values can be accessed through the `get` and `set` methods.
```dart

sharedValue.get(); // = 349

sharedValue.set(0);

sharedValue.get(); // = 0
```

If the value was not set before  `null` will be returned.

