import 'package:yummy/features/finance/data/models/expense_entry_model.dart';
import 'package:yummy/features/finance/data/models/income_entry_model.dart';
import 'package:yummy/features/finance/data/models/purchase_entry_model.dart';
import 'package:yummy/features/finance/domain/entities/expense_entry_entity.dart';
import 'package:yummy/features/finance/domain/entities/income_entry_entity.dart';
import 'package:yummy/features/finance/domain/entities/purchase_entry_entity.dart';

class FinanceMapper {
  static ExpenseEntryEntity toExpenseEntity(ExpenseEntryModel model) {
    return ExpenseEntryEntity(
      category: model.category ?? '',
      vendor: model.vendor ?? '',
      amount: model.amount ?? 0,
      date: model.date ?? '',
      paymentMode: model.paymentMode ?? '',
      notes: model.notes ?? '',
    );
  }

  static ExpenseEntryModel fromExpenseEntity(ExpenseEntryEntity entity) {
    return ExpenseEntryModel(
      category: entity.category,
      vendor: entity.vendor,
      amount: entity.amount,
      date: entity.date,
      paymentMode: entity.paymentMode,
      notes: entity.notes,
    );
  }

  static PurchaseEntryEntity toPurchaseEntity(PurchaseEntryModel model) {
    return PurchaseEntryEntity(
      vendor: model.vendor ?? '',
      category: model.category ?? '',
      amount: model.amount ?? 0,
      date: model.date ?? '',
      reference: model.reference ?? '',
    );
  }

  static PurchaseEntryModel fromPurchaseEntity(PurchaseEntryEntity entity) {
    return PurchaseEntryModel(
      vendor: entity.vendor,
      category: entity.category,
      amount: entity.amount,
      date: entity.date,
      reference: entity.reference,
    );
  }

  static IncomeEntryEntity toIncomeEntity(IncomeEntryModel model) {
    return IncomeEntryEntity(
      source: model.source ?? '',
      amount: model.amount ?? 0,
      date: model.date ?? '',
      type: model.type ?? '',
      note: model.note ?? '',
    );
  }

  static IncomeEntryModel fromIncomeEntity(IncomeEntryEntity entity) {
    return IncomeEntryModel(
      source: entity.source,
      amount: entity.amount,
      date: entity.date,
      type: entity.type,
      note: entity.note,
    );
  }
}
