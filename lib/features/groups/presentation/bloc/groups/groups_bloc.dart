import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:yummy/features/groups/domain/entities/group_entity.dart';
import 'package:yummy/features/groups/domain/usecases/get_groups_usecase.dart';
import 'package:yummy/features/groups/domain/usecases/toggle_group_status_usecase.dart';
import 'package:yummy/features/groups/domain/usecases/upsert_group_usecase.dart';

part 'groups_event.dart';
part 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final GetGroupsUseCase _getGroups;
  final UpsertGroupUseCase _upsertGroup;
  final ToggleGroupStatusUseCase _toggleGroupStatus;

  GroupsBloc({
    required GetGroupsUseCase getGroups,
    required UpsertGroupUseCase upsertGroup,
    required ToggleGroupStatusUseCase toggleGroupStatus,
  })  : _getGroups = getGroups,
        _upsertGroup = upsertGroup,
        _toggleGroupStatus = toggleGroupStatus,
        super(const GroupsState()) {
    on<GroupsRequested>(_onRequested);
    on<GroupSaved>(_onSaved);
    on<GroupStatusToggled>(_onStatusToggled);
  }

  Future<void> _onRequested(
    GroupsRequested event,
    Emitter<GroupsState> emit,
  ) async {
    emit(state.copyWith(status: GroupsStatus.loading));
    try {
      final groups = await _getGroups();
      emit(
        state.copyWith(
          status: GroupsStatus.success,
          groups: groups,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GroupsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSaved(
    GroupSaved event,
    Emitter<GroupsState> emit,
  ) async {
    await _upsertGroup(event.group);
    add(const GroupsRequested());
  }

  Future<void> _onStatusToggled(
    GroupStatusToggled event,
    Emitter<GroupsState> emit,
  ) async {
    await _toggleGroupStatus(event.groupName);
    add(const GroupsRequested());
  }
}
