import 'package:drift/drift.dart';

import '../../core/models/formation.dart';
import '../../core/models/group_role.dart';
import '../../core/models/member_type.dart';
import '../../core/models/position.dart';
import '../../core/models/team_constraint.dart';

/// 공유·병합(SPEC F13.4)을 위한 공통 열: 수정 시각, 수정한 기기, 삭제 표시(tombstone).
mixin SyncColumns on Table {
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get updatedBy => text()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// 모임 (SPEC §7 Group).
@DataClassName('GroupRow')
class Groups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant('⚽'))();
  IntColumn get color => integer().withDefault(const Constant(0xFF1B8A3C))();
  TextColumn get myRole => textEnum<GroupRole>()();
  TextColumn get myDisplayName => text().nullable()();
  TextColumn get defaultFormat => textEnum<MatchFormat>().withDefault(
    Constant(MatchFormat.fiveVsFive.name),
  )();

  /// 생성 마법사 진행 단계 (0~3 진행 중, 4 = 완료).
  IntColumn get onboardingStep => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastUsedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 선수 (SPEC §7 Player).
@DataClassName('PlayerRow')
class Players extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get groupId =>
      text().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get nickname => text().nullable()();
  TextColumn get memberType => textEnum<MemberType>()();
  IntColumn get shooting => integer()();
  IntColumn get dribbling => integer()();
  IntColumn get speed => integer()();
  IntColumn get passing => integer()();
  IntColumn get physical => integer()();
  IntColumn get creativity => integer()();
  IntColumn get teamwork => integer()();
  TextColumn get mainPosition => textEnum<Position>()();

  /// 가능 포지션 이름을 쉼표로 이은 값 (예: "ala,pivo").
  TextColumn get subPositions => text().withDefault(const Constant(''))();
  BoolColumn get canKeep => boolean().withDefault(const Constant(false))();
  BoolColumn get isGuest => boolean().withDefault(const Constant(false))();
  BoolColumn get statsSimple => boolean().withDefault(const Constant(false))();
  TextColumn get memo => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 상시 제약 (SPEC §7 PlayerConstraint).
@DataClassName('ConstraintRow')
class PlayerConstraints extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get groupId =>
      text().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => textEnum<ConstraintType>()();

  /// 선수 id를 쉼표로 이은 값.
  TextColumn get playerIds => text()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 기기별 설정 (공유되지 않음).
@DataClassName('DeviceSettingRow')
class DeviceSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// 진행 중인 매치 준비 상태 (모임별 1행, JSON). 공유되지 않는다.
@DataClassName('SessionDraftRow')
class SessionDrafts extends Table {
  TextColumn get groupId =>
      text().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get json => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {groupId};
}
