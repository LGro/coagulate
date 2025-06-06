import 'dart:io' show Platform;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:veilid/veilid.dart';

// Allowed to pull sentinel value
// ignore: do_not_use_environment
const bool kIsReleaseMode = bool.fromEnvironment('dart.vm.product');
// Allowed to pull sentinel value
// ignore: do_not_use_environment
const bool kIsProfileMode = bool.fromEnvironment('dart.vm.profile');
const bool kIsDebugMode = !kIsReleaseMode && !kIsProfileMode;

Future<Map<String, dynamic>> getDefaultVeilidPlatformConfig(
    bool isWeb, String appName) async {
  final ignoreLogTargetsStr =
      // Allowed to change settings
      // ignore: do_not_use_environment
      const String.fromEnvironment('IGNORE_LOG_TARGETS').trim();
  final ignoreLogTargets = ignoreLogTargetsStr.isEmpty
      ? <String>[]
      : ignoreLogTargetsStr.split(',').map((e) => e.trim()).toList();

  // Allowed to change settings
  // ignore: do_not_use_environment
  var flamePathStr = const String.fromEnvironment('FLAME').trim();
  if (flamePathStr == '1') {
    flamePathStr = p.join(
        (await getApplicationSupportDirectory()).absolute.path,
        '$appName.folded');
    // Allowed for debugging
    // ignore: avoid_print
    print('Flame data logged to $flamePathStr');
  }

  if (isWeb) {
    return VeilidWASMConfig(
            logging: VeilidWASMConfigLogging(
                performance: VeilidWASMConfigLoggingPerformance(
                    enabled: true,
                    level: kIsDebugMode
                        ? VeilidConfigLogLevel.debug
                        : VeilidConfigLogLevel.info,
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
                  level: kIsDebugMode
                      ? VeilidConfigLogLevel.debug
                      : VeilidConfigLogLevel.info,
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
                  ignoreLogTargets: ignoreLogTargets),
              flame: VeilidFFIConfigLoggingFlame(
                  enabled: flamePathStr.isNotEmpty, path: flamePathStr)))
      .toJson();
}

Future<VeilidConfig> getVeilidConfig(bool isWeb, String programName) async {
  var config = await getDefaultVeilidConfig(
    isWeb: isWeb,
    programName: programName,
    // Allowed to change settings
    // ignore: avoid_redundant_argument_values, do_not_use_environment
    namespace: const String.fromEnvironment('NAMESPACE'),
    // Allowed to change settings
    // ignore: avoid_redundant_argument_values, do_not_use_environment
    bootstrap: const String.fromEnvironment('BOOTSTRAP'),
    // Allowed to change settings
    // ignore: avoid_redundant_argument_values, do_not_use_environment
    networkKeyPassword: const String.fromEnvironment('NETWORK_KEY'),
  );

  // Allowed to change settings
  // ignore: do_not_use_environment
  if (const String.fromEnvironment('DELETE_TABLE_STORE') == '1') {
    config =
        config.copyWith(tableStore: config.tableStore.copyWith(delete: true));
  }
  // Allowed to change settings
  // ignore: do_not_use_environment
  if (const String.fromEnvironment('DELETE_PROTECTED_STORE') == '1') {
    config = config.copyWith(
        protectedStore: config.protectedStore.copyWith(delete: true));
  }
  // Allowed to change settings
  // ignore: do_not_use_environment
  if (const String.fromEnvironment('DELETE_BLOCK_STORE') == '1') {
    config =
        config.copyWith(blockStore: config.blockStore.copyWith(delete: true));
  }

  // Allowed to change settings
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
        // XXX: Remove DHTV and DHTW after DHT widening (and maybe remote
        // rehydration?)
        const VeilidConfigCapabilities(disable: ['DHTV', 'DHTW', 'TUNL']),
    protectedStore:
        // XXX: Linux often does not have a secret storage mechanism installed
        config.protectedStore
            .copyWith(allowInsecureFallback: !isWeb && Platform.isLinux),
  );
}
