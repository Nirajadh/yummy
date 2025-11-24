import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DashboardMetricEntity extends Equatable {
  final String title;
  final String value;
  final double trend;
  final IconData icon;
  final Color color;

  const DashboardMetricEntity({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [title, value, trend, icon, color];
}
