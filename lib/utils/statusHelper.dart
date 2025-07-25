// lib/utils/status_helper.dart
import 'package:flutter/material.dart';

class StatusHelper {
  static Color getStatusColor(String status) {
    switch (status) {
      case 'Confirmado':
        return Colors.green;
      case 'Pendente':
        return Colors.orange;
      case 'Cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'Confirmado':
        return Icons.check_circle;
      case 'Pendente':
        return Icons.schedule;
      case 'Cancelado':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  static List<String> getAllStatus() {
    return ['Pendente', 'Confirmado', 'Cancelado'];
  }
}
