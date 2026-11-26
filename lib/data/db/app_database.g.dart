// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GroupsTable extends Groups with TableInfo<$GroupsTable, GroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('⚽'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF1B8A3C),
  );
  @override
  late final GeneratedColumnWithTypeConverter<GroupRole, String> myRole =
      GeneratedColumn<String>(
        'my_role',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<GroupRole>($GroupsTable.$convertermyRole);
  static const VerificationMeta _myDisplayNameMeta = const VerificationMeta(
    'myDisplayName',
  );
  @override
  late final GeneratedColumn<String> myDisplayName = GeneratedColumn<String>(
    'my_display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MatchFormat, String>
  defaultFormat = GeneratedColumn<String>(
    'default_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(MatchFormat.fiveVsFive.name),
  ).withConverter<MatchFormat>($GroupsTable.$converterdefaultFormat);
  static const VerificationMeta _onboardingStepMeta = const VerificationMeta(
    'onboardingStep',
  );
  @override
  late final GeneratedColumn<int> onboardingStep = GeneratedColumn<int>(
    'onboarding_step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSharedAtMeta = const VerificationMeta(
    'lastSharedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSharedAt = GeneratedColumn<DateTime>(
    'last_shared_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    color,
    myRole,
    myDisplayName,
    defaultFormat,
    onboardingStep,
    createdAt,
    updatedAt,
    lastUsedAt,
    lastSharedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('my_display_name')) {
      context.handle(
        _myDisplayNameMeta,
        myDisplayName.isAcceptableOrUnknown(
          data['my_display_name']!,
          _myDisplayNameMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_step')) {
      context.handle(
        _onboardingStepMeta,
        onboardingStep.isAcceptableOrUnknown(
          data['onboarding_step']!,
          _onboardingStepMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    if (data.containsKey('last_shared_at')) {
      context.handle(
        _lastSharedAtMeta,
        lastSharedAt.isAcceptableOrUnknown(
          data['last_shared_at']!,
          _lastSharedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      myRole: $GroupsTable.$convertermyRole.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}my_role'],
        )!,
      ),
      myDisplayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}my_display_name'],
      ),
      defaultFormat: $GroupsTable.$converterdefaultFormat.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}default_format'],
        )!,
      ),
      onboardingStep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}onboarding_step'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      )!,
      lastSharedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_shared_at'],
      ),
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GroupRole, String, String> $convertermyRole =
      const EnumNameConverter<GroupRole>(GroupRole.values);
  static JsonTypeConverter2<MatchFormat, String, String>
  $converterdefaultFormat = const EnumNameConverter<MatchFormat>(
    MatchFormat.values,
  );
}

class GroupRow extends DataClass implements Insertable<GroupRow> {
  final String id;
  final String name;
  final String icon;
  final int color;
  final GroupRole myRole;
  final String? myDisplayName;
  final MatchFormat defaultFormat;

  /// 생성 마법사 진행 단계 (0~3 진행 중, 4 = 완료).
  final int onboardingStep;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastUsedAt;

  /// 마지막으로 초대 링크·변경 공유를 보내거나 받은 시각 ("공유 안 된 변경 N건" 기준).
  final DateTime? lastSharedAt;
  const GroupRow({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.myRole,
    this.myDisplayName,
    required this.defaultFormat,
    required this.onboardingStep,
    required this.createdAt,
    required this.updatedAt,
    required this.lastUsedAt,
    this.lastSharedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    {
      map['my_role'] = Variable<String>(
        $GroupsTable.$convertermyRole.toSql(myRole),
      );
    }
    if (!nullToAbsent || myDisplayName != null) {
      map['my_display_name'] = Variable<String>(myDisplayName);
    }
    {
      map['default_format'] = Variable<String>(
        $GroupsTable.$converterdefaultFormat.toSql(defaultFormat),
      );
    }
    map['onboarding_step'] = Variable<int>(onboardingStep);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    if (!nullToAbsent || lastSharedAt != null) {
      map['last_shared_at'] = Variable<DateTime>(lastSharedAt);
    }
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      myRole: Value(myRole),
      myDisplayName: myDisplayName == null && nullToAbsent
          ? const Value.absent()
          : Value(myDisplayName),
      defaultFormat: Value(defaultFormat),
      onboardingStep: Value(onboardingStep),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastUsedAt: Value(lastUsedAt),
      lastSharedAt: lastSharedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSharedAt),
    );
  }

  factory GroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      myRole: $GroupsTable.$convertermyRole.fromJson(
        serializer.fromJson<String>(json['myRole']),
      ),
      myDisplayName: serializer.fromJson<String?>(json['myDisplayName']),
      defaultFormat: $GroupsTable.$converterdefaultFormat.fromJson(
        serializer.fromJson<String>(json['defaultFormat']),
      ),
      onboardingStep: serializer.fromJson<int>(json['onboardingStep']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastUsedAt: serializer.fromJson<DateTime>(json['lastUsedAt']),
      lastSharedAt: serializer.fromJson<DateTime?>(json['lastSharedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
      'myRole': serializer.toJson<String>(
        $GroupsTable.$convertermyRole.toJson(myRole),
      ),
      'myDisplayName': serializer.toJson<String?>(myDisplayName),
      'defaultFormat': serializer.toJson<String>(
        $GroupsTable.$converterdefaultFormat.toJson(defaultFormat),
      ),
      'onboardingStep': serializer.toJson<int>(onboardingStep),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastUsedAt': serializer.toJson<DateTime>(lastUsedAt),
      'lastSharedAt': serializer.toJson<DateTime?>(lastSharedAt),
    };
  }

  GroupRow copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    GroupRole? myRole,
    Value<String?> myDisplayName = const Value.absent(),
    MatchFormat? defaultFormat,
    int? onboardingStep,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastUsedAt,
    Value<DateTime?> lastSharedAt = const Value.absent(),
  }) => GroupRow(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    myRole: myRole ?? this.myRole,
    myDisplayName: myDisplayName.present
        ? myDisplayName.value
        : this.myDisplayName,
    defaultFormat: defaultFormat ?? this.defaultFormat,
    onboardingStep: onboardingStep ?? this.onboardingStep,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    lastSharedAt: lastSharedAt.present ? lastSharedAt.value : this.lastSharedAt,
  );
  GroupRow copyWithCompanion(GroupsCompanion data) {
    return GroupRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      myRole: data.myRole.present ? data.myRole.value : this.myRole,
      myDisplayName: data.myDisplayName.present
          ? data.myDisplayName.value
          : this.myDisplayName,
      defaultFormat: data.defaultFormat.present
          ? data.defaultFormat.value
          : this.defaultFormat,
      onboardingStep: data.onboardingStep.present
          ? data.onboardingStep.value
          : this.onboardingStep,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
      lastSharedAt: data.lastSharedAt.present
          ? data.lastSharedAt.value
          : this.lastSharedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('myRole: $myRole, ')
          ..write('myDisplayName: $myDisplayName, ')
          ..write('defaultFormat: $defaultFormat, ')
          ..write('onboardingStep: $onboardingStep, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('lastSharedAt: $lastSharedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    icon,
    color,
    myRole,
    myDisplayName,
    defaultFormat,
    onboardingStep,
    createdAt,
    updatedAt,
    lastUsedAt,
    lastSharedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.myRole == this.myRole &&
          other.myDisplayName == this.myDisplayName &&
          other.defaultFormat == this.defaultFormat &&
          other.onboardingStep == this.onboardingStep &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastUsedAt == this.lastUsedAt &&
          other.lastSharedAt == this.lastSharedAt);
}

