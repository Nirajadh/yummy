import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TableOrderLine extends Equatable {
  final String name;
  final int quantity;

  const TableOrderLine({required this.name, required this.quantity});

  TableOrderLine copyWith({String? name, int? quantity}) {
    return TableOrderLine(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [name, quantity];
}

// Events
abstract class TableOrderEvent extends Equatable {
  const TableOrderEvent();

  @override
  List<Object?> get props => [];
}

class TableOrderInitialized extends TableOrderEvent {
  final List<String> items;
  const TableOrderInitialized(this.items);

  @override
  List<Object?> get props => [items];
}

class TableOrderIncremented extends TableOrderEvent {
  final String name;
  const TableOrderIncremented(this.name);

  @override
  List<Object?> get props => [name];
}

class TableOrderDecremented extends TableOrderEvent {
  final String name;
  const TableOrderDecremented(this.name);

  @override
  List<Object?> get props => [name];
}

class TableOrderNoteChanged extends TableOrderEvent {
  final String name;
  final String note;
  const TableOrderNoteChanged(this.name, this.note);

  @override
  List<Object?> get props => [name, note];
}

class TableOrderItemAdded extends TableOrderEvent {
  final String name;
  final int quantity;
  const TableOrderItemAdded(this.name, this.quantity);

  @override
  List<Object?> get props => [name, quantity];
}

class TableOrderItemRemoved extends TableOrderEvent {
  final String name;
  const TableOrderItemRemoved(this.name);

  @override
  List<Object?> get props => [name];
}

// State
class TableOrderState extends Equatable {
  final List<TableOrderLine> lines;
  final Map<String, String> notes;

  const TableOrderState({this.lines = const [], this.notes = const {}});

  double get subtotal =>
      lines.fold<double>(0, (sum, line) => sum + (12.0 * line.quantity));

  TableOrderState copyWith({
    List<TableOrderLine>? lines,
    Map<String, String>? notes,
  }) {
    return TableOrderState(
      lines: lines ?? this.lines,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [lines, notes];
}

// Bloc
class TableOrderBloc extends Bloc<TableOrderEvent, TableOrderState> {
  TableOrderBloc() : super(const TableOrderState()) {
    on<TableOrderInitialized>(_onInit);
    on<TableOrderIncremented>(_onIncrement);
    on<TableOrderDecremented>(_onDecrement);
    on<TableOrderNoteChanged>(_onNote);
    on<TableOrderItemRemoved>(_onRemove);
    on<TableOrderItemAdded>(_onAdd);
  }

  void _onInit(
    TableOrderInitialized event,
    Emitter<TableOrderState> emit,
  ) {
    final map = <String, int>{};
    for (final item in event.items) {
      map[item] = (map[item] ?? 0) + 1;
    }
    final lines = map.entries
        .map((e) => TableOrderLine(name: e.key, quantity: e.value))
        .toList();
    emit(
      TableOrderState(
        lines: lines,
        notes: {for (final l in lines) l.name: ''},
      ),
    );
  }

  void _onIncrement(
    TableOrderIncremented event,
    Emitter<TableOrderState> emit,
  ) {
    final updated = state.lines
        .map((l) => l.name == event.name
            ? l.copyWith(quantity: l.quantity + 1)
            : l)
        .toList();
    emit(state.copyWith(lines: updated));
  }

  void _onDecrement(
    TableOrderDecremented event,
    Emitter<TableOrderState> emit,
  ) {
    final updated = <TableOrderLine>[];
    final newNotes = Map<String, String>.from(state.notes);
    for (final l in state.lines) {
      if (l.name != event.name) {
        updated.add(l);
        continue;
      }
      final next = l.quantity - 1;
      if (next > 0) {
        updated.add(l.copyWith(quantity: next));
      } else {
        newNotes.remove(event.name);
      }
    }
    emit(state.copyWith(lines: updated, notes: newNotes));
  }

  void _onNote(
    TableOrderNoteChanged event,
    Emitter<TableOrderState> emit,
  ) {
    final newNotes = Map<String, String>.from(state.notes);
    newNotes[event.name] = event.note;
    emit(state.copyWith(notes: newNotes));
  }

  void _onRemove(
    TableOrderItemRemoved event,
    Emitter<TableOrderState> emit,
  ) {
    final updated = state.lines.where((l) => l.name != event.name).toList();
    final newNotes = Map<String, String>.from(state.notes)..remove(event.name);
    emit(state.copyWith(lines: updated, notes: newNotes));
  }

  void _onAdd(
    TableOrderItemAdded event,
    Emitter<TableOrderState> emit,
  ) {
    final updated = <TableOrderLine>[];
    var found = false;
    for (final l in state.lines) {
      if (l.name == event.name) {
        updated.add(
          l.copyWith(quantity: l.quantity + event.quantity),
        );
        found = true;
      } else {
        updated.add(l);
      }
    }
    if (!found) {
      updated.add(TableOrderLine(name: event.name, quantity: event.quantity));
    }
    final newNotes = Map<String, String>.from(state.notes);
    newNotes.putIfAbsent(event.name, () => '');
    emit(state.copyWith(lines: updated, notes: newNotes));
  }
}
