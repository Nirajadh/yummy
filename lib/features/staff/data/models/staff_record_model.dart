import 'package:yummy/features/common/data/dummy_data.dart' as dummy;

class StaffRecordModel {
  String? staffName;
  String? type;
  double? amount;
  String? date;
  String? note;

  StaffRecordModel({
    this.staffName,
    this.type,
    this.amount,
    this.date,
    this.note,
  });

  factory StaffRecordModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '');

    return StaffRecordModel(
      staffName: (json['staffName'] as String?)?.trim(),
      type: (json['type'] as String?)?.trim(),
      amount: amount,
      date: (json['date'] as String?)?.trim(),
      note: (json['note'] as String?)?.trim(),
    );
  }

  factory StaffRecordModel.fromDummy(dummy.StaffRecord record) {
    return StaffRecordModel(
      staffName: record.staffName,
      type: record.type,
      amount: record.amount,
      date: record.date,
      note: record.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffName': staffName,
      'type': type,
      'amount': amount,
      'date': date,
      'note': note,
    };
  }
}
