import 'package:flutter/material.dart';
import 'package:yummy/features/dashboard/data/models/dashboard_metric_model.dart';
import 'package:yummy/features/dashboard/domain/entities/dashboard_metric_entity.dart';

class DashboardMapper {
  static DashboardMetricEntity toEntity(DashboardMetricModel model) {
    return DashboardMetricEntity(
      title: model.title ?? '',
      value: model.value ?? '',
      trend: model.trend ?? 0,
      icon: _resolveIcon(model.iconCodePoint),
      color: Color(model.colorValue ?? Colors.grey.toARGB32()),
    );
  }

  static DashboardMetricModel fromEntity(DashboardMetricEntity entity) {
    return DashboardMetricModel(
      title: entity.title,
      value: entity.value,
      trend: entity.trend,
      iconCodePoint: entity.icon.codePoint,
      colorValue: entity.color.toARGB32(),
    );
  }

  static IconData _resolveIcon(int? codePoint) {
    switch (codePoint) {
      // These numeric values come from the Material icon code points.
      case 58183: // insights
        return Icons.insights;
      case 58584: // point_of_sale
        return Icons.point_of_sale;
      case 58132: // history
        return Icons.history;
      case 58780: // shopping_cart
        return Icons.shopping_cart;
      case 57409: // account_balance_wallet
        return Icons.account_balance_wallet;
      case 58670: // request_page
        return Icons.request_page;
      default:
        return Icons.help_outline;
    }
  }
}
