import 'package:flutter/material.dart';
import 'package:yummy/features/dashboard/data/models/dashboard_metric_model.dart';
import 'package:yummy/features/dashboard/domain/entities/dashboard_metric_entity.dart';

class DashboardMapper {
  static DashboardMetricEntity toEntity(DashboardMetricModel model) {
    return DashboardMetricEntity(
      title: model.title ?? '',
      value: model.value ?? '',
      trend: model.trend ?? 0,
      icon: IconData(
        model.iconCodePoint ?? Icons.help_outline.codePoint,
        fontFamily: 'MaterialIcons',
      ),
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
}
