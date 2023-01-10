import 'package:veilid/base64url_no_pad.dart';

bool isValidDHTKey(String key) {
  if (key.length != 43) {
    return false;
  }
  try {
    var dec = base64UrlNoPadDecode(key);
    if (dec.length != 32) {
      return false;
    }
  } catch (e) {
    return false;
  }
  return true;
}
