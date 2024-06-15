import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

class UniqueDeviceId {
  static Future<String> getDeviceUuid() async {
    var deviceInfo = DeviceInfoPlugin();
    String deviceIdentifier;

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceIdentifier = androidInfo.id ?? ''; // 使用 Android 设备的唯一标识符
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceIdentifier = iosInfo.identifierForVendor ?? ''; // 使用 iOS 设备的唯一标识符
      } else {
        throw UnsupportedError("该平台不受支持");
      }

      var uuid = Uuid();
      return uuid.v5(Uuid.NAMESPACE_URL, deviceIdentifier);
    } catch (e) {
      // 处理异常情况，例如在不支持的设备或模拟器上运行时
      return 'Error: $e';
    }
  }
}
