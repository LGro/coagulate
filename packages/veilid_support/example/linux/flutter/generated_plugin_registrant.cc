//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <veilid/veilid_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) veilid_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "VeilidPlugin");
  veilid_plugin_register_with_registrar(veilid_registrar);
}
