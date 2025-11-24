part of 'groups_bloc.dart';

sealed class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object?> get props => [];
}

class GroupsRequested extends GroupsEvent {
  const GroupsRequested();
}

class GroupSaved extends GroupsEvent {
  final GroupEntity group;

  const GroupSaved(this.group);

  @override
  List<Object?> get props => [group];
}

class GroupStatusToggled extends GroupsEvent {
  final String groupName;

  const GroupStatusToggled(this.groupName);

  @override
  List<Object?> get props => [groupName];
}