class GroupsCompanion extends UpdateCompanion<GroupRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> color;
  final Value<GroupRole> myRole;
  final Value<String?> myDisplayName;
  final Value<MatchFormat> defaultFormat;
  final Value<int> onboardingStep;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> lastUsedAt;
  final Value<DateTime?> lastSharedAt;
  final Value<int> rowid;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.myRole = const Value.absent(),
    this.myDisplayName = const Value.absent(),
    this.defaultFormat = const Value.absent(),
    this.onboardingStep = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.lastSharedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    required String id,
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    required GroupRole myRole,
    this.myDisplayName = const Value.absent(),
    this.defaultFormat = const Value.absent(),
    this.onboardingStep = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime lastUsedAt,
    this.lastSharedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       myRole = Value(myRole),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       lastUsedAt = Value(lastUsedAt);
  static Insertable<GroupRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<String>? myRole,
    Expression<String>? myDisplayName,
    Expression<String>? defaultFormat,
    Expression<int>? onboardingStep,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastUsedAt,
    Expression<DateTime>? lastSharedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (myRole != null) 'my_role': myRole,
      if (myDisplayName != null) 'my_display_name': myDisplayName,
      if (defaultFormat != null) 'default_format': defaultFormat,
      if (onboardingStep != null) 'onboarding_step': onboardingStep,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (lastSharedAt != null) 'last_shared_at': lastSharedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<int>? color,
    Value<GroupRole>? myRole,
    Value<String?>? myDisplayName,
    Value<MatchFormat>? defaultFormat,
    Value<int>? onboardingStep,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? lastUsedAt,
    Value<DateTime?>? lastSharedAt,
    Value<int>? rowid,
  }) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      myRole: myRole ?? this.myRole,
      myDisplayName: myDisplayName ?? this.myDisplayName,
      defaultFormat: defaultFormat ?? this.defaultFormat,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      lastSharedAt: lastSharedAt ?? this.lastSharedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (myRole.present) {
      map['my_role'] = Variable<String>(
        $GroupsTable.$convertermyRole.toSql(myRole.value),
      );
    }
    if (myDisplayName.present) {
      map['my_display_name'] = Variable<String>(myDisplayName.value);
    }
    if (defaultFormat.present) {
      map['default_format'] = Variable<String>(
        $GroupsTable.$converterdefaultFormat.toSql(defaultFormat.value),
      );
    }
    if (onboardingStep.present) {
      map['onboarding_step'] = Variable<int>(onboardingStep.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (lastSharedAt.present) {
      map['last_shared_at'] = Variable<DateTime>(lastSharedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('myRole: $myRole, ')
          ..write('myDisplayName: $myDisplayName, ')
          ..write('defaultFormat: $defaultFormat, ')
          ..write('onboardingStep: $onboardingStep, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('lastSharedAt: $lastSharedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayersTable extends Players with TableInfo<$PlayersTable, PlayerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MemberType, String> memberType =
      GeneratedColumn<String>(
        'member_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MemberType>($PlayersTable.$convertermemberType);
  static const VerificationMeta _shootingMeta = const VerificationMeta(
    'shooting',
  );
  @override
  late final GeneratedColumn<int> shooting = GeneratedColumn<int>(
    'shooting',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dribblingMeta = const VerificationMeta(
    'dribbling',
  );
  @override
  late final GeneratedColumn<int> dribbling = GeneratedColumn<int>(
    'dribbling',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<int> speed = GeneratedColumn<int>(
    'speed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passingMeta = const VerificationMeta(
    'passing',
  );
  @override
  late final GeneratedColumn<int> passing = GeneratedColumn<int>(
    'passing',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _physicalMeta = const VerificationMeta(
    'physical',
  );
  @override
  late final GeneratedColumn<int> physical = GeneratedColumn<int>(
    'physical',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creativityMeta = const VerificationMeta(
    'creativity',
  );
  @override
  late final GeneratedColumn<int> creativity = GeneratedColumn<int>(
    'creativity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamworkMeta = const VerificationMeta(
    'teamwork',
  );
  @override
  late final GeneratedColumn<int> teamwork = GeneratedColumn<int>(
    'teamwork',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Position, String> mainPosition =
      GeneratedColumn<String>(
        'main_position',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Position>($PlayersTable.$convertermainPosition);
  static const VerificationMeta _subPositionsMeta = const VerificationMeta(
    'subPositions',
  );
  @override
  late final GeneratedColumn<String> subPositions = GeneratedColumn<String>(
    'sub_positions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _canKeepMeta = const VerificationMeta(
    'canKeep',
  );
  @override
  late final GeneratedColumn<bool> canKeep = GeneratedColumn<bool>(
    'can_keep',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_keep" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isGuestMeta = const VerificationMeta(
    'isGuest',
  );
  @override
  late final GeneratedColumn<bool> isGuest = GeneratedColumn<bool>(
    'is_guest',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_guest" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statsSimpleMeta = const VerificationMeta(
    'statsSimple',
  );
  @override
  late final GeneratedColumn<bool> statsSimple = GeneratedColumn<bool>(
    'stats_simple',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("stats_simple" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    updatedBy,
    deletedAt,
    id,
    groupId,
    name,
    nickname,
    memberType,
    shooting,
    dribbling,
    speed,
    passing,
    physical,
    creativity,
    teamwork,
    mainPosition,
    subPositions,
    canKeep,
    isGuest,
    statsSimple,
    memo,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('shooting')) {
      context.handle(
        _shootingMeta,
        shooting.isAcceptableOrUnknown(data['shooting']!, _shootingMeta),
      );
    } else if (isInserting) {
      context.missing(_shootingMeta);
    }
    if (data.containsKey('dribbling')) {
      context.handle(
        _dribblingMeta,
        dribbling.isAcceptableOrUnknown(data['dribbling']!, _dribblingMeta),
      );
    } else if (isInserting) {
      context.missing(_dribblingMeta);
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    } else if (isInserting) {
      context.missing(_speedMeta);
    }
    if (data.containsKey('passing')) {
      context.handle(
        _passingMeta,
        passing.isAcceptableOrUnknown(data['passing']!, _passingMeta),
      );
    } else if (isInserting) {
      context.missing(_passingMeta);
    }
    if (data.containsKey('physical')) {
      context.handle(
        _physicalMeta,
        physical.isAcceptableOrUnknown(data['physical']!, _physicalMeta),
      );
    } else if (isInserting) {
      context.missing(_physicalMeta);
    }
    if (data.containsKey('creativity')) {
      context.handle(
        _creativityMeta,
        creativity.isAcceptableOrUnknown(data['creativity']!, _creativityMeta),
      );
    } else if (isInserting) {
      context.missing(_creativityMeta);
    }
    if (data.containsKey('teamwork')) {
      context.handle(
        _teamworkMeta,
        teamwork.isAcceptableOrUnknown(data['teamwork']!, _teamworkMeta),
      );
    } else if (isInserting) {
      context.missing(_teamworkMeta);
    }
    if (data.containsKey('sub_positions')) {
      context.handle(
        _subPositionsMeta,
        subPositions.isAcceptableOrUnknown(
          data['sub_positions']!,
          _subPositionsMeta,
        ),
      );
    }
    if (data.containsKey('can_keep')) {
      context.handle(
        _canKeepMeta,
        canKeep.isAcceptableOrUnknown(data['can_keep']!, _canKeepMeta),
      );
    }
    if (data.containsKey('is_guest')) {
      context.handle(
        _isGuestMeta,
        isGuest.isAcceptableOrUnknown(data['is_guest']!, _isGuestMeta),
      );
    }
    if (data.containsKey('stats_simple')) {
      context.handle(
        _statsSimpleMeta,
        statsSimple.isAcceptableOrUnknown(
          data['stats_simple']!,
          _statsSimpleMeta,
        ),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      memberType: $PlayersTable.$convertermemberType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}member_type'],
        )!,
      ),
      shooting: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shooting'],
      )!,
      dribbling: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dribbling'],
      )!,
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speed'],
      )!,
      passing: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}passing'],
      )!,
      physical: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}physical'],
      )!,
      creativity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creativity'],
      )!,
      teamwork: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}teamwork'],
      )!,
      mainPosition: $PlayersTable.$convertermainPosition.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}main_position'],
        )!,
      ),
      subPositions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_positions'],
      )!,
      canKeep: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_keep'],
      )!,
      isGuest: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_guest'],
      )!,
      statsSimple: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}stats_simple'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MemberType, String, String> $convertermemberType =
      const EnumNameConverter<MemberType>(MemberType.values);
  static JsonTypeConverter2<Position, String, String> $convertermainPosition =
      const EnumNameConverter<Position>(Position.values);
}

class PlayerRow extends DataClass implements Insertable<PlayerRow> {
  final DateTime updatedAt;
  final String updatedBy;
  final DateTime? deletedAt;
  final String id;
  final String groupId;
  final String name;
  final String? nickname;
  final MemberType memberType;
  final int shooting;
  final int dribbling;
  final int speed;
  final int passing;
  final int physical;
  final int creativity;
  final int teamwork;
  final Position mainPosition;

  /// 가능 포지션 이름을 쉼표로 이은 값 (예: "ala,pivo").
  final String subPositions;
  final bool canKeep;
  final bool isGuest;
  final bool statsSimple;
  final String? memo;
  final DateTime createdAt;
  const PlayerRow({
    required this.updatedAt,
    required this.updatedBy,
    this.deletedAt,
    required this.id,
    required this.groupId,
    required this.name,
    this.nickname,
    required this.memberType,
    required this.shooting,
    required this.dribbling,
    required this.speed,
    required this.passing,
    required this.physical,
    required this.creativity,
    required this.teamwork,
    required this.mainPosition,
    required this.subPositions,
    required this.canKeep,
    required this.isGuest,
    required this.statsSimple,
    this.memo,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['updated_by'] = Variable<String>(updatedBy);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    {
      map['member_type'] = Variable<String>(
        $PlayersTable.$convertermemberType.toSql(memberType),
      );
    }
    map['shooting'] = Variable<int>(shooting);
    map['dribbling'] = Variable<int>(dribbling);
    map['speed'] = Variable<int>(speed);
    map['passing'] = Variable<int>(passing);
    map['physical'] = Variable<int>(physical);
    map['creativity'] = Variable<int>(creativity);
    map['teamwork'] = Variable<int>(teamwork);
    {
      map['main_position'] = Variable<String>(
        $PlayersTable.$convertermainPosition.toSql(mainPosition),
      );
    }
    map['sub_positions'] = Variable<String>(subPositions);
    map['can_keep'] = Variable<bool>(canKeep);
    map['is_guest'] = Variable<bool>(isGuest);
    map['stats_simple'] = Variable<bool>(statsSimple);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      groupId: Value(groupId),
      name: Value(name),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      memberType: Value(memberType),
      shooting: Value(shooting),
      dribbling: Value(dribbling),
      speed: Value(speed),
      passing: Value(passing),
      physical: Value(physical),
      creativity: Value(creativity),
      teamwork: Value(teamwork),
      mainPosition: Value(mainPosition),
      subPositions: Value(subPositions),
      canKeep: Value(canKeep),
      isGuest: Value(isGuest),
      statsSimple: Value(statsSimple),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdAt: Value(createdAt),
    );
  }

