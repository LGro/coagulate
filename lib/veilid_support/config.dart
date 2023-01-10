import 'package:veilid/veilid.dart';

Future<VeilidConfig> getVeilidChatConfig() async {
  VeilidConfig config = await getDefaultVeilidConfig("VeilidChat");
  return config;
}
