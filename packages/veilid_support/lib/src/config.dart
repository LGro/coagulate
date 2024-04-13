import 'dart:io' show Platform;

import 'package:veilid/veilid.dart';

Map<String, dynamic> getDefaultVeilidPlatformConfig(
    bool isWeb, String appName) {
  final ignoreLogTargetsStr =
      // ignore: do_not_use_environment
      const String.fromEnvironment('IGNORE_LOG_TARGETS').trim();
  final ignoreLogTargets = ignoreLogTargetsStr.isEmpty
      ? <String>[]
      : ignoreLogTargetsStr.split(',').map((e) => e.trim()).toList();

  if (isWeb) {
    return VeilidWASMConfig(
            logging: VeilidWASMConfigLogging(
                performance: VeilidWASMConfigLoggingPerformance(
                    enabled: true,
                    level: VeilidConfigLogLevel.debug,
                    logsInTimings: true,
                    logsInConsole: false,
                    ignoreLogTargets: ignoreLogTargets),
                api: VeilidWASMConfigLoggingApi(
                    enabled: true,
                    level: VeilidConfigLogLevel.info,
                    ignoreLogTargets: ignoreLogTargets)))
        .toJson();
  }
  return VeilidFFIConfig(
          logging: VeilidFFIConfigLogging(
              terminal: VeilidFFIConfigLoggingTerminal(
                  enabled: false,
                  level: VeilidConfigLogLevel.debug,
                  ignoreLogTargets: ignoreLogTargets),
              otlp: VeilidFFIConfigLoggingOtlp(
                  enabled: false,
                  level: VeilidConfigLogLevel.trace,
                  grpcEndpoint: '127.0.0.1:4317',
                  serviceName: appName,
                  ignoreLogTargets: ignoreLogTargets),
              api: VeilidFFIConfigLoggingApi(
                  enabled: true,
                  level: VeilidConfigLogLevel.info,
                  ignoreLogTargets: ignoreLogTargets)))
      .toJson();
}

Future<VeilidConfig> getVeilidConfig(bool isWeb, String programName) async {
  var config = await getDefaultVeilidConfig(
    isWeb: isWeb,
    programName: programName,
    // ignore: avoid_redundant_argument_values, do_not_use_environment
    namespace: const String.fromEnvironment('NAMESPACE'),
    // ignore: avoid_redundant_argument_values, do_not_use_environment
    bootstrap: const String.fromEnvironment('BOOTSTRAP'),
    // ignore: avoid_redundant_argument_values, do_not_use_environment
    networkKeyPassword: const String.fromEnvironment('NETWORK_KEY'),
  );

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

  // ignore: do_not_use_environment
  const envNetwork = String.fromEnvironment('NETWORK');
  if (envNetwork.isNotEmpty) {
    final bootstrap = isWeb
        ? ['ws://bootstrap.$envNetwork.veilid.net:5150/ws']
        : ['bootstrap.$envNetwork.veilid.net'];
    config = config.copyWith(
        network: config.network.copyWith(
            routingTable:
                config.network.routingTable.copyWith(bootstrap: bootstrap)));
  }

  return config.copyWith(
    capabilities:
        // XXX: Remove DHTV and DHTW when we get background sync implemented
        const VeilidConfigCapabilities(disable: ['DHTV', 'DHTW', 'TUNL']),
    protectedStore:
        // XXX: Linux often does not have a secret storage mechanism installed
        config.protectedStore.copyWith(allowInsecureFallback: Platform.isLinux),
  );
}