  factory PlayerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerRow(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      name: serializer.fromJson<String>(json['name']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      memberType: $PlayersTable.$convertermemberType.fromJson(
        serializer.fromJson<String>(json['memberType']),
      ),
      shooting: serializer.fromJson<int>(json['shooting']),
      dribbling: serializer.fromJson<int>(json['dribbling']),
      speed: serializer.fromJson<int>(json['speed']),
      passing: serializer.fromJson<int>(json['passing']),
      physical: serializer.fromJson<int>(json['physical']),
      creativity: serializer.fromJson<int>(json['creativity']),
      teamwork: serializer.fromJson<int>(json['teamwork']),
      mainPosition: $PlayersTable.$convertermainPosition.fromJson(
        serializer.fromJson<String>(json['mainPosition']),
      ),
      subPositions: serializer.fromJson<String>(json['subPositions']),
      canKeep: serializer.fromJson<bool>(json['canKeep']),
      isGuest: serializer.fromJson<bool>(json['isGuest']),
      statsSimple: serializer.fromJson<bool>(json['statsSimple']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'name': serializer.toJson<String>(name),
      'nickname': serializer.toJson<String?>(nickname),
      'memberType': serializer.toJson<String>(
        $PlayersTable.$convertermemberType.toJson(memberType),
      ),
      'shooting': serializer.toJson<int>(shooting),
      'dribbling': serializer.toJson<int>(dribbling),
      'speed': serializer.toJson<int>(speed),
      'passing': serializer.toJson<int>(passing),
      'physical': serializer.toJson<int>(physical),
      'creativity': serializer.toJson<int>(creativity),
      'teamwork': serializer.toJson<int>(teamwork),
      'mainPosition': serializer.toJson<String>(
        $PlayersTable.$convertermainPosition.toJson(mainPosition),
      ),
      'subPositions': serializer.toJson<String>(subPositions),
      'canKeep': serializer.toJson<bool>(canKeep),
      'isGuest': serializer.toJson<bool>(isGuest),
      'statsSimple': serializer.toJson<bool>(statsSimple),
      'memo': serializer.toJson<String?>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlayerRow copyWith({
    DateTime? updatedAt,
    String? updatedBy,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? groupId,
    String? name,
    Value<String?> nickname = const Value.absent(),
    MemberType? memberType,
    int? shooting,
    int? dribbling,
    int? speed,
    int? passing,
    int? physical,
    int? creativity,
    int? teamwork,
    Position? mainPosition,
    String? subPositions,
    bool? canKeep,
    bool? isGuest,
    bool? statsSimple,
    Value<String?> memo = const Value.absent(),
    DateTime? createdAt,
  }) => PlayerRow(
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    name: name ?? this.name,
    nickname: nickname.present ? nickname.value : this.nickname,
    memberType: memberType ?? this.memberType,
    shooting: shooting ?? this.shooting,
    dribbling: dribbling ?? this.dribbling,
    speed: speed ?? this.speed,
    passing: passing ?? this.passing,
    physical: physical ?? this.physical,
    creativity: creativity ?? this.creativity,
    teamwork: teamwork ?? this.teamwork,
    mainPosition: mainPosition ?? this.mainPosition,
    subPositions: subPositions ?? this.subPositions,
    canKeep: canKeep ?? this.canKeep,
    isGuest: isGuest ?? this.isGuest,
    statsSimple: statsSimple ?? this.statsSimple,
    memo: memo.present ? memo.value : this.memo,
    createdAt: createdAt ?? this.createdAt,
  );
  PlayerRow copyWithCompanion(PlayersCompanion data) {
    return PlayerRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      name: data.name.present ? data.name.value : this.name,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      memberType: data.memberType.present
          ? data.memberType.value
          : this.memberType,
      shooting: data.shooting.present ? data.shooting.value : this.shooting,
      dribbling: data.dribbling.present ? data.dribbling.value : this.dribbling,
      speed: data.speed.present ? data.speed.value : this.speed,
      passing: data.passing.present ? data.passing.value : this.passing,
      physical: data.physical.present ? data.physical.value : this.physical,
      creativity: data.creativity.present
          ? data.creativity.value
          : this.creativity,
      teamwork: data.teamwork.present ? data.teamwork.value : this.teamwork,
      mainPosition: data.mainPosition.present
          ? data.mainPosition.value
          : this.mainPosition,
      subPositions: data.subPositions.present
          ? data.subPositions.value
          : this.subPositions,
      canKeep: data.canKeep.present ? data.canKeep.value : this.canKeep,
      isGuest: data.isGuest.present ? data.isGuest.value : this.isGuest,
      statsSimple: data.statsSimple.present
          ? data.statsSimple.value
          : this.statsSimple,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('memberType: $memberType, ')
          ..write('shooting: $shooting, ')
          ..write('dribbling: $dribbling, ')
          ..write('speed: $speed, ')
          ..write('passing: $passing, ')
          ..write('physical: $physical, ')
          ..write('creativity: $creativity, ')
          ..write('teamwork: $teamwork, ')
          ..write('mainPosition: $mainPosition, ')
          ..write('subPositions: $subPositions, ')
          ..write('canKeep: $canKeep, ')
          ..write('isGuest: $isGuest, ')
          ..write('statsSimple: $statsSimple, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    updatedAt,
    updatedBy,
    deletedAt,
    id,
    groupId,
    name,
    nickname,
    memberType,
    shooting,
    dribbling,
    speed,
    passing,
    physical,
    creativity,
    teamwork,
    mainPosition,
    subPositions,
    canKeep,
    isGuest,
    statsSimple,
    memo,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerRow &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.name == this.name &&
          other.nickname == this.nickname &&
          other.memberType == this.memberType &&
          other.shooting == this.shooting &&
          other.dribbling == this.dribbling &&
          other.speed == this.speed &&
          other.passing == this.passing &&
          other.physical == this.physical &&
          other.creativity == this.creativity &&
          other.teamwork == this.teamwork &&
          other.mainPosition == this.mainPosition &&
          other.subPositions == this.subPositions &&
          other.canKeep == this.canKeep &&
          other.isGuest == this.isGuest &&
          other.statsSimple == this.statsSimple &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt);
}

class PlayersCompanion extends UpdateCompanion<PlayerRow> {
  final Value<DateTime> updatedAt;
  final Value<String> updatedBy;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> name;
  final Value<String?> nickname;
  final Value<MemberType> memberType;
  final Value<int> shooting;
  final Value<int> dribbling;
  final Value<int> speed;
  final Value<int> passing;
  final Value<int> physical;
  final Value<int> creativity;
  final Value<int> teamwork;
  final Value<Position> mainPosition;
  final Value<String> subPositions;
  final Value<bool> canKeep;
  final Value<bool> isGuest;
  final Value<bool> statsSimple;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlayersCompanion({
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.name = const Value.absent(),
    this.nickname = const Value.absent(),
    this.memberType = const Value.absent(),
    this.shooting = const Value.absent(),
    this.dribbling = const Value.absent(),
    this.speed = const Value.absent(),
    this.passing = const Value.absent(),
    this.physical = const Value.absent(),
    this.creativity = const Value.absent(),
    this.teamwork = const Value.absent(),
    this.mainPosition = const Value.absent(),
    this.subPositions = const Value.absent(),
    this.canKeep = const Value.absent(),
    this.isGuest = const Value.absent(),
    this.statsSimple = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayersCompanion.insert({
    required DateTime updatedAt,
    required String updatedBy,
    this.deletedAt = const Value.absent(),
    required String id,
    required String groupId,
    required String name,
    this.nickname = const Value.absent(),
    required MemberType memberType,
    required int shooting,
    required int dribbling,
    required int speed,
    required int passing,
    required int physical,
    required int creativity,
    required int teamwork,
    required Position mainPosition,
    this.subPositions = const Value.absent(),
    this.canKeep = const Value.absent(),
    this.isGuest = const Value.absent(),
    this.statsSimple = const Value.absent(),
    this.memo = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       updatedBy = Value(updatedBy),
       id = Value(id),
       groupId = Value(groupId),
       name = Value(name),
       memberType = Value(memberType),
       shooting = Value(shooting),
       dribbling = Value(dribbling),
       speed = Value(speed),
       passing = Value(passing),
       physical = Value(physical),
       creativity = Value(creativity),
       teamwork = Value(teamwork),
       mainPosition = Value(mainPosition),
       createdAt = Value(createdAt);
  static Insertable<PlayerRow> custom({
    Expression<DateTime>? updatedAt,
    Expression<String>? updatedBy,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? name,
    Expression<String>? nickname,
    Expression<String>? memberType,
    Expression<int>? shooting,
    Expression<int>? dribbling,
    Expression<int>? speed,
    Expression<int>? passing,
    Expression<int>? physical,
    Expression<int>? creativity,
    Expression<int>? teamwork,
    Expression<String>? mainPosition,
    Expression<String>? subPositions,
    Expression<bool>? canKeep,
    Expression<bool>? isGuest,
    Expression<bool>? statsSimple,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (name != null) 'name': name,
      if (nickname != null) 'nickname': nickname,
      if (memberType != null) 'member_type': memberType,
      if (shooting != null) 'shooting': shooting,
      if (dribbling != null) 'dribbling': dribbling,
      if (speed != null) 'speed': speed,
      if (passing != null) 'passing': passing,
      if (physical != null) 'physical': physical,
      if (creativity != null) 'creativity': creativity,
      if (teamwork != null) 'teamwork': teamwork,
      if (mainPosition != null) 'main_position': mainPosition,
      if (subPositions != null) 'sub_positions': subPositions,
      if (canKeep != null) 'can_keep': canKeep,
      if (isGuest != null) 'is_guest': isGuest,
      if (statsSimple != null) 'stats_simple': statsSimple,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayersCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<String>? updatedBy,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? name,
    Value<String?>? nickname,
    Value<MemberType>? memberType,
    Value<int>? shooting,
    Value<int>? dribbling,
    Value<int>? speed,
    Value<int>? passing,
    Value<int>? physical,
    Value<int>? creativity,
    Value<int>? teamwork,
    Value<Position>? mainPosition,
    Value<String>? subPositions,
    Value<bool>? canKeep,
    Value<bool>? isGuest,
    Value<bool>? statsSimple,
    Value<String?>? memo,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PlayersCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      memberType: memberType ?? this.memberType,
      shooting: shooting ?? this.shooting,
      dribbling: dribbling ?? this.dribbling,
      speed: speed ?? this.speed,
      passing: passing ?? this.passing,
      physical: physical ?? this.physical,
      creativity: creativity ?? this.creativity,
      teamwork: teamwork ?? this.teamwork,
      mainPosition: mainPosition ?? this.mainPosition,
      subPositions: subPositions ?? this.subPositions,
      canKeep: canKeep ?? this.canKeep,
      isGuest: isGuest ?? this.isGuest,
      statsSimple: statsSimple ?? this.statsSimple,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (memberType.present) {
      map['member_type'] = Variable<String>(
        $PlayersTable.$convertermemberType.toSql(memberType.value),
      );
    }
    if (shooting.present) {
      map['shooting'] = Variable<int>(shooting.value);
    }
    if (dribbling.present) {
      map['dribbling'] = Variable<int>(dribbling.value);
    }
    if (speed.present) {
      map['speed'] = Variable<int>(speed.value);
    }
    if (passing.present) {
      map['passing'] = Variable<int>(passing.value);
    }
    if (physical.present) {
      map['physical'] = Variable<int>(physical.value);
    }
    if (creativity.present) {
      map['creativity'] = Variable<int>(creativity.value);
    }
    if (teamwork.present) {
      map['teamwork'] = Variable<int>(teamwork.value);
    }
    if (mainPosition.present) {
      map['main_position'] = Variable<String>(
        $PlayersTable.$convertermainPosition.toSql(mainPosition.value),
      );
    }
    if (subPositions.present) {
      map['sub_positions'] = Variable<String>(subPositions.value);
    }
    if (canKeep.present) {
      map['can_keep'] = Variable<bool>(canKeep.value);
    }
    if (isGuest.present) {
      map['is_guest'] = Variable<bool>(isGuest.value);
    }
    if (statsSimple.present) {
      map['stats_simple'] = Variable<bool>(statsSimple.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('memberType: $memberType, ')
          ..write('shooting: $shooting, ')
          ..write('dribbling: $dribbling, ')
          ..write('speed: $speed, ')
          ..write('passing: $passing, ')
          ..write('physical: $physical, ')
          ..write('creativity: $creativity, ')
          ..write('teamwork: $teamwork, ')
          ..write('mainPosition: $mainPosition, ')
          ..write('subPositions: $subPositions, ')
          ..write('canKeep: $canKeep, ')
          ..write('isGuest: $isGuest, ')
          ..write('statsSimple: $statsSimple, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayerConstraintsTable extends PlayerConstraints
    with TableInfo<$PlayerConstraintsTable, ConstraintRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerConstraintsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ConstraintType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ConstraintType>($PlayerConstraintsTable.$convertertype);
  static const VerificationMeta _playerIdsMeta = const VerificationMeta(
    'playerIds',
  );
  @override
  late final GeneratedColumn<String> playerIds = GeneratedColumn<String>(
    'player_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    updatedBy,
    deletedAt,
    id,
    groupId,
    type,
    playerIds,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_constraints';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConstraintRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('player_ids')) {
      context.handle(
        _playerIdsMeta,
        playerIds.isAcceptableOrUnknown(data['player_ids']!, _playerIdsMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdsMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConstraintRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConstraintRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      type: $PlayerConstraintsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      playerIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_ids'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $PlayerConstraintsTable createAlias(String alias) {
    return $PlayerConstraintsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ConstraintType, String, String> $convertertype =
      const EnumNameConverter<ConstraintType>(ConstraintType.values);
}

class ConstraintRow extends DataClass implements Insertable<ConstraintRow> {
  final DateTime updatedAt;
  final String updatedBy;
  final DateTime? deletedAt;
  final String id;
  final String groupId;
  final ConstraintType type;

  /// 선수 id를 쉼표로 이은 값.
  final String playerIds;
  final String? note;
  const ConstraintRow({
    required this.updatedAt,
    required this.updatedBy,
    this.deletedAt,
    required this.id,
    required this.groupId,
    required this.type,
    required this.playerIds,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['updated_by'] = Variable<String>(updatedBy);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    {
      map['type'] = Variable<String>(
        $PlayerConstraintsTable.$convertertype.toSql(type),
      );
    }
    map['player_ids'] = Variable<String>(playerIds);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PlayerConstraintsCompanion toCompanion(bool nullToAbsent) {
    return PlayerConstraintsCompanion(
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      groupId: Value(groupId),
      type: Value(type),
      playerIds: Value(playerIds),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory ConstraintRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConstraintRow(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      type: $PlayerConstraintsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      playerIds: serializer.fromJson<String>(json['playerIds']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'type': serializer.toJson<String>(
        $PlayerConstraintsTable.$convertertype.toJson(type),
      ),
      'playerIds': serializer.toJson<String>(playerIds),
      'note': serializer.toJson<String?>(note),
    };
  }

  ConstraintRow copyWith({
    DateTime? updatedAt,
    String? updatedBy,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? groupId,
    ConstraintType? type,
    String? playerIds,
    Value<String?> note = const Value.absent(),
  }) => ConstraintRow(
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    type: type ?? this.type,
    playerIds: playerIds ?? this.playerIds,
    note: note.present ? note.value : this.note,
  );
  ConstraintRow copyWithCompanion(PlayerConstraintsCompanion data) {
    return ConstraintRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      type: data.type.present ? data.type.value : this.type,
      playerIds: data.playerIds.present ? data.playerIds.value : this.playerIds,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConstraintRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('type: $type, ')
          ..write('playerIds: $playerIds, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    updatedBy,
    deletedAt,
    id,
    groupId,
    type,
    playerIds,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConstraintRow &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.type == this.type &&
          other.playerIds == this.playerIds &&
          other.note == this.note);
}

class PlayerConstraintsCompanion extends UpdateCompanion<ConstraintRow> {
  final Value<DateTime> updatedAt;
  final Value<String> updatedBy;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> groupId;
  final Value<ConstraintType> type;
  final Value<String> playerIds;
  final Value<String?> note;
  final Value<int> rowid;
  const PlayerConstraintsCompanion({
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.type = const Value.absent(),
    this.playerIds = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayerConstraintsCompanion.insert({
    required DateTime updatedAt,
    required String updatedBy,
    this.deletedAt = const Value.absent(),
    required String id,
    required String groupId,
    required ConstraintType type,
    required String playerIds,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       updatedBy = Value(updatedBy),
       id = Value(id),
       groupId = Value(groupId),
       type = Value(type),
       playerIds = Value(playerIds);
  static Insertable<ConstraintRow> custom({
    Expression<DateTime>? updatedAt,
    Expression<String>? updatedBy,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? type,
    Expression<String>? playerIds,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (type != null) 'type': type,
      if (playerIds != null) 'player_ids': playerIds,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayerConstraintsCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<String>? updatedBy,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? groupId,
    Value<ConstraintType>? type,
    Value<String>? playerIds,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return PlayerConstraintsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      type: type ?? this.type,
      playerIds: playerIds ?? this.playerIds,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $PlayerConstraintsTable.$convertertype.toSql(type.value),
      );
    }
    if (playerIds.present) {
      map['player_ids'] = Variable<String>(playerIds.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerConstraintsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('type: $type, ')
          ..write('playerIds: $playerIds, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceSettingsTable extends DeviceSettings
    with TableInfo<$DeviceSettingsTable, DeviceSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  DeviceSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $DeviceSettingsTable createAlias(String alias) {
    return $DeviceSettingsTable(attachedDatabase, alias);
  }
}

class DeviceSettingRow extends DataClass
    implements Insertable<DeviceSettingRow> {
  final String key;
  final String value;
  const DeviceSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  DeviceSettingsCompanion toCompanion(bool nullToAbsent) {
    return DeviceSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory DeviceSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  DeviceSettingRow copyWith({String? key, String? value}) =>
      DeviceSettingRow(key: key ?? this.key, value: value ?? this.value);
  DeviceSettingRow copyWithCompanion(DeviceSettingsCompanion data) {
    return DeviceSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class DeviceSettingsCompanion extends UpdateCompanion<DeviceSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const DeviceSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<DeviceSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return DeviceSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionDraftsTable extends SessionDrafts
    with TableInfo<$SessionDraftsTable, SessionDraftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [groupId, json, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionDraftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId};
  @override
  SessionDraftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionDraftRow(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionDraftsTable createAlias(String alias) {
    return $SessionDraftsTable(attachedDatabase, alias);
  }
}

class SessionDraftRow extends DataClass implements Insertable<SessionDraftRow> {
  final String groupId;
  final String json;
  final DateTime updatedAt;
  const SessionDraftRow({
    required this.groupId,
    required this.json,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['json'] = Variable<String>(json);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionDraftsCompanion toCompanion(bool nullToAbsent) {
    return SessionDraftsCompanion(
      groupId: Value(groupId),
      json: Value(json),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionDraftRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionDraftRow(
      groupId: serializer.fromJson<String>(json['groupId']),
      json: serializer.fromJson<String>(json['json']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'json': serializer.toJson<String>(json),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SessionDraftRow copyWith({
    String? groupId,
    String? json,
    DateTime? updatedAt,
  }) => SessionDraftRow(
    groupId: groupId ?? this.groupId,
    json: json ?? this.json,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionDraftRow copyWithCompanion(SessionDraftsCompanion data) {
    return SessionDraftRow(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      json: data.json.present ? data.json.value : this.json,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionDraftRow(')
          ..write('groupId: $groupId, ')
          ..write('json: $json, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, json, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionDraftRow &&
          other.groupId == this.groupId &&
          other.json == this.json &&
          other.updatedAt == this.updatedAt);
}

class SessionDraftsCompanion extends UpdateCompanion<SessionDraftRow> {
  final Value<String> groupId;
  final Value<String> json;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionDraftsCompanion({
    this.groupId = const Value.absent(),
    this.json = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionDraftsCompanion.insert({
    required String groupId,
    required String json,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       json = Value(json),
       updatedAt = Value(updatedAt);
  static Insertable<SessionDraftRow> custom({
    Expression<String>? groupId,
    Expression<String>? json,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (json != null) 'json': json,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionDraftsCompanion copyWith({
    Value<String>? groupId,
    Value<String>? json,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionDraftsCompanion(
      groupId: groupId ?? this.groupId,
      json: json ?? this.json,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionDraftsCompanion(')
          ..write('groupId: $groupId, ')
          ..write('json: $json, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LineupHistoriesTable extends LineupHistories
    with TableInfo<$LineupHistoriesTable, LineupHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineupHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _confirmedAtMeta = const VerificationMeta(
    'confirmedAt',
  );
  @override
  late final GeneratedColumn<DateTime> confirmedAt = GeneratedColumn<DateTime>(
    'confirmed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceScoreMeta = const VerificationMeta(
    'balanceScore',
  );
  @override
  late final GeneratedColumn<double> balanceScore = GeneratedColumn<double>(
    'balance_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    updatedBy,
    deletedAt,
    id,
    groupId,
    confirmedAt,
    balanceScore,
    json,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lineup_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<LineupHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('confirmed_at')) {
      context.handle(
        _confirmedAtMeta,
        confirmedAt.isAcceptableOrUnknown(
          data['confirmed_at']!,
          _confirmedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confirmedAtMeta);
    }
    if (data.containsKey('balance_score')) {
      context.handle(
        _balanceScoreMeta,
        balanceScore.isAcceptableOrUnknown(
          data['balance_score']!,
          _balanceScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balanceScoreMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LineupHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineupHistoryRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      confirmedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}confirmed_at'],
      )!,
      balanceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance_score'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $LineupHistoriesTable createAlias(String alias) {
    return $LineupHistoriesTable(attachedDatabase, alias);
  }
}

class LineupHistoryRow extends DataClass
    implements Insertable<LineupHistoryRow> {
  final DateTime updatedAt;
  final String updatedBy;
  final DateTime? deletedAt;
  final String id;
  final String groupId;
  final DateTime confirmedAt;
  final double balanceScore;

  /// 편성 전체 (형식·팀별 이름/색/자리/후보/키퍼) JSON.
  final String json;
  const LineupHistoryRow({
    required this.updatedAt,
    required this.updatedBy,
    this.deletedAt,
    required this.id,
    required this.groupId,
    required this.confirmedAt,
    required this.balanceScore,
    required this.json,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['updated_by'] = Variable<String>(updatedBy);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['confirmed_at'] = Variable<DateTime>(confirmedAt);
    map['balance_score'] = Variable<double>(balanceScore);
    map['json'] = Variable<String>(json);
    return map;
  }

  LineupHistoriesCompanion toCompanion(bool nullToAbsent) {
    return LineupHistoriesCompanion(
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      groupId: Value(groupId),
      confirmedAt: Value(confirmedAt),
      balanceScore: Value(balanceScore),
      json: Value(json),
    );
  }

  factory LineupHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineupHistoryRow(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      confirmedAt: serializer.fromJson<DateTime>(json['confirmedAt']),
      balanceScore: serializer.fromJson<double>(json['balanceScore']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'confirmedAt': serializer.toJson<DateTime>(confirmedAt),
      'balanceScore': serializer.toJson<double>(balanceScore),
      'json': serializer.toJson<String>(json),
    };
  }

  LineupHistoryRow copyWith({
    DateTime? updatedAt,
    String? updatedBy,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? groupId,
    DateTime? confirmedAt,
    double? balanceScore,
    String? json,
  }) => LineupHistoryRow(
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    confirmedAt: confirmedAt ?? this.confirmedAt,
    balanceScore: balanceScore ?? this.balanceScore,
    json: json ?? this.json,
  );
  LineupHistoryRow copyWithCompanion(LineupHistoriesCompanion data) {
    return LineupHistoryRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      confirmedAt: data.confirmedAt.present
          ? data.confirmedAt.value
          : this.confirmedAt,
      balanceScore: data.balanceScore.present
          ? data.balanceScore.value
          : this.balanceScore,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineupHistoryRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('balanceScore: $balanceScore, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    updatedBy,
    deletedAt,
    id,
    groupId,
    confirmedAt,
    balanceScore,
    json,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineupHistoryRow &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.confirmedAt == this.confirmedAt &&
          other.balanceScore == this.balanceScore &&
          other.json == this.json);
}

class LineupHistoriesCompanion extends UpdateCompanion<LineupHistoryRow> {
  final Value<DateTime> updatedAt;
  final Value<String> updatedBy;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> groupId;
  final Value<DateTime> confirmedAt;
  final Value<double> balanceScore;
  final Value<String> json;
  final Value<int> rowid;
  const LineupHistoriesCompanion({
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.balanceScore = const Value.absent(),
    this.json = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LineupHistoriesCompanion.insert({
    required DateTime updatedAt,
    required String updatedBy,
    this.deletedAt = const Value.absent(),
    required String id,
    required String groupId,
    required DateTime confirmedAt,
    required double balanceScore,
    required String json,
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       updatedBy = Value(updatedBy),
       id = Value(id),
       groupId = Value(groupId),
       confirmedAt = Value(confirmedAt),
       balanceScore = Value(balanceScore),
       json = Value(json);
  static Insertable<LineupHistoryRow> custom({
    Expression<DateTime>? updatedAt,
    Expression<String>? updatedBy,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<DateTime>? confirmedAt,
    Expression<double>? balanceScore,
    Expression<String>? json,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (confirmedAt != null) 'confirmed_at': confirmedAt,
      if (balanceScore != null) 'balance_score': balanceScore,
      if (json != null) 'json': json,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LineupHistoriesCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<String>? updatedBy,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? groupId,
    Value<DateTime>? confirmedAt,
    Value<double>? balanceScore,
    Value<String>? json,
    Value<int>? rowid,
  }) {
    return LineupHistoriesCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      balanceScore: balanceScore ?? this.balanceScore,
      json: json ?? this.json,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (confirmedAt.present) {
      map['confirmed_at'] = Variable<DateTime>(confirmedAt.value);
    }
    if (balanceScore.present) {
      map['balance_score'] = Variable<double>(balanceScore.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineupHistoriesCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('balanceScore: $balanceScore, ')
          ..write('json: $json, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupSettingsTable extends GroupSettings
    with TableInfo<$GroupSettingsTable, GroupSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [groupId, key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, key};
  @override
  GroupSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupSettingRow(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GroupSettingsTable createAlias(String alias) {
    return $GroupSettingsTable(attachedDatabase, alias);
  }
}

class GroupSettingRow extends DataClass implements Insertable<GroupSettingRow> {
  final String groupId;
  final String key;
  final String value;
  final DateTime updatedAt;
  const GroupSettingRow({
    required this.groupId,
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GroupSettingsCompanion toCompanion(bool nullToAbsent) {
    return GroupSettingsCompanion(
      groupId: Value(groupId),
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory GroupSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupSettingRow(
      groupId: serializer.fromJson<String>(json['groupId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GroupSettingRow copyWith({
    String? groupId,
    String? key,
    String? value,
    DateTime? updatedAt,
  }) => GroupSettingRow(
    groupId: groupId ?? this.groupId,
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GroupSettingRow copyWithCompanion(GroupSettingsCompanion data) {
    return GroupSettingRow(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupSettingRow(')
          ..write('groupId: $groupId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupSettingRow &&
          other.groupId == this.groupId &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class GroupSettingsCompanion extends UpdateCompanion<GroupSettingRow> {
  final Value<String> groupId;
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GroupSettingsCompanion({
    this.groupId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupSettingsCompanion.insert({
    required String groupId,
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<GroupSettingRow> custom({
    Expression<String>? groupId,
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupSettingsCompanion copyWith({
    Value<String>? groupId,
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return GroupSettingsCompanion(
      groupId: groupId ?? this.groupId,
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupSettingsCompanion(')
          ..write('groupId: $groupId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $PlayerConstraintsTable playerConstraints =
      $PlayerConstraintsTable(this);
  late final $DeviceSettingsTable deviceSettings = $DeviceSettingsTable(this);
  late final $SessionDraftsTable sessionDrafts = $SessionDraftsTable(this);
  late final $LineupHistoriesTable lineupHistories = $LineupHistoriesTable(
    this,
  );
  late final $GroupSettingsTable groupSettings = $GroupSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    groups,
    players,
    playerConstraints,
    deviceSettings,
    sessionDrafts,
    lineupHistories,
    groupSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('players', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('player_constraints', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_drafts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lineup_histories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_settings', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  required String id,
  required String name,
  Value<String> icon,
  Value<int> color,
  required GroupRole myRole,
  Value<String?> myDisplayName,
  Value<MatchFormat> defaultFormat,
  Value<int> onboardingStep,
  required DateTime createdAt,
  required DateTime updatedAt,
  required DateTime lastUsedAt,
  Value<DateTime?> lastSharedAt,
  Value<int> rowid,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> icon,
  Value<int> color,
  Value<GroupRole> myRole,
  Value<String?> myDisplayName,
  Value<MatchFormat> defaultFormat,
  Value<int> onboardingStep,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> lastUsedAt,
  Value<DateTime?> lastSharedAt,
  Value<int> rowid,
});

final class $$GroupsTableReferences
    extends BaseReferences<_$AppDatabase, $GroupsTable, GroupRow> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlayersTable, List<PlayerRow>> _playersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.players,
    aliasName: 'groups__id__players__group_id',
  );

  $$PlayersTableProcessedTableManager get playersRefs {
    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlayerConstraintsTable, List<ConstraintRow>>
  _playerConstraintsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playerConstraints,
        aliasName: 'groups__id__player_constraints__group_id',
      );

  $$PlayerConstraintsTableProcessedTableManager get playerConstraintsRefs {
    final manager = $$PlayerConstraintsTableTableManager(
      $_db,
      $_db.playerConstraints,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playerConstraintsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionDraftsTable, List<SessionDraftRow>>
  _sessionDraftsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionDrafts,
    aliasName: 'groups__id__session_drafts__group_id',
  );

  $$SessionDraftsTableProcessedTableManager get sessionDraftsRefs {
    final manager = $$SessionDraftsTableTableManager(
      $_db,
      $_db.sessionDrafts,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionDraftsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LineupHistoriesTable, List<LineupHistoryRow>>
  _lineupHistoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lineupHistories,
    aliasName: 'groups__id__lineup_histories__group_id',
  );

  $$LineupHistoriesTableProcessedTableManager get lineupHistoriesRefs {
    final manager = $$LineupHistoriesTableTableManager(
      $_db,
      $_db.lineupHistories,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _lineupHistoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GroupSettingsTable, List<GroupSettingRow>>
  _groupSettingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupSettings,
    aliasName: 'groups__id__group_settings__group_id',
  );

  $$GroupSettingsTableProcessedTableManager get groupSettingsRefs {
    final manager = $$GroupSettingsTableTableManager(
      $_db,
      $_db.groupSettings,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupSettingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GroupRole, GroupRole, String> get myRole =>
      $composableBuilder(
        column: $table.myRole,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get myDisplayName => $composableBuilder(
    column: $table.myDisplayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MatchFormat, MatchFormat, String>
  get defaultFormat => $composableBuilder(
    column: $table.defaultFormat,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get onboardingStep => $composableBuilder(
    column: $table.onboardingStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSharedAt => $composableBuilder(
    column: $table.lastSharedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playersRefs(
    Expression<bool> Function($$PlayersTableFilterComposer f) f,
  ) {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playerConstraintsRefs(
    Expression<bool> Function($$PlayerConstraintsTableFilterComposer f) f,
  ) {
    final $$PlayerConstraintsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playerConstraints,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerConstraintsTableFilterComposer(
            $db: $db,
            $table: $db.playerConstraints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionDraftsRefs(
    Expression<bool> Function($$SessionDraftsTableFilterComposer f) f,
  ) {
    final $$SessionDraftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionDrafts,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionDraftsTableFilterComposer(
            $db: $db,
            $table: $db.sessionDrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lineupHistoriesRefs(
    Expression<bool> Function($$LineupHistoriesTableFilterComposer f) f,
  ) {
    final $$LineupHistoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineupHistories,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineupHistoriesTableFilterComposer(
            $db: $db,
            $table: $db.lineupHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> groupSettingsRefs(
    Expression<bool> Function($$GroupSettingsTableFilterComposer f) f,
  ) {
    final $$GroupSettingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupSettings,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupSettingsTableFilterComposer(
            $db: $db,
            $table: $db.groupSettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get myRole => $composableBuilder(
    column: $table.myRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get myDisplayName => $composableBuilder(
    column: $table.myDisplayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultFormat => $composableBuilder(
    column: $table.defaultFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get onboardingStep => $composableBuilder(
    column: $table.onboardingStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSharedAt => $composableBuilder(
    column: $table.lastSharedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GroupRole, String> get myRole =>
      $composableBuilder(column: $table.myRole, builder: (column) => column);

  GeneratedColumn<String> get myDisplayName => $composableBuilder(
    column: $table.myDisplayName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MatchFormat, String> get defaultFormat =>
      $composableBuilder(
        column: $table.defaultFormat,
        builder: (column) => column,
      );

  GeneratedColumn<int> get onboardingStep => $composableBuilder(
    column: $table.onboardingStep,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSharedAt => $composableBuilder(
    column: $table.lastSharedAt,
    builder: (column) => column,
  );

  Expression<T> playersRefs<T extends Object>(
    Expression<T> Function($$PlayersTableAnnotationComposer a) f,
  ) {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> playerConstraintsRefs<T extends Object>(
    Expression<T> Function($$PlayerConstraintsTableAnnotationComposer a) f,
  ) {
    final $$PlayerConstraintsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playerConstraints,
          getReferencedColumn: (t) => t.groupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlayerConstraintsTableAnnotationComposer(
                $db: $db,
                $table: $db.playerConstraints,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> sessionDraftsRefs<T extends Object>(
    Expression<T> Function($$SessionDraftsTableAnnotationComposer a) f,
  ) {
    final $$SessionDraftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionDrafts,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionDraftsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionDrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lineupHistoriesRefs<T extends Object>(
    Expression<T> Function($$LineupHistoriesTableAnnotationComposer a) f,
  ) {
    final $$LineupHistoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineupHistories,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineupHistoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.lineupHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> groupSettingsRefs<T extends Object>(
    Expression<T> Function($$GroupSettingsTableAnnotationComposer a) f,
  ) {
    final $$GroupSettingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupSettings,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupSettingsTableAnnotationComposer(
            $db: $db,
            $table: $db.groupSettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupsTable,
          GroupRow,
          $$GroupsTableFilterComposer,
          $$GroupsTableOrderingComposer,
          $$GroupsTableAnnotationComposer,
          $$GroupsTableCreateCompanionBuilder,
          $$GroupsTableUpdateCompanionBuilder,
          (GroupRow, $$GroupsTableReferences),
          GroupRow,
          PrefetchHooks Function({
            bool playersRefs,
            bool playerConstraintsRefs,
            bool sessionDraftsRefs,
            bool lineupHistoriesRefs,
            bool groupSettingsRefs,
          })
        > {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<GroupRole> myRole = const Value.absent(),
                Value<String?> myDisplayName = const Value.absent(),
                Value<MatchFormat> defaultFormat = const Value.absent(),
                Value<int> onboardingStep = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> lastUsedAt = const Value.absent(),
                Value<DateTime?> lastSharedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion(
                id: id,
                name: name,
                icon: icon,
                color: color,
                myRole: myRole,
                myDisplayName: myDisplayName,
                defaultFormat: defaultFormat,
                onboardingStep: onboardingStep,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastUsedAt: lastUsedAt,
                lastSharedAt: lastSharedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                required GroupRole myRole,
                Value<String?> myDisplayName = const Value.absent(),
                Value<MatchFormat> defaultFormat = const Value.absent(),
                Value<int> onboardingStep = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime lastUsedAt,
                Value<DateTime?> lastSharedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                color: color,
                myRole: myRole,
                myDisplayName: myDisplayName,
                defaultFormat: defaultFormat,
                onboardingStep: onboardingStep,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastUsedAt: lastUsedAt,
                lastSharedAt: lastSharedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupsTable, GroupRow>(table),
                  $$GroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                playersRefs = false,
                playerConstraintsRefs = false,
                sessionDraftsRefs = false,
                lineupHistoriesRefs = false,
                groupSettingsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playersRefs) db.players,
                    if (playerConstraintsRefs) db.playerConstraints,
                    if (sessionDraftsRefs) db.sessionDrafts,
                    if (lineupHistoriesRefs) db.lineupHistories,
                    if (groupSettingsRefs) db.groupSettings,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playersRefs)
                        await $_getPrefetchedDataByColumns<
                          GroupRow,
                          $GroupsTable,
                          PlayerRow,
                          $PlayersTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._playersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).playersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'group_id',
                          typedResults: items,
                        ),
                      if (playerConstraintsRefs)
                        await $_getPrefetchedDataByColumns<
                          GroupRow,
                          $GroupsTable,
                          ConstraintRow,
                          $PlayerConstraintsTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._playerConstraintsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).playerConstraintsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'group_id',
                          typedResults: items,
                        ),
                      if (sessionDraftsRefs)
                        await $_getPrefetchedDataByColumns<
                          GroupRow,
                          $GroupsTable,
                          SessionDraftRow,
                          $SessionDraftsTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._sessionDraftsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionDraftsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'group_id',
                          typedResults: items,
                        ),
                      if (lineupHistoriesRefs)
                        await $_getPrefetchedDataByColumns<
                          GroupRow,
                          $GroupsTable,
                          LineupHistoryRow,
                          $LineupHistoriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._lineupHistoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).lineupHistoriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'group_id',
                          typedResults: items,
                        ),
                      if (groupSettingsRefs)
                        await $_getPrefetchedDataByColumns<
                          GroupRow,
                          $GroupsTable,
                          GroupSettingRow,
                          $GroupSettingsTable
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._groupSettingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).groupSettingsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'group_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupsTable,
      GroupRow,
      $$GroupsTableFilterComposer,
      $$GroupsTableOrderingComposer,
      $$GroupsTableAnnotationComposer,
      $$GroupsTableCreateCompanionBuilder,
      $$GroupsTableUpdateCompanionBuilder,
      (GroupRow, $$GroupsTableReferences),
      GroupRow,
      PrefetchHooks Function({
        bool playersRefs,
        bool playerConstraintsRefs,
        bool sessionDraftsRefs,
        bool lineupHistoriesRefs,
        bool groupSettingsRefs,
      })
    >;
typedef $$PlayersTableCreateCompanionBuilder = PlayersCompanion Function({
  required DateTime updatedAt,
  required String updatedBy,
  Value<DateTime?> deletedAt,
  required String id,
  required String groupId,
  required String name,
  Value<String?> nickname,
  required MemberType memberType,
  required int shooting,
  required int dribbling,
  required int speed,
  required int passing,
  required int physical,
  required int creativity,
  required int teamwork,
  required Position mainPosition,
  Value<String> subPositions,
  Value<bool> canKeep,
  Value<bool> isGuest,
  Value<bool> statsSimple,
  Value<String?> memo,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PlayersTableUpdateCompanionBuilder = PlayersCompanion Function({
  Value<DateTime> updatedAt,
  Value<String> updatedBy,
  Value<DateTime?> deletedAt,
  Value<String> id,
  Value<String> groupId,
  Value<String> name,
  Value<String?> nickname,
  Value<MemberType> memberType,
  Value<int> shooting,
  Value<int> dribbling,
  Value<int> speed,
  Value<int> passing,
  Value<int> physical,
  Value<int> creativity,
  Value<int> teamwork,
  Value<Position> mainPosition,
  Value<String> subPositions,
  Value<bool> canKeep,
  Value<bool> isGuest,
  Value<bool> statsSimple,
  Value<String?> memo,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$PlayersTableReferences
    extends BaseReferences<_$AppDatabase, $PlayersTable, PlayerRow> {
  $$PlayersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$AppDatabase db) =>
      db.groups.createAlias('players__group_id__groups__id');

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MemberType, MemberType, String>
  get memberType => $composableBuilder(
    column: $table.memberType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get shooting => $composableBuilder(
    column: $table.shooting,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dribbling => $composableBuilder(
    column: $table.dribbling,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passing => $composableBuilder(
    column: $table.passing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get physical => $composableBuilder(
    column: $table.physical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creativity => $composableBuilder(
    column: $table.creativity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get teamwork => $composableBuilder(
    column: $table.teamwork,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Position, Position, String> get mainPosition =>
      $composableBuilder(
        column: $table.mainPosition,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get subPositions => $composableBuilder(
    column: $table.subPositions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canKeep => $composableBuilder(
    column: $table.canKeep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGuest => $composableBuilder(
    column: $table.isGuest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get statsSimple => $composableBuilder(
    column: $table.statsSimple,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberType => $composableBuilder(
    column: $table.memberType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shooting => $composableBuilder(
    column: $table.shooting,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dribbling => $composableBuilder(
    column: $table.dribbling,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passing => $composableBuilder(
    column: $table.passing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get physical => $composableBuilder(
    column: $table.physical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creativity => $composableBuilder(
    column: $table.creativity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get teamwork => $composableBuilder(
    column: $table.teamwork,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mainPosition => $composableBuilder(
    column: $table.mainPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subPositions => $composableBuilder(
    column: $table.subPositions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canKeep => $composableBuilder(
    column: $table.canKeep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGuest => $composableBuilder(
    column: $table.isGuest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get statsSimple => $composableBuilder(
    column: $table.statsSimple,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MemberType, String> get memberType =>
      $composableBuilder(
        column: $table.memberType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get shooting =>
      $composableBuilder(column: $table.shooting, builder: (column) => column);

  GeneratedColumn<int> get dribbling =>
      $composableBuilder(column: $table.dribbling, builder: (column) => column);

  GeneratedColumn<int> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<int> get passing =>
      $composableBuilder(column: $table.passing, builder: (column) => column);

  GeneratedColumn<int> get physical =>
      $composableBuilder(column: $table.physical, builder: (column) => column);

  GeneratedColumn<int> get creativity => $composableBuilder(
    column: $table.creativity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get teamwork =>
      $composableBuilder(column: $table.teamwork, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Position, String> get mainPosition =>
      $composableBuilder(
        column: $table.mainPosition,
        builder: (column) => column,
      );

  GeneratedColumn<String> get subPositions => $composableBuilder(
    column: $table.subPositions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canKeep =>
      $composableBuilder(column: $table.canKeep, builder: (column) => column);

  GeneratedColumn<bool> get isGuest =>
      $composableBuilder(column: $table.isGuest, builder: (column) => column);

  GeneratedColumn<bool> get statsSimple => $composableBuilder(
    column: $table.statsSimple,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayersTable,
          PlayerRow,
          $$PlayersTableFilterComposer,
          $$PlayersTableOrderingComposer,
          $$PlayersTableAnnotationComposer,
          $$PlayersTableCreateCompanionBuilder,
          $$PlayersTableUpdateCompanionBuilder,
          (PlayerRow, $$PlayersTableReferences),
          PlayerRow,
          PrefetchHooks Function({bool groupId})
        > {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<MemberType> memberType = const Value.absent(),
                Value<int> shooting = const Value.absent(),
                Value<int> dribbling = const Value.absent(),
                Value<int> speed = const Value.absent(),
                Value<int> passing = const Value.absent(),
                Value<int> physical = const Value.absent(),
                Value<int> creativity = const Value.absent(),
                Value<int> teamwork = const Value.absent(),
                Value<Position> mainPosition = const Value.absent(),
                Value<String> subPositions = const Value.absent(),
                Value<bool> canKeep = const Value.absent(),
                Value<bool> isGuest = const Value.absent(),
                Value<bool> statsSimple = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayersCompanion(
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                id: id,
                groupId: groupId,
                name: name,
                nickname: nickname,
                memberType: memberType,
                shooting: shooting,
                dribbling: dribbling,
                speed: speed,
                passing: passing,
                physical: physical,
                creativity: creativity,
                teamwork: teamwork,
                mainPosition: mainPosition,
                subPositions: subPositions,
                canKeep: canKeep,
                isGuest: isGuest,
                statsSimple: statsSimple,
                memo: memo,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                required String updatedBy,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String groupId,
                required String name,
                Value<String?> nickname = const Value.absent(),
                required MemberType memberType,
                required int shooting,
                required int dribbling,
                required int speed,
                required int passing,
                required int physical,
                required int creativity,
                required int teamwork,
                required Position mainPosition,
                Value<String> subPositions = const Value.absent(),
                Value<bool> canKeep = const Value.absent(),
                Value<bool> isGuest = const Value.absent(),
                Value<bool> statsSimple = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PlayersCompanion.insert(
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                id: id,
                groupId: groupId,
                name: name,
                nickname: nickname,
                memberType: memberType,
                shooting: shooting,
                dribbling: dribbling,
                speed: speed,
                passing: passing,
                physical: physical,
                creativity: creativity,
                teamwork: teamwork,
                mainPosition: mainPosition,
                subPositions: subPositions,
                canKeep: canKeep,
                isGuest: isGuest,
                statsSimple: statsSimple,
                memo: memo,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayersTable, PlayerRow>(table),
                  $$PlayersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (groupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.groupId,
                        referencedTable: $$PlayersTableReferences._groupIdTable(
                          db,
                        ),
                        referencedColumn: $$PlayersTableReferences
                            ._groupIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayersTable,
      PlayerRow,
      $$PlayersTableFilterComposer,
      $$PlayersTableOrderingComposer,
      $$PlayersTableAnnotationComposer,
      $$PlayersTableCreateCompanionBuilder,
      $$PlayersTableUpdateCompanionBuilder,
      (PlayerRow, $$PlayersTableReferences),
      PlayerRow,
      PrefetchHooks Function({bool groupId})
    >;
typedef $$PlayerConstraintsTableCreateCompanionBuilder =
    PlayerConstraintsCompanion Function({
      required DateTime updatedAt,
      required String updatedBy,
      Value<DateTime?> deletedAt,
      required String id,
      required String groupId,
      required ConstraintType type,
      required String playerIds,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$PlayerConstraintsTableUpdateCompanionBuilder =
    PlayerConstraintsCompanion Function({
      Value<DateTime> updatedAt,
      Value<String> updatedBy,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> groupId,
      Value<ConstraintType> type,
      Value<String> playerIds,
      Value<String?> note,
      Value<int> rowid,
    });

final class $$PlayerConstraintsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PlayerConstraintsTable, ConstraintRow> {
  $$PlayerConstraintsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroupsTable _groupIdTable(_$AppDatabase db) =>
      db.groups.createAlias('player_constraints__group_id__groups__id');

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlayerConstraintsTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerConstraintsTable> {
  $$PlayerConstraintsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ConstraintType, ConstraintType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get playerIds => $composableBuilder(
    column: $table.playerIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayerConstraintsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerConstraintsTable> {
  $$PlayerConstraintsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerIds => $composableBuilder(
    column: $table.playerIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayerConstraintsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerConstraintsTable> {
  $$PlayerConstraintsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ConstraintType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get playerIds =>
      $composableBuilder(column: $table.playerIds, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayerConstraintsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerConstraintsTable,
          ConstraintRow,
          $$PlayerConstraintsTableFilterComposer,
          $$PlayerConstraintsTableOrderingComposer,
          $$PlayerConstraintsTableAnnotationComposer,
          $$PlayerConstraintsTableCreateCompanionBuilder,
          $$PlayerConstraintsTableUpdateCompanionBuilder,
          (ConstraintRow, $$PlayerConstraintsTableReferences),
          ConstraintRow,
          PrefetchHooks Function({bool groupId})
        > {
  $$PlayerConstraintsTableTableManager(
    _$AppDatabase db,
    $PlayerConstraintsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerConstraintsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerConstraintsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerConstraintsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<ConstraintType> type = const Value.absent(),
                Value<String> playerIds = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerConstraintsCompanion(
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                id: id,
                groupId: groupId,
                type: type,
                playerIds: playerIds,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                required String updatedBy,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String groupId,
                required ConstraintType type,
                required String playerIds,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerConstraintsCompanion.insert(
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                id: id,
                groupId: groupId,
                type: type,
                playerIds: playerIds,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayerConstraintsTable, ConstraintRow>(table),
                  $$PlayerConstraintsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (groupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.groupId,
                        referencedTable: $$PlayerConstraintsTableReferences
                            ._groupIdTable(db),
                        referencedColumn: $$PlayerConstraintsTableReferences
                            ._groupIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlayerConstraintsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerConstraintsTable,
      ConstraintRow,
      $$PlayerConstraintsTableFilterComposer,
      $$PlayerConstraintsTableOrderingComposer,
      $$PlayerConstraintsTableAnnotationComposer,
      $$PlayerConstraintsTableCreateCompanionBuilder,
      $$PlayerConstraintsTableUpdateCompanionBuilder,
      (ConstraintRow, $$PlayerConstraintsTableReferences),
      ConstraintRow,
      PrefetchHooks Function({bool groupId})
    >;
typedef $$DeviceSettingsTableCreateCompanionBuilder =
    DeviceSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$DeviceSettingsTableUpdateCompanionBuilder =
    DeviceSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$DeviceSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceSettingsTable> {
  $$DeviceSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeviceSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceSettingsTable> {
  $$DeviceSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeviceSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceSettingsTable> {
  $$DeviceSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$DeviceSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceSettingsTable,
          DeviceSettingRow,
          $$DeviceSettingsTableFilterComposer,
          $$DeviceSettingsTableOrderingComposer,
          $$DeviceSettingsTableAnnotationComposer,
          $$DeviceSettingsTableCreateCompanionBuilder,
          $$DeviceSettingsTableUpdateCompanionBuilder,
          (
            DeviceSettingRow,
            BaseReferences<
              _$AppDatabase,
              $DeviceSettingsTable,
              DeviceSettingRow
            >,
          ),
          DeviceSettingRow,
          PrefetchHooks Function()
        > {
  $$DeviceSettingsTableTableManager(
    _$AppDatabase db,
    $DeviceSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => DeviceSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => DeviceSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DeviceSettingsTable, DeviceSettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DeviceSettingsTable,
                    DeviceSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeviceSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceSettingsTable,
      DeviceSettingRow,
      $$DeviceSettingsTableFilterComposer,
      $$DeviceSettingsTableOrderingComposer,
      $$DeviceSettingsTableAnnotationComposer,
      $$DeviceSettingsTableCreateCompanionBuilder,
      $$DeviceSettingsTableUpdateCompanionBuilder,
      (
        DeviceSettingRow,
        BaseReferences<_$AppDatabase, $DeviceSettingsTable, DeviceSettingRow>,
      ),
      DeviceSettingRow,
      PrefetchHooks Function()
    >;
typedef $$SessionDraftsTableCreateCompanionBuilder =
    SessionDraftsCompanion Function({
      required String groupId,
      required String json,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SessionDraftsTableUpdateCompanionBuilder =
    SessionDraftsCompanion Function({
      Value<String> groupId,
      Value<String> json,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SessionDraftsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SessionDraftsTable, SessionDraftRow> {
  $$SessionDraftsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroupsTable _groupIdTable(_$AppDatabase db) =>
      db.groups.createAlias('session_drafts__group_id__groups__id');

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionDraftsTable> {
  $$SessionDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionDraftsTable> {
  $$SessionDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionDraftsTable> {
  $$SessionDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionDraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionDraftsTable,
          SessionDraftRow,
          $$SessionDraftsTableFilterComposer,
          $$SessionDraftsTableOrderingComposer,
          $$SessionDraftsTableAnnotationComposer,
          $$SessionDraftsTableCreateCompanionBuilder,
          $$SessionDraftsTableUpdateCompanionBuilder,
          (SessionDraftRow, $$SessionDraftsTableReferences),
          SessionDraftRow,
          PrefetchHooks Function({bool groupId})
        > {
  $$SessionDraftsTableTableManager(_$AppDatabase db, $SessionDraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> groupId = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionDraftsCompanion(
                groupId: groupId,
                json: json,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String groupId,
                required String json,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionDraftsCompanion.insert(
                groupId: groupId,
                json: json,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionDraftsTable, SessionDraftRow>(table),
                  $$SessionDraftsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (groupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.groupId,
                        referencedTable: $$SessionDraftsTableReferences
                            ._groupIdTable(db),
                        referencedColumn: $$SessionDraftsTableReferences
                            ._groupIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionDraftsTable,
      SessionDraftRow,
      $$SessionDraftsTableFilterComposer,
      $$SessionDraftsTableOrderingComposer,
      $$SessionDraftsTableAnnotationComposer,
      $$SessionDraftsTableCreateCompanionBuilder,
      $$SessionDraftsTableUpdateCompanionBuilder,
      (SessionDraftRow, $$SessionDraftsTableReferences),
      SessionDraftRow,
      PrefetchHooks Function({bool groupId})
    >;
typedef $$LineupHistoriesTableCreateCompanionBuilder =
    LineupHistoriesCompanion Function({
      required DateTime updatedAt,
      required String updatedBy,
      Value<DateTime?> deletedAt,
      required String id,
      required String groupId,
      required DateTime confirmedAt,
      required double balanceScore,
      required String json,
      Value<int> rowid,
    });
typedef $$LineupHistoriesTableUpdateCompanionBuilder =
    LineupHistoriesCompanion Function({
      Value<DateTime> updatedAt,
      Value<String> updatedBy,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> groupId,
      Value<DateTime> confirmedAt,
      Value<double> balanceScore,
      Value<String> json,
      Value<int> rowid,
    });

final class $$LineupHistoriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $LineupHistoriesTable, LineupHistoryRow> {
  $$LineupHistoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroupsTable _groupIdTable(_$AppDatabase db) =>
      db.groups.createAlias('lineup_histories__group_id__groups__id');

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LineupHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LineupHistoriesTable> {
  $$LineupHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balanceScore => $composableBuilder(
    column: $table.balanceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineupHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LineupHistoriesTable> {
  $$LineupHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balanceScore => $composableBuilder(
    column: $table.balanceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineupHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LineupHistoriesTable> {
  $$LineupHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get balanceScore => $composableBuilder(
    column: $table.balanceScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineupHistoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LineupHistoriesTable,
          LineupHistoryRow,
          $$LineupHistoriesTableFilterComposer,
          $$LineupHistoriesTableOrderingComposer,
          $$LineupHistoriesTableAnnotationComposer,
          $$LineupHistoriesTableCreateCompanionBuilder,
          $$LineupHistoriesTableUpdateCompanionBuilder,
          (LineupHistoryRow, $$LineupHistoriesTableReferences),
          LineupHistoryRow,
          PrefetchHooks Function({bool groupId})
        > {
  $$LineupHistoriesTableTableManager(
    _$AppDatabase db,
    $LineupHistoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineupHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineupHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineupHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<DateTime> confirmedAt = const Value.absent(),
                Value<double> balanceScore = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LineupHistoriesCompanion(
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                id: id,
                groupId: groupId,
                confirmedAt: confirmedAt,
                balanceScore: balanceScore,
                json: json,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                required String updatedBy,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String groupId,
                required DateTime confirmedAt,
                required double balanceScore,
                required String json,
                Value<int> rowid = const Value.absent(),
              }) => LineupHistoriesCompanion.insert(
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                id: id,
                groupId: groupId,
                confirmedAt: confirmedAt,
                balanceScore: balanceScore,
                json: json,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LineupHistoriesTable, LineupHistoryRow>(table),
                  $$LineupHistoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (groupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.groupId,
                        referencedTable: $$LineupHistoriesTableReferences
                            ._groupIdTable(db),
                        referencedColumn: $$LineupHistoriesTableReferences
                            ._groupIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LineupHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LineupHistoriesTable,
      LineupHistoryRow,
      $$LineupHistoriesTableFilterComposer,
      $$LineupHistoriesTableOrderingComposer,
      $$LineupHistoriesTableAnnotationComposer,
      $$LineupHistoriesTableCreateCompanionBuilder,
      $$LineupHistoriesTableUpdateCompanionBuilder,
      (LineupHistoryRow, $$LineupHistoriesTableReferences),
      LineupHistoryRow,
      PrefetchHooks Function({bool groupId})
    >;
typedef $$GroupSettingsTableCreateCompanionBuilder =
    GroupSettingsCompanion Function({
      required String groupId,
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$GroupSettingsTableUpdateCompanionBuilder =
    GroupSettingsCompanion Function({
      Value<String> groupId,
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$GroupSettingsTableReferences
    extends
        BaseReferences<_$AppDatabase, $GroupSettingsTable, GroupSettingRow> {
  $$GroupSettingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroupsTable _groupIdTable(_$AppDatabase db) =>
      db.groups.createAlias('group_settings__group_id__groups__id');

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroupSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupSettingsTable> {
  $$GroupSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupSettingsTable> {
  $$GroupSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupSettingsTable> {
  $$GroupSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupSettingsTable,
          GroupSettingRow,
          $$GroupSettingsTableFilterComposer,
          $$GroupSettingsTableOrderingComposer,
          $$GroupSettingsTableAnnotationComposer,
          $$GroupSettingsTableCreateCompanionBuilder,
          $$GroupSettingsTableUpdateCompanionBuilder,
          (GroupSettingRow, $$GroupSettingsTableReferences),
          GroupSettingRow,
          PrefetchHooks Function({bool groupId})
        > {
  $$GroupSettingsTableTableManager(_$AppDatabase db, $GroupSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> groupId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupSettingsCompanion(
                groupId: groupId,
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String groupId,
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => GroupSettingsCompanion.insert(
                groupId: groupId,
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupSettingsTable, GroupSettingRow>(table),
                  $$GroupSettingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (groupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.groupId,
                        referencedTable: $$GroupSettingsTableReferences
                            ._groupIdTable(db),
                        referencedColumn: $$GroupSettingsTableReferences
                            ._groupIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GroupSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupSettingsTable,
      GroupSettingRow,
      $$GroupSettingsTableFilterComposer,
      $$GroupSettingsTableOrderingComposer,
      $$GroupSettingsTableAnnotationComposer,
      $$GroupSettingsTableCreateCompanionBuilder,
      $$GroupSettingsTableUpdateCompanionBuilder,
      (GroupSettingRow, $$GroupSettingsTableReferences),
      GroupSettingRow,
      PrefetchHooks Function({bool groupId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$PlayerConstraintsTableTableManager get playerConstraints =>
      $$PlayerConstraintsTableTableManager(_db, _db.playerConstraints);
  $$DeviceSettingsTableTableManager get deviceSettings =>
      $$DeviceSettingsTableTableManager(_db, _db.deviceSettings);
  $$SessionDraftsTableTableManager get sessionDrafts =>
      $$SessionDraftsTableTableManager(_db, _db.sessionDrafts);
  $$LineupHistoriesTableTableManager get lineupHistories =>
      $$LineupHistoriesTableTableManager(_db, _db.lineupHistories);
  $$GroupSettingsTableTableManager get groupSettings =>
      $$GroupSettingsTableTableManager(_db, _db.groupSettings);
}
