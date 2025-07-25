// lib/utils/date_formatter.dart
class DateFormatter {
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateRange(DateTime inicio, DateTime fim) {
    return '${formatDate(inicio)} - ${formatDate(fim)}';
  }

  static int calculateDays(DateTime inicio, DateTime fim) {
    return fim.difference(inicio).inDays + 1;
  }
}
