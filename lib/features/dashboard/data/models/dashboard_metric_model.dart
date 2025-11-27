import 'package:flutter/material.dart';
import 'package:yummy/features/common/data/dummy_data.dart' as dummy;

class DashboardMetricModel {
  String? title;
  String? value;
  double? trend;
  int? iconCodePoint;
  int? colorValue;

  DashboardMetricModel({
    this.title,
    this.value,
    this.trend,
    this.iconCodePoint,
    this.colorValue,
  });

  factory DashboardMetricModel.fromJson(Map<String, dynamic> json) {
    final trend = _parseDouble(json['trend']);
    final iconCode = _parseInt(json['iconCodePoint']);
    final color = _parseInt(json['colorValue']);

    return DashboardMetricModel(
      title: (json['title'] as String?)?.trim(),
      value: (json['value'] as String?)?.trim(),
      trend: trend,
      iconCodePoint: iconCode ?? Icons.help_outline.codePoint,
      colorValue: color ?? Colors.grey.toARGB32(),
    );
  }

  factory DashboardMetricModel.fromDummy(dummy.DashboardMetric metric) {
    return DashboardMetricModel(
      title: metric.title,
      value: metric.value,
      trend: metric.trend,
      iconCodePoint: metric.icon.codePoint,
      colorValue: metric.color.toARGB32(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'value': value,
      'trend': trend,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
