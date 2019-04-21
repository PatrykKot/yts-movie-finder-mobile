import 'package:flutter/services.dart';

Future<bool> isVpnEnabled() async {
  return await const MethodChannel('vpn').invokeMethod("");
}