#include "include/shared_value/shared_value_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "shared_value_plugin.h"

void SharedValuePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  shared_value::SharedValuePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
