//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <shared_value/shared_value_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) shared_value_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SharedValuePlugin");
  shared_value_plugin_register_with_registrar(shared_value_registrar);
}
