import 'package:veilid/veilid.dart';

Future<VeilidConfig> getVeilidChatConfig() async {
  var config = await getDefaultVeilidConfig('VeilidChat');
  // ignore: do_not_use_environment
  if (const String.fromEnvironment('DELETE_TABLE_STORE') == '1') {
    config =
        config.copyWith(tableStore: config.tableStore.copyWith(delete: true));
  }
  // ignore: do_not_use_environment
  if (const String.fromEnvironment('DELETE_PROTECTED_STORE') == '1') {
    config = config.copyWith(
        protectedStore: config.protectedStore.copyWith(delete: true));
  }
  // ignore: do_not_use_environment
  if (const String.fromEnvironment('DELETE_BLOCK_STORE') == '1') {
    config =
        config.copyWith(blockStore: config.blockStore.copyWith(delete: true));
  }

  return config.copyWith(
    capabilities: const VeilidConfigCapabilities(disable: ['DHTV', 'TUNL']),
    protectedStore: config.protectedStore.copyWith(allowInsecureFallback: true),
    // network: config.network.copyWith(
    //         dht: config.network.dht.copyWith(
    //             getValueCount: 3,
    //             getValueFanout: 8,
    //             getValueTimeoutMs: 5000,
    //             setValueCount: 4,
    //             setValueFanout: 10,
    //             setValueTimeoutMs: 5000))
  );
}
