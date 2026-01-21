import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  static String formatDisplayDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return isoString;
    }
  }

  static String formatDisplayDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
    } catch (e) {
      return isoString;
    }
  }

  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static int calculateDaysBetween(String startDate, String endDate) {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      return end.difference(start).inDays;
    } catch (e) {
      return 0;
    }
  }
}

