#ifndef FLUTTER_PLUGIN_SHARED_VALUE_PLUGIN_H_
#define FLUTTER_PLUGIN_SHARED_VALUE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace shared_value {

class SharedValuePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  SharedValuePlugin();

  virtual ~SharedValuePlugin();

  // Disallow copy and assign.
  SharedValuePlugin(const SharedValuePlugin&) = delete;
  SharedValuePlugin& operator=(const SharedValuePlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace shared_value

#endif  // FLUTTER_PLUGIN_SHARED_VALUE_PLUGIN_H_
