import 'dart:developer';

import 'package:get/get.dart';
import 'package:yummy/core/services/shared_prefrences.dart';

class AuthService extends GetxService {
  static Future<bool> isUserLoggedIn() async {
    try {
      String? accessToken = await SecureStorageService().getValue(key: "token");
      String? issuedAtStr = await SecureStorageService().getValue(
        key: "token_issued_at",
      );
      String? isVerified = await SecureStorageService().getValue(
        key: "isVerified",
      );

      if (isVerified != 'true') {
        return false;
      }

      if (accessToken == null || issuedAtStr == null) {
        return false;
      }

      DateTime issuedAt = DateTime.parse(issuedAtStr);

      DateTime clientExpiry = issuedAt.add(Duration(days: 2, hours: 6));

      Duration remainingTime = clientExpiry.difference(DateTime.now());

      if (remainingTime.isNegative) {
        return false;
      }

      log(
        'Token will expire in: '
        '${remainingTime.inDays} days, '
        '${remainingTime.inHours % 24} hours, '
        '${remainingTime.inMinutes % 60} minutes',
      );

      return true;
    } catch (e) {
      log('Error checking token: $e');
      return false;
    }
  }
}
