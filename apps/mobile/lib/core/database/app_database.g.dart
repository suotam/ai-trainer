// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalWorkoutInstancesTable extends LocalWorkoutInstances
    with TableInfo<$LocalWorkoutInstancesTable, LocalWorkoutInstanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalWorkoutInstancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workoutTypeMeta = const VerificationMeta(
    'workoutType',
  );
  @override
  late final GeneratedColumn<String> workoutType = GeneratedColumn<String>(
    'workout_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledLocalDateMeta =
      const VerificationMeta('scheduledLocalDate');
  @override
  late final GeneratedColumn<String> scheduledLocalDate =
      GeneratedColumn<String>(
        'scheduled_local_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _scheduledStartAtMeta = const VerificationMeta(
    'scheduledStartAt',
  );
  @override
  late final GeneratedColumn<int> scheduledStartAt = GeneratedColumn<int>(
    'scheduled_start_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeZoneIdMeta = const VerificationMeta(
    'timeZoneId',
  );
  @override
  late final GeneratedColumn<String> timeZoneId = GeneratedColumn<String>(
    'time_zone_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedDurationSecondsMeta =
      const VerificationMeta('plannedDurationSeconds');
  @override
  late final GeneratedColumn<int> plannedDurationSeconds = GeneratedColumn<int>(
    'planned_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceReferenceMeta = const VerificationMeta(
    'sourceReference',
  );
  @override
  late final GeneratedColumn<String> sourceReference = GeneratedColumn<String>(
    'source_reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionNumberMeta = const VerificationMeta(
    'revisionNumber',
  );
  @override
  late final GeneratedColumn<int> revisionNumber = GeneratedColumn<int>(
    'revision_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedSessionIdMeta = const VerificationMeta(
    'startedSessionId',
  );
  @override
  late final GeneratedColumn<String> startedSessionId = GeneratedColumn<String>(
    'started_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(localAnonymousOwnerId),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(syncStateLocalOnly),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    purpose,
    workoutType,
    scheduledLocalDate,
    scheduledStartAt,
    timeZoneId,
    plannedDurationSeconds,
    status,
    sourceType,
    sourceReference,
    revisionNumber,
    startedSessionId,
    completedAt,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_workout_instances';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalWorkoutInstanceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    }
    if (data.containsKey('workout_type')) {
      context.handle(
        _workoutTypeMeta,
        workoutType.isAcceptableOrUnknown(
          data['workout_type']!,
          _workoutTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutTypeMeta);
    }
    if (data.containsKey('scheduled_local_date')) {
      context.handle(
        _scheduledLocalDateMeta,
        scheduledLocalDate.isAcceptableOrUnknown(
          data['scheduled_local_date']!,
          _scheduledLocalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledLocalDateMeta);
    }
    if (data.containsKey('scheduled_start_at')) {
      context.handle(
        _scheduledStartAtMeta,
        scheduledStartAt.isAcceptableOrUnknown(
          data['scheduled_start_at']!,
          _scheduledStartAtMeta,
        ),
      );
    }
    if (data.containsKey('time_zone_id')) {
      context.handle(
        _timeZoneIdMeta,
        timeZoneId.isAcceptableOrUnknown(
          data['time_zone_id']!,
          _timeZoneIdMeta,
        ),
      );
    }
    if (data.containsKey('planned_duration_seconds')) {
      context.handle(
        _plannedDurationSecondsMeta,
        plannedDurationSeconds.isAcceptableOrUnknown(
          data['planned_duration_seconds']!,
          _plannedDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_reference')) {
      context.handle(
        _sourceReferenceMeta,
        sourceReference.isAcceptableOrUnknown(
          data['source_reference']!,
          _sourceReferenceMeta,
        ),
      );
    }
    if (data.containsKey('revision_number')) {
      context.handle(
        _revisionNumberMeta,
        revisionNumber.isAcceptableOrUnknown(
          data['revision_number']!,
          _revisionNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_revisionNumberMeta);
    }
    if (data.containsKey('started_session_id')) {
      context.handle(
        _startedSessionIdMeta,
        startedSessionId.isAcceptableOrUnknown(
          data['started_session_id']!,
          _startedSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
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
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_rowVersionMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalWorkoutInstanceRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalWorkoutInstanceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      ),
      workoutType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_type'],
      )!,
      scheduledLocalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheduled_local_date'],
      )!,
      scheduledStartAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_start_at'],
      ),
      timeZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone_id'],
      ),
      plannedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_duration_seconds'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      sourceReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_reference'],
      ),
      revisionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_number'],
      )!,
      startedSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_session_id'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $LocalWorkoutInstancesTable createAlias(String alias) {
    return $LocalWorkoutInstancesTable(attachedDatabase, alias);
  }
}

class LocalWorkoutInstanceRow extends DataClass
    implements Insertable<LocalWorkoutInstanceRow> {
  final String id;
  final String title;
  final String? description;
  final String? purpose;
  final String workoutType;
  final String scheduledLocalDate;
  final int? scheduledStartAt;
  final String? timeZoneId;
  final int? plannedDurationSeconds;
  final String status;
  final String sourceType;
  final String? sourceReference;
  final int revisionNumber;
  final String? startedSessionId;
  final int? completedAt;
  final int createdAt;
  final int updatedAt;
  final int rowVersion;
  final String ownerId;
  final String syncState;
  const LocalWorkoutInstanceRow({
    required this.id,
    required this.title,
    this.description,
    this.purpose,
    required this.workoutType,
    required this.scheduledLocalDate,
    this.scheduledStartAt,
    this.timeZoneId,
    this.plannedDurationSeconds,
    required this.status,
    required this.sourceType,
    this.sourceReference,
    required this.revisionNumber,
    this.startedSessionId,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.rowVersion,
    required this.ownerId,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    map['workout_type'] = Variable<String>(workoutType);
    map['scheduled_local_date'] = Variable<String>(scheduledLocalDate);
    if (!nullToAbsent || scheduledStartAt != null) {
      map['scheduled_start_at'] = Variable<int>(scheduledStartAt);
    }
    if (!nullToAbsent || timeZoneId != null) {
      map['time_zone_id'] = Variable<String>(timeZoneId);
    }
    if (!nullToAbsent || plannedDurationSeconds != null) {
      map['planned_duration_seconds'] = Variable<int>(plannedDurationSeconds);
    }
    map['status'] = Variable<String>(status);
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || sourceReference != null) {
      map['source_reference'] = Variable<String>(sourceReference);
    }
    map['revision_number'] = Variable<int>(revisionNumber);
    if (!nullToAbsent || startedSessionId != null) {
      map['started_session_id'] = Variable<String>(startedSessionId);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['row_version'] = Variable<int>(rowVersion);
    map['owner_id'] = Variable<String>(ownerId);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  LocalWorkoutInstancesCompanion toCompanion(bool nullToAbsent) {
    return LocalWorkoutInstancesCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      purpose: purpose == null && nullToAbsent
          ? const Value.absent()
          : Value(purpose),
      workoutType: Value(workoutType),
      scheduledLocalDate: Value(scheduledLocalDate),
      scheduledStartAt: scheduledStartAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledStartAt),
      timeZoneId: timeZoneId == null && nullToAbsent
          ? const Value.absent()
          : Value(timeZoneId),
      plannedDurationSeconds: plannedDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDurationSeconds),
      status: Value(status),
      sourceType: Value(sourceType),
      sourceReference: sourceReference == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceReference),
      revisionNumber: Value(revisionNumber),
      startedSessionId: startedSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(startedSessionId),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      rowVersion: Value(rowVersion),
      ownerId: Value(ownerId),
      syncState: Value(syncState),
    );
  }

  factory LocalWorkoutInstanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalWorkoutInstanceRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      purpose: serializer.fromJson<String?>(json['purpose']),
      workoutType: serializer.fromJson<String>(json['workoutType']),
      scheduledLocalDate: serializer.fromJson<String>(
        json['scheduledLocalDate'],
      ),
      scheduledStartAt: serializer.fromJson<int?>(json['scheduledStartAt']),
      timeZoneId: serializer.fromJson<String?>(json['timeZoneId']),
      plannedDurationSeconds: serializer.fromJson<int?>(
        json['plannedDurationSeconds'],
      ),
      status: serializer.fromJson<String>(json['status']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceReference: serializer.fromJson<String?>(json['sourceReference']),
      revisionNumber: serializer.fromJson<int>(json['revisionNumber']),
      startedSessionId: serializer.fromJson<String?>(json['startedSessionId']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'purpose': serializer.toJson<String?>(purpose),
      'workoutType': serializer.toJson<String>(workoutType),
      'scheduledLocalDate': serializer.toJson<String>(scheduledLocalDate),
      'scheduledStartAt': serializer.toJson<int?>(scheduledStartAt),
      'timeZoneId': serializer.toJson<String?>(timeZoneId),
      'plannedDurationSeconds': serializer.toJson<int?>(plannedDurationSeconds),
      'status': serializer.toJson<String>(status),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceReference': serializer.toJson<String?>(sourceReference),
      'revisionNumber': serializer.toJson<int>(revisionNumber),
      'startedSessionId': serializer.toJson<String?>(startedSessionId),
      'completedAt': serializer.toJson<int?>(completedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'rowVersion': serializer.toJson<int>(rowVersion),
      'ownerId': serializer.toJson<String>(ownerId),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  LocalWorkoutInstanceRow copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> purpose = const Value.absent(),
    String? workoutType,
    String? scheduledLocalDate,
    Value<int?> scheduledStartAt = const Value.absent(),
    Value<String?> timeZoneId = const Value.absent(),
    Value<int?> plannedDurationSeconds = const Value.absent(),
    String? status,
    String? sourceType,
    Value<String?> sourceReference = const Value.absent(),
    int? revisionNumber,
    Value<String?> startedSessionId = const Value.absent(),
    Value<int?> completedAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    int? rowVersion,
    String? ownerId,
    String? syncState,
  }) => LocalWorkoutInstanceRow(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    purpose: purpose.present ? purpose.value : this.purpose,
    workoutType: workoutType ?? this.workoutType,
    scheduledLocalDate: scheduledLocalDate ?? this.scheduledLocalDate,
    scheduledStartAt: scheduledStartAt.present
        ? scheduledStartAt.value
        : this.scheduledStartAt,
    timeZoneId: timeZoneId.present ? timeZoneId.value : this.timeZoneId,
    plannedDurationSeconds: plannedDurationSeconds.present
        ? plannedDurationSeconds.value
        : this.plannedDurationSeconds,
    status: status ?? this.status,
    sourceType: sourceType ?? this.sourceType,
    sourceReference: sourceReference.present
        ? sourceReference.value
        : this.sourceReference,
    revisionNumber: revisionNumber ?? this.revisionNumber,
    startedSessionId: startedSessionId.present
        ? startedSessionId.value
        : this.startedSessionId,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    rowVersion: rowVersion ?? this.rowVersion,
    ownerId: ownerId ?? this.ownerId,
    syncState: syncState ?? this.syncState,
  );
  LocalWorkoutInstanceRow copyWithCompanion(
    LocalWorkoutInstancesCompanion data,
  ) {
    return LocalWorkoutInstanceRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      workoutType: data.workoutType.present
          ? data.workoutType.value
          : this.workoutType,
      scheduledLocalDate: data.scheduledLocalDate.present
          ? data.scheduledLocalDate.value
          : this.scheduledLocalDate,
      scheduledStartAt: data.scheduledStartAt.present
          ? data.scheduledStartAt.value
          : this.scheduledStartAt,
      timeZoneId: data.timeZoneId.present
          ? data.timeZoneId.value
          : this.timeZoneId,
      plannedDurationSeconds: data.plannedDurationSeconds.present
          ? data.plannedDurationSeconds.value
          : this.plannedDurationSeconds,
      status: data.status.present ? data.status.value : this.status,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sourceReference: data.sourceReference.present
          ? data.sourceReference.value
          : this.sourceReference,
      revisionNumber: data.revisionNumber.present
          ? data.revisionNumber.value
          : this.revisionNumber,
      startedSessionId: data.startedSessionId.present
          ? data.startedSessionId.value
          : this.startedSessionId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalWorkoutInstanceRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('purpose: $purpose, ')
          ..write('workoutType: $workoutType, ')
          ..write('scheduledLocalDate: $scheduledLocalDate, ')
          ..write('scheduledStartAt: $scheduledStartAt, ')
          ..write('timeZoneId: $timeZoneId, ')
          ..write('plannedDurationSeconds: $plannedDurationSeconds, ')
          ..write('status: $status, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceReference: $sourceReference, ')
          ..write('revisionNumber: $revisionNumber, ')
          ..write('startedSessionId: $startedSessionId, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    purpose,
    workoutType,
    scheduledLocalDate,
    scheduledStartAt,
    timeZoneId,
    plannedDurationSeconds,
    status,
    sourceType,
    sourceReference,
    revisionNumber,
    startedSessionId,
    completedAt,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalWorkoutInstanceRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.purpose == this.purpose &&
          other.workoutType == this.workoutType &&
          other.scheduledLocalDate == this.scheduledLocalDate &&
          other.scheduledStartAt == this.scheduledStartAt &&
          other.timeZoneId == this.timeZoneId &&
          other.plannedDurationSeconds == this.plannedDurationSeconds &&
          other.status == this.status &&
          other.sourceType == this.sourceType &&
          other.sourceReference == this.sourceReference &&
          other.revisionNumber == this.revisionNumber &&
          other.startedSessionId == this.startedSessionId &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.rowVersion == this.rowVersion &&
          other.ownerId == this.ownerId &&
          other.syncState == this.syncState);
}

class LocalWorkoutInstancesCompanion
    extends UpdateCompanion<LocalWorkoutInstanceRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> purpose;
  final Value<String> workoutType;
  final Value<String> scheduledLocalDate;
  final Value<int?> scheduledStartAt;
  final Value<String?> timeZoneId;
  final Value<int?> plannedDurationSeconds;
  final Value<String> status;
  final Value<String> sourceType;
  final Value<String?> sourceReference;
  final Value<int> revisionNumber;
  final Value<String?> startedSessionId;
  final Value<int?> completedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowVersion;
  final Value<String> ownerId;
  final Value<String> syncState;
  final Value<int> rowid;
  const LocalWorkoutInstancesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.purpose = const Value.absent(),
    this.workoutType = const Value.absent(),
    this.scheduledLocalDate = const Value.absent(),
    this.scheduledStartAt = const Value.absent(),
    this.timeZoneId = const Value.absent(),
    this.plannedDurationSeconds = const Value.absent(),
    this.status = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceReference = const Value.absent(),
    this.revisionNumber = const Value.absent(),
    this.startedSessionId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowVersion = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalWorkoutInstancesCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.purpose = const Value.absent(),
    required String workoutType,
    required String scheduledLocalDate,
    this.scheduledStartAt = const Value.absent(),
    this.timeZoneId = const Value.absent(),
    this.plannedDurationSeconds = const Value.absent(),
    required String status,
    required String sourceType,
    this.sourceReference = const Value.absent(),
    required int revisionNumber,
    this.startedSessionId = const Value.absent(),
    this.completedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required int rowVersion,
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       workoutType = Value(workoutType),
       scheduledLocalDate = Value(scheduledLocalDate),
       status = Value(status),
       sourceType = Value(sourceType),
       revisionNumber = Value(revisionNumber),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       rowVersion = Value(rowVersion);
  static Insertable<LocalWorkoutInstanceRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? purpose,
    Expression<String>? workoutType,
    Expression<String>? scheduledLocalDate,
    Expression<int>? scheduledStartAt,
    Expression<String>? timeZoneId,
    Expression<int>? plannedDurationSeconds,
    Expression<String>? status,
    Expression<String>? sourceType,
    Expression<String>? sourceReference,
    Expression<int>? revisionNumber,
    Expression<String>? startedSessionId,
    Expression<int>? completedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowVersion,
    Expression<String>? ownerId,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (purpose != null) 'purpose': purpose,
      if (workoutType != null) 'workout_type': workoutType,
      if (scheduledLocalDate != null)
        'scheduled_local_date': scheduledLocalDate,
      if (scheduledStartAt != null) 'scheduled_start_at': scheduledStartAt,
      if (timeZoneId != null) 'time_zone_id': timeZoneId,
      if (plannedDurationSeconds != null)
        'planned_duration_seconds': plannedDurationSeconds,
      if (status != null) 'status': status,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceReference != null) 'source_reference': sourceReference,
      if (revisionNumber != null) 'revision_number': revisionNumber,
      if (startedSessionId != null) 'started_session_id': startedSessionId,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowVersion != null) 'row_version': rowVersion,
      if (ownerId != null) 'owner_id': ownerId,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalWorkoutInstancesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? purpose,
    Value<String>? workoutType,
    Value<String>? scheduledLocalDate,
    Value<int?>? scheduledStartAt,
    Value<String?>? timeZoneId,
    Value<int?>? plannedDurationSeconds,
    Value<String>? status,
    Value<String>? sourceType,
    Value<String?>? sourceReference,
    Value<int>? revisionNumber,
    Value<String?>? startedSessionId,
    Value<int?>? completedAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowVersion,
    Value<String>? ownerId,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return LocalWorkoutInstancesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      purpose: purpose ?? this.purpose,
      workoutType: workoutType ?? this.workoutType,
      scheduledLocalDate: scheduledLocalDate ?? this.scheduledLocalDate,
      scheduledStartAt: scheduledStartAt ?? this.scheduledStartAt,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      plannedDurationSeconds:
          plannedDurationSeconds ?? this.plannedDurationSeconds,
      status: status ?? this.status,
      sourceType: sourceType ?? this.sourceType,
      sourceReference: sourceReference ?? this.sourceReference,
      revisionNumber: revisionNumber ?? this.revisionNumber,
      startedSessionId: startedSessionId ?? this.startedSessionId,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowVersion: rowVersion ?? this.rowVersion,
      ownerId: ownerId ?? this.ownerId,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (workoutType.present) {
      map['workout_type'] = Variable<String>(workoutType.value);
    }
    if (scheduledLocalDate.present) {
      map['scheduled_local_date'] = Variable<String>(scheduledLocalDate.value);
    }
    if (scheduledStartAt.present) {
      map['scheduled_start_at'] = Variable<int>(scheduledStartAt.value);
    }
    if (timeZoneId.present) {
      map['time_zone_id'] = Variable<String>(timeZoneId.value);
    }
    if (plannedDurationSeconds.present) {
      map['planned_duration_seconds'] = Variable<int>(
        plannedDurationSeconds.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceReference.present) {
      map['source_reference'] = Variable<String>(sourceReference.value);
    }
    if (revisionNumber.present) {
      map['revision_number'] = Variable<int>(revisionNumber.value);
    }
    if (startedSessionId.present) {
      map['started_session_id'] = Variable<String>(startedSessionId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalWorkoutInstancesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('purpose: $purpose, ')
          ..write('workoutType: $workoutType, ')
          ..write('scheduledLocalDate: $scheduledLocalDate, ')
          ..write('scheduledStartAt: $scheduledStartAt, ')
          ..write('timeZoneId: $timeZoneId, ')
          ..write('plannedDurationSeconds: $plannedDurationSeconds, ')
          ..write('status: $status, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceReference: $sourceReference, ')
          ..write('revisionNumber: $revisionNumber, ')
          ..write('startedSessionId: $startedSessionId, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalWorkoutSectionsTable extends LocalWorkoutSections
    with TableInfo<$LocalWorkoutSectionsTable, LocalWorkoutSectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalWorkoutSectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutInstanceIdMeta = const VerificationMeta(
    'workoutInstanceId',
  );
  @override
  late final GeneratedColumn<String> workoutInstanceId =
      GeneratedColumn<String>(
        'workout_instance_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_workout_instances (id) ON DELETE CASCADE',
        ),
      );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionTypeMeta = const VerificationMeta(
    'sectionType',
  );
  @override
  late final GeneratedColumn<String> sectionType = GeneratedColumn<String>(
    'section_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOptionalMeta = const VerificationMeta(
    'isOptional',
  );
  @override
  late final GeneratedColumn<bool> isOptional = GeneratedColumn<bool>(
    'is_optional',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_optional" IN (0, 1))',
    ),
  );
  static const VerificationMeta _plannedDurationSecondsMeta =
      const VerificationMeta('plannedDurationSeconds');
  @override
  late final GeneratedColumn<int> plannedDurationSeconds = GeneratedColumn<int>(
    'planned_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutInstanceId,
    position,
    title,
    sectionType,
    purpose,
    priority,
    isOptional,
    plannedDurationSeconds,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_workout_sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalWorkoutSectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workout_instance_id')) {
      context.handle(
        _workoutInstanceIdMeta,
        workoutInstanceId.isAcceptableOrUnknown(
          data['workout_instance_id']!,
          _workoutInstanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutInstanceIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('section_type')) {
      context.handle(
        _sectionTypeMeta,
        sectionType.isAcceptableOrUnknown(
          data['section_type']!,
          _sectionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sectionTypeMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('is_optional')) {
      context.handle(
        _isOptionalMeta,
        isOptional.isAcceptableOrUnknown(data['is_optional']!, _isOptionalMeta),
      );
    } else if (isInserting) {
      context.missing(_isOptionalMeta);
    }
    if (data.containsKey('planned_duration_seconds')) {
      context.handle(
        _plannedDurationSecondsMeta,
        plannedDurationSeconds.isAcceptableOrUnknown(
          data['planned_duration_seconds']!,
          _plannedDurationSecondsMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {workoutInstanceId, position},
  ];
  @override
  LocalWorkoutSectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalWorkoutSectionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutInstanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_instance_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      sectionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_type'],
      )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      isOptional: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_optional'],
      )!,
      plannedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_duration_seconds'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalWorkoutSectionsTable createAlias(String alias) {
    return $LocalWorkoutSectionsTable(attachedDatabase, alias);
  }
}

class LocalWorkoutSectionRow extends DataClass
    implements Insertable<LocalWorkoutSectionRow> {
  final String id;
  final String workoutInstanceId;
  final int position;
  final String title;
  final String sectionType;
  final String? purpose;
  final String priority;
  final bool isOptional;
  final int? plannedDurationSeconds;
  final int createdAt;
  final int updatedAt;
  const LocalWorkoutSectionRow({
    required this.id,
    required this.workoutInstanceId,
    required this.position,
    required this.title,
    required this.sectionType,
    this.purpose,
    required this.priority,
    required this.isOptional,
    this.plannedDurationSeconds,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_instance_id'] = Variable<String>(workoutInstanceId);
    map['position'] = Variable<int>(position);
    map['title'] = Variable<String>(title);
    map['section_type'] = Variable<String>(sectionType);
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    map['priority'] = Variable<String>(priority);
    map['is_optional'] = Variable<bool>(isOptional);
    if (!nullToAbsent || plannedDurationSeconds != null) {
      map['planned_duration_seconds'] = Variable<int>(plannedDurationSeconds);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  LocalWorkoutSectionsCompanion toCompanion(bool nullToAbsent) {
    return LocalWorkoutSectionsCompanion(
      id: Value(id),
      workoutInstanceId: Value(workoutInstanceId),
      position: Value(position),
      title: Value(title),
      sectionType: Value(sectionType),
      purpose: purpose == null && nullToAbsent
          ? const Value.absent()
          : Value(purpose),
      priority: Value(priority),
      isOptional: Value(isOptional),
      plannedDurationSeconds: plannedDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDurationSeconds),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalWorkoutSectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalWorkoutSectionRow(
      id: serializer.fromJson<String>(json['id']),
      workoutInstanceId: serializer.fromJson<String>(json['workoutInstanceId']),
      position: serializer.fromJson<int>(json['position']),
      title: serializer.fromJson<String>(json['title']),
      sectionType: serializer.fromJson<String>(json['sectionType']),
      purpose: serializer.fromJson<String?>(json['purpose']),
      priority: serializer.fromJson<String>(json['priority']),
      isOptional: serializer.fromJson<bool>(json['isOptional']),
      plannedDurationSeconds: serializer.fromJson<int?>(
        json['plannedDurationSeconds'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutInstanceId': serializer.toJson<String>(workoutInstanceId),
      'position': serializer.toJson<int>(position),
      'title': serializer.toJson<String>(title),
      'sectionType': serializer.toJson<String>(sectionType),
      'purpose': serializer.toJson<String?>(purpose),
      'priority': serializer.toJson<String>(priority),
      'isOptional': serializer.toJson<bool>(isOptional),
      'plannedDurationSeconds': serializer.toJson<int?>(plannedDurationSeconds),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  LocalWorkoutSectionRow copyWith({
    String? id,
    String? workoutInstanceId,
    int? position,
    String? title,
    String? sectionType,
    Value<String?> purpose = const Value.absent(),
    String? priority,
    bool? isOptional,
    Value<int?> plannedDurationSeconds = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => LocalWorkoutSectionRow(
    id: id ?? this.id,
    workoutInstanceId: workoutInstanceId ?? this.workoutInstanceId,
    position: position ?? this.position,
    title: title ?? this.title,
    sectionType: sectionType ?? this.sectionType,
    purpose: purpose.present ? purpose.value : this.purpose,
    priority: priority ?? this.priority,
    isOptional: isOptional ?? this.isOptional,
    plannedDurationSeconds: plannedDurationSeconds.present
        ? plannedDurationSeconds.value
        : this.plannedDurationSeconds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalWorkoutSectionRow copyWithCompanion(LocalWorkoutSectionsCompanion data) {
    return LocalWorkoutSectionRow(
      id: data.id.present ? data.id.value : this.id,
      workoutInstanceId: data.workoutInstanceId.present
          ? data.workoutInstanceId.value
          : this.workoutInstanceId,
      position: data.position.present ? data.position.value : this.position,
      title: data.title.present ? data.title.value : this.title,
      sectionType: data.sectionType.present
          ? data.sectionType.value
          : this.sectionType,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      priority: data.priority.present ? data.priority.value : this.priority,
      isOptional: data.isOptional.present
          ? data.isOptional.value
          : this.isOptional,
      plannedDurationSeconds: data.plannedDurationSeconds.present
          ? data.plannedDurationSeconds.value
          : this.plannedDurationSeconds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalWorkoutSectionRow(')
          ..write('id: $id, ')
          ..write('workoutInstanceId: $workoutInstanceId, ')
          ..write('position: $position, ')
          ..write('title: $title, ')
          ..write('sectionType: $sectionType, ')
          ..write('purpose: $purpose, ')
          ..write('priority: $priority, ')
          ..write('isOptional: $isOptional, ')
          ..write('plannedDurationSeconds: $plannedDurationSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutInstanceId,
    position,
    title,
    sectionType,
    purpose,
    priority,
    isOptional,
    plannedDurationSeconds,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalWorkoutSectionRow &&
          other.id == this.id &&
          other.workoutInstanceId == this.workoutInstanceId &&
          other.position == this.position &&
          other.title == this.title &&
          other.sectionType == this.sectionType &&
          other.purpose == this.purpose &&
          other.priority == this.priority &&
          other.isOptional == this.isOptional &&
          other.plannedDurationSeconds == this.plannedDurationSeconds &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalWorkoutSectionsCompanion
    extends UpdateCompanion<LocalWorkoutSectionRow> {
  final Value<String> id;
  final Value<String> workoutInstanceId;
  final Value<int> position;
  final Value<String> title;
  final Value<String> sectionType;
  final Value<String?> purpose;
  final Value<String> priority;
  final Value<bool> isOptional;
  final Value<int?> plannedDurationSeconds;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const LocalWorkoutSectionsCompanion({
    this.id = const Value.absent(),
    this.workoutInstanceId = const Value.absent(),
    this.position = const Value.absent(),
    this.title = const Value.absent(),
    this.sectionType = const Value.absent(),
    this.purpose = const Value.absent(),
    this.priority = const Value.absent(),
    this.isOptional = const Value.absent(),
    this.plannedDurationSeconds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalWorkoutSectionsCompanion.insert({
    required String id,
    required String workoutInstanceId,
    required int position,
    required String title,
    required String sectionType,
    this.purpose = const Value.absent(),
    required String priority,
    required bool isOptional,
    this.plannedDurationSeconds = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workoutInstanceId = Value(workoutInstanceId),
       position = Value(position),
       title = Value(title),
       sectionType = Value(sectionType),
       priority = Value(priority),
       isOptional = Value(isOptional),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalWorkoutSectionRow> custom({
    Expression<String>? id,
    Expression<String>? workoutInstanceId,
    Expression<int>? position,
    Expression<String>? title,
    Expression<String>? sectionType,
    Expression<String>? purpose,
    Expression<String>? priority,
    Expression<bool>? isOptional,
    Expression<int>? plannedDurationSeconds,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutInstanceId != null) 'workout_instance_id': workoutInstanceId,
      if (position != null) 'position': position,
      if (title != null) 'title': title,
      if (sectionType != null) 'section_type': sectionType,
      if (purpose != null) 'purpose': purpose,
      if (priority != null) 'priority': priority,
      if (isOptional != null) 'is_optional': isOptional,
      if (plannedDurationSeconds != null)
        'planned_duration_seconds': plannedDurationSeconds,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalWorkoutSectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutInstanceId,
    Value<int>? position,
    Value<String>? title,
    Value<String>? sectionType,
    Value<String?>? purpose,
    Value<String>? priority,
    Value<bool>? isOptional,
    Value<int?>? plannedDurationSeconds,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalWorkoutSectionsCompanion(
      id: id ?? this.id,
      workoutInstanceId: workoutInstanceId ?? this.workoutInstanceId,
      position: position ?? this.position,
      title: title ?? this.title,
      sectionType: sectionType ?? this.sectionType,
      purpose: purpose ?? this.purpose,
      priority: priority ?? this.priority,
      isOptional: isOptional ?? this.isOptional,
      plannedDurationSeconds:
          plannedDurationSeconds ?? this.plannedDurationSeconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutInstanceId.present) {
      map['workout_instance_id'] = Variable<String>(workoutInstanceId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sectionType.present) {
      map['section_type'] = Variable<String>(sectionType.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (isOptional.present) {
      map['is_optional'] = Variable<bool>(isOptional.value);
    }
    if (plannedDurationSeconds.present) {
      map['planned_duration_seconds'] = Variable<int>(
        plannedDurationSeconds.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalWorkoutSectionsCompanion(')
          ..write('id: $id, ')
          ..write('workoutInstanceId: $workoutInstanceId, ')
          ..write('position: $position, ')
          ..write('title: $title, ')
          ..write('sectionType: $sectionType, ')
          ..write('purpose: $purpose, ')
          ..write('priority: $priority, ')
          ..write('isOptional: $isOptional, ')
          ..write('plannedDurationSeconds: $plannedDurationSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalWorkoutStepsTable extends LocalWorkoutSteps
    with TableInfo<$LocalWorkoutStepsTable, LocalWorkoutStepRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalWorkoutStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_workout_sections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _parentStepIdMeta = const VerificationMeta(
    'parentStepId',
  );
  @override
  late final GeneratedColumn<String> parentStepId = GeneratedColumn<String>(
    'parent_step_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_workout_steps (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepTypeMeta = const VerificationMeta(
    'stepType',
  );
  @override
  late final GeneratedColumn<String> stepType = GeneratedColumn<String>(
    'step_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instructionsMeta = const VerificationMeta(
    'instructions',
  );
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
    'instructions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSkippableMeta = const VerificationMeta(
    'isSkippable',
  );
  @override
  late final GeneratedColumn<bool> isSkippable = GeneratedColumn<bool>(
    'is_skippable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_skippable" IN (0, 1))',
    ),
  );
  static const VerificationMeta _prescriptionTypeMeta = const VerificationMeta(
    'prescriptionType',
  );
  @override
  late final GeneratedColumn<String> prescriptionType = GeneratedColumn<String>(
    'prescription_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedDurationSecondsMeta =
      const VerificationMeta('plannedDurationSeconds');
  @override
  late final GeneratedColumn<int> plannedDurationSeconds = GeneratedColumn<int>(
    'planned_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedDistanceMetersMeta =
      const VerificationMeta('plannedDistanceMeters');
  @override
  late final GeneratedColumn<double> plannedDistanceMeters =
      GeneratedColumn<double>(
        'planned_distance_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _plannedRepetitionsMeta =
      const VerificationMeta('plannedRepetitions');
  @override
  late final GeneratedColumn<int> plannedRepetitions = GeneratedColumn<int>(
    'planned_repetitions',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedWeightKgMeta = const VerificationMeta(
    'plannedWeightKg',
  );
  @override
  late final GeneratedColumn<double> plannedWeightKg = GeneratedColumn<double>(
    'planned_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sectionId,
    parentStepId,
    position,
    stepType,
    title,
    instructions,
    purpose,
    priority,
    isSkippable,
    prescriptionType,
    plannedDurationSeconds,
    plannedDistanceMeters,
    plannedRepetitions,
    plannedWeightKg,
    metadataJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_workout_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalWorkoutStepRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('parent_step_id')) {
      context.handle(
        _parentStepIdMeta,
        parentStepId.isAcceptableOrUnknown(
          data['parent_step_id']!,
          _parentStepIdMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('step_type')) {
      context.handle(
        _stepTypeMeta,
        stepType.isAcceptableOrUnknown(data['step_type']!, _stepTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_stepTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('instructions')) {
      context.handle(
        _instructionsMeta,
        instructions.isAcceptableOrUnknown(
          data['instructions']!,
          _instructionsMeta,
        ),
      );
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('is_skippable')) {
      context.handle(
        _isSkippableMeta,
        isSkippable.isAcceptableOrUnknown(
          data['is_skippable']!,
          _isSkippableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isSkippableMeta);
    }
    if (data.containsKey('prescription_type')) {
      context.handle(
        _prescriptionTypeMeta,
        prescriptionType.isAcceptableOrUnknown(
          data['prescription_type']!,
          _prescriptionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_prescriptionTypeMeta);
    }
    if (data.containsKey('planned_duration_seconds')) {
      context.handle(
        _plannedDurationSecondsMeta,
        plannedDurationSeconds.isAcceptableOrUnknown(
          data['planned_duration_seconds']!,
          _plannedDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('planned_distance_meters')) {
      context.handle(
        _plannedDistanceMetersMeta,
        plannedDistanceMeters.isAcceptableOrUnknown(
          data['planned_distance_meters']!,
          _plannedDistanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('planned_repetitions')) {
      context.handle(
        _plannedRepetitionsMeta,
        plannedRepetitions.isAcceptableOrUnknown(
          data['planned_repetitions']!,
          _plannedRepetitionsMeta,
        ),
      );
    }
    if (data.containsKey('planned_weight_kg')) {
      context.handle(
        _plannedWeightKgMeta,
        plannedWeightKg.isAcceptableOrUnknown(
          data['planned_weight_kg']!,
          _plannedWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalWorkoutStepRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalWorkoutStepRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      parentStepId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_step_id'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      stepType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}step_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      instructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructions'],
      ),
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      isSkippable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_skippable'],
      )!,
      prescriptionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prescription_type'],
      )!,
      plannedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_duration_seconds'],
      ),
      plannedDistanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}planned_distance_meters'],
      ),
      plannedRepetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_repetitions'],
      ),
      plannedWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}planned_weight_kg'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalWorkoutStepsTable createAlias(String alias) {
    return $LocalWorkoutStepsTable(attachedDatabase, alias);
  }
}

class LocalWorkoutStepRow extends DataClass
    implements Insertable<LocalWorkoutStepRow> {
  final String id;
  final String sectionId;
  final String? parentStepId;
  final int position;
  final String stepType;
  final String title;
  final String? instructions;
  final String? purpose;
  final String priority;
  final bool isSkippable;
  final String prescriptionType;
  final int? plannedDurationSeconds;
  final double? plannedDistanceMeters;
  final int? plannedRepetitions;
  final double? plannedWeightKg;
  final String? metadataJson;
  final int createdAt;
  final int updatedAt;
  const LocalWorkoutStepRow({
    required this.id,
    required this.sectionId,
    this.parentStepId,
    required this.position,
    required this.stepType,
    required this.title,
    this.instructions,
    this.purpose,
    required this.priority,
    required this.isSkippable,
    required this.prescriptionType,
    this.plannedDurationSeconds,
    this.plannedDistanceMeters,
    this.plannedRepetitions,
    this.plannedWeightKg,
    this.metadataJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['section_id'] = Variable<String>(sectionId);
    if (!nullToAbsent || parentStepId != null) {
      map['parent_step_id'] = Variable<String>(parentStepId);
    }
    map['position'] = Variable<int>(position);
    map['step_type'] = Variable<String>(stepType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || instructions != null) {
      map['instructions'] = Variable<String>(instructions);
    }
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    map['priority'] = Variable<String>(priority);
    map['is_skippable'] = Variable<bool>(isSkippable);
    map['prescription_type'] = Variable<String>(prescriptionType);
    if (!nullToAbsent || plannedDurationSeconds != null) {
      map['planned_duration_seconds'] = Variable<int>(plannedDurationSeconds);
    }
    if (!nullToAbsent || plannedDistanceMeters != null) {
      map['planned_distance_meters'] = Variable<double>(plannedDistanceMeters);
    }
    if (!nullToAbsent || plannedRepetitions != null) {
      map['planned_repetitions'] = Variable<int>(plannedRepetitions);
    }
    if (!nullToAbsent || plannedWeightKg != null) {
      map['planned_weight_kg'] = Variable<double>(plannedWeightKg);
    }
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  LocalWorkoutStepsCompanion toCompanion(bool nullToAbsent) {
    return LocalWorkoutStepsCompanion(
      id: Value(id),
      sectionId: Value(sectionId),
      parentStepId: parentStepId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentStepId),
      position: Value(position),
      stepType: Value(stepType),
      title: Value(title),
      instructions: instructions == null && nullToAbsent
          ? const Value.absent()
          : Value(instructions),
      purpose: purpose == null && nullToAbsent
          ? const Value.absent()
          : Value(purpose),
      priority: Value(priority),
      isSkippable: Value(isSkippable),
      prescriptionType: Value(prescriptionType),
      plannedDurationSeconds: plannedDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDurationSeconds),
      plannedDistanceMeters: plannedDistanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDistanceMeters),
      plannedRepetitions: plannedRepetitions == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedRepetitions),
      plannedWeightKg: plannedWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedWeightKg),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalWorkoutStepRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalWorkoutStepRow(
      id: serializer.fromJson<String>(json['id']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      parentStepId: serializer.fromJson<String?>(json['parentStepId']),
      position: serializer.fromJson<int>(json['position']),
      stepType: serializer.fromJson<String>(json['stepType']),
      title: serializer.fromJson<String>(json['title']),
      instructions: serializer.fromJson<String?>(json['instructions']),
      purpose: serializer.fromJson<String?>(json['purpose']),
      priority: serializer.fromJson<String>(json['priority']),
      isSkippable: serializer.fromJson<bool>(json['isSkippable']),
      prescriptionType: serializer.fromJson<String>(json['prescriptionType']),
      plannedDurationSeconds: serializer.fromJson<int?>(
        json['plannedDurationSeconds'],
      ),
      plannedDistanceMeters: serializer.fromJson<double?>(
        json['plannedDistanceMeters'],
      ),
      plannedRepetitions: serializer.fromJson<int?>(json['plannedRepetitions']),
      plannedWeightKg: serializer.fromJson<double?>(json['plannedWeightKg']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sectionId': serializer.toJson<String>(sectionId),
      'parentStepId': serializer.toJson<String?>(parentStepId),
      'position': serializer.toJson<int>(position),
      'stepType': serializer.toJson<String>(stepType),
      'title': serializer.toJson<String>(title),
      'instructions': serializer.toJson<String?>(instructions),
      'purpose': serializer.toJson<String?>(purpose),
      'priority': serializer.toJson<String>(priority),
      'isSkippable': serializer.toJson<bool>(isSkippable),
      'prescriptionType': serializer.toJson<String>(prescriptionType),
      'plannedDurationSeconds': serializer.toJson<int?>(plannedDurationSeconds),
      'plannedDistanceMeters': serializer.toJson<double?>(
        plannedDistanceMeters,
      ),
      'plannedRepetitions': serializer.toJson<int?>(plannedRepetitions),
      'plannedWeightKg': serializer.toJson<double?>(plannedWeightKg),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  LocalWorkoutStepRow copyWith({
    String? id,
    String? sectionId,
    Value<String?> parentStepId = const Value.absent(),
    int? position,
    String? stepType,
    String? title,
    Value<String?> instructions = const Value.absent(),
    Value<String?> purpose = const Value.absent(),
    String? priority,
    bool? isSkippable,
    String? prescriptionType,
    Value<int?> plannedDurationSeconds = const Value.absent(),
    Value<double?> plannedDistanceMeters = const Value.absent(),
    Value<int?> plannedRepetitions = const Value.absent(),
    Value<double?> plannedWeightKg = const Value.absent(),
    Value<String?> metadataJson = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => LocalWorkoutStepRow(
    id: id ?? this.id,
    sectionId: sectionId ?? this.sectionId,
    parentStepId: parentStepId.present ? parentStepId.value : this.parentStepId,
    position: position ?? this.position,
    stepType: stepType ?? this.stepType,
    title: title ?? this.title,
    instructions: instructions.present ? instructions.value : this.instructions,
    purpose: purpose.present ? purpose.value : this.purpose,
    priority: priority ?? this.priority,
    isSkippable: isSkippable ?? this.isSkippable,
    prescriptionType: prescriptionType ?? this.prescriptionType,
    plannedDurationSeconds: plannedDurationSeconds.present
        ? plannedDurationSeconds.value
        : this.plannedDurationSeconds,
    plannedDistanceMeters: plannedDistanceMeters.present
        ? plannedDistanceMeters.value
        : this.plannedDistanceMeters,
    plannedRepetitions: plannedRepetitions.present
        ? plannedRepetitions.value
        : this.plannedRepetitions,
    plannedWeightKg: plannedWeightKg.present
        ? plannedWeightKg.value
        : this.plannedWeightKg,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalWorkoutStepRow copyWithCompanion(LocalWorkoutStepsCompanion data) {
    return LocalWorkoutStepRow(
      id: data.id.present ? data.id.value : this.id,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      parentStepId: data.parentStepId.present
          ? data.parentStepId.value
          : this.parentStepId,
      position: data.position.present ? data.position.value : this.position,
      stepType: data.stepType.present ? data.stepType.value : this.stepType,
      title: data.title.present ? data.title.value : this.title,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      priority: data.priority.present ? data.priority.value : this.priority,
      isSkippable: data.isSkippable.present
          ? data.isSkippable.value
          : this.isSkippable,
      prescriptionType: data.prescriptionType.present
          ? data.prescriptionType.value
          : this.prescriptionType,
      plannedDurationSeconds: data.plannedDurationSeconds.present
          ? data.plannedDurationSeconds.value
          : this.plannedDurationSeconds,
      plannedDistanceMeters: data.plannedDistanceMeters.present
          ? data.plannedDistanceMeters.value
          : this.plannedDistanceMeters,
      plannedRepetitions: data.plannedRepetitions.present
          ? data.plannedRepetitions.value
          : this.plannedRepetitions,
      plannedWeightKg: data.plannedWeightKg.present
          ? data.plannedWeightKg.value
          : this.plannedWeightKg,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalWorkoutStepRow(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('parentStepId: $parentStepId, ')
          ..write('position: $position, ')
          ..write('stepType: $stepType, ')
          ..write('title: $title, ')
          ..write('instructions: $instructions, ')
          ..write('purpose: $purpose, ')
          ..write('priority: $priority, ')
          ..write('isSkippable: $isSkippable, ')
          ..write('prescriptionType: $prescriptionType, ')
          ..write('plannedDurationSeconds: $plannedDurationSeconds, ')
          ..write('plannedDistanceMeters: $plannedDistanceMeters, ')
          ..write('plannedRepetitions: $plannedRepetitions, ')
          ..write('plannedWeightKg: $plannedWeightKg, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sectionId,
    parentStepId,
    position,
    stepType,
    title,
    instructions,
    purpose,
    priority,
    isSkippable,
    prescriptionType,
    plannedDurationSeconds,
    plannedDistanceMeters,
    plannedRepetitions,
    plannedWeightKg,
    metadataJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalWorkoutStepRow &&
          other.id == this.id &&
          other.sectionId == this.sectionId &&
          other.parentStepId == this.parentStepId &&
          other.position == this.position &&
          other.stepType == this.stepType &&
          other.title == this.title &&
          other.instructions == this.instructions &&
          other.purpose == this.purpose &&
          other.priority == this.priority &&
          other.isSkippable == this.isSkippable &&
          other.prescriptionType == this.prescriptionType &&
          other.plannedDurationSeconds == this.plannedDurationSeconds &&
          other.plannedDistanceMeters == this.plannedDistanceMeters &&
          other.plannedRepetitions == this.plannedRepetitions &&
          other.plannedWeightKg == this.plannedWeightKg &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalWorkoutStepsCompanion extends UpdateCompanion<LocalWorkoutStepRow> {
  final Value<String> id;
  final Value<String> sectionId;
  final Value<String?> parentStepId;
  final Value<int> position;
  final Value<String> stepType;
  final Value<String> title;
  final Value<String?> instructions;
  final Value<String?> purpose;
  final Value<String> priority;
  final Value<bool> isSkippable;
  final Value<String> prescriptionType;
  final Value<int?> plannedDurationSeconds;
  final Value<double?> plannedDistanceMeters;
  final Value<int?> plannedRepetitions;
  final Value<double?> plannedWeightKg;
  final Value<String?> metadataJson;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const LocalWorkoutStepsCompanion({
    this.id = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.parentStepId = const Value.absent(),
    this.position = const Value.absent(),
    this.stepType = const Value.absent(),
    this.title = const Value.absent(),
    this.instructions = const Value.absent(),
    this.purpose = const Value.absent(),
    this.priority = const Value.absent(),
    this.isSkippable = const Value.absent(),
    this.prescriptionType = const Value.absent(),
    this.plannedDurationSeconds = const Value.absent(),
    this.plannedDistanceMeters = const Value.absent(),
    this.plannedRepetitions = const Value.absent(),
    this.plannedWeightKg = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalWorkoutStepsCompanion.insert({
    required String id,
    required String sectionId,
    this.parentStepId = const Value.absent(),
    required int position,
    required String stepType,
    required String title,
    this.instructions = const Value.absent(),
    this.purpose = const Value.absent(),
    required String priority,
    required bool isSkippable,
    required String prescriptionType,
    this.plannedDurationSeconds = const Value.absent(),
    this.plannedDistanceMeters = const Value.absent(),
    this.plannedRepetitions = const Value.absent(),
    this.plannedWeightKg = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sectionId = Value(sectionId),
       position = Value(position),
       stepType = Value(stepType),
       title = Value(title),
       priority = Value(priority),
       isSkippable = Value(isSkippable),
       prescriptionType = Value(prescriptionType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalWorkoutStepRow> custom({
    Expression<String>? id,
    Expression<String>? sectionId,
    Expression<String>? parentStepId,
    Expression<int>? position,
    Expression<String>? stepType,
    Expression<String>? title,
    Expression<String>? instructions,
    Expression<String>? purpose,
    Expression<String>? priority,
    Expression<bool>? isSkippable,
    Expression<String>? prescriptionType,
    Expression<int>? plannedDurationSeconds,
    Expression<double>? plannedDistanceMeters,
    Expression<int>? plannedRepetitions,
    Expression<double>? plannedWeightKg,
    Expression<String>? metadataJson,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sectionId != null) 'section_id': sectionId,
      if (parentStepId != null) 'parent_step_id': parentStepId,
      if (position != null) 'position': position,
      if (stepType != null) 'step_type': stepType,
      if (title != null) 'title': title,
      if (instructions != null) 'instructions': instructions,
      if (purpose != null) 'purpose': purpose,
      if (priority != null) 'priority': priority,
      if (isSkippable != null) 'is_skippable': isSkippable,
      if (prescriptionType != null) 'prescription_type': prescriptionType,
      if (plannedDurationSeconds != null)
        'planned_duration_seconds': plannedDurationSeconds,
      if (plannedDistanceMeters != null)
        'planned_distance_meters': plannedDistanceMeters,
      if (plannedRepetitions != null) 'planned_repetitions': plannedRepetitions,
      if (plannedWeightKg != null) 'planned_weight_kg': plannedWeightKg,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalWorkoutStepsCompanion copyWith({
    Value<String>? id,
    Value<String>? sectionId,
    Value<String?>? parentStepId,
    Value<int>? position,
    Value<String>? stepType,
    Value<String>? title,
    Value<String?>? instructions,
    Value<String?>? purpose,
    Value<String>? priority,
    Value<bool>? isSkippable,
    Value<String>? prescriptionType,
    Value<int?>? plannedDurationSeconds,
    Value<double?>? plannedDistanceMeters,
    Value<int?>? plannedRepetitions,
    Value<double?>? plannedWeightKg,
    Value<String?>? metadataJson,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalWorkoutStepsCompanion(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      parentStepId: parentStepId ?? this.parentStepId,
      position: position ?? this.position,
      stepType: stepType ?? this.stepType,
      title: title ?? this.title,
      instructions: instructions ?? this.instructions,
      purpose: purpose ?? this.purpose,
      priority: priority ?? this.priority,
      isSkippable: isSkippable ?? this.isSkippable,
      prescriptionType: prescriptionType ?? this.prescriptionType,
      plannedDurationSeconds:
          plannedDurationSeconds ?? this.plannedDurationSeconds,
      plannedDistanceMeters:
          plannedDistanceMeters ?? this.plannedDistanceMeters,
      plannedRepetitions: plannedRepetitions ?? this.plannedRepetitions,
      plannedWeightKg: plannedWeightKg ?? this.plannedWeightKg,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (parentStepId.present) {
      map['parent_step_id'] = Variable<String>(parentStepId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (stepType.present) {
      map['step_type'] = Variable<String>(stepType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (isSkippable.present) {
      map['is_skippable'] = Variable<bool>(isSkippable.value);
    }
    if (prescriptionType.present) {
      map['prescription_type'] = Variable<String>(prescriptionType.value);
    }
    if (plannedDurationSeconds.present) {
      map['planned_duration_seconds'] = Variable<int>(
        plannedDurationSeconds.value,
      );
    }
    if (plannedDistanceMeters.present) {
      map['planned_distance_meters'] = Variable<double>(
        plannedDistanceMeters.value,
      );
    }
    if (plannedRepetitions.present) {
      map['planned_repetitions'] = Variable<int>(plannedRepetitions.value);
    }
    if (plannedWeightKg.present) {
      map['planned_weight_kg'] = Variable<double>(plannedWeightKg.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalWorkoutStepsCompanion(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('parentStepId: $parentStepId, ')
          ..write('position: $position, ')
          ..write('stepType: $stepType, ')
          ..write('title: $title, ')
          ..write('instructions: $instructions, ')
          ..write('purpose: $purpose, ')
          ..write('priority: $priority, ')
          ..write('isSkippable: $isSkippable, ')
          ..write('prescriptionType: $prescriptionType, ')
          ..write('plannedDurationSeconds: $plannedDurationSeconds, ')
          ..write('plannedDistanceMeters: $plannedDistanceMeters, ')
          ..write('plannedRepetitions: $plannedRepetitions, ')
          ..write('plannedWeightKg: $plannedWeightKg, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSetPlansTable extends LocalSetPlans
    with TableInfo<$LocalSetPlansTable, LocalSetPlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSetPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutStepIdMeta = const VerificationMeta(
    'workoutStepId',
  );
  @override
  late final GeneratedColumn<String> workoutStepId = GeneratedColumn<String>(
    'workout_step_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_workout_steps (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedRepetitionsMeta =
      const VerificationMeta('plannedRepetitions');
  @override
  late final GeneratedColumn<int> plannedRepetitions = GeneratedColumn<int>(
    'planned_repetitions',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minimumRepetitionsMeta =
      const VerificationMeta('minimumRepetitions');
  @override
  late final GeneratedColumn<int> minimumRepetitions = GeneratedColumn<int>(
    'minimum_repetitions',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maximumRepetitionsMeta =
      const VerificationMeta('maximumRepetitions');
  @override
  late final GeneratedColumn<int> maximumRepetitions = GeneratedColumn<int>(
    'maximum_repetitions',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedWeightKgMeta = const VerificationMeta(
    'plannedWeightKg',
  );
  @override
  late final GeneratedColumn<double> plannedWeightKg = GeneratedColumn<double>(
    'planned_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedDurationSecondsMeta =
      const VerificationMeta('plannedDurationSeconds');
  @override
  late final GeneratedColumn<int> plannedDurationSeconds = GeneratedColumn<int>(
    'planned_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restAfterSecondsMeta = const VerificationMeta(
    'restAfterSeconds',
  );
  @override
  late final GeneratedColumn<int> restAfterSeconds = GeneratedColumn<int>(
    'rest_after_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetRpeMeta = const VerificationMeta(
    'targetRpe',
  );
  @override
  late final GeneratedColumn<double> targetRpe = GeneratedColumn<double>(
    'target_rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutStepId,
    position,
    plannedRepetitions,
    minimumRepetitions,
    maximumRepetitions,
    plannedWeightKg,
    plannedDurationSeconds,
    restAfterSeconds,
    targetRpe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_set_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSetPlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workout_step_id')) {
      context.handle(
        _workoutStepIdMeta,
        workoutStepId.isAcceptableOrUnknown(
          data['workout_step_id']!,
          _workoutStepIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutStepIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('planned_repetitions')) {
      context.handle(
        _plannedRepetitionsMeta,
        plannedRepetitions.isAcceptableOrUnknown(
          data['planned_repetitions']!,
          _plannedRepetitionsMeta,
        ),
      );
    }
    if (data.containsKey('minimum_repetitions')) {
      context.handle(
        _minimumRepetitionsMeta,
        minimumRepetitions.isAcceptableOrUnknown(
          data['minimum_repetitions']!,
          _minimumRepetitionsMeta,
        ),
      );
    }
    if (data.containsKey('maximum_repetitions')) {
      context.handle(
        _maximumRepetitionsMeta,
        maximumRepetitions.isAcceptableOrUnknown(
          data['maximum_repetitions']!,
          _maximumRepetitionsMeta,
        ),
      );
    }
    if (data.containsKey('planned_weight_kg')) {
      context.handle(
        _plannedWeightKgMeta,
        plannedWeightKg.isAcceptableOrUnknown(
          data['planned_weight_kg']!,
          _plannedWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('planned_duration_seconds')) {
      context.handle(
        _plannedDurationSecondsMeta,
        plannedDurationSeconds.isAcceptableOrUnknown(
          data['planned_duration_seconds']!,
          _plannedDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('rest_after_seconds')) {
      context.handle(
        _restAfterSecondsMeta,
        restAfterSeconds.isAcceptableOrUnknown(
          data['rest_after_seconds']!,
          _restAfterSecondsMeta,
        ),
      );
    }
    if (data.containsKey('target_rpe')) {
      context.handle(
        _targetRpeMeta,
        targetRpe.isAcceptableOrUnknown(data['target_rpe']!, _targetRpeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {workoutStepId, position},
  ];
  @override
  LocalSetPlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSetPlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutStepId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_step_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      plannedRepetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_repetitions'],
      ),
      minimumRepetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimum_repetitions'],
      ),
      maximumRepetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}maximum_repetitions'],
      ),
      plannedWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}planned_weight_kg'],
      ),
      plannedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_duration_seconds'],
      ),
      restAfterSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_after_seconds'],
      ),
      targetRpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_rpe'],
      ),
    );
  }

  @override
  $LocalSetPlansTable createAlias(String alias) {
    return $LocalSetPlansTable(attachedDatabase, alias);
  }
}

class LocalSetPlanRow extends DataClass implements Insertable<LocalSetPlanRow> {
  final String id;
  final String workoutStepId;
  final int position;
  final int? plannedRepetitions;
  final int? minimumRepetitions;
  final int? maximumRepetitions;
  final double? plannedWeightKg;
  final int? plannedDurationSeconds;
  final int? restAfterSeconds;
  final double? targetRpe;
  const LocalSetPlanRow({
    required this.id,
    required this.workoutStepId,
    required this.position,
    this.plannedRepetitions,
    this.minimumRepetitions,
    this.maximumRepetitions,
    this.plannedWeightKg,
    this.plannedDurationSeconds,
    this.restAfterSeconds,
    this.targetRpe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_step_id'] = Variable<String>(workoutStepId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || plannedRepetitions != null) {
      map['planned_repetitions'] = Variable<int>(plannedRepetitions);
    }
    if (!nullToAbsent || minimumRepetitions != null) {
      map['minimum_repetitions'] = Variable<int>(minimumRepetitions);
    }
    if (!nullToAbsent || maximumRepetitions != null) {
      map['maximum_repetitions'] = Variable<int>(maximumRepetitions);
    }
    if (!nullToAbsent || plannedWeightKg != null) {
      map['planned_weight_kg'] = Variable<double>(plannedWeightKg);
    }
    if (!nullToAbsent || plannedDurationSeconds != null) {
      map['planned_duration_seconds'] = Variable<int>(plannedDurationSeconds);
    }
    if (!nullToAbsent || restAfterSeconds != null) {
      map['rest_after_seconds'] = Variable<int>(restAfterSeconds);
    }
    if (!nullToAbsent || targetRpe != null) {
      map['target_rpe'] = Variable<double>(targetRpe);
    }
    return map;
  }

  LocalSetPlansCompanion toCompanion(bool nullToAbsent) {
    return LocalSetPlansCompanion(
      id: Value(id),
      workoutStepId: Value(workoutStepId),
      position: Value(position),
      plannedRepetitions: plannedRepetitions == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedRepetitions),
      minimumRepetitions: minimumRepetitions == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumRepetitions),
      maximumRepetitions: maximumRepetitions == null && nullToAbsent
          ? const Value.absent()
          : Value(maximumRepetitions),
      plannedWeightKg: plannedWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedWeightKg),
      plannedDurationSeconds: plannedDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDurationSeconds),
      restAfterSeconds: restAfterSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(restAfterSeconds),
      targetRpe: targetRpe == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRpe),
    );
  }

  factory LocalSetPlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSetPlanRow(
      id: serializer.fromJson<String>(json['id']),
      workoutStepId: serializer.fromJson<String>(json['workoutStepId']),
      position: serializer.fromJson<int>(json['position']),
      plannedRepetitions: serializer.fromJson<int?>(json['plannedRepetitions']),
      minimumRepetitions: serializer.fromJson<int?>(json['minimumRepetitions']),
      maximumRepetitions: serializer.fromJson<int?>(json['maximumRepetitions']),
      plannedWeightKg: serializer.fromJson<double?>(json['plannedWeightKg']),
      plannedDurationSeconds: serializer.fromJson<int?>(
        json['plannedDurationSeconds'],
      ),
      restAfterSeconds: serializer.fromJson<int?>(json['restAfterSeconds']),
      targetRpe: serializer.fromJson<double?>(json['targetRpe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutStepId': serializer.toJson<String>(workoutStepId),
      'position': serializer.toJson<int>(position),
      'plannedRepetitions': serializer.toJson<int?>(plannedRepetitions),
      'minimumRepetitions': serializer.toJson<int?>(minimumRepetitions),
      'maximumRepetitions': serializer.toJson<int?>(maximumRepetitions),
      'plannedWeightKg': serializer.toJson<double?>(plannedWeightKg),
      'plannedDurationSeconds': serializer.toJson<int?>(plannedDurationSeconds),
      'restAfterSeconds': serializer.toJson<int?>(restAfterSeconds),
      'targetRpe': serializer.toJson<double?>(targetRpe),
    };
  }

  LocalSetPlanRow copyWith({
    String? id,
    String? workoutStepId,
    int? position,
    Value<int?> plannedRepetitions = const Value.absent(),
    Value<int?> minimumRepetitions = const Value.absent(),
    Value<int?> maximumRepetitions = const Value.absent(),
    Value<double?> plannedWeightKg = const Value.absent(),
    Value<int?> plannedDurationSeconds = const Value.absent(),
    Value<int?> restAfterSeconds = const Value.absent(),
    Value<double?> targetRpe = const Value.absent(),
  }) => LocalSetPlanRow(
    id: id ?? this.id,
    workoutStepId: workoutStepId ?? this.workoutStepId,
    position: position ?? this.position,
    plannedRepetitions: plannedRepetitions.present
        ? plannedRepetitions.value
        : this.plannedRepetitions,
    minimumRepetitions: minimumRepetitions.present
        ? minimumRepetitions.value
        : this.minimumRepetitions,
    maximumRepetitions: maximumRepetitions.present
        ? maximumRepetitions.value
        : this.maximumRepetitions,
    plannedWeightKg: plannedWeightKg.present
        ? plannedWeightKg.value
        : this.plannedWeightKg,
    plannedDurationSeconds: plannedDurationSeconds.present
        ? plannedDurationSeconds.value
        : this.plannedDurationSeconds,
    restAfterSeconds: restAfterSeconds.present
        ? restAfterSeconds.value
        : this.restAfterSeconds,
    targetRpe: targetRpe.present ? targetRpe.value : this.targetRpe,
  );
  LocalSetPlanRow copyWithCompanion(LocalSetPlansCompanion data) {
    return LocalSetPlanRow(
      id: data.id.present ? data.id.value : this.id,
      workoutStepId: data.workoutStepId.present
          ? data.workoutStepId.value
          : this.workoutStepId,
      position: data.position.present ? data.position.value : this.position,
      plannedRepetitions: data.plannedRepetitions.present
          ? data.plannedRepetitions.value
          : this.plannedRepetitions,
      minimumRepetitions: data.minimumRepetitions.present
          ? data.minimumRepetitions.value
          : this.minimumRepetitions,
      maximumRepetitions: data.maximumRepetitions.present
          ? data.maximumRepetitions.value
          : this.maximumRepetitions,
      plannedWeightKg: data.plannedWeightKg.present
          ? data.plannedWeightKg.value
          : this.plannedWeightKg,
      plannedDurationSeconds: data.plannedDurationSeconds.present
          ? data.plannedDurationSeconds.value
          : this.plannedDurationSeconds,
      restAfterSeconds: data.restAfterSeconds.present
          ? data.restAfterSeconds.value
          : this.restAfterSeconds,
      targetRpe: data.targetRpe.present ? data.targetRpe.value : this.targetRpe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSetPlanRow(')
          ..write('id: $id, ')
          ..write('workoutStepId: $workoutStepId, ')
          ..write('position: $position, ')
          ..write('plannedRepetitions: $plannedRepetitions, ')
          ..write('minimumRepetitions: $minimumRepetitions, ')
          ..write('maximumRepetitions: $maximumRepetitions, ')
          ..write('plannedWeightKg: $plannedWeightKg, ')
          ..write('plannedDurationSeconds: $plannedDurationSeconds, ')
          ..write('restAfterSeconds: $restAfterSeconds, ')
          ..write('targetRpe: $targetRpe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutStepId,
    position,
    plannedRepetitions,
    minimumRepetitions,
    maximumRepetitions,
    plannedWeightKg,
    plannedDurationSeconds,
    restAfterSeconds,
    targetRpe,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSetPlanRow &&
          other.id == this.id &&
          other.workoutStepId == this.workoutStepId &&
          other.position == this.position &&
          other.plannedRepetitions == this.plannedRepetitions &&
          other.minimumRepetitions == this.minimumRepetitions &&
          other.maximumRepetitions == this.maximumRepetitions &&
          other.plannedWeightKg == this.plannedWeightKg &&
          other.plannedDurationSeconds == this.plannedDurationSeconds &&
          other.restAfterSeconds == this.restAfterSeconds &&
          other.targetRpe == this.targetRpe);
}

class LocalSetPlansCompanion extends UpdateCompanion<LocalSetPlanRow> {
  final Value<String> id;
  final Value<String> workoutStepId;
  final Value<int> position;
  final Value<int?> plannedRepetitions;
  final Value<int?> minimumRepetitions;
  final Value<int?> maximumRepetitions;
  final Value<double?> plannedWeightKg;
  final Value<int?> plannedDurationSeconds;
  final Value<int?> restAfterSeconds;
  final Value<double?> targetRpe;
  final Value<int> rowid;
  const LocalSetPlansCompanion({
    this.id = const Value.absent(),
    this.workoutStepId = const Value.absent(),
    this.position = const Value.absent(),
    this.plannedRepetitions = const Value.absent(),
    this.minimumRepetitions = const Value.absent(),
    this.maximumRepetitions = const Value.absent(),
    this.plannedWeightKg = const Value.absent(),
    this.plannedDurationSeconds = const Value.absent(),
    this.restAfterSeconds = const Value.absent(),
    this.targetRpe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSetPlansCompanion.insert({
    required String id,
    required String workoutStepId,
    required int position,
    this.plannedRepetitions = const Value.absent(),
    this.minimumRepetitions = const Value.absent(),
    this.maximumRepetitions = const Value.absent(),
    this.plannedWeightKg = const Value.absent(),
    this.plannedDurationSeconds = const Value.absent(),
    this.restAfterSeconds = const Value.absent(),
    this.targetRpe = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workoutStepId = Value(workoutStepId),
       position = Value(position);
  static Insertable<LocalSetPlanRow> custom({
    Expression<String>? id,
    Expression<String>? workoutStepId,
    Expression<int>? position,
    Expression<int>? plannedRepetitions,
    Expression<int>? minimumRepetitions,
    Expression<int>? maximumRepetitions,
    Expression<double>? plannedWeightKg,
    Expression<int>? plannedDurationSeconds,
    Expression<int>? restAfterSeconds,
    Expression<double>? targetRpe,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutStepId != null) 'workout_step_id': workoutStepId,
      if (position != null) 'position': position,
      if (plannedRepetitions != null) 'planned_repetitions': plannedRepetitions,
      if (minimumRepetitions != null) 'minimum_repetitions': minimumRepetitions,
      if (maximumRepetitions != null) 'maximum_repetitions': maximumRepetitions,
      if (plannedWeightKg != null) 'planned_weight_kg': plannedWeightKg,
      if (plannedDurationSeconds != null)
        'planned_duration_seconds': plannedDurationSeconds,
      if (restAfterSeconds != null) 'rest_after_seconds': restAfterSeconds,
      if (targetRpe != null) 'target_rpe': targetRpe,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSetPlansCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutStepId,
    Value<int>? position,
    Value<int?>? plannedRepetitions,
    Value<int?>? minimumRepetitions,
    Value<int?>? maximumRepetitions,
    Value<double?>? plannedWeightKg,
    Value<int?>? plannedDurationSeconds,
    Value<int?>? restAfterSeconds,
    Value<double?>? targetRpe,
    Value<int>? rowid,
  }) {
    return LocalSetPlansCompanion(
      id: id ?? this.id,
      workoutStepId: workoutStepId ?? this.workoutStepId,
      position: position ?? this.position,
      plannedRepetitions: plannedRepetitions ?? this.plannedRepetitions,
      minimumRepetitions: minimumRepetitions ?? this.minimumRepetitions,
      maximumRepetitions: maximumRepetitions ?? this.maximumRepetitions,
      plannedWeightKg: plannedWeightKg ?? this.plannedWeightKg,
      plannedDurationSeconds:
          plannedDurationSeconds ?? this.plannedDurationSeconds,
      restAfterSeconds: restAfterSeconds ?? this.restAfterSeconds,
      targetRpe: targetRpe ?? this.targetRpe,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutStepId.present) {
      map['workout_step_id'] = Variable<String>(workoutStepId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (plannedRepetitions.present) {
      map['planned_repetitions'] = Variable<int>(plannedRepetitions.value);
    }
    if (minimumRepetitions.present) {
      map['minimum_repetitions'] = Variable<int>(minimumRepetitions.value);
    }
    if (maximumRepetitions.present) {
      map['maximum_repetitions'] = Variable<int>(maximumRepetitions.value);
    }
    if (plannedWeightKg.present) {
      map['planned_weight_kg'] = Variable<double>(plannedWeightKg.value);
    }
    if (plannedDurationSeconds.present) {
      map['planned_duration_seconds'] = Variable<int>(
        plannedDurationSeconds.value,
      );
    }
    if (restAfterSeconds.present) {
      map['rest_after_seconds'] = Variable<int>(restAfterSeconds.value);
    }
    if (targetRpe.present) {
      map['target_rpe'] = Variable<double>(targetRpe.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSetPlansCompanion(')
          ..write('id: $id, ')
          ..write('workoutStepId: $workoutStepId, ')
          ..write('position: $position, ')
          ..write('plannedRepetitions: $plannedRepetitions, ')
          ..write('minimumRepetitions: $minimumRepetitions, ')
          ..write('maximumRepetitions: $maximumRepetitions, ')
          ..write('plannedWeightKg: $plannedWeightKg, ')
          ..write('plannedDurationSeconds: $plannedDurationSeconds, ')
          ..write('restAfterSeconds: $restAfterSeconds, ')
          ..write('targetRpe: $targetRpe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalWorkoutSessionsTable extends LocalWorkoutSessions
    with TableInfo<$LocalWorkoutSessionsTable, LocalWorkoutSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalWorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutInstanceIdMeta = const VerificationMeta(
    'workoutInstanceId',
  );
  @override
  late final GeneratedColumn<String> workoutInstanceId =
      GeneratedColumn<String>(
        'workout_instance_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_workout_instances (id) ON DELETE RESTRICT',
        ),
      );
  static const VerificationMeta _instanceRevisionNumberMeta =
      const VerificationMeta('instanceRevisionNumber');
  @override
  late final GeneratedColumn<int> instanceRevisionNumber = GeneratedColumn<int>(
    'instance_revision_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastResumedAtMeta = const VerificationMeta(
    'lastResumedAt',
  );
  @override
  late final GeneratedColumn<int> lastResumedAt = GeneratedColumn<int>(
    'last_resumed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pausedAtMeta = const VerificationMeta(
    'pausedAt',
  );
  @override
  late final GeneratedColumn<int> pausedAt = GeneratedColumn<int>(
    'paused_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeStepIdMeta = const VerificationMeta(
    'activeStepId',
  );
  @override
  late final GeneratedColumn<String> activeStepId = GeneratedColumn<String>(
    'active_step_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elapsedActiveSecondsMeta =
      const VerificationMeta('elapsedActiveSeconds');
  @override
  late final GeneratedColumn<int> elapsedActiveSeconds = GeneratedColumn<int>(
    'elapsed_active_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(localAnonymousOwnerId),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(syncStateLocalOnly),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutInstanceId,
    instanceRevisionNumber,
    status,
    startedAt,
    lastResumedAt,
    pausedAt,
    completedAt,
    activeStepId,
    elapsedActiveSeconds,
    notes,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalWorkoutSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workout_instance_id')) {
      context.handle(
        _workoutInstanceIdMeta,
        workoutInstanceId.isAcceptableOrUnknown(
          data['workout_instance_id']!,
          _workoutInstanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutInstanceIdMeta);
    }
    if (data.containsKey('instance_revision_number')) {
      context.handle(
        _instanceRevisionNumberMeta,
        instanceRevisionNumber.isAcceptableOrUnknown(
          data['instance_revision_number']!,
          _instanceRevisionNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instanceRevisionNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('last_resumed_at')) {
      context.handle(
        _lastResumedAtMeta,
        lastResumedAt.isAcceptableOrUnknown(
          data['last_resumed_at']!,
          _lastResumedAtMeta,
        ),
      );
    }
    if (data.containsKey('paused_at')) {
      context.handle(
        _pausedAtMeta,
        pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('active_step_id')) {
      context.handle(
        _activeStepIdMeta,
        activeStepId.isAcceptableOrUnknown(
          data['active_step_id']!,
          _activeStepIdMeta,
        ),
      );
    }
    if (data.containsKey('elapsed_active_seconds')) {
      context.handle(
        _elapsedActiveSecondsMeta,
        elapsedActiveSeconds.isAcceptableOrUnknown(
          data['elapsed_active_seconds']!,
          _elapsedActiveSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_elapsedActiveSecondsMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_rowVersionMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalWorkoutSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalWorkoutSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutInstanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_instance_id'],
      )!,
      instanceRevisionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}instance_revision_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      lastResumedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_resumed_at'],
      ),
      pausedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      activeStepId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_step_id'],
      ),
      elapsedActiveSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_active_seconds'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $LocalWorkoutSessionsTable createAlias(String alias) {
    return $LocalWorkoutSessionsTable(attachedDatabase, alias);
  }
}

class LocalWorkoutSessionRow extends DataClass
    implements Insertable<LocalWorkoutSessionRow> {
  final String id;
  final String workoutInstanceId;
  final int instanceRevisionNumber;
  final String status;
  final int startedAt;
  final int? lastResumedAt;
  final int? pausedAt;
  final int? completedAt;
  final String? activeStepId;
  final int elapsedActiveSeconds;
  final String? notes;
  final int createdAt;
  final int updatedAt;
  final int rowVersion;
  final String ownerId;
  final String syncState;
  const LocalWorkoutSessionRow({
    required this.id,
    required this.workoutInstanceId,
    required this.instanceRevisionNumber,
    required this.status,
    required this.startedAt,
    this.lastResumedAt,
    this.pausedAt,
    this.completedAt,
    this.activeStepId,
    required this.elapsedActiveSeconds,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.rowVersion,
    required this.ownerId,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_instance_id'] = Variable<String>(workoutInstanceId);
    map['instance_revision_number'] = Variable<int>(instanceRevisionNumber);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || lastResumedAt != null) {
      map['last_resumed_at'] = Variable<int>(lastResumedAt);
    }
    if (!nullToAbsent || pausedAt != null) {
      map['paused_at'] = Variable<int>(pausedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    if (!nullToAbsent || activeStepId != null) {
      map['active_step_id'] = Variable<String>(activeStepId);
    }
    map['elapsed_active_seconds'] = Variable<int>(elapsedActiveSeconds);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['row_version'] = Variable<int>(rowVersion);
    map['owner_id'] = Variable<String>(ownerId);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  LocalWorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return LocalWorkoutSessionsCompanion(
      id: Value(id),
      workoutInstanceId: Value(workoutInstanceId),
      instanceRevisionNumber: Value(instanceRevisionNumber),
      status: Value(status),
      startedAt: Value(startedAt),
      lastResumedAt: lastResumedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastResumedAt),
      pausedAt: pausedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      activeStepId: activeStepId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeStepId),
      elapsedActiveSeconds: Value(elapsedActiveSeconds),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      rowVersion: Value(rowVersion),
      ownerId: Value(ownerId),
      syncState: Value(syncState),
    );
  }

  factory LocalWorkoutSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalWorkoutSessionRow(
      id: serializer.fromJson<String>(json['id']),
      workoutInstanceId: serializer.fromJson<String>(json['workoutInstanceId']),
      instanceRevisionNumber: serializer.fromJson<int>(
        json['instanceRevisionNumber'],
      ),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      lastResumedAt: serializer.fromJson<int?>(json['lastResumedAt']),
      pausedAt: serializer.fromJson<int?>(json['pausedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      activeStepId: serializer.fromJson<String?>(json['activeStepId']),
      elapsedActiveSeconds: serializer.fromJson<int>(
        json['elapsedActiveSeconds'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutInstanceId': serializer.toJson<String>(workoutInstanceId),
      'instanceRevisionNumber': serializer.toJson<int>(instanceRevisionNumber),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<int>(startedAt),
      'lastResumedAt': serializer.toJson<int?>(lastResumedAt),
      'pausedAt': serializer.toJson<int?>(pausedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
      'activeStepId': serializer.toJson<String?>(activeStepId),
      'elapsedActiveSeconds': serializer.toJson<int>(elapsedActiveSeconds),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'rowVersion': serializer.toJson<int>(rowVersion),
      'ownerId': serializer.toJson<String>(ownerId),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  LocalWorkoutSessionRow copyWith({
    String? id,
    String? workoutInstanceId,
    int? instanceRevisionNumber,
    String? status,
    int? startedAt,
    Value<int?> lastResumedAt = const Value.absent(),
    Value<int?> pausedAt = const Value.absent(),
    Value<int?> completedAt = const Value.absent(),
    Value<String?> activeStepId = const Value.absent(),
    int? elapsedActiveSeconds,
    Value<String?> notes = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    int? rowVersion,
    String? ownerId,
    String? syncState,
  }) => LocalWorkoutSessionRow(
    id: id ?? this.id,
    workoutInstanceId: workoutInstanceId ?? this.workoutInstanceId,
    instanceRevisionNumber:
        instanceRevisionNumber ?? this.instanceRevisionNumber,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    lastResumedAt: lastResumedAt.present
        ? lastResumedAt.value
        : this.lastResumedAt,
    pausedAt: pausedAt.present ? pausedAt.value : this.pausedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    activeStepId: activeStepId.present ? activeStepId.value : this.activeStepId,
    elapsedActiveSeconds: elapsedActiveSeconds ?? this.elapsedActiveSeconds,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    rowVersion: rowVersion ?? this.rowVersion,
    ownerId: ownerId ?? this.ownerId,
    syncState: syncState ?? this.syncState,
  );
  LocalWorkoutSessionRow copyWithCompanion(LocalWorkoutSessionsCompanion data) {
    return LocalWorkoutSessionRow(
      id: data.id.present ? data.id.value : this.id,
      workoutInstanceId: data.workoutInstanceId.present
          ? data.workoutInstanceId.value
          : this.workoutInstanceId,
      instanceRevisionNumber: data.instanceRevisionNumber.present
          ? data.instanceRevisionNumber.value
          : this.instanceRevisionNumber,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      lastResumedAt: data.lastResumedAt.present
          ? data.lastResumedAt.value
          : this.lastResumedAt,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      activeStepId: data.activeStepId.present
          ? data.activeStepId.value
          : this.activeStepId,
      elapsedActiveSeconds: data.elapsedActiveSeconds.present
          ? data.elapsedActiveSeconds.value
          : this.elapsedActiveSeconds,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalWorkoutSessionRow(')
          ..write('id: $id, ')
          ..write('workoutInstanceId: $workoutInstanceId, ')
          ..write('instanceRevisionNumber: $instanceRevisionNumber, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastResumedAt: $lastResumedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('activeStepId: $activeStepId, ')
          ..write('elapsedActiveSeconds: $elapsedActiveSeconds, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutInstanceId,
    instanceRevisionNumber,
    status,
    startedAt,
    lastResumedAt,
    pausedAt,
    completedAt,
    activeStepId,
    elapsedActiveSeconds,
    notes,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalWorkoutSessionRow &&
          other.id == this.id &&
          other.workoutInstanceId == this.workoutInstanceId &&
          other.instanceRevisionNumber == this.instanceRevisionNumber &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.lastResumedAt == this.lastResumedAt &&
          other.pausedAt == this.pausedAt &&
          other.completedAt == this.completedAt &&
          other.activeStepId == this.activeStepId &&
          other.elapsedActiveSeconds == this.elapsedActiveSeconds &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.rowVersion == this.rowVersion &&
          other.ownerId == this.ownerId &&
          other.syncState == this.syncState);
}

class LocalWorkoutSessionsCompanion
    extends UpdateCompanion<LocalWorkoutSessionRow> {
  final Value<String> id;
  final Value<String> workoutInstanceId;
  final Value<int> instanceRevisionNumber;
  final Value<String> status;
  final Value<int> startedAt;
  final Value<int?> lastResumedAt;
  final Value<int?> pausedAt;
  final Value<int?> completedAt;
  final Value<String?> activeStepId;
  final Value<int> elapsedActiveSeconds;
  final Value<String?> notes;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowVersion;
  final Value<String> ownerId;
  final Value<String> syncState;
  final Value<int> rowid;
  const LocalWorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.workoutInstanceId = const Value.absent(),
    this.instanceRevisionNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastResumedAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.activeStepId = const Value.absent(),
    this.elapsedActiveSeconds = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowVersion = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalWorkoutSessionsCompanion.insert({
    required String id,
    required String workoutInstanceId,
    required int instanceRevisionNumber,
    required String status,
    required int startedAt,
    this.lastResumedAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.activeStepId = const Value.absent(),
    required int elapsedActiveSeconds,
    this.notes = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required int rowVersion,
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workoutInstanceId = Value(workoutInstanceId),
       instanceRevisionNumber = Value(instanceRevisionNumber),
       status = Value(status),
       startedAt = Value(startedAt),
       elapsedActiveSeconds = Value(elapsedActiveSeconds),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       rowVersion = Value(rowVersion);
  static Insertable<LocalWorkoutSessionRow> custom({
    Expression<String>? id,
    Expression<String>? workoutInstanceId,
    Expression<int>? instanceRevisionNumber,
    Expression<String>? status,
    Expression<int>? startedAt,
    Expression<int>? lastResumedAt,
    Expression<int>? pausedAt,
    Expression<int>? completedAt,
    Expression<String>? activeStepId,
    Expression<int>? elapsedActiveSeconds,
    Expression<String>? notes,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowVersion,
    Expression<String>? ownerId,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutInstanceId != null) 'workout_instance_id': workoutInstanceId,
      if (instanceRevisionNumber != null)
        'instance_revision_number': instanceRevisionNumber,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (lastResumedAt != null) 'last_resumed_at': lastResumedAt,
      if (pausedAt != null) 'paused_at': pausedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (activeStepId != null) 'active_step_id': activeStepId,
      if (elapsedActiveSeconds != null)
        'elapsed_active_seconds': elapsedActiveSeconds,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowVersion != null) 'row_version': rowVersion,
      if (ownerId != null) 'owner_id': ownerId,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalWorkoutSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutInstanceId,
    Value<int>? instanceRevisionNumber,
    Value<String>? status,
    Value<int>? startedAt,
    Value<int?>? lastResumedAt,
    Value<int?>? pausedAt,
    Value<int?>? completedAt,
    Value<String?>? activeStepId,
    Value<int>? elapsedActiveSeconds,
    Value<String?>? notes,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowVersion,
    Value<String>? ownerId,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return LocalWorkoutSessionsCompanion(
      id: id ?? this.id,
      workoutInstanceId: workoutInstanceId ?? this.workoutInstanceId,
      instanceRevisionNumber:
          instanceRevisionNumber ?? this.instanceRevisionNumber,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      lastResumedAt: lastResumedAt ?? this.lastResumedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      completedAt: completedAt ?? this.completedAt,
      activeStepId: activeStepId ?? this.activeStepId,
      elapsedActiveSeconds: elapsedActiveSeconds ?? this.elapsedActiveSeconds,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowVersion: rowVersion ?? this.rowVersion,
      ownerId: ownerId ?? this.ownerId,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutInstanceId.present) {
      map['workout_instance_id'] = Variable<String>(workoutInstanceId.value);
    }
    if (instanceRevisionNumber.present) {
      map['instance_revision_number'] = Variable<int>(
        instanceRevisionNumber.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (lastResumedAt.present) {
      map['last_resumed_at'] = Variable<int>(lastResumedAt.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<int>(pausedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (activeStepId.present) {
      map['active_step_id'] = Variable<String>(activeStepId.value);
    }
    if (elapsedActiveSeconds.present) {
      map['elapsed_active_seconds'] = Variable<int>(elapsedActiveSeconds.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalWorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('workoutInstanceId: $workoutInstanceId, ')
          ..write('instanceRevisionNumber: $instanceRevisionNumber, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastResumedAt: $lastResumedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('activeStepId: $activeStepId, ')
          ..write('elapsedActiveSeconds: $elapsedActiveSeconds, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalStepPerformancesTable extends LocalStepPerformances
    with TableInfo<$LocalStepPerformancesTable, LocalStepPerformanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalStepPerformancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutSessionIdMeta = const VerificationMeta(
    'workoutSessionId',
  );
  @override
  late final GeneratedColumn<String> workoutSessionId = GeneratedColumn<String>(
    'workout_session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_workout_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _workoutStepIdMeta = const VerificationMeta(
    'workoutStepId',
  );
  @override
  late final GeneratedColumn<String> workoutStepId = GeneratedColumn<String>(
    'workout_step_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_workout_steps (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualRepetitionsMeta = const VerificationMeta(
    'actualRepetitions',
  );
  @override
  late final GeneratedColumn<int> actualRepetitions = GeneratedColumn<int>(
    'actual_repetitions',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualDurationSecondsMeta =
      const VerificationMeta('actualDurationSeconds');
  @override
  late final GeneratedColumn<int> actualDurationSeconds = GeneratedColumn<int>(
    'actual_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualDistanceMetersMeta =
      const VerificationMeta('actualDistanceMeters');
  @override
  late final GeneratedColumn<double> actualDistanceMeters =
      GeneratedColumn<double>(
        'actual_distance_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _actualWeightKgMeta = const VerificationMeta(
    'actualWeightKg',
  );
  @override
  late final GeneratedColumn<double> actualWeightKg = GeneratedColumn<double>(
    'actual_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _perceivedExertionMeta = const VerificationMeta(
    'perceivedExertion',
  );
  @override
  late final GeneratedColumn<double> perceivedExertion =
      GeneratedColumn<double>(
        'perceived_exertion',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutSessionId,
    workoutStepId,
    status,
    startedAt,
    completedAt,
    actualRepetitions,
    actualDurationSeconds,
    actualDistanceMeters,
    actualWeightKg,
    perceivedExertion,
    notes,
    updatedAt,
    rowVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_step_performances';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalStepPerformanceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workout_session_id')) {
      context.handle(
        _workoutSessionIdMeta,
        workoutSessionId.isAcceptableOrUnknown(
          data['workout_session_id']!,
          _workoutSessionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutSessionIdMeta);
    }
    if (data.containsKey('workout_step_id')) {
      context.handle(
        _workoutStepIdMeta,
        workoutStepId.isAcceptableOrUnknown(
          data['workout_step_id']!,
          _workoutStepIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutStepIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('actual_repetitions')) {
      context.handle(
        _actualRepetitionsMeta,
        actualRepetitions.isAcceptableOrUnknown(
          data['actual_repetitions']!,
          _actualRepetitionsMeta,
        ),
      );
    }
    if (data.containsKey('actual_duration_seconds')) {
      context.handle(
        _actualDurationSecondsMeta,
        actualDurationSeconds.isAcceptableOrUnknown(
          data['actual_duration_seconds']!,
          _actualDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('actual_distance_meters')) {
      context.handle(
        _actualDistanceMetersMeta,
        actualDistanceMeters.isAcceptableOrUnknown(
          data['actual_distance_meters']!,
          _actualDistanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('actual_weight_kg')) {
      context.handle(
        _actualWeightKgMeta,
        actualWeightKg.isAcceptableOrUnknown(
          data['actual_weight_kg']!,
          _actualWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('perceived_exertion')) {
      context.handle(
        _perceivedExertionMeta,
        perceivedExertion.isAcceptableOrUnknown(
          data['perceived_exertion']!,
          _perceivedExertionMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_rowVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {workoutSessionId, workoutStepId},
  ];
  @override
  LocalStepPerformanceRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalStepPerformanceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_session_id'],
      )!,
      workoutStepId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_step_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      actualRepetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_repetitions'],
      ),
      actualDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_duration_seconds'],
      ),
      actualDistanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_distance_meters'],
      ),
      actualWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_weight_kg'],
      ),
      perceivedExertion: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}perceived_exertion'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
    );
  }

  @override
  $LocalStepPerformancesTable createAlias(String alias) {
    return $LocalStepPerformancesTable(attachedDatabase, alias);
  }
}

class LocalStepPerformanceRow extends DataClass
    implements Insertable<LocalStepPerformanceRow> {
  final String id;
  final String workoutSessionId;
  final String workoutStepId;
  final String status;
  final int? startedAt;
  final int? completedAt;
  final int? actualRepetitions;
  final int? actualDurationSeconds;
  final double? actualDistanceMeters;
  final double? actualWeightKg;
  final double? perceivedExertion;
  final String? notes;
  final int updatedAt;
  final int rowVersion;
  const LocalStepPerformanceRow({
    required this.id,
    required this.workoutSessionId,
    required this.workoutStepId,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.actualRepetitions,
    this.actualDurationSeconds,
    this.actualDistanceMeters,
    this.actualWeightKg,
    this.perceivedExertion,
    this.notes,
    required this.updatedAt,
    required this.rowVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_session_id'] = Variable<String>(workoutSessionId);
    map['workout_step_id'] = Variable<String>(workoutStepId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<int>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    if (!nullToAbsent || actualRepetitions != null) {
      map['actual_repetitions'] = Variable<int>(actualRepetitions);
    }
    if (!nullToAbsent || actualDurationSeconds != null) {
      map['actual_duration_seconds'] = Variable<int>(actualDurationSeconds);
    }
    if (!nullToAbsent || actualDistanceMeters != null) {
      map['actual_distance_meters'] = Variable<double>(actualDistanceMeters);
    }
    if (!nullToAbsent || actualWeightKg != null) {
      map['actual_weight_kg'] = Variable<double>(actualWeightKg);
    }
    if (!nullToAbsent || perceivedExertion != null) {
      map['perceived_exertion'] = Variable<double>(perceivedExertion);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    map['row_version'] = Variable<int>(rowVersion);
    return map;
  }

  LocalStepPerformancesCompanion toCompanion(bool nullToAbsent) {
    return LocalStepPerformancesCompanion(
      id: Value(id),
      workoutSessionId: Value(workoutSessionId),
      workoutStepId: Value(workoutStepId),
      status: Value(status),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      actualRepetitions: actualRepetitions == null && nullToAbsent
          ? const Value.absent()
          : Value(actualRepetitions),
      actualDurationSeconds: actualDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDurationSeconds),
      actualDistanceMeters: actualDistanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDistanceMeters),
      actualWeightKg: actualWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(actualWeightKg),
      perceivedExertion: perceivedExertion == null && nullToAbsent
          ? const Value.absent()
          : Value(perceivedExertion),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      updatedAt: Value(updatedAt),
      rowVersion: Value(rowVersion),
    );
  }

  factory LocalStepPerformanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalStepPerformanceRow(
      id: serializer.fromJson<String>(json['id']),
      workoutSessionId: serializer.fromJson<String>(json['workoutSessionId']),
      workoutStepId: serializer.fromJson<String>(json['workoutStepId']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<int?>(json['startedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      actualRepetitions: serializer.fromJson<int?>(json['actualRepetitions']),
      actualDurationSeconds: serializer.fromJson<int?>(
        json['actualDurationSeconds'],
      ),
      actualDistanceMeters: serializer.fromJson<double?>(
        json['actualDistanceMeters'],
      ),
      actualWeightKg: serializer.fromJson<double?>(json['actualWeightKg']),
      perceivedExertion: serializer.fromJson<double?>(
        json['perceivedExertion'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutSessionId': serializer.toJson<String>(workoutSessionId),
      'workoutStepId': serializer.toJson<String>(workoutStepId),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<int?>(startedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
      'actualRepetitions': serializer.toJson<int?>(actualRepetitions),
      'actualDurationSeconds': serializer.toJson<int?>(actualDurationSeconds),
      'actualDistanceMeters': serializer.toJson<double?>(actualDistanceMeters),
      'actualWeightKg': serializer.toJson<double?>(actualWeightKg),
      'perceivedExertion': serializer.toJson<double?>(perceivedExertion),
      'notes': serializer.toJson<String?>(notes),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'rowVersion': serializer.toJson<int>(rowVersion),
    };
  }

  LocalStepPerformanceRow copyWith({
    String? id,
    String? workoutSessionId,
    String? workoutStepId,
    String? status,
    Value<int?> startedAt = const Value.absent(),
    Value<int?> completedAt = const Value.absent(),
    Value<int?> actualRepetitions = const Value.absent(),
    Value<int?> actualDurationSeconds = const Value.absent(),
    Value<double?> actualDistanceMeters = const Value.absent(),
    Value<double?> actualWeightKg = const Value.absent(),
    Value<double?> perceivedExertion = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? updatedAt,
    int? rowVersion,
  }) => LocalStepPerformanceRow(
    id: id ?? this.id,
    workoutSessionId: workoutSessionId ?? this.workoutSessionId,
    workoutStepId: workoutStepId ?? this.workoutStepId,
    status: status ?? this.status,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    actualRepetitions: actualRepetitions.present
        ? actualRepetitions.value
        : this.actualRepetitions,
    actualDurationSeconds: actualDurationSeconds.present
        ? actualDurationSeconds.value
        : this.actualDurationSeconds,
    actualDistanceMeters: actualDistanceMeters.present
        ? actualDistanceMeters.value
        : this.actualDistanceMeters,
    actualWeightKg: actualWeightKg.present
        ? actualWeightKg.value
        : this.actualWeightKg,
    perceivedExertion: perceivedExertion.present
        ? perceivedExertion.value
        : this.perceivedExertion,
    notes: notes.present ? notes.value : this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
    rowVersion: rowVersion ?? this.rowVersion,
  );
  LocalStepPerformanceRow copyWithCompanion(
    LocalStepPerformancesCompanion data,
  ) {
    return LocalStepPerformanceRow(
      id: data.id.present ? data.id.value : this.id,
      workoutSessionId: data.workoutSessionId.present
          ? data.workoutSessionId.value
          : this.workoutSessionId,
      workoutStepId: data.workoutStepId.present
          ? data.workoutStepId.value
          : this.workoutStepId,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      actualRepetitions: data.actualRepetitions.present
          ? data.actualRepetitions.value
          : this.actualRepetitions,
      actualDurationSeconds: data.actualDurationSeconds.present
          ? data.actualDurationSeconds.value
          : this.actualDurationSeconds,
      actualDistanceMeters: data.actualDistanceMeters.present
          ? data.actualDistanceMeters.value
          : this.actualDistanceMeters,
      actualWeightKg: data.actualWeightKg.present
          ? data.actualWeightKg.value
          : this.actualWeightKg,
      perceivedExertion: data.perceivedExertion.present
          ? data.perceivedExertion.value
          : this.perceivedExertion,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalStepPerformanceRow(')
          ..write('id: $id, ')
          ..write('workoutSessionId: $workoutSessionId, ')
          ..write('workoutStepId: $workoutStepId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('actualRepetitions: $actualRepetitions, ')
          ..write('actualDurationSeconds: $actualDurationSeconds, ')
          ..write('actualDistanceMeters: $actualDistanceMeters, ')
          ..write('actualWeightKg: $actualWeightKg, ')
          ..write('perceivedExertion: $perceivedExertion, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutSessionId,
    workoutStepId,
    status,
    startedAt,
    completedAt,
    actualRepetitions,
    actualDurationSeconds,
    actualDistanceMeters,
    actualWeightKg,
    perceivedExertion,
    notes,
    updatedAt,
    rowVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalStepPerformanceRow &&
          other.id == this.id &&
          other.workoutSessionId == this.workoutSessionId &&
          other.workoutStepId == this.workoutStepId &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.actualRepetitions == this.actualRepetitions &&
          other.actualDurationSeconds == this.actualDurationSeconds &&
          other.actualDistanceMeters == this.actualDistanceMeters &&
          other.actualWeightKg == this.actualWeightKg &&
          other.perceivedExertion == this.perceivedExertion &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt &&
          other.rowVersion == this.rowVersion);
}

class LocalStepPerformancesCompanion
    extends UpdateCompanion<LocalStepPerformanceRow> {
  final Value<String> id;
  final Value<String> workoutSessionId;
  final Value<String> workoutStepId;
  final Value<String> status;
  final Value<int?> startedAt;
  final Value<int?> completedAt;
  final Value<int?> actualRepetitions;
  final Value<int?> actualDurationSeconds;
  final Value<double?> actualDistanceMeters;
  final Value<double?> actualWeightKg;
  final Value<double?> perceivedExertion;
  final Value<String?> notes;
  final Value<int> updatedAt;
  final Value<int> rowVersion;
  final Value<int> rowid;
  const LocalStepPerformancesCompanion({
    this.id = const Value.absent(),
    this.workoutSessionId = const Value.absent(),
    this.workoutStepId = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.actualRepetitions = const Value.absent(),
    this.actualDurationSeconds = const Value.absent(),
    this.actualDistanceMeters = const Value.absent(),
    this.actualWeightKg = const Value.absent(),
    this.perceivedExertion = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalStepPerformancesCompanion.insert({
    required String id,
    required String workoutSessionId,
    required String workoutStepId,
    required String status,
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.actualRepetitions = const Value.absent(),
    this.actualDurationSeconds = const Value.absent(),
    this.actualDistanceMeters = const Value.absent(),
    this.actualWeightKg = const Value.absent(),
    this.perceivedExertion = const Value.absent(),
    this.notes = const Value.absent(),
    required int updatedAt,
    required int rowVersion,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workoutSessionId = Value(workoutSessionId),
       workoutStepId = Value(workoutStepId),
       status = Value(status),
       updatedAt = Value(updatedAt),
       rowVersion = Value(rowVersion);
  static Insertable<LocalStepPerformanceRow> custom({
    Expression<String>? id,
    Expression<String>? workoutSessionId,
    Expression<String>? workoutStepId,
    Expression<String>? status,
    Expression<int>? startedAt,
    Expression<int>? completedAt,
    Expression<int>? actualRepetitions,
    Expression<int>? actualDurationSeconds,
    Expression<double>? actualDistanceMeters,
    Expression<double>? actualWeightKg,
    Expression<double>? perceivedExertion,
    Expression<String>? notes,
    Expression<int>? updatedAt,
    Expression<int>? rowVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutSessionId != null) 'workout_session_id': workoutSessionId,
      if (workoutStepId != null) 'workout_step_id': workoutStepId,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (actualRepetitions != null) 'actual_repetitions': actualRepetitions,
      if (actualDurationSeconds != null)
        'actual_duration_seconds': actualDurationSeconds,
      if (actualDistanceMeters != null)
        'actual_distance_meters': actualDistanceMeters,
      if (actualWeightKg != null) 'actual_weight_kg': actualWeightKg,
      if (perceivedExertion != null) 'perceived_exertion': perceivedExertion,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowVersion != null) 'row_version': rowVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalStepPerformancesCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutSessionId,
    Value<String>? workoutStepId,
    Value<String>? status,
    Value<int?>? startedAt,
    Value<int?>? completedAt,
    Value<int?>? actualRepetitions,
    Value<int?>? actualDurationSeconds,
    Value<double?>? actualDistanceMeters,
    Value<double?>? actualWeightKg,
    Value<double?>? perceivedExertion,
    Value<String?>? notes,
    Value<int>? updatedAt,
    Value<int>? rowVersion,
    Value<int>? rowid,
  }) {
    return LocalStepPerformancesCompanion(
      id: id ?? this.id,
      workoutSessionId: workoutSessionId ?? this.workoutSessionId,
      workoutStepId: workoutStepId ?? this.workoutStepId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      actualRepetitions: actualRepetitions ?? this.actualRepetitions,
      actualDurationSeconds:
          actualDurationSeconds ?? this.actualDurationSeconds,
      actualDistanceMeters: actualDistanceMeters ?? this.actualDistanceMeters,
      actualWeightKg: actualWeightKg ?? this.actualWeightKg,
      perceivedExertion: perceivedExertion ?? this.perceivedExertion,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      rowVersion: rowVersion ?? this.rowVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutSessionId.present) {
      map['workout_session_id'] = Variable<String>(workoutSessionId.value);
    }
    if (workoutStepId.present) {
      map['workout_step_id'] = Variable<String>(workoutStepId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (actualRepetitions.present) {
      map['actual_repetitions'] = Variable<int>(actualRepetitions.value);
    }
    if (actualDurationSeconds.present) {
      map['actual_duration_seconds'] = Variable<int>(
        actualDurationSeconds.value,
      );
    }
    if (actualDistanceMeters.present) {
      map['actual_distance_meters'] = Variable<double>(
        actualDistanceMeters.value,
      );
    }
    if (actualWeightKg.present) {
      map['actual_weight_kg'] = Variable<double>(actualWeightKg.value);
    }
    if (perceivedExertion.present) {
      map['perceived_exertion'] = Variable<double>(perceivedExertion.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalStepPerformancesCompanion(')
          ..write('id: $id, ')
          ..write('workoutSessionId: $workoutSessionId, ')
          ..write('workoutStepId: $workoutStepId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('actualRepetitions: $actualRepetitions, ')
          ..write('actualDurationSeconds: $actualDurationSeconds, ')
          ..write('actualDistanceMeters: $actualDistanceMeters, ')
          ..write('actualWeightKg: $actualWeightKg, ')
          ..write('perceivedExertion: $perceivedExertion, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSetPerformancesTable extends LocalSetPerformances
    with TableInfo<$LocalSetPerformancesTable, LocalSetPerformanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSetPerformancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepPerformanceIdMeta = const VerificationMeta(
    'stepPerformanceId',
  );
  @override
  late final GeneratedColumn<String> stepPerformanceId =
      GeneratedColumn<String>(
        'step_performance_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_step_performances (id) ON DELETE CASCADE',
        ),
      );
  static const VerificationMeta _setPlanIdMeta = const VerificationMeta(
    'setPlanId',
  );
  @override
  late final GeneratedColumn<String> setPlanId = GeneratedColumn<String>(
    'set_plan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_set_plans (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualRepetitionsMeta = const VerificationMeta(
    'actualRepetitions',
  );
  @override
  late final GeneratedColumn<int> actualRepetitions = GeneratedColumn<int>(
    'actual_repetitions',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualWeightKgMeta = const VerificationMeta(
    'actualWeightKg',
  );
  @override
  late final GeneratedColumn<double> actualWeightKg = GeneratedColumn<double>(
    'actual_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualDurationSecondsMeta =
      const VerificationMeta('actualDurationSeconds');
  @override
  late final GeneratedColumn<int> actualDurationSeconds = GeneratedColumn<int>(
    'actual_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualRpeMeta = const VerificationMeta(
    'actualRpe',
  );
  @override
  late final GeneratedColumn<double> actualRpe = GeneratedColumn<double>(
    'actual_rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stepPerformanceId,
    setPlanId,
    position,
    status,
    actualRepetitions,
    actualWeightKg,
    actualDurationSeconds,
    actualRpe,
    completedAt,
    notes,
    updatedAt,
    rowVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_set_performances';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSetPerformanceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('step_performance_id')) {
      context.handle(
        _stepPerformanceIdMeta,
        stepPerformanceId.isAcceptableOrUnknown(
          data['step_performance_id']!,
          _stepPerformanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stepPerformanceIdMeta);
    }
    if (data.containsKey('set_plan_id')) {
      context.handle(
        _setPlanIdMeta,
        setPlanId.isAcceptableOrUnknown(data['set_plan_id']!, _setPlanIdMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('actual_repetitions')) {
      context.handle(
        _actualRepetitionsMeta,
        actualRepetitions.isAcceptableOrUnknown(
          data['actual_repetitions']!,
          _actualRepetitionsMeta,
        ),
      );
    }
    if (data.containsKey('actual_weight_kg')) {
      context.handle(
        _actualWeightKgMeta,
        actualWeightKg.isAcceptableOrUnknown(
          data['actual_weight_kg']!,
          _actualWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('actual_duration_seconds')) {
      context.handle(
        _actualDurationSecondsMeta,
        actualDurationSeconds.isAcceptableOrUnknown(
          data['actual_duration_seconds']!,
          _actualDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('actual_rpe')) {
      context.handle(
        _actualRpeMeta,
        actualRpe.isAcceptableOrUnknown(data['actual_rpe']!, _actualRpeMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_rowVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {stepPerformanceId, position},
  ];
  @override
  LocalSetPerformanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSetPerformanceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      stepPerformanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}step_performance_id'],
      )!,
      setPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_plan_id'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      actualRepetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_repetitions'],
      ),
      actualWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_weight_kg'],
      ),
      actualDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_duration_seconds'],
      ),
      actualRpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_rpe'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
    );
  }

  @override
  $LocalSetPerformancesTable createAlias(String alias) {
    return $LocalSetPerformancesTable(attachedDatabase, alias);
  }
}

class LocalSetPerformanceRow extends DataClass
    implements Insertable<LocalSetPerformanceRow> {
  final String id;
  final String stepPerformanceId;
  final String? setPlanId;
  final int position;
  final String status;
  final int? actualRepetitions;
  final double? actualWeightKg;
  final int? actualDurationSeconds;
  final double? actualRpe;
  final int? completedAt;
  final String? notes;
  final int updatedAt;
  final int rowVersion;
  const LocalSetPerformanceRow({
    required this.id,
    required this.stepPerformanceId,
    this.setPlanId,
    required this.position,
    required this.status,
    this.actualRepetitions,
    this.actualWeightKg,
    this.actualDurationSeconds,
    this.actualRpe,
    this.completedAt,
    this.notes,
    required this.updatedAt,
    required this.rowVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['step_performance_id'] = Variable<String>(stepPerformanceId);
    if (!nullToAbsent || setPlanId != null) {
      map['set_plan_id'] = Variable<String>(setPlanId);
    }
    map['position'] = Variable<int>(position);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || actualRepetitions != null) {
      map['actual_repetitions'] = Variable<int>(actualRepetitions);
    }
    if (!nullToAbsent || actualWeightKg != null) {
      map['actual_weight_kg'] = Variable<double>(actualWeightKg);
    }
    if (!nullToAbsent || actualDurationSeconds != null) {
      map['actual_duration_seconds'] = Variable<int>(actualDurationSeconds);
    }
    if (!nullToAbsent || actualRpe != null) {
      map['actual_rpe'] = Variable<double>(actualRpe);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    map['row_version'] = Variable<int>(rowVersion);
    return map;
  }

  LocalSetPerformancesCompanion toCompanion(bool nullToAbsent) {
    return LocalSetPerformancesCompanion(
      id: Value(id),
      stepPerformanceId: Value(stepPerformanceId),
      setPlanId: setPlanId == null && nullToAbsent
          ? const Value.absent()
          : Value(setPlanId),
      position: Value(position),
      status: Value(status),
      actualRepetitions: actualRepetitions == null && nullToAbsent
          ? const Value.absent()
          : Value(actualRepetitions),
      actualWeightKg: actualWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(actualWeightKg),
      actualDurationSeconds: actualDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDurationSeconds),
      actualRpe: actualRpe == null && nullToAbsent
          ? const Value.absent()
          : Value(actualRpe),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      updatedAt: Value(updatedAt),
      rowVersion: Value(rowVersion),
    );
  }

  factory LocalSetPerformanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSetPerformanceRow(
      id: serializer.fromJson<String>(json['id']),
      stepPerformanceId: serializer.fromJson<String>(json['stepPerformanceId']),
      setPlanId: serializer.fromJson<String?>(json['setPlanId']),
      position: serializer.fromJson<int>(json['position']),
      status: serializer.fromJson<String>(json['status']),
      actualRepetitions: serializer.fromJson<int?>(json['actualRepetitions']),
      actualWeightKg: serializer.fromJson<double?>(json['actualWeightKg']),
      actualDurationSeconds: serializer.fromJson<int?>(
        json['actualDurationSeconds'],
      ),
      actualRpe: serializer.fromJson<double?>(json['actualRpe']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'stepPerformanceId': serializer.toJson<String>(stepPerformanceId),
      'setPlanId': serializer.toJson<String?>(setPlanId),
      'position': serializer.toJson<int>(position),
      'status': serializer.toJson<String>(status),
      'actualRepetitions': serializer.toJson<int?>(actualRepetitions),
      'actualWeightKg': serializer.toJson<double?>(actualWeightKg),
      'actualDurationSeconds': serializer.toJson<int?>(actualDurationSeconds),
      'actualRpe': serializer.toJson<double?>(actualRpe),
      'completedAt': serializer.toJson<int?>(completedAt),
      'notes': serializer.toJson<String?>(notes),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'rowVersion': serializer.toJson<int>(rowVersion),
    };
  }

  LocalSetPerformanceRow copyWith({
    String? id,
    String? stepPerformanceId,
    Value<String?> setPlanId = const Value.absent(),
    int? position,
    String? status,
    Value<int?> actualRepetitions = const Value.absent(),
    Value<double?> actualWeightKg = const Value.absent(),
    Value<int?> actualDurationSeconds = const Value.absent(),
    Value<double?> actualRpe = const Value.absent(),
    Value<int?> completedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? updatedAt,
    int? rowVersion,
  }) => LocalSetPerformanceRow(
    id: id ?? this.id,
    stepPerformanceId: stepPerformanceId ?? this.stepPerformanceId,
    setPlanId: setPlanId.present ? setPlanId.value : this.setPlanId,
    position: position ?? this.position,
    status: status ?? this.status,
    actualRepetitions: actualRepetitions.present
        ? actualRepetitions.value
        : this.actualRepetitions,
    actualWeightKg: actualWeightKg.present
        ? actualWeightKg.value
        : this.actualWeightKg,
    actualDurationSeconds: actualDurationSeconds.present
        ? actualDurationSeconds.value
        : this.actualDurationSeconds,
    actualRpe: actualRpe.present ? actualRpe.value : this.actualRpe,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    notes: notes.present ? notes.value : this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
    rowVersion: rowVersion ?? this.rowVersion,
  );
  LocalSetPerformanceRow copyWithCompanion(LocalSetPerformancesCompanion data) {
    return LocalSetPerformanceRow(
      id: data.id.present ? data.id.value : this.id,
      stepPerformanceId: data.stepPerformanceId.present
          ? data.stepPerformanceId.value
          : this.stepPerformanceId,
      setPlanId: data.setPlanId.present ? data.setPlanId.value : this.setPlanId,
      position: data.position.present ? data.position.value : this.position,
      status: data.status.present ? data.status.value : this.status,
      actualRepetitions: data.actualRepetitions.present
          ? data.actualRepetitions.value
          : this.actualRepetitions,
      actualWeightKg: data.actualWeightKg.present
          ? data.actualWeightKg.value
          : this.actualWeightKg,
      actualDurationSeconds: data.actualDurationSeconds.present
          ? data.actualDurationSeconds.value
          : this.actualDurationSeconds,
      actualRpe: data.actualRpe.present ? data.actualRpe.value : this.actualRpe,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSetPerformanceRow(')
          ..write('id: $id, ')
          ..write('stepPerformanceId: $stepPerformanceId, ')
          ..write('setPlanId: $setPlanId, ')
          ..write('position: $position, ')
          ..write('status: $status, ')
          ..write('actualRepetitions: $actualRepetitions, ')
          ..write('actualWeightKg: $actualWeightKg, ')
          ..write('actualDurationSeconds: $actualDurationSeconds, ')
          ..write('actualRpe: $actualRpe, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    stepPerformanceId,
    setPlanId,
    position,
    status,
    actualRepetitions,
    actualWeightKg,
    actualDurationSeconds,
    actualRpe,
    completedAt,
    notes,
    updatedAt,
    rowVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSetPerformanceRow &&
          other.id == this.id &&
          other.stepPerformanceId == this.stepPerformanceId &&
          other.setPlanId == this.setPlanId &&
          other.position == this.position &&
          other.status == this.status &&
          other.actualRepetitions == this.actualRepetitions &&
          other.actualWeightKg == this.actualWeightKg &&
          other.actualDurationSeconds == this.actualDurationSeconds &&
          other.actualRpe == this.actualRpe &&
          other.completedAt == this.completedAt &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt &&
          other.rowVersion == this.rowVersion);
}

class LocalSetPerformancesCompanion
    extends UpdateCompanion<LocalSetPerformanceRow> {
  final Value<String> id;
  final Value<String> stepPerformanceId;
  final Value<String?> setPlanId;
  final Value<int> position;
  final Value<String> status;
  final Value<int?> actualRepetitions;
  final Value<double?> actualWeightKg;
  final Value<int?> actualDurationSeconds;
  final Value<double?> actualRpe;
  final Value<int?> completedAt;
  final Value<String?> notes;
  final Value<int> updatedAt;
  final Value<int> rowVersion;
  final Value<int> rowid;
  const LocalSetPerformancesCompanion({
    this.id = const Value.absent(),
    this.stepPerformanceId = const Value.absent(),
    this.setPlanId = const Value.absent(),
    this.position = const Value.absent(),
    this.status = const Value.absent(),
    this.actualRepetitions = const Value.absent(),
    this.actualWeightKg = const Value.absent(),
    this.actualDurationSeconds = const Value.absent(),
    this.actualRpe = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSetPerformancesCompanion.insert({
    required String id,
    required String stepPerformanceId,
    this.setPlanId = const Value.absent(),
    required int position,
    required String status,
    this.actualRepetitions = const Value.absent(),
    this.actualWeightKg = const Value.absent(),
    this.actualDurationSeconds = const Value.absent(),
    this.actualRpe = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    required int updatedAt,
    required int rowVersion,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       stepPerformanceId = Value(stepPerformanceId),
       position = Value(position),
       status = Value(status),
       updatedAt = Value(updatedAt),
       rowVersion = Value(rowVersion);
  static Insertable<LocalSetPerformanceRow> custom({
    Expression<String>? id,
    Expression<String>? stepPerformanceId,
    Expression<String>? setPlanId,
    Expression<int>? position,
    Expression<String>? status,
    Expression<int>? actualRepetitions,
    Expression<double>? actualWeightKg,
    Expression<int>? actualDurationSeconds,
    Expression<double>? actualRpe,
    Expression<int>? completedAt,
    Expression<String>? notes,
    Expression<int>? updatedAt,
    Expression<int>? rowVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stepPerformanceId != null) 'step_performance_id': stepPerformanceId,
      if (setPlanId != null) 'set_plan_id': setPlanId,
      if (position != null) 'position': position,
      if (status != null) 'status': status,
      if (actualRepetitions != null) 'actual_repetitions': actualRepetitions,
      if (actualWeightKg != null) 'actual_weight_kg': actualWeightKg,
      if (actualDurationSeconds != null)
        'actual_duration_seconds': actualDurationSeconds,
      if (actualRpe != null) 'actual_rpe': actualRpe,
      if (completedAt != null) 'completed_at': completedAt,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowVersion != null) 'row_version': rowVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSetPerformancesCompanion copyWith({
    Value<String>? id,
    Value<String>? stepPerformanceId,
    Value<String?>? setPlanId,
    Value<int>? position,
    Value<String>? status,
    Value<int?>? actualRepetitions,
    Value<double?>? actualWeightKg,
    Value<int?>? actualDurationSeconds,
    Value<double?>? actualRpe,
    Value<int?>? completedAt,
    Value<String?>? notes,
    Value<int>? updatedAt,
    Value<int>? rowVersion,
    Value<int>? rowid,
  }) {
    return LocalSetPerformancesCompanion(
      id: id ?? this.id,
      stepPerformanceId: stepPerformanceId ?? this.stepPerformanceId,
      setPlanId: setPlanId ?? this.setPlanId,
      position: position ?? this.position,
      status: status ?? this.status,
      actualRepetitions: actualRepetitions ?? this.actualRepetitions,
      actualWeightKg: actualWeightKg ?? this.actualWeightKg,
      actualDurationSeconds:
          actualDurationSeconds ?? this.actualDurationSeconds,
      actualRpe: actualRpe ?? this.actualRpe,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      rowVersion: rowVersion ?? this.rowVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (stepPerformanceId.present) {
      map['step_performance_id'] = Variable<String>(stepPerformanceId.value);
    }
    if (setPlanId.present) {
      map['set_plan_id'] = Variable<String>(setPlanId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (actualRepetitions.present) {
      map['actual_repetitions'] = Variable<int>(actualRepetitions.value);
    }
    if (actualWeightKg.present) {
      map['actual_weight_kg'] = Variable<double>(actualWeightKg.value);
    }
    if (actualDurationSeconds.present) {
      map['actual_duration_seconds'] = Variable<int>(
        actualDurationSeconds.value,
      );
    }
    if (actualRpe.present) {
      map['actual_rpe'] = Variable<double>(actualRpe.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSetPerformancesCompanion(')
          ..write('id: $id, ')
          ..write('stepPerformanceId: $stepPerformanceId, ')
          ..write('setPlanId: $setPlanId, ')
          ..write('position: $position, ')
          ..write('status: $status, ')
          ..write('actualRepetitions: $actualRepetitions, ')
          ..write('actualWeightKg: $actualWeightKg, ')
          ..write('actualDurationSeconds: $actualDurationSeconds, ')
          ..write('actualRpe: $actualRpe, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalWorkoutFeedbackTable extends LocalWorkoutFeedback
    with TableInfo<$LocalWorkoutFeedbackTable, LocalWorkoutFeedbackRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalWorkoutFeedbackTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutSessionIdMeta = const VerificationMeta(
    'workoutSessionId',
  );
  @override
  late final GeneratedColumn<String> workoutSessionId = GeneratedColumn<String>(
    'workout_session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES local_workout_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _overallEffortMeta = const VerificationMeta(
    'overallEffort',
  );
  @override
  late final GeneratedColumn<double> overallEffort = GeneratedColumn<double>(
    'overall_effort',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feelingMeta = const VerificationMeta(
    'feeling',
  );
  @override
  late final GeneratedColumn<String> feeling = GeneratedColumn<String>(
    'feeling',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _painReportedMeta = const VerificationMeta(
    'painReported',
  );
  @override
  late final GeneratedColumn<bool> painReported = GeneratedColumn<bool>(
    'pain_reported',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pain_reported" IN (0, 1))',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutSessionId,
    overallEffort,
    feeling,
    painReported,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_workout_feedback';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalWorkoutFeedbackRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workout_session_id')) {
      context.handle(
        _workoutSessionIdMeta,
        workoutSessionId.isAcceptableOrUnknown(
          data['workout_session_id']!,
          _workoutSessionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutSessionIdMeta);
    }
    if (data.containsKey('overall_effort')) {
      context.handle(
        _overallEffortMeta,
        overallEffort.isAcceptableOrUnknown(
          data['overall_effort']!,
          _overallEffortMeta,
        ),
      );
    }
    if (data.containsKey('feeling')) {
      context.handle(
        _feelingMeta,
        feeling.isAcceptableOrUnknown(data['feeling']!, _feelingMeta),
      );
    }
    if (data.containsKey('pain_reported')) {
      context.handle(
        _painReportedMeta,
        painReported.isAcceptableOrUnknown(
          data['pain_reported']!,
          _painReportedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_painReportedMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalWorkoutFeedbackRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalWorkoutFeedbackRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_session_id'],
      )!,
      overallEffort: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overall_effort'],
      ),
      feeling: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feeling'],
      ),
      painReported: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pain_reported'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalWorkoutFeedbackTable createAlias(String alias) {
    return $LocalWorkoutFeedbackTable(attachedDatabase, alias);
  }
}

class LocalWorkoutFeedbackRow extends DataClass
    implements Insertable<LocalWorkoutFeedbackRow> {
  final String id;
  final String workoutSessionId;
  final double? overallEffort;
  final String? feeling;
  final bool painReported;
  final String? notes;
  final int createdAt;
  final int updatedAt;
  const LocalWorkoutFeedbackRow({
    required this.id,
    required this.workoutSessionId,
    this.overallEffort,
    this.feeling,
    required this.painReported,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_session_id'] = Variable<String>(workoutSessionId);
    if (!nullToAbsent || overallEffort != null) {
      map['overall_effort'] = Variable<double>(overallEffort);
    }
    if (!nullToAbsent || feeling != null) {
      map['feeling'] = Variable<String>(feeling);
    }
    map['pain_reported'] = Variable<bool>(painReported);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  LocalWorkoutFeedbackCompanion toCompanion(bool nullToAbsent) {
    return LocalWorkoutFeedbackCompanion(
      id: Value(id),
      workoutSessionId: Value(workoutSessionId),
      overallEffort: overallEffort == null && nullToAbsent
          ? const Value.absent()
          : Value(overallEffort),
      feeling: feeling == null && nullToAbsent
          ? const Value.absent()
          : Value(feeling),
      painReported: Value(painReported),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalWorkoutFeedbackRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalWorkoutFeedbackRow(
      id: serializer.fromJson<String>(json['id']),
      workoutSessionId: serializer.fromJson<String>(json['workoutSessionId']),
      overallEffort: serializer.fromJson<double?>(json['overallEffort']),
      feeling: serializer.fromJson<String?>(json['feeling']),
      painReported: serializer.fromJson<bool>(json['painReported']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutSessionId': serializer.toJson<String>(workoutSessionId),
      'overallEffort': serializer.toJson<double?>(overallEffort),
      'feeling': serializer.toJson<String?>(feeling),
      'painReported': serializer.toJson<bool>(painReported),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  LocalWorkoutFeedbackRow copyWith({
    String? id,
    String? workoutSessionId,
    Value<double?> overallEffort = const Value.absent(),
    Value<String?> feeling = const Value.absent(),
    bool? painReported,
    Value<String?> notes = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => LocalWorkoutFeedbackRow(
    id: id ?? this.id,
    workoutSessionId: workoutSessionId ?? this.workoutSessionId,
    overallEffort: overallEffort.present
        ? overallEffort.value
        : this.overallEffort,
    feeling: feeling.present ? feeling.value : this.feeling,
    painReported: painReported ?? this.painReported,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalWorkoutFeedbackRow copyWithCompanion(
    LocalWorkoutFeedbackCompanion data,
  ) {
    return LocalWorkoutFeedbackRow(
      id: data.id.present ? data.id.value : this.id,
      workoutSessionId: data.workoutSessionId.present
          ? data.workoutSessionId.value
          : this.workoutSessionId,
      overallEffort: data.overallEffort.present
          ? data.overallEffort.value
          : this.overallEffort,
      feeling: data.feeling.present ? data.feeling.value : this.feeling,
      painReported: data.painReported.present
          ? data.painReported.value
          : this.painReported,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalWorkoutFeedbackRow(')
          ..write('id: $id, ')
          ..write('workoutSessionId: $workoutSessionId, ')
          ..write('overallEffort: $overallEffort, ')
          ..write('feeling: $feeling, ')
          ..write('painReported: $painReported, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutSessionId,
    overallEffort,
    feeling,
    painReported,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalWorkoutFeedbackRow &&
          other.id == this.id &&
          other.workoutSessionId == this.workoutSessionId &&
          other.overallEffort == this.overallEffort &&
          other.feeling == this.feeling &&
          other.painReported == this.painReported &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalWorkoutFeedbackCompanion
    extends UpdateCompanion<LocalWorkoutFeedbackRow> {
  final Value<String> id;
  final Value<String> workoutSessionId;
  final Value<double?> overallEffort;
  final Value<String?> feeling;
  final Value<bool> painReported;
  final Value<String?> notes;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const LocalWorkoutFeedbackCompanion({
    this.id = const Value.absent(),
    this.workoutSessionId = const Value.absent(),
    this.overallEffort = const Value.absent(),
    this.feeling = const Value.absent(),
    this.painReported = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalWorkoutFeedbackCompanion.insert({
    required String id,
    required String workoutSessionId,
    this.overallEffort = const Value.absent(),
    this.feeling = const Value.absent(),
    required bool painReported,
    this.notes = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workoutSessionId = Value(workoutSessionId),
       painReported = Value(painReported),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalWorkoutFeedbackRow> custom({
    Expression<String>? id,
    Expression<String>? workoutSessionId,
    Expression<double>? overallEffort,
    Expression<String>? feeling,
    Expression<bool>? painReported,
    Expression<String>? notes,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutSessionId != null) 'workout_session_id': workoutSessionId,
      if (overallEffort != null) 'overall_effort': overallEffort,
      if (feeling != null) 'feeling': feeling,
      if (painReported != null) 'pain_reported': painReported,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalWorkoutFeedbackCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutSessionId,
    Value<double?>? overallEffort,
    Value<String?>? feeling,
    Value<bool>? painReported,
    Value<String?>? notes,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalWorkoutFeedbackCompanion(
      id: id ?? this.id,
      workoutSessionId: workoutSessionId ?? this.workoutSessionId,
      overallEffort: overallEffort ?? this.overallEffort,
      feeling: feeling ?? this.feeling,
      painReported: painReported ?? this.painReported,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutSessionId.present) {
      map['workout_session_id'] = Variable<String>(workoutSessionId.value);
    }
    if (overallEffort.present) {
      map['overall_effort'] = Variable<double>(overallEffort.value);
    }
    if (feeling.present) {
      map['feeling'] = Variable<String>(feeling.value);
    }
    if (painReported.present) {
      map['pain_reported'] = Variable<bool>(painReported.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalWorkoutFeedbackCompanion(')
          ..write('id: $id, ')
          ..write('workoutSessionId: $workoutSessionId, ')
          ..write('overallEffort: $overallEffort, ')
          ..write('feeling: $feeling, ')
          ..write('painReported: $painReported, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalActivitySummariesTable extends LocalActivitySummaries
    with TableInfo<$LocalActivitySummariesTable, LocalActivitySummaryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalActivitySummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutInstanceIdMeta = const VerificationMeta(
    'workoutInstanceId',
  );
  @override
  late final GeneratedColumn<String> workoutInstanceId =
      GeneratedColumn<String>(
        'workout_instance_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_workout_instances (id)',
        ),
      );
  static const VerificationMeta _workoutSessionIdMeta = const VerificationMeta(
    'workoutSessionId',
  );
  @override
  late final GeneratedColumn<String> workoutSessionId = GeneratedColumn<String>(
    'workout_session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES local_workout_sessions (id)',
    ),
  );
  static const VerificationMeta _titleSnapshotMeta = const VerificationMeta(
    'titleSnapshot',
  );
  @override
  late final GeneratedColumn<String> titleSnapshot = GeneratedColumn<String>(
    'title_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutTypeMeta = const VerificationMeta(
    'workoutType',
  );
  @override
  late final GeneratedColumn<String> workoutType = GeneratedColumn<String>(
    'workout_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeDurationSecondsMeta =
      const VerificationMeta('activeDurationSeconds');
  @override
  late final GeneratedColumn<int> activeDurationSeconds = GeneratedColumn<int>(
    'active_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedStepCountMeta =
      const VerificationMeta('completedStepCount');
  @override
  late final GeneratedColumn<int> completedStepCount = GeneratedColumn<int>(
    'completed_step_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalStepCountMeta = const VerificationMeta(
    'totalStepCount',
  );
  @override
  late final GeneratedColumn<int> totalStepCount = GeneratedColumn<int>(
    'total_step_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overallEffortMeta = const VerificationMeta(
    'overallEffort',
  );
  @override
  late final GeneratedColumn<double> overallEffort = GeneratedColumn<double>(
    'overall_effort',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(localAnonymousOwnerId),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(syncStateLocalOnly),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutInstanceId,
    workoutSessionId,
    titleSnapshot,
    workoutType,
    startedAt,
    completedAt,
    activeDurationSeconds,
    completedStepCount,
    totalStepCount,
    overallEffort,
    createdAt,
    ownerId,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_activity_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalActivitySummaryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workout_instance_id')) {
      context.handle(
        _workoutInstanceIdMeta,
        workoutInstanceId.isAcceptableOrUnknown(
          data['workout_instance_id']!,
          _workoutInstanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutInstanceIdMeta);
    }
    if (data.containsKey('workout_session_id')) {
      context.handle(
        _workoutSessionIdMeta,
        workoutSessionId.isAcceptableOrUnknown(
          data['workout_session_id']!,
          _workoutSessionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutSessionIdMeta);
    }
    if (data.containsKey('title_snapshot')) {
      context.handle(
        _titleSnapshotMeta,
        titleSnapshot.isAcceptableOrUnknown(
          data['title_snapshot']!,
          _titleSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_titleSnapshotMeta);
    }
    if (data.containsKey('workout_type')) {
      context.handle(
        _workoutTypeMeta,
        workoutType.isAcceptableOrUnknown(
          data['workout_type']!,
          _workoutTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutTypeMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('active_duration_seconds')) {
      context.handle(
        _activeDurationSecondsMeta,
        activeDurationSeconds.isAcceptableOrUnknown(
          data['active_duration_seconds']!,
          _activeDurationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeDurationSecondsMeta);
    }
    if (data.containsKey('completed_step_count')) {
      context.handle(
        _completedStepCountMeta,
        completedStepCount.isAcceptableOrUnknown(
          data['completed_step_count']!,
          _completedStepCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedStepCountMeta);
    }
    if (data.containsKey('total_step_count')) {
      context.handle(
        _totalStepCountMeta,
        totalStepCount.isAcceptableOrUnknown(
          data['total_step_count']!,
          _totalStepCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalStepCountMeta);
    }
    if (data.containsKey('overall_effort')) {
      context.handle(
        _overallEffortMeta,
        overallEffort.isAcceptableOrUnknown(
          data['overall_effort']!,
          _overallEffortMeta,
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
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalActivitySummaryRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalActivitySummaryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutInstanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_instance_id'],
      )!,
      workoutSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_session_id'],
      )!,
      titleSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_snapshot'],
      )!,
      workoutType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_type'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      )!,
      activeDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_duration_seconds'],
      )!,
      completedStepCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_step_count'],
      )!,
      totalStepCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_step_count'],
      )!,
      overallEffort: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overall_effort'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $LocalActivitySummariesTable createAlias(String alias) {
    return $LocalActivitySummariesTable(attachedDatabase, alias);
  }
}

class LocalActivitySummaryRow extends DataClass
    implements Insertable<LocalActivitySummaryRow> {
  final String id;
  final String workoutInstanceId;
  final String workoutSessionId;
  final String titleSnapshot;
  final String workoutType;
  final int startedAt;
  final int completedAt;
  final int activeDurationSeconds;
  final int completedStepCount;
  final int totalStepCount;
  final double? overallEffort;
  final int createdAt;
  final String ownerId;
  final String syncState;
  const LocalActivitySummaryRow({
    required this.id,
    required this.workoutInstanceId,
    required this.workoutSessionId,
    required this.titleSnapshot,
    required this.workoutType,
    required this.startedAt,
    required this.completedAt,
    required this.activeDurationSeconds,
    required this.completedStepCount,
    required this.totalStepCount,
    this.overallEffort,
    required this.createdAt,
    required this.ownerId,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_instance_id'] = Variable<String>(workoutInstanceId);
    map['workout_session_id'] = Variable<String>(workoutSessionId);
    map['title_snapshot'] = Variable<String>(titleSnapshot);
    map['workout_type'] = Variable<String>(workoutType);
    map['started_at'] = Variable<int>(startedAt);
    map['completed_at'] = Variable<int>(completedAt);
    map['active_duration_seconds'] = Variable<int>(activeDurationSeconds);
    map['completed_step_count'] = Variable<int>(completedStepCount);
    map['total_step_count'] = Variable<int>(totalStepCount);
    if (!nullToAbsent || overallEffort != null) {
      map['overall_effort'] = Variable<double>(overallEffort);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['owner_id'] = Variable<String>(ownerId);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  LocalActivitySummariesCompanion toCompanion(bool nullToAbsent) {
    return LocalActivitySummariesCompanion(
      id: Value(id),
      workoutInstanceId: Value(workoutInstanceId),
      workoutSessionId: Value(workoutSessionId),
      titleSnapshot: Value(titleSnapshot),
      workoutType: Value(workoutType),
      startedAt: Value(startedAt),
      completedAt: Value(completedAt),
      activeDurationSeconds: Value(activeDurationSeconds),
      completedStepCount: Value(completedStepCount),
      totalStepCount: Value(totalStepCount),
      overallEffort: overallEffort == null && nullToAbsent
          ? const Value.absent()
          : Value(overallEffort),
      createdAt: Value(createdAt),
      ownerId: Value(ownerId),
      syncState: Value(syncState),
    );
  }

  factory LocalActivitySummaryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalActivitySummaryRow(
      id: serializer.fromJson<String>(json['id']),
      workoutInstanceId: serializer.fromJson<String>(json['workoutInstanceId']),
      workoutSessionId: serializer.fromJson<String>(json['workoutSessionId']),
      titleSnapshot: serializer.fromJson<String>(json['titleSnapshot']),
      workoutType: serializer.fromJson<String>(json['workoutType']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      completedAt: serializer.fromJson<int>(json['completedAt']),
      activeDurationSeconds: serializer.fromJson<int>(
        json['activeDurationSeconds'],
      ),
      completedStepCount: serializer.fromJson<int>(json['completedStepCount']),
      totalStepCount: serializer.fromJson<int>(json['totalStepCount']),
      overallEffort: serializer.fromJson<double?>(json['overallEffort']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutInstanceId': serializer.toJson<String>(workoutInstanceId),
      'workoutSessionId': serializer.toJson<String>(workoutSessionId),
      'titleSnapshot': serializer.toJson<String>(titleSnapshot),
      'workoutType': serializer.toJson<String>(workoutType),
      'startedAt': serializer.toJson<int>(startedAt),
      'completedAt': serializer.toJson<int>(completedAt),
      'activeDurationSeconds': serializer.toJson<int>(activeDurationSeconds),
      'completedStepCount': serializer.toJson<int>(completedStepCount),
      'totalStepCount': serializer.toJson<int>(totalStepCount),
      'overallEffort': serializer.toJson<double?>(overallEffort),
      'createdAt': serializer.toJson<int>(createdAt),
      'ownerId': serializer.toJson<String>(ownerId),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  LocalActivitySummaryRow copyWith({
    String? id,
    String? workoutInstanceId,
    String? workoutSessionId,
    String? titleSnapshot,
    String? workoutType,
    int? startedAt,
    int? completedAt,
    int? activeDurationSeconds,
    int? completedStepCount,
    int? totalStepCount,
    Value<double?> overallEffort = const Value.absent(),
    int? createdAt,
    String? ownerId,
    String? syncState,
  }) => LocalActivitySummaryRow(
    id: id ?? this.id,
    workoutInstanceId: workoutInstanceId ?? this.workoutInstanceId,
    workoutSessionId: workoutSessionId ?? this.workoutSessionId,
    titleSnapshot: titleSnapshot ?? this.titleSnapshot,
    workoutType: workoutType ?? this.workoutType,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    activeDurationSeconds: activeDurationSeconds ?? this.activeDurationSeconds,
    completedStepCount: completedStepCount ?? this.completedStepCount,
    totalStepCount: totalStepCount ?? this.totalStepCount,
    overallEffort: overallEffort.present
        ? overallEffort.value
        : this.overallEffort,
    createdAt: createdAt ?? this.createdAt,
    ownerId: ownerId ?? this.ownerId,
    syncState: syncState ?? this.syncState,
  );
  LocalActivitySummaryRow copyWithCompanion(
    LocalActivitySummariesCompanion data,
  ) {
    return LocalActivitySummaryRow(
      id: data.id.present ? data.id.value : this.id,
      workoutInstanceId: data.workoutInstanceId.present
          ? data.workoutInstanceId.value
          : this.workoutInstanceId,
      workoutSessionId: data.workoutSessionId.present
          ? data.workoutSessionId.value
          : this.workoutSessionId,
      titleSnapshot: data.titleSnapshot.present
          ? data.titleSnapshot.value
          : this.titleSnapshot,
      workoutType: data.workoutType.present
          ? data.workoutType.value
          : this.workoutType,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      activeDurationSeconds: data.activeDurationSeconds.present
          ? data.activeDurationSeconds.value
          : this.activeDurationSeconds,
      completedStepCount: data.completedStepCount.present
          ? data.completedStepCount.value
          : this.completedStepCount,
      totalStepCount: data.totalStepCount.present
          ? data.totalStepCount.value
          : this.totalStepCount,
      overallEffort: data.overallEffort.present
          ? data.overallEffort.value
          : this.overallEffort,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalActivitySummaryRow(')
          ..write('id: $id, ')
          ..write('workoutInstanceId: $workoutInstanceId, ')
          ..write('workoutSessionId: $workoutSessionId, ')
          ..write('titleSnapshot: $titleSnapshot, ')
          ..write('workoutType: $workoutType, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('activeDurationSeconds: $activeDurationSeconds, ')
          ..write('completedStepCount: $completedStepCount, ')
          ..write('totalStepCount: $totalStepCount, ')
          ..write('overallEffort: $overallEffort, ')
          ..write('createdAt: $createdAt, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutInstanceId,
    workoutSessionId,
    titleSnapshot,
    workoutType,
    startedAt,
    completedAt,
    activeDurationSeconds,
    completedStepCount,
    totalStepCount,
    overallEffort,
    createdAt,
    ownerId,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalActivitySummaryRow &&
          other.id == this.id &&
          other.workoutInstanceId == this.workoutInstanceId &&
          other.workoutSessionId == this.workoutSessionId &&
          other.titleSnapshot == this.titleSnapshot &&
          other.workoutType == this.workoutType &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.activeDurationSeconds == this.activeDurationSeconds &&
          other.completedStepCount == this.completedStepCount &&
          other.totalStepCount == this.totalStepCount &&
          other.overallEffort == this.overallEffort &&
          other.createdAt == this.createdAt &&
          other.ownerId == this.ownerId &&
          other.syncState == this.syncState);
}

class LocalActivitySummariesCompanion
    extends UpdateCompanion<LocalActivitySummaryRow> {
  final Value<String> id;
  final Value<String> workoutInstanceId;
  final Value<String> workoutSessionId;
  final Value<String> titleSnapshot;
  final Value<String> workoutType;
  final Value<int> startedAt;
  final Value<int> completedAt;
  final Value<int> activeDurationSeconds;
  final Value<int> completedStepCount;
  final Value<int> totalStepCount;
  final Value<double?> overallEffort;
  final Value<int> createdAt;
  final Value<String> ownerId;
  final Value<String> syncState;
  final Value<int> rowid;
  const LocalActivitySummariesCompanion({
    this.id = const Value.absent(),
    this.workoutInstanceId = const Value.absent(),
    this.workoutSessionId = const Value.absent(),
    this.titleSnapshot = const Value.absent(),
    this.workoutType = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.activeDurationSeconds = const Value.absent(),
    this.completedStepCount = const Value.absent(),
    this.totalStepCount = const Value.absent(),
    this.overallEffort = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalActivitySummariesCompanion.insert({
    required String id,
    required String workoutInstanceId,
    required String workoutSessionId,
    required String titleSnapshot,
    required String workoutType,
    required int startedAt,
    required int completedAt,
    required int activeDurationSeconds,
    required int completedStepCount,
    required int totalStepCount,
    this.overallEffort = const Value.absent(),
    required int createdAt,
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workoutInstanceId = Value(workoutInstanceId),
       workoutSessionId = Value(workoutSessionId),
       titleSnapshot = Value(titleSnapshot),
       workoutType = Value(workoutType),
       startedAt = Value(startedAt),
       completedAt = Value(completedAt),
       activeDurationSeconds = Value(activeDurationSeconds),
       completedStepCount = Value(completedStepCount),
       totalStepCount = Value(totalStepCount),
       createdAt = Value(createdAt);
  static Insertable<LocalActivitySummaryRow> custom({
    Expression<String>? id,
    Expression<String>? workoutInstanceId,
    Expression<String>? workoutSessionId,
    Expression<String>? titleSnapshot,
    Expression<String>? workoutType,
    Expression<int>? startedAt,
    Expression<int>? completedAt,
    Expression<int>? activeDurationSeconds,
    Expression<int>? completedStepCount,
    Expression<int>? totalStepCount,
    Expression<double>? overallEffort,
    Expression<int>? createdAt,
    Expression<String>? ownerId,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutInstanceId != null) 'workout_instance_id': workoutInstanceId,
      if (workoutSessionId != null) 'workout_session_id': workoutSessionId,
      if (titleSnapshot != null) 'title_snapshot': titleSnapshot,
      if (workoutType != null) 'workout_type': workoutType,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (activeDurationSeconds != null)
        'active_duration_seconds': activeDurationSeconds,
      if (completedStepCount != null)
        'completed_step_count': completedStepCount,
      if (totalStepCount != null) 'total_step_count': totalStepCount,
      if (overallEffort != null) 'overall_effort': overallEffort,
      if (createdAt != null) 'created_at': createdAt,
      if (ownerId != null) 'owner_id': ownerId,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalActivitySummariesCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutInstanceId,
    Value<String>? workoutSessionId,
    Value<String>? titleSnapshot,
    Value<String>? workoutType,
    Value<int>? startedAt,
    Value<int>? completedAt,
    Value<int>? activeDurationSeconds,
    Value<int>? completedStepCount,
    Value<int>? totalStepCount,
    Value<double?>? overallEffort,
    Value<int>? createdAt,
    Value<String>? ownerId,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return LocalActivitySummariesCompanion(
      id: id ?? this.id,
      workoutInstanceId: workoutInstanceId ?? this.workoutInstanceId,
      workoutSessionId: workoutSessionId ?? this.workoutSessionId,
      titleSnapshot: titleSnapshot ?? this.titleSnapshot,
      workoutType: workoutType ?? this.workoutType,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      activeDurationSeconds:
          activeDurationSeconds ?? this.activeDurationSeconds,
      completedStepCount: completedStepCount ?? this.completedStepCount,
      totalStepCount: totalStepCount ?? this.totalStepCount,
      overallEffort: overallEffort ?? this.overallEffort,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutInstanceId.present) {
      map['workout_instance_id'] = Variable<String>(workoutInstanceId.value);
    }
    if (workoutSessionId.present) {
      map['workout_session_id'] = Variable<String>(workoutSessionId.value);
    }
    if (titleSnapshot.present) {
      map['title_snapshot'] = Variable<String>(titleSnapshot.value);
    }
    if (workoutType.present) {
      map['workout_type'] = Variable<String>(workoutType.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (activeDurationSeconds.present) {
      map['active_duration_seconds'] = Variable<int>(
        activeDurationSeconds.value,
      );
    }
    if (completedStepCount.present) {
      map['completed_step_count'] = Variable<int>(completedStepCount.value);
    }
    if (totalStepCount.present) {
      map['total_step_count'] = Variable<int>(totalStepCount.value);
    }
    if (overallEffort.present) {
      map['overall_effort'] = Variable<double>(overallEffort.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalActivitySummariesCompanion(')
          ..write('id: $id, ')
          ..write('workoutInstanceId: $workoutInstanceId, ')
          ..write('workoutSessionId: $workoutSessionId, ')
          ..write('titleSnapshot: $titleSnapshot, ')
          ..write('workoutType: $workoutType, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('activeDurationSeconds: $activeDurationSeconds, ')
          ..write('completedStepCount: $completedStepCount, ')
          ..write('totalStepCount: $totalStepCount, ')
          ..write('overallEffort: $overallEffort, ')
          ..write('createdAt: $createdAt, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAppStateTable extends LocalAppState
    with TableInfo<$LocalAppStateTable, LocalAppStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAppStateTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_app_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAppStateRow> instance, {
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
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalAppStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAppStateRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalAppStateTable createAlias(String alias) {
    return $LocalAppStateTable(attachedDatabase, alias);
  }
}

class LocalAppStateRow extends DataClass
    implements Insertable<LocalAppStateRow> {
  final String key;
  final String value;
  final int updatedAt;
  const LocalAppStateRow({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  LocalAppStateCompanion toCompanion(bool nullToAbsent) {
    return LocalAppStateCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalAppStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAppStateRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  LocalAppStateRow copyWith({String? key, String? value, int? updatedAt}) =>
      LocalAppStateRow(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalAppStateRow copyWithCompanion(LocalAppStateCompanion data) {
    return LocalAppStateRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAppStateRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAppStateRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class LocalAppStateCompanion extends UpdateCompanion<LocalAppStateRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const LocalAppStateCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAppStateCompanion.insert({
    required String key,
    required String value,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<LocalAppStateRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAppStateCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalAppStateCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAppStateCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalOutboxTable extends LocalOutbox
    with TableInfo<$LocalOutboxTable, LocalOutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(localAnonymousOwnerId),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    entityType,
    entityId,
    operationType,
    idempotencyKey,
    sequence,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalOutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
  LocalOutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalOutboxRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalOutboxTable createAlias(String alias) {
    return $LocalOutboxTable(attachedDatabase, alias);
  }
}

class LocalOutboxRow extends DataClass implements Insertable<LocalOutboxRow> {
  final String id;
  final String ownerId;
  final String entityType;
  final String entityId;
  final String operationType;
  final String idempotencyKey;
  final int sequence;
  final String status;
  final int createdAt;
  const LocalOutboxRow({
    required this.id,
    required this.ownerId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.idempotencyKey,
    required this.sequence,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation_type'] = Variable<String>(operationType);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['sequence'] = Variable<int>(sequence);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  LocalOutboxCompanion toCompanion(bool nullToAbsent) {
    return LocalOutboxCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operationType: Value(operationType),
      idempotencyKey: Value(idempotencyKey),
      sequence: Value(sequence),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory LocalOutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalOutboxRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      sequence: serializer.fromJson<int>(json['sequence']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operationType': serializer.toJson<String>(operationType),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'sequence': serializer.toJson<int>(sequence),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  LocalOutboxRow copyWith({
    String? id,
    String? ownerId,
    String? entityType,
    String? entityId,
    String? operationType,
    String? idempotencyKey,
    int? sequence,
    String? status,
    int? createdAt,
  }) => LocalOutboxRow(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operationType: operationType ?? this.operationType,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    sequence: sequence ?? this.sequence,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalOutboxRow copyWithCompanion(LocalOutboxCompanion data) {
    return LocalOutboxRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalOutboxRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('sequence: $sequence, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    entityType,
    entityId,
    operationType,
    idempotencyKey,
    sequence,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalOutboxRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operationType == this.operationType &&
          other.idempotencyKey == this.idempotencyKey &&
          other.sequence == this.sequence &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class LocalOutboxCompanion extends UpdateCompanion<LocalOutboxRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operationType;
  final Value<String> idempotencyKey;
  final Value<int> sequence;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> rowid;
  const LocalOutboxCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.sequence = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalOutboxCompanion.insert({
    required String id,
    this.ownerId = const Value.absent(),
    required String entityType,
    required String entityId,
    required String operationType,
    required String idempotencyKey,
    required int sequence,
    this.status = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operationType = Value(operationType),
       idempotencyKey = Value(idempotencyKey),
       sequence = Value(sequence),
       createdAt = Value(createdAt);
  static Insertable<LocalOutboxRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operationType,
    Expression<String>? idempotencyKey,
    Expression<int>? sequence,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operationType != null) 'operation_type': operationType,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (sequence != null) 'sequence': sequence,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalOutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operationType,
    Value<String>? idempotencyKey,
    Value<int>? sequence,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalOutboxCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      sequence: sequence ?? this.sequence,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalOutboxCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('sequence: $sequence, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSyncedVersionsTable extends LocalSyncedVersions
    with TableInfo<$LocalSyncedVersionsTable, LocalSyncedVersionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSyncedVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityType,
    entityId,
    serverVersion,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_synced_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSyncedVersionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverVersionMeta);
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
  Set<GeneratedColumn> get $primaryKey => {entityType, entityId};
  @override
  LocalSyncedVersionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSyncedVersionRow(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalSyncedVersionsTable createAlias(String alias) {
    return $LocalSyncedVersionsTable(attachedDatabase, alias);
  }
}

class LocalSyncedVersionRow extends DataClass
    implements Insertable<LocalSyncedVersionRow> {
  final String entityType;
  final String entityId;
  final int serverVersion;
  final int updatedAt;
  const LocalSyncedVersionRow({
    required this.entityType,
    required this.entityId,
    required this.serverVersion,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['server_version'] = Variable<int>(serverVersion);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  LocalSyncedVersionsCompanion toCompanion(bool nullToAbsent) {
    return LocalSyncedVersionsCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      serverVersion: Value(serverVersion),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalSyncedVersionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSyncedVersionRow(
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      serverVersion: serializer.fromJson<int>(json['serverVersion']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'serverVersion': serializer.toJson<int>(serverVersion),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  LocalSyncedVersionRow copyWith({
    String? entityType,
    String? entityId,
    int? serverVersion,
    int? updatedAt,
  }) => LocalSyncedVersionRow(
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    serverVersion: serverVersion ?? this.serverVersion,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalSyncedVersionRow copyWithCompanion(LocalSyncedVersionsCompanion data) {
    return LocalSyncedVersionRow(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncedVersionRow(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(entityType, entityId, serverVersion, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSyncedVersionRow &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.serverVersion == this.serverVersion &&
          other.updatedAt == this.updatedAt);
}

class LocalSyncedVersionsCompanion
    extends UpdateCompanion<LocalSyncedVersionRow> {
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<int> serverVersion;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const LocalSyncedVersionsCompanion({
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSyncedVersionsCompanion.insert({
    required String entityType,
    required String entityId,
    required int serverVersion,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       serverVersion = Value(serverVersion),
       updatedAt = Value(updatedAt);
  static Insertable<LocalSyncedVersionRow> custom({
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<int>? serverVersion,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (serverVersion != null) 'server_version': serverVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSyncedVersionsCompanion copyWith({
    Value<String>? entityType,
    Value<String>? entityId,
    Value<int>? serverVersion,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalSyncedVersionsCompanion(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      serverVersion: serverVersion ?? this.serverVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncedVersionsCompanion(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSyncResolutionsTable extends LocalSyncResolutions
    with TableInfo<$LocalSyncResolutionsTable, LocalSyncResolutionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSyncResolutionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _outboxIdMeta = const VerificationMeta(
    'outboxId',
  );
  @override
  late final GeneratedColumn<String> outboxId = GeneratedColumn<String>(
    'outbox_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decisionMeta = const VerificationMeta(
    'decision',
  );
  @override
  late final GeneratedColumn<String> decision = GeneratedColumn<String>(
    'decision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<int> resolvedAt = GeneratedColumn<int>(
    'resolved_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [outboxId, decision, resolvedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sync_resolutions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSyncResolutionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('outbox_id')) {
      context.handle(
        _outboxIdMeta,
        outboxId.isAcceptableOrUnknown(data['outbox_id']!, _outboxIdMeta),
      );
    } else if (isInserting) {
      context.missing(_outboxIdMeta);
    }
    if (data.containsKey('decision')) {
      context.handle(
        _decisionMeta,
        decision.isAcceptableOrUnknown(data['decision']!, _decisionMeta),
      );
    } else if (isInserting) {
      context.missing(_decisionMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_resolvedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {outboxId};
  @override
  LocalSyncResolutionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSyncResolutionRow(
      outboxId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outbox_id'],
      )!,
      decision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolved_at'],
      )!,
    );
  }

  @override
  $LocalSyncResolutionsTable createAlias(String alias) {
    return $LocalSyncResolutionsTable(attachedDatabase, alias);
  }
}

class LocalSyncResolutionRow extends DataClass
    implements Insertable<LocalSyncResolutionRow> {
  final String outboxId;
  final String decision;
  final int resolvedAt;
  const LocalSyncResolutionRow({
    required this.outboxId,
    required this.decision,
    required this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['outbox_id'] = Variable<String>(outboxId);
    map['decision'] = Variable<String>(decision);
    map['resolved_at'] = Variable<int>(resolvedAt);
    return map;
  }

  LocalSyncResolutionsCompanion toCompanion(bool nullToAbsent) {
    return LocalSyncResolutionsCompanion(
      outboxId: Value(outboxId),
      decision: Value(decision),
      resolvedAt: Value(resolvedAt),
    );
  }

  factory LocalSyncResolutionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSyncResolutionRow(
      outboxId: serializer.fromJson<String>(json['outboxId']),
      decision: serializer.fromJson<String>(json['decision']),
      resolvedAt: serializer.fromJson<int>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'outboxId': serializer.toJson<String>(outboxId),
      'decision': serializer.toJson<String>(decision),
      'resolvedAt': serializer.toJson<int>(resolvedAt),
    };
  }

  LocalSyncResolutionRow copyWith({
    String? outboxId,
    String? decision,
    int? resolvedAt,
  }) => LocalSyncResolutionRow(
    outboxId: outboxId ?? this.outboxId,
    decision: decision ?? this.decision,
    resolvedAt: resolvedAt ?? this.resolvedAt,
  );
  LocalSyncResolutionRow copyWithCompanion(LocalSyncResolutionsCompanion data) {
    return LocalSyncResolutionRow(
      outboxId: data.outboxId.present ? data.outboxId.value : this.outboxId,
      decision: data.decision.present ? data.decision.value : this.decision,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncResolutionRow(')
          ..write('outboxId: $outboxId, ')
          ..write('decision: $decision, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(outboxId, decision, resolvedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSyncResolutionRow &&
          other.outboxId == this.outboxId &&
          other.decision == this.decision &&
          other.resolvedAt == this.resolvedAt);
}

class LocalSyncResolutionsCompanion
    extends UpdateCompanion<LocalSyncResolutionRow> {
  final Value<String> outboxId;
  final Value<String> decision;
  final Value<int> resolvedAt;
  final Value<int> rowid;
  const LocalSyncResolutionsCompanion({
    this.outboxId = const Value.absent(),
    this.decision = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSyncResolutionsCompanion.insert({
    required String outboxId,
    required String decision,
    required int resolvedAt,
    this.rowid = const Value.absent(),
  }) : outboxId = Value(outboxId),
       decision = Value(decision),
       resolvedAt = Value(resolvedAt);
  static Insertable<LocalSyncResolutionRow> custom({
    Expression<String>? outboxId,
    Expression<String>? decision,
    Expression<int>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (outboxId != null) 'outbox_id': outboxId,
      if (decision != null) 'decision': decision,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSyncResolutionsCompanion copyWith({
    Value<String>? outboxId,
    Value<String>? decision,
    Value<int>? resolvedAt,
    Value<int>? rowid,
  }) {
    return LocalSyncResolutionsCompanion(
      outboxId: outboxId ?? this.outboxId,
      decision: decision ?? this.decision,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (outboxId.present) {
      map['outbox_id'] = Variable<String>(outboxId.value);
    }
    if (decision.present) {
      map['decision'] = Variable<String>(decision.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<int>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncResolutionsCompanion(')
          ..write('outboxId: $outboxId, ')
          ..write('decision: $decision, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalUserSportsTable extends LocalUserSports
    with TableInfo<$LocalUserSportsTable, LocalUserSportRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUserSportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sportCodeMeta = const VerificationMeta(
    'sportCode',
  );
  @override
  late final GeneratedColumn<String> sportCode = GeneratedColumn<String>(
    'sport_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customCategoryMeta = const VerificationMeta(
    'customCategory',
  );
  @override
  late final GeneratedColumn<String> customCategory = GeneratedColumn<String>(
    'custom_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _experienceLevelMeta = const VerificationMeta(
    'experienceLevel',
  );
  @override
  late final GeneratedColumn<String> experienceLevel = GeneratedColumn<String>(
    'experience_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UNKNOWN'),
  );
  static const VerificationMeta _lastRegularActivityDateMeta =
      const VerificationMeta('lastRegularActivityDate');
  @override
  late final GeneratedColumn<String> lastRegularActivityDate =
      GeneratedColumn<String>(
        'last_regular_activity_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _returnAfterPauseMeta = const VerificationMeta(
    'returnAfterPause',
  );
  @override
  late final GeneratedColumn<bool> returnAfterPause = GeneratedColumn<bool>(
    'return_after_pause',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("return_after_pause" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _frequencyPerWeekMeta = const VerificationMeta(
    'frequencyPerWeek',
  );
  @override
  late final GeneratedColumn<int> frequencyPerWeek = GeneratedColumn<int>(
    'frequency_per_week',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typicalDurationMinutesMeta =
      const VerificationMeta('typicalDurationMinutes');
  @override
  late final GeneratedColumn<int> typicalDurationMinutes = GeneratedColumn<int>(
    'typical_duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typicalIntensityMeta = const VerificationMeta(
    'typicalIntensity',
  );
  @override
  late final GeneratedColumn<String> typicalIntensity = GeneratedColumn<String>(
    'typical_intensity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _environmentMeta = const VerificationMeta(
    'environment',
  );
  @override
  late final GeneratedColumn<String> environment = GeneratedColumn<String>(
    'environment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fixedDaysMeta = const VerificationMeta(
    'fixedDays',
  );
  @override
  late final GeneratedColumn<String> fixedDays = GeneratedColumn<String>(
    'fixed_days',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(userSportStatusActive),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(localAnonymousOwnerId),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(syncStateLocalOnly),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sportCode,
    customName,
    customCategory,
    role,
    priority,
    experienceLevel,
    lastRegularActivityDate,
    returnAfterPause,
    note,
    frequencyPerWeek,
    typicalDurationMinutes,
    typicalIntensity,
    environment,
    fixedDays,
    status,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_user_sports';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUserSportRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sport_code')) {
      context.handle(
        _sportCodeMeta,
        sportCode.isAcceptableOrUnknown(data['sport_code']!, _sportCodeMeta),
      );
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('custom_category')) {
      context.handle(
        _customCategoryMeta,
        customCategory.isAcceptableOrUnknown(
          data['custom_category']!,
          _customCategoryMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('experience_level')) {
      context.handle(
        _experienceLevelMeta,
        experienceLevel.isAcceptableOrUnknown(
          data['experience_level']!,
          _experienceLevelMeta,
        ),
      );
    }
    if (data.containsKey('last_regular_activity_date')) {
      context.handle(
        _lastRegularActivityDateMeta,
        lastRegularActivityDate.isAcceptableOrUnknown(
          data['last_regular_activity_date']!,
          _lastRegularActivityDateMeta,
        ),
      );
    }
    if (data.containsKey('return_after_pause')) {
      context.handle(
        _returnAfterPauseMeta,
        returnAfterPause.isAcceptableOrUnknown(
          data['return_after_pause']!,
          _returnAfterPauseMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('frequency_per_week')) {
      context.handle(
        _frequencyPerWeekMeta,
        frequencyPerWeek.isAcceptableOrUnknown(
          data['frequency_per_week']!,
          _frequencyPerWeekMeta,
        ),
      );
    }
    if (data.containsKey('typical_duration_minutes')) {
      context.handle(
        _typicalDurationMinutesMeta,
        typicalDurationMinutes.isAcceptableOrUnknown(
          data['typical_duration_minutes']!,
          _typicalDurationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('typical_intensity')) {
      context.handle(
        _typicalIntensityMeta,
        typicalIntensity.isAcceptableOrUnknown(
          data['typical_intensity']!,
          _typicalIntensityMeta,
        ),
      );
    }
    if (data.containsKey('environment')) {
      context.handle(
        _environmentMeta,
        environment.isAcceptableOrUnknown(
          data['environment']!,
          _environmentMeta,
        ),
      );
    }
    if (data.containsKey('fixed_days')) {
      context.handle(
        _fixedDaysMeta,
        fixedDays.isAcceptableOrUnknown(data['fixed_days']!, _fixedDaysMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_rowVersionMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUserSportRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUserSportRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sportCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sport_code'],
      ),
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      customCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_category'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      experienceLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}experience_level'],
      )!,
      lastRegularActivityDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_regular_activity_date'],
      ),
      returnAfterPause: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}return_after_pause'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      frequencyPerWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frequency_per_week'],
      ),
      typicalDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}typical_duration_minutes'],
      ),
      typicalIntensity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}typical_intensity'],
      ),
      environment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}environment'],
      ),
      fixedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fixed_days'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $LocalUserSportsTable createAlias(String alias) {
    return $LocalUserSportsTable(attachedDatabase, alias);
  }
}

class LocalUserSportRow extends DataClass
    implements Insertable<LocalUserSportRow> {
  final String id;
  final String? sportCode;
  final String? customName;
  final String? customCategory;
  final String role;
  final String priority;
  final String experienceLevel;
  final String? lastRegularActivityDate;
  final bool returnAfterPause;
  final String? note;
  final int? frequencyPerWeek;
  final int? typicalDurationMinutes;
  final String? typicalIntensity;
  final String? environment;
  final String? fixedDays;
  final String status;
  final int createdAt;
  final int updatedAt;
  final int rowVersion;
  final String ownerId;
  final String syncState;
  const LocalUserSportRow({
    required this.id,
    this.sportCode,
    this.customName,
    this.customCategory,
    required this.role,
    required this.priority,
    required this.experienceLevel,
    this.lastRegularActivityDate,
    required this.returnAfterPause,
    this.note,
    this.frequencyPerWeek,
    this.typicalDurationMinutes,
    this.typicalIntensity,
    this.environment,
    this.fixedDays,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.rowVersion,
    required this.ownerId,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || sportCode != null) {
      map['sport_code'] = Variable<String>(sportCode);
    }
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    if (!nullToAbsent || customCategory != null) {
      map['custom_category'] = Variable<String>(customCategory);
    }
    map['role'] = Variable<String>(role);
    map['priority'] = Variable<String>(priority);
    map['experience_level'] = Variable<String>(experienceLevel);
    if (!nullToAbsent || lastRegularActivityDate != null) {
      map['last_regular_activity_date'] = Variable<String>(
        lastRegularActivityDate,
      );
    }
    map['return_after_pause'] = Variable<bool>(returnAfterPause);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || frequencyPerWeek != null) {
      map['frequency_per_week'] = Variable<int>(frequencyPerWeek);
    }
    if (!nullToAbsent || typicalDurationMinutes != null) {
      map['typical_duration_minutes'] = Variable<int>(typicalDurationMinutes);
    }
    if (!nullToAbsent || typicalIntensity != null) {
      map['typical_intensity'] = Variable<String>(typicalIntensity);
    }
    if (!nullToAbsent || environment != null) {
      map['environment'] = Variable<String>(environment);
    }
    if (!nullToAbsent || fixedDays != null) {
      map['fixed_days'] = Variable<String>(fixedDays);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['row_version'] = Variable<int>(rowVersion);
    map['owner_id'] = Variable<String>(ownerId);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  LocalUserSportsCompanion toCompanion(bool nullToAbsent) {
    return LocalUserSportsCompanion(
      id: Value(id),
      sportCode: sportCode == null && nullToAbsent
          ? const Value.absent()
          : Value(sportCode),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      customCategory: customCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(customCategory),
      role: Value(role),
      priority: Value(priority),
      experienceLevel: Value(experienceLevel),
      lastRegularActivityDate: lastRegularActivityDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRegularActivityDate),
      returnAfterPause: Value(returnAfterPause),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      frequencyPerWeek: frequencyPerWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(frequencyPerWeek),
      typicalDurationMinutes: typicalDurationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(typicalDurationMinutes),
      typicalIntensity: typicalIntensity == null && nullToAbsent
          ? const Value.absent()
          : Value(typicalIntensity),
      environment: environment == null && nullToAbsent
          ? const Value.absent()
          : Value(environment),
      fixedDays: fixedDays == null && nullToAbsent
          ? const Value.absent()
          : Value(fixedDays),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      rowVersion: Value(rowVersion),
      ownerId: Value(ownerId),
      syncState: Value(syncState),
    );
  }

  factory LocalUserSportRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUserSportRow(
      id: serializer.fromJson<String>(json['id']),
      sportCode: serializer.fromJson<String?>(json['sportCode']),
      customName: serializer.fromJson<String?>(json['customName']),
      customCategory: serializer.fromJson<String?>(json['customCategory']),
      role: serializer.fromJson<String>(json['role']),
      priority: serializer.fromJson<String>(json['priority']),
      experienceLevel: serializer.fromJson<String>(json['experienceLevel']),
      lastRegularActivityDate: serializer.fromJson<String?>(
        json['lastRegularActivityDate'],
      ),
      returnAfterPause: serializer.fromJson<bool>(json['returnAfterPause']),
      note: serializer.fromJson<String?>(json['note']),
      frequencyPerWeek: serializer.fromJson<int?>(json['frequencyPerWeek']),
      typicalDurationMinutes: serializer.fromJson<int?>(
        json['typicalDurationMinutes'],
      ),
      typicalIntensity: serializer.fromJson<String?>(json['typicalIntensity']),
      environment: serializer.fromJson<String?>(json['environment']),
      fixedDays: serializer.fromJson<String?>(json['fixedDays']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sportCode': serializer.toJson<String?>(sportCode),
      'customName': serializer.toJson<String?>(customName),
      'customCategory': serializer.toJson<String?>(customCategory),
      'role': serializer.toJson<String>(role),
      'priority': serializer.toJson<String>(priority),
      'experienceLevel': serializer.toJson<String>(experienceLevel),
      'lastRegularActivityDate': serializer.toJson<String?>(
        lastRegularActivityDate,
      ),
      'returnAfterPause': serializer.toJson<bool>(returnAfterPause),
      'note': serializer.toJson<String?>(note),
      'frequencyPerWeek': serializer.toJson<int?>(frequencyPerWeek),
      'typicalDurationMinutes': serializer.toJson<int?>(typicalDurationMinutes),
      'typicalIntensity': serializer.toJson<String?>(typicalIntensity),
      'environment': serializer.toJson<String?>(environment),
      'fixedDays': serializer.toJson<String?>(fixedDays),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'rowVersion': serializer.toJson<int>(rowVersion),
      'ownerId': serializer.toJson<String>(ownerId),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  LocalUserSportRow copyWith({
    String? id,
    Value<String?> sportCode = const Value.absent(),
    Value<String?> customName = const Value.absent(),
    Value<String?> customCategory = const Value.absent(),
    String? role,
    String? priority,
    String? experienceLevel,
    Value<String?> lastRegularActivityDate = const Value.absent(),
    bool? returnAfterPause,
    Value<String?> note = const Value.absent(),
    Value<int?> frequencyPerWeek = const Value.absent(),
    Value<int?> typicalDurationMinutes = const Value.absent(),
    Value<String?> typicalIntensity = const Value.absent(),
    Value<String?> environment = const Value.absent(),
    Value<String?> fixedDays = const Value.absent(),
    String? status,
    int? createdAt,
    int? updatedAt,
    int? rowVersion,
    String? ownerId,
    String? syncState,
  }) => LocalUserSportRow(
    id: id ?? this.id,
    sportCode: sportCode.present ? sportCode.value : this.sportCode,
    customName: customName.present ? customName.value : this.customName,
    customCategory: customCategory.present
        ? customCategory.value
        : this.customCategory,
    role: role ?? this.role,
    priority: priority ?? this.priority,
    experienceLevel: experienceLevel ?? this.experienceLevel,
    lastRegularActivityDate: lastRegularActivityDate.present
        ? lastRegularActivityDate.value
        : this.lastRegularActivityDate,
    returnAfterPause: returnAfterPause ?? this.returnAfterPause,
    note: note.present ? note.value : this.note,
    frequencyPerWeek: frequencyPerWeek.present
        ? frequencyPerWeek.value
        : this.frequencyPerWeek,
    typicalDurationMinutes: typicalDurationMinutes.present
        ? typicalDurationMinutes.value
        : this.typicalDurationMinutes,
    typicalIntensity: typicalIntensity.present
        ? typicalIntensity.value
        : this.typicalIntensity,
    environment: environment.present ? environment.value : this.environment,
    fixedDays: fixedDays.present ? fixedDays.value : this.fixedDays,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    rowVersion: rowVersion ?? this.rowVersion,
    ownerId: ownerId ?? this.ownerId,
    syncState: syncState ?? this.syncState,
  );
  LocalUserSportRow copyWithCompanion(LocalUserSportsCompanion data) {
    return LocalUserSportRow(
      id: data.id.present ? data.id.value : this.id,
      sportCode: data.sportCode.present ? data.sportCode.value : this.sportCode,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      customCategory: data.customCategory.present
          ? data.customCategory.value
          : this.customCategory,
      role: data.role.present ? data.role.value : this.role,
      priority: data.priority.present ? data.priority.value : this.priority,
      experienceLevel: data.experienceLevel.present
          ? data.experienceLevel.value
          : this.experienceLevel,
      lastRegularActivityDate: data.lastRegularActivityDate.present
          ? data.lastRegularActivityDate.value
          : this.lastRegularActivityDate,
      returnAfterPause: data.returnAfterPause.present
          ? data.returnAfterPause.value
          : this.returnAfterPause,
      note: data.note.present ? data.note.value : this.note,
      frequencyPerWeek: data.frequencyPerWeek.present
          ? data.frequencyPerWeek.value
          : this.frequencyPerWeek,
      typicalDurationMinutes: data.typicalDurationMinutes.present
          ? data.typicalDurationMinutes.value
          : this.typicalDurationMinutes,
      typicalIntensity: data.typicalIntensity.present
          ? data.typicalIntensity.value
          : this.typicalIntensity,
      environment: data.environment.present
          ? data.environment.value
          : this.environment,
      fixedDays: data.fixedDays.present ? data.fixedDays.value : this.fixedDays,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserSportRow(')
          ..write('id: $id, ')
          ..write('sportCode: $sportCode, ')
          ..write('customName: $customName, ')
          ..write('customCategory: $customCategory, ')
          ..write('role: $role, ')
          ..write('priority: $priority, ')
          ..write('experienceLevel: $experienceLevel, ')
          ..write('lastRegularActivityDate: $lastRegularActivityDate, ')
          ..write('returnAfterPause: $returnAfterPause, ')
          ..write('note: $note, ')
          ..write('frequencyPerWeek: $frequencyPerWeek, ')
          ..write('typicalDurationMinutes: $typicalDurationMinutes, ')
          ..write('typicalIntensity: $typicalIntensity, ')
          ..write('environment: $environment, ')
          ..write('fixedDays: $fixedDays, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    sportCode,
    customName,
    customCategory,
    role,
    priority,
    experienceLevel,
    lastRegularActivityDate,
    returnAfterPause,
    note,
    frequencyPerWeek,
    typicalDurationMinutes,
    typicalIntensity,
    environment,
    fixedDays,
    status,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUserSportRow &&
          other.id == this.id &&
          other.sportCode == this.sportCode &&
          other.customName == this.customName &&
          other.customCategory == this.customCategory &&
          other.role == this.role &&
          other.priority == this.priority &&
          other.experienceLevel == this.experienceLevel &&
          other.lastRegularActivityDate == this.lastRegularActivityDate &&
          other.returnAfterPause == this.returnAfterPause &&
          other.note == this.note &&
          other.frequencyPerWeek == this.frequencyPerWeek &&
          other.typicalDurationMinutes == this.typicalDurationMinutes &&
          other.typicalIntensity == this.typicalIntensity &&
          other.environment == this.environment &&
          other.fixedDays == this.fixedDays &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.rowVersion == this.rowVersion &&
          other.ownerId == this.ownerId &&
          other.syncState == this.syncState);
}

class LocalUserSportsCompanion extends UpdateCompanion<LocalUserSportRow> {
  final Value<String> id;
  final Value<String?> sportCode;
  final Value<String?> customName;
  final Value<String?> customCategory;
  final Value<String> role;
  final Value<String> priority;
  final Value<String> experienceLevel;
  final Value<String?> lastRegularActivityDate;
  final Value<bool> returnAfterPause;
  final Value<String?> note;
  final Value<int?> frequencyPerWeek;
  final Value<int?> typicalDurationMinutes;
  final Value<String?> typicalIntensity;
  final Value<String?> environment;
  final Value<String?> fixedDays;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowVersion;
  final Value<String> ownerId;
  final Value<String> syncState;
  final Value<int> rowid;
  const LocalUserSportsCompanion({
    this.id = const Value.absent(),
    this.sportCode = const Value.absent(),
    this.customName = const Value.absent(),
    this.customCategory = const Value.absent(),
    this.role = const Value.absent(),
    this.priority = const Value.absent(),
    this.experienceLevel = const Value.absent(),
    this.lastRegularActivityDate = const Value.absent(),
    this.returnAfterPause = const Value.absent(),
    this.note = const Value.absent(),
    this.frequencyPerWeek = const Value.absent(),
    this.typicalDurationMinutes = const Value.absent(),
    this.typicalIntensity = const Value.absent(),
    this.environment = const Value.absent(),
    this.fixedDays = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowVersion = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUserSportsCompanion.insert({
    required String id,
    this.sportCode = const Value.absent(),
    this.customName = const Value.absent(),
    this.customCategory = const Value.absent(),
    required String role,
    required String priority,
    this.experienceLevel = const Value.absent(),
    this.lastRegularActivityDate = const Value.absent(),
    this.returnAfterPause = const Value.absent(),
    this.note = const Value.absent(),
    this.frequencyPerWeek = const Value.absent(),
    this.typicalDurationMinutes = const Value.absent(),
    this.typicalIntensity = const Value.absent(),
    this.environment = const Value.absent(),
    this.fixedDays = const Value.absent(),
    this.status = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required int rowVersion,
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       role = Value(role),
       priority = Value(priority),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       rowVersion = Value(rowVersion);
  static Insertable<LocalUserSportRow> custom({
    Expression<String>? id,
    Expression<String>? sportCode,
    Expression<String>? customName,
    Expression<String>? customCategory,
    Expression<String>? role,
    Expression<String>? priority,
    Expression<String>? experienceLevel,
    Expression<String>? lastRegularActivityDate,
    Expression<bool>? returnAfterPause,
    Expression<String>? note,
    Expression<int>? frequencyPerWeek,
    Expression<int>? typicalDurationMinutes,
    Expression<String>? typicalIntensity,
    Expression<String>? environment,
    Expression<String>? fixedDays,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowVersion,
    Expression<String>? ownerId,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sportCode != null) 'sport_code': sportCode,
      if (customName != null) 'custom_name': customName,
      if (customCategory != null) 'custom_category': customCategory,
      if (role != null) 'role': role,
      if (priority != null) 'priority': priority,
      if (experienceLevel != null) 'experience_level': experienceLevel,
      if (lastRegularActivityDate != null)
        'last_regular_activity_date': lastRegularActivityDate,
      if (returnAfterPause != null) 'return_after_pause': returnAfterPause,
      if (note != null) 'note': note,
      if (frequencyPerWeek != null) 'frequency_per_week': frequencyPerWeek,
      if (typicalDurationMinutes != null)
        'typical_duration_minutes': typicalDurationMinutes,
      if (typicalIntensity != null) 'typical_intensity': typicalIntensity,
      if (environment != null) 'environment': environment,
      if (fixedDays != null) 'fixed_days': fixedDays,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowVersion != null) 'row_version': rowVersion,
      if (ownerId != null) 'owner_id': ownerId,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUserSportsCompanion copyWith({
    Value<String>? id,
    Value<String?>? sportCode,
    Value<String?>? customName,
    Value<String?>? customCategory,
    Value<String>? role,
    Value<String>? priority,
    Value<String>? experienceLevel,
    Value<String?>? lastRegularActivityDate,
    Value<bool>? returnAfterPause,
    Value<String?>? note,
    Value<int?>? frequencyPerWeek,
    Value<int?>? typicalDurationMinutes,
    Value<String?>? typicalIntensity,
    Value<String?>? environment,
    Value<String?>? fixedDays,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowVersion,
    Value<String>? ownerId,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return LocalUserSportsCompanion(
      id: id ?? this.id,
      sportCode: sportCode ?? this.sportCode,
      customName: customName ?? this.customName,
      customCategory: customCategory ?? this.customCategory,
      role: role ?? this.role,
      priority: priority ?? this.priority,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      lastRegularActivityDate:
          lastRegularActivityDate ?? this.lastRegularActivityDate,
      returnAfterPause: returnAfterPause ?? this.returnAfterPause,
      note: note ?? this.note,
      frequencyPerWeek: frequencyPerWeek ?? this.frequencyPerWeek,
      typicalDurationMinutes:
          typicalDurationMinutes ?? this.typicalDurationMinutes,
      typicalIntensity: typicalIntensity ?? this.typicalIntensity,
      environment: environment ?? this.environment,
      fixedDays: fixedDays ?? this.fixedDays,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowVersion: rowVersion ?? this.rowVersion,
      ownerId: ownerId ?? this.ownerId,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sportCode.present) {
      map['sport_code'] = Variable<String>(sportCode.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (customCategory.present) {
      map['custom_category'] = Variable<String>(customCategory.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (experienceLevel.present) {
      map['experience_level'] = Variable<String>(experienceLevel.value);
    }
    if (lastRegularActivityDate.present) {
      map['last_regular_activity_date'] = Variable<String>(
        lastRegularActivityDate.value,
      );
    }
    if (returnAfterPause.present) {
      map['return_after_pause'] = Variable<bool>(returnAfterPause.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (frequencyPerWeek.present) {
      map['frequency_per_week'] = Variable<int>(frequencyPerWeek.value);
    }
    if (typicalDurationMinutes.present) {
      map['typical_duration_minutes'] = Variable<int>(
        typicalDurationMinutes.value,
      );
    }
    if (typicalIntensity.present) {
      map['typical_intensity'] = Variable<String>(typicalIntensity.value);
    }
    if (environment.present) {
      map['environment'] = Variable<String>(environment.value);
    }
    if (fixedDays.present) {
      map['fixed_days'] = Variable<String>(fixedDays.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserSportsCompanion(')
          ..write('id: $id, ')
          ..write('sportCode: $sportCode, ')
          ..write('customName: $customName, ')
          ..write('customCategory: $customCategory, ')
          ..write('role: $role, ')
          ..write('priority: $priority, ')
          ..write('experienceLevel: $experienceLevel, ')
          ..write('lastRegularActivityDate: $lastRegularActivityDate, ')
          ..write('returnAfterPause: $returnAfterPause, ')
          ..write('note: $note, ')
          ..write('frequencyPerWeek: $frequencyPerWeek, ')
          ..write('typicalDurationMinutes: $typicalDurationMinutes, ')
          ..write('typicalIntensity: $typicalIntensity, ')
          ..write('environment: $environment, ')
          ..write('fixedDays: $fixedDays, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalGoalsTable extends LocalGoals
    with TableInfo<$LocalGoalsTable, LocalGoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalTypeMeta = const VerificationMeta(
    'goalType',
  );
  @override
  late final GeneratedColumn<String> goalType = GeneratedColumn<String>(
    'goal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _horizonMeta = const VerificationMeta(
    'horizon',
  );
  @override
  late final GeneratedColumn<String> horizon = GeneratedColumn<String>(
    'horizon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('OPEN_ENDED'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(goalStatusActive),
  );
  static const VerificationMeta _userSportIdMeta = const VerificationMeta(
    'userSportId',
  );
  @override
  late final GeneratedColumn<String> userSportId = GeneratedColumn<String>(
    'user_sport_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_user_sports (id)',
    ),
  );
  static const VerificationMeta _targetLocalDateMeta = const VerificationMeta(
    'targetLocalDate',
  );
  @override
  late final GeneratedColumn<String> targetLocalDate = GeneratedColumn<String>(
    'target_local_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(localAnonymousOwnerId),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(syncStateLocalOnly),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    goalType,
    priority,
    horizon,
    status,
    userSportId,
    targetLocalDate,
    note,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalGoalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('goal_type')) {
      context.handle(
        _goalTypeMeta,
        goalType.isAcceptableOrUnknown(data['goal_type']!, _goalTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_goalTypeMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('horizon')) {
      context.handle(
        _horizonMeta,
        horizon.isAcceptableOrUnknown(data['horizon']!, _horizonMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('user_sport_id')) {
      context.handle(
        _userSportIdMeta,
        userSportId.isAcceptableOrUnknown(
          data['user_sport_id']!,
          _userSportIdMeta,
        ),
      );
    }
    if (data.containsKey('target_local_date')) {
      context.handle(
        _targetLocalDateMeta,
        targetLocalDate.isAcceptableOrUnknown(
          data['target_local_date']!,
          _targetLocalDateMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_rowVersionMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalGoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalGoalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      goalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_type'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      horizon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}horizon'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      userSportId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_sport_id'],
      ),
      targetLocalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_local_date'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $LocalGoalsTable createAlias(String alias) {
    return $LocalGoalsTable(attachedDatabase, alias);
  }
}

class LocalGoalRow extends DataClass implements Insertable<LocalGoalRow> {
  final String id;
  final String title;
  final String goalType;
  final String priority;
  final String horizon;
  final String status;
  final String? userSportId;
  final String? targetLocalDate;
  final String? note;
  final int createdAt;
  final int updatedAt;
  final int rowVersion;
  final String ownerId;
  final String syncState;
  const LocalGoalRow({
    required this.id,
    required this.title,
    required this.goalType,
    required this.priority,
    required this.horizon,
    required this.status,
    this.userSportId,
    this.targetLocalDate,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.rowVersion,
    required this.ownerId,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['goal_type'] = Variable<String>(goalType);
    map['priority'] = Variable<String>(priority);
    map['horizon'] = Variable<String>(horizon);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || userSportId != null) {
      map['user_sport_id'] = Variable<String>(userSportId);
    }
    if (!nullToAbsent || targetLocalDate != null) {
      map['target_local_date'] = Variable<String>(targetLocalDate);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['row_version'] = Variable<int>(rowVersion);
    map['owner_id'] = Variable<String>(ownerId);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  LocalGoalsCompanion toCompanion(bool nullToAbsent) {
    return LocalGoalsCompanion(
      id: Value(id),
      title: Value(title),
      goalType: Value(goalType),
      priority: Value(priority),
      horizon: Value(horizon),
      status: Value(status),
      userSportId: userSportId == null && nullToAbsent
          ? const Value.absent()
          : Value(userSportId),
      targetLocalDate: targetLocalDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetLocalDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      rowVersion: Value(rowVersion),
      ownerId: Value(ownerId),
      syncState: Value(syncState),
    );
  }

  factory LocalGoalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalGoalRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      goalType: serializer.fromJson<String>(json['goalType']),
      priority: serializer.fromJson<String>(json['priority']),
      horizon: serializer.fromJson<String>(json['horizon']),
      status: serializer.fromJson<String>(json['status']),
      userSportId: serializer.fromJson<String?>(json['userSportId']),
      targetLocalDate: serializer.fromJson<String?>(json['targetLocalDate']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'goalType': serializer.toJson<String>(goalType),
      'priority': serializer.toJson<String>(priority),
      'horizon': serializer.toJson<String>(horizon),
      'status': serializer.toJson<String>(status),
      'userSportId': serializer.toJson<String?>(userSportId),
      'targetLocalDate': serializer.toJson<String?>(targetLocalDate),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'rowVersion': serializer.toJson<int>(rowVersion),
      'ownerId': serializer.toJson<String>(ownerId),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  LocalGoalRow copyWith({
    String? id,
    String? title,
    String? goalType,
    String? priority,
    String? horizon,
    String? status,
    Value<String?> userSportId = const Value.absent(),
    Value<String?> targetLocalDate = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    int? rowVersion,
    String? ownerId,
    String? syncState,
  }) => LocalGoalRow(
    id: id ?? this.id,
    title: title ?? this.title,
    goalType: goalType ?? this.goalType,
    priority: priority ?? this.priority,
    horizon: horizon ?? this.horizon,
    status: status ?? this.status,
    userSportId: userSportId.present ? userSportId.value : this.userSportId,
    targetLocalDate: targetLocalDate.present
        ? targetLocalDate.value
        : this.targetLocalDate,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    rowVersion: rowVersion ?? this.rowVersion,
    ownerId: ownerId ?? this.ownerId,
    syncState: syncState ?? this.syncState,
  );
  LocalGoalRow copyWithCompanion(LocalGoalsCompanion data) {
    return LocalGoalRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      goalType: data.goalType.present ? data.goalType.value : this.goalType,
      priority: data.priority.present ? data.priority.value : this.priority,
      horizon: data.horizon.present ? data.horizon.value : this.horizon,
      status: data.status.present ? data.status.value : this.status,
      userSportId: data.userSportId.present
          ? data.userSportId.value
          : this.userSportId,
      targetLocalDate: data.targetLocalDate.present
          ? data.targetLocalDate.value
          : this.targetLocalDate,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalGoalRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('goalType: $goalType, ')
          ..write('priority: $priority, ')
          ..write('horizon: $horizon, ')
          ..write('status: $status, ')
          ..write('userSportId: $userSportId, ')
          ..write('targetLocalDate: $targetLocalDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    goalType,
    priority,
    horizon,
    status,
    userSportId,
    targetLocalDate,
    note,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalGoalRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.goalType == this.goalType &&
          other.priority == this.priority &&
          other.horizon == this.horizon &&
          other.status == this.status &&
          other.userSportId == this.userSportId &&
          other.targetLocalDate == this.targetLocalDate &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.rowVersion == this.rowVersion &&
          other.ownerId == this.ownerId &&
          other.syncState == this.syncState);
}

class LocalGoalsCompanion extends UpdateCompanion<LocalGoalRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> goalType;
  final Value<String> priority;
  final Value<String> horizon;
  final Value<String> status;
  final Value<String?> userSportId;
  final Value<String?> targetLocalDate;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowVersion;
  final Value<String> ownerId;
  final Value<String> syncState;
  final Value<int> rowid;
  const LocalGoalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.goalType = const Value.absent(),
    this.priority = const Value.absent(),
    this.horizon = const Value.absent(),
    this.status = const Value.absent(),
    this.userSportId = const Value.absent(),
    this.targetLocalDate = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowVersion = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalGoalsCompanion.insert({
    required String id,
    required String title,
    required String goalType,
    required String priority,
    this.horizon = const Value.absent(),
    this.status = const Value.absent(),
    this.userSportId = const Value.absent(),
    this.targetLocalDate = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required int rowVersion,
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       goalType = Value(goalType),
       priority = Value(priority),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       rowVersion = Value(rowVersion);
  static Insertable<LocalGoalRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? goalType,
    Expression<String>? priority,
    Expression<String>? horizon,
    Expression<String>? status,
    Expression<String>? userSportId,
    Expression<String>? targetLocalDate,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowVersion,
    Expression<String>? ownerId,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (goalType != null) 'goal_type': goalType,
      if (priority != null) 'priority': priority,
      if (horizon != null) 'horizon': horizon,
      if (status != null) 'status': status,
      if (userSportId != null) 'user_sport_id': userSportId,
      if (targetLocalDate != null) 'target_local_date': targetLocalDate,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowVersion != null) 'row_version': rowVersion,
      if (ownerId != null) 'owner_id': ownerId,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalGoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? goalType,
    Value<String>? priority,
    Value<String>? horizon,
    Value<String>? status,
    Value<String?>? userSportId,
    Value<String?>? targetLocalDate,
    Value<String?>? note,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowVersion,
    Value<String>? ownerId,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return LocalGoalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      goalType: goalType ?? this.goalType,
      priority: priority ?? this.priority,
      horizon: horizon ?? this.horizon,
      status: status ?? this.status,
      userSportId: userSportId ?? this.userSportId,
      targetLocalDate: targetLocalDate ?? this.targetLocalDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowVersion: rowVersion ?? this.rowVersion,
      ownerId: ownerId ?? this.ownerId,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (goalType.present) {
      map['goal_type'] = Variable<String>(goalType.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (horizon.present) {
      map['horizon'] = Variable<String>(horizon.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (userSportId.present) {
      map['user_sport_id'] = Variable<String>(userSportId.value);
    }
    if (targetLocalDate.present) {
      map['target_local_date'] = Variable<String>(targetLocalDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalGoalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('goalType: $goalType, ')
          ..write('priority: $priority, ')
          ..write('horizon: $horizon, ')
          ..write('status: $status, ')
          ..write('userSportId: $userSportId, ')
          ..write('targetLocalDate: $targetLocalDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAvailabilityRulesTable extends LocalAvailabilityRules
    with TableInfo<$LocalAvailabilityRulesTable, LocalAvailabilityRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAvailabilityRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<String> dayOfWeek = GeneratedColumn<String>(
    'day_of_week',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _budgetMinutesMeta = const VerificationMeta(
    'budgetMinutes',
  );
  @override
  late final GeneratedColumn<int> budgetMinutes = GeneratedColumn<int>(
    'budget_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preferredPartOfDayMeta =
      const VerificationMeta('preferredPartOfDay');
  @override
  late final GeneratedColumn<String> preferredPartOfDay =
      GeneratedColumn<String>(
        'preferred_part_of_day',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(localAnonymousOwnerId),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(syncStateLocalOnly),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dayOfWeek,
    level,
    budgetMinutes,
    preferredPartOfDay,
    note,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_availability_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAvailabilityRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('budget_minutes')) {
      context.handle(
        _budgetMinutesMeta,
        budgetMinutes.isAcceptableOrUnknown(
          data['budget_minutes']!,
          _budgetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('preferred_part_of_day')) {
      context.handle(
        _preferredPartOfDayMeta,
        preferredPartOfDay.isAcceptableOrUnknown(
          data['preferred_part_of_day']!,
          _preferredPartOfDayMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_rowVersionMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAvailabilityRuleRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAvailabilityRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_of_week'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      budgetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_minutes'],
      ),
      preferredPartOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_part_of_day'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $LocalAvailabilityRulesTable createAlias(String alias) {
    return $LocalAvailabilityRulesTable(attachedDatabase, alias);
  }
}

class LocalAvailabilityRuleRow extends DataClass
    implements Insertable<LocalAvailabilityRuleRow> {
  final String id;
  final String dayOfWeek;
  final String level;
  final int? budgetMinutes;
  final String? preferredPartOfDay;
  final String? note;
  final int createdAt;
  final int updatedAt;
  final int rowVersion;
  final String ownerId;
  final String syncState;
  const LocalAvailabilityRuleRow({
    required this.id,
    required this.dayOfWeek,
    required this.level,
    this.budgetMinutes,
    this.preferredPartOfDay,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.rowVersion,
    required this.ownerId,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day_of_week'] = Variable<String>(dayOfWeek);
    map['level'] = Variable<String>(level);
    if (!nullToAbsent || budgetMinutes != null) {
      map['budget_minutes'] = Variable<int>(budgetMinutes);
    }
    if (!nullToAbsent || preferredPartOfDay != null) {
      map['preferred_part_of_day'] = Variable<String>(preferredPartOfDay);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['row_version'] = Variable<int>(rowVersion);
    map['owner_id'] = Variable<String>(ownerId);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  LocalAvailabilityRulesCompanion toCompanion(bool nullToAbsent) {
    return LocalAvailabilityRulesCompanion(
      id: Value(id),
      dayOfWeek: Value(dayOfWeek),
      level: Value(level),
      budgetMinutes: budgetMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetMinutes),
      preferredPartOfDay: preferredPartOfDay == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredPartOfDay),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      rowVersion: Value(rowVersion),
      ownerId: Value(ownerId),
      syncState: Value(syncState),
    );
  }

  factory LocalAvailabilityRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAvailabilityRuleRow(
      id: serializer.fromJson<String>(json['id']),
      dayOfWeek: serializer.fromJson<String>(json['dayOfWeek']),
      level: serializer.fromJson<String>(json['level']),
      budgetMinutes: serializer.fromJson<int?>(json['budgetMinutes']),
      preferredPartOfDay: serializer.fromJson<String?>(
        json['preferredPartOfDay'],
      ),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dayOfWeek': serializer.toJson<String>(dayOfWeek),
      'level': serializer.toJson<String>(level),
      'budgetMinutes': serializer.toJson<int?>(budgetMinutes),
      'preferredPartOfDay': serializer.toJson<String?>(preferredPartOfDay),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'rowVersion': serializer.toJson<int>(rowVersion),
      'ownerId': serializer.toJson<String>(ownerId),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  LocalAvailabilityRuleRow copyWith({
    String? id,
    String? dayOfWeek,
    String? level,
    Value<int?> budgetMinutes = const Value.absent(),
    Value<String?> preferredPartOfDay = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    int? rowVersion,
    String? ownerId,
    String? syncState,
  }) => LocalAvailabilityRuleRow(
    id: id ?? this.id,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    level: level ?? this.level,
    budgetMinutes: budgetMinutes.present
        ? budgetMinutes.value
        : this.budgetMinutes,
    preferredPartOfDay: preferredPartOfDay.present
        ? preferredPartOfDay.value
        : this.preferredPartOfDay,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    rowVersion: rowVersion ?? this.rowVersion,
    ownerId: ownerId ?? this.ownerId,
    syncState: syncState ?? this.syncState,
  );
  LocalAvailabilityRuleRow copyWithCompanion(
    LocalAvailabilityRulesCompanion data,
  ) {
    return LocalAvailabilityRuleRow(
      id: data.id.present ? data.id.value : this.id,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      level: data.level.present ? data.level.value : this.level,
      budgetMinutes: data.budgetMinutes.present
          ? data.budgetMinutes.value
          : this.budgetMinutes,
      preferredPartOfDay: data.preferredPartOfDay.present
          ? data.preferredPartOfDay.value
          : this.preferredPartOfDay,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAvailabilityRuleRow(')
          ..write('id: $id, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('level: $level, ')
          ..write('budgetMinutes: $budgetMinutes, ')
          ..write('preferredPartOfDay: $preferredPartOfDay, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dayOfWeek,
    level,
    budgetMinutes,
    preferredPartOfDay,
    note,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAvailabilityRuleRow &&
          other.id == this.id &&
          other.dayOfWeek == this.dayOfWeek &&
          other.level == this.level &&
          other.budgetMinutes == this.budgetMinutes &&
          other.preferredPartOfDay == this.preferredPartOfDay &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.rowVersion == this.rowVersion &&
          other.ownerId == this.ownerId &&
          other.syncState == this.syncState);
}

class LocalAvailabilityRulesCompanion
    extends UpdateCompanion<LocalAvailabilityRuleRow> {
  final Value<String> id;
  final Value<String> dayOfWeek;
  final Value<String> level;
  final Value<int?> budgetMinutes;
  final Value<String?> preferredPartOfDay;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowVersion;
  final Value<String> ownerId;
  final Value<String> syncState;
  final Value<int> rowid;
  const LocalAvailabilityRulesCompanion({
    this.id = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.level = const Value.absent(),
    this.budgetMinutes = const Value.absent(),
    this.preferredPartOfDay = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowVersion = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAvailabilityRulesCompanion.insert({
    required String id,
    required String dayOfWeek,
    required String level,
    this.budgetMinutes = const Value.absent(),
    this.preferredPartOfDay = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required int rowVersion,
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dayOfWeek = Value(dayOfWeek),
       level = Value(level),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       rowVersion = Value(rowVersion);
  static Insertable<LocalAvailabilityRuleRow> custom({
    Expression<String>? id,
    Expression<String>? dayOfWeek,
    Expression<String>? level,
    Expression<int>? budgetMinutes,
    Expression<String>? preferredPartOfDay,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowVersion,
    Expression<String>? ownerId,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (level != null) 'level': level,
      if (budgetMinutes != null) 'budget_minutes': budgetMinutes,
      if (preferredPartOfDay != null)
        'preferred_part_of_day': preferredPartOfDay,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowVersion != null) 'row_version': rowVersion,
      if (ownerId != null) 'owner_id': ownerId,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAvailabilityRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? dayOfWeek,
    Value<String>? level,
    Value<int?>? budgetMinutes,
    Value<String?>? preferredPartOfDay,
    Value<String?>? note,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowVersion,
    Value<String>? ownerId,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return LocalAvailabilityRulesCompanion(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      level: level ?? this.level,
      budgetMinutes: budgetMinutes ?? this.budgetMinutes,
      preferredPartOfDay: preferredPartOfDay ?? this.preferredPartOfDay,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowVersion: rowVersion ?? this.rowVersion,
      ownerId: ownerId ?? this.ownerId,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<String>(dayOfWeek.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (budgetMinutes.present) {
      map['budget_minutes'] = Variable<int>(budgetMinutes.value);
    }
    if (preferredPartOfDay.present) {
      map['preferred_part_of_day'] = Variable<String>(preferredPartOfDay.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAvailabilityRulesCompanion(')
          ..write('id: $id, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('level: $level, ')
          ..write('budgetMinutes: $budgetMinutes, ')
          ..write('preferredPartOfDay: $preferredPartOfDay, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalEquipmentItemsTable extends LocalEquipmentItems
    with TableInfo<$LocalEquipmentItemsTable, LocalEquipmentItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalEquipmentItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentCodeMeta = const VerificationMeta(
    'equipmentCode',
  );
  @override
  late final GeneratedColumn<String> equipmentCode = GeneratedColumn<String>(
    'equipment_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(equipmentStatusActive),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(localAnonymousOwnerId),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(syncStateLocalOnly),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    equipmentCode,
    customName,
    note,
    status,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_equipment_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalEquipmentItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('equipment_code')) {
      context.handle(
        _equipmentCodeMeta,
        equipmentCode.isAcceptableOrUnknown(
          data['equipment_code']!,
          _equipmentCodeMeta,
        ),
      );
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_rowVersionMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalEquipmentItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalEquipmentItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      equipmentCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment_code'],
      ),
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $LocalEquipmentItemsTable createAlias(String alias) {
    return $LocalEquipmentItemsTable(attachedDatabase, alias);
  }
}

class LocalEquipmentItemRow extends DataClass
    implements Insertable<LocalEquipmentItemRow> {
  final String id;
  final String? equipmentCode;
  final String? customName;
  final String? note;
  final String status;
  final int createdAt;
  final int updatedAt;
  final int rowVersion;
  final String ownerId;
  final String syncState;
  const LocalEquipmentItemRow({
    required this.id,
    this.equipmentCode,
    this.customName,
    this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.rowVersion,
    required this.ownerId,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || equipmentCode != null) {
      map['equipment_code'] = Variable<String>(equipmentCode);
    }
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['row_version'] = Variable<int>(rowVersion);
    map['owner_id'] = Variable<String>(ownerId);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  LocalEquipmentItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalEquipmentItemsCompanion(
      id: Value(id),
      equipmentCode: equipmentCode == null && nullToAbsent
          ? const Value.absent()
          : Value(equipmentCode),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      rowVersion: Value(rowVersion),
      ownerId: Value(ownerId),
      syncState: Value(syncState),
    );
  }

  factory LocalEquipmentItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalEquipmentItemRow(
      id: serializer.fromJson<String>(json['id']),
      equipmentCode: serializer.fromJson<String?>(json['equipmentCode']),
      customName: serializer.fromJson<String?>(json['customName']),
      note: serializer.fromJson<String?>(json['note']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'equipmentCode': serializer.toJson<String?>(equipmentCode),
      'customName': serializer.toJson<String?>(customName),
      'note': serializer.toJson<String?>(note),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'rowVersion': serializer.toJson<int>(rowVersion),
      'ownerId': serializer.toJson<String>(ownerId),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  LocalEquipmentItemRow copyWith({
    String? id,
    Value<String?> equipmentCode = const Value.absent(),
    Value<String?> customName = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? status,
    int? createdAt,
    int? updatedAt,
    int? rowVersion,
    String? ownerId,
    String? syncState,
  }) => LocalEquipmentItemRow(
    id: id ?? this.id,
    equipmentCode: equipmentCode.present
        ? equipmentCode.value
        : this.equipmentCode,
    customName: customName.present ? customName.value : this.customName,
    note: note.present ? note.value : this.note,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    rowVersion: rowVersion ?? this.rowVersion,
    ownerId: ownerId ?? this.ownerId,
    syncState: syncState ?? this.syncState,
  );
  LocalEquipmentItemRow copyWithCompanion(LocalEquipmentItemsCompanion data) {
    return LocalEquipmentItemRow(
      id: data.id.present ? data.id.value : this.id,
      equipmentCode: data.equipmentCode.present
          ? data.equipmentCode.value
          : this.equipmentCode,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      note: data.note.present ? data.note.value : this.note,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalEquipmentItemRow(')
          ..write('id: $id, ')
          ..write('equipmentCode: $equipmentCode, ')
          ..write('customName: $customName, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    equipmentCode,
    customName,
    note,
    status,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalEquipmentItemRow &&
          other.id == this.id &&
          other.equipmentCode == this.equipmentCode &&
          other.customName == this.customName &&
          other.note == this.note &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.rowVersion == this.rowVersion &&
          other.ownerId == this.ownerId &&
          other.syncState == this.syncState);
}

class LocalEquipmentItemsCompanion
    extends UpdateCompanion<LocalEquipmentItemRow> {
  final Value<String> id;
  final Value<String?> equipmentCode;
  final Value<String?> customName;
  final Value<String?> note;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowVersion;
  final Value<String> ownerId;
  final Value<String> syncState;
  final Value<int> rowid;
  const LocalEquipmentItemsCompanion({
    this.id = const Value.absent(),
    this.equipmentCode = const Value.absent(),
    this.customName = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowVersion = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalEquipmentItemsCompanion.insert({
    required String id,
    this.equipmentCode = const Value.absent(),
    this.customName = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required int rowVersion,
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       rowVersion = Value(rowVersion);
  static Insertable<LocalEquipmentItemRow> custom({
    Expression<String>? id,
    Expression<String>? equipmentCode,
    Expression<String>? customName,
    Expression<String>? note,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowVersion,
    Expression<String>? ownerId,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (equipmentCode != null) 'equipment_code': equipmentCode,
      if (customName != null) 'custom_name': customName,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowVersion != null) 'row_version': rowVersion,
      if (ownerId != null) 'owner_id': ownerId,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalEquipmentItemsCompanion copyWith({
    Value<String>? id,
    Value<String?>? equipmentCode,
    Value<String?>? customName,
    Value<String?>? note,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowVersion,
    Value<String>? ownerId,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return LocalEquipmentItemsCompanion(
      id: id ?? this.id,
      equipmentCode: equipmentCode ?? this.equipmentCode,
      customName: customName ?? this.customName,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowVersion: rowVersion ?? this.rowVersion,
      ownerId: ownerId ?? this.ownerId,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (equipmentCode.present) {
      map['equipment_code'] = Variable<String>(equipmentCode.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalEquipmentItemsCompanion(')
          ..write('id: $id, ')
          ..write('equipmentCode: $equipmentCode, ')
          ..write('customName: $customName, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalConstraintsTable extends LocalConstraints
    with TableInfo<$LocalConstraintsTable, LocalConstraintRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalConstraintsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(constraintStatusActive),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(localAnonymousOwnerId),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(syncStateLocalOnly),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    note,
    status,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_constraints';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalConstraintRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_rowVersionMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalConstraintRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalConstraintRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $LocalConstraintsTable createAlias(String alias) {
    return $LocalConstraintsTable(attachedDatabase, alias);
  }
}

class LocalConstraintRow extends DataClass
    implements Insertable<LocalConstraintRow> {
  final String id;
  final String title;
  final String? note;
  final String status;
  final int createdAt;
  final int updatedAt;
  final int rowVersion;
  final String ownerId;
  final String syncState;
  const LocalConstraintRow({
    required this.id,
    required this.title,
    this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.rowVersion,
    required this.ownerId,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['row_version'] = Variable<int>(rowVersion);
    map['owner_id'] = Variable<String>(ownerId);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  LocalConstraintsCompanion toCompanion(bool nullToAbsent) {
    return LocalConstraintsCompanion(
      id: Value(id),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      rowVersion: Value(rowVersion),
      ownerId: Value(ownerId),
      syncState: Value(syncState),
    );
  }

  factory LocalConstraintRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalConstraintRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'rowVersion': serializer.toJson<int>(rowVersion),
      'ownerId': serializer.toJson<String>(ownerId),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  LocalConstraintRow copyWith({
    String? id,
    String? title,
    Value<String?> note = const Value.absent(),
    String? status,
    int? createdAt,
    int? updatedAt,
    int? rowVersion,
    String? ownerId,
    String? syncState,
  }) => LocalConstraintRow(
    id: id ?? this.id,
    title: title ?? this.title,
    note: note.present ? note.value : this.note,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    rowVersion: rowVersion ?? this.rowVersion,
    ownerId: ownerId ?? this.ownerId,
    syncState: syncState ?? this.syncState,
  );
  LocalConstraintRow copyWithCompanion(LocalConstraintsCompanion data) {
    return LocalConstraintRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalConstraintRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    note,
    status,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalConstraintRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.note == this.note &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.rowVersion == this.rowVersion &&
          other.ownerId == this.ownerId &&
          other.syncState == this.syncState);
}

class LocalConstraintsCompanion extends UpdateCompanion<LocalConstraintRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> note;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowVersion;
  final Value<String> ownerId;
  final Value<String> syncState;
  final Value<int> rowid;
  const LocalConstraintsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowVersion = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalConstraintsCompanion.insert({
    required String id,
    required String title,
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required int rowVersion,
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       rowVersion = Value(rowVersion);
  static Insertable<LocalConstraintRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? note,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowVersion,
    Expression<String>? ownerId,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowVersion != null) 'row_version': rowVersion,
      if (ownerId != null) 'owner_id': ownerId,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalConstraintsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? note,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowVersion,
    Value<String>? ownerId,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return LocalConstraintsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowVersion: rowVersion ?? this.rowVersion,
      ownerId: ownerId ?? this.ownerId,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalConstraintsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTrainingPlansTable extends LocalTrainingPlans
    with TableInfo<$LocalTrainingPlansTable, LocalTrainingPlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTrainingPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(planStatusActive),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(localAnonymousOwnerId),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(syncStateLocalOnly),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    note,
    status,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_training_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTrainingPlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_rowVersionMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTrainingPlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTrainingPlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $LocalTrainingPlansTable createAlias(String alias) {
    return $LocalTrainingPlansTable(attachedDatabase, alias);
  }
}

class LocalTrainingPlanRow extends DataClass
    implements Insertable<LocalTrainingPlanRow> {
  final String id;
  final String title;
  final String? note;
  final String status;
  final int createdAt;
  final int updatedAt;
  final int rowVersion;
  final String ownerId;
  final String syncState;
  const LocalTrainingPlanRow({
    required this.id,
    required this.title,
    this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.rowVersion,
    required this.ownerId,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['row_version'] = Variable<int>(rowVersion);
    map['owner_id'] = Variable<String>(ownerId);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  LocalTrainingPlansCompanion toCompanion(bool nullToAbsent) {
    return LocalTrainingPlansCompanion(
      id: Value(id),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      rowVersion: Value(rowVersion),
      ownerId: Value(ownerId),
      syncState: Value(syncState),
    );
  }

  factory LocalTrainingPlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTrainingPlanRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'rowVersion': serializer.toJson<int>(rowVersion),
      'ownerId': serializer.toJson<String>(ownerId),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  LocalTrainingPlanRow copyWith({
    String? id,
    String? title,
    Value<String?> note = const Value.absent(),
    String? status,
    int? createdAt,
    int? updatedAt,
    int? rowVersion,
    String? ownerId,
    String? syncState,
  }) => LocalTrainingPlanRow(
    id: id ?? this.id,
    title: title ?? this.title,
    note: note.present ? note.value : this.note,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    rowVersion: rowVersion ?? this.rowVersion,
    ownerId: ownerId ?? this.ownerId,
    syncState: syncState ?? this.syncState,
  );
  LocalTrainingPlanRow copyWithCompanion(LocalTrainingPlansCompanion data) {
    return LocalTrainingPlanRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTrainingPlanRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    note,
    status,
    createdAt,
    updatedAt,
    rowVersion,
    ownerId,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTrainingPlanRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.note == this.note &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.rowVersion == this.rowVersion &&
          other.ownerId == this.ownerId &&
          other.syncState == this.syncState);
}

class LocalTrainingPlansCompanion
    extends UpdateCompanion<LocalTrainingPlanRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> note;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowVersion;
  final Value<String> ownerId;
  final Value<String> syncState;
  final Value<int> rowid;
  const LocalTrainingPlansCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowVersion = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTrainingPlansCompanion.insert({
    required String id,
    required String title,
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required int rowVersion,
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       rowVersion = Value(rowVersion);
  static Insertable<LocalTrainingPlanRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? note,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowVersion,
    Expression<String>? ownerId,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowVersion != null) 'row_version': rowVersion,
      if (ownerId != null) 'owner_id': ownerId,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTrainingPlansCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? note,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowVersion,
    Value<String>? ownerId,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return LocalTrainingPlansCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowVersion: rowVersion ?? this.rowVersion,
      ownerId: ownerId ?? this.ownerId,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTrainingPlansCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowVersion: $rowVersion, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCalendarChangesTable extends LocalCalendarChanges
    with TableInfo<$LocalCalendarChangesTable, LocalCalendarChangeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCalendarChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutInstanceIdMeta = const VerificationMeta(
    'workoutInstanceId',
  );
  @override
  late final GeneratedColumn<String> workoutInstanceId =
      GeneratedColumn<String>(
        'workout_instance_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_workout_instances (id)',
        ),
      );
  static const VerificationMeta _changeTypeMeta = const VerificationMeta(
    'changeType',
  );
  @override
  late final GeneratedColumn<String> changeType = GeneratedColumn<String>(
    'change_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromLocalDateMeta = const VerificationMeta(
    'fromLocalDate',
  );
  @override
  late final GeneratedColumn<String> fromLocalDate = GeneratedColumn<String>(
    'from_local_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toLocalDateMeta = const VerificationMeta(
    'toLocalDate',
  );
  @override
  late final GeneratedColumn<String> toLocalDate = GeneratedColumn<String>(
    'to_local_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replacementInstanceIdMeta =
      const VerificationMeta('replacementInstanceId');
  @override
  late final GeneratedColumn<String> replacementInstanceId =
      GeneratedColumn<String>(
        'replacement_instance_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_workout_instances (id)',
        ),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(localAnonymousOwnerId),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(syncStateLocalOnly),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutInstanceId,
    changeType,
    fromLocalDate,
    toLocalDate,
    replacementInstanceId,
    createdAt,
    ownerId,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_calendar_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCalendarChangeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workout_instance_id')) {
      context.handle(
        _workoutInstanceIdMeta,
        workoutInstanceId.isAcceptableOrUnknown(
          data['workout_instance_id']!,
          _workoutInstanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutInstanceIdMeta);
    }
    if (data.containsKey('change_type')) {
      context.handle(
        _changeTypeMeta,
        changeType.isAcceptableOrUnknown(data['change_type']!, _changeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_changeTypeMeta);
    }
    if (data.containsKey('from_local_date')) {
      context.handle(
        _fromLocalDateMeta,
        fromLocalDate.isAcceptableOrUnknown(
          data['from_local_date']!,
          _fromLocalDateMeta,
        ),
      );
    }
    if (data.containsKey('to_local_date')) {
      context.handle(
        _toLocalDateMeta,
        toLocalDate.isAcceptableOrUnknown(
          data['to_local_date']!,
          _toLocalDateMeta,
        ),
      );
    }
    if (data.containsKey('replacement_instance_id')) {
      context.handle(
        _replacementInstanceIdMeta,
        replacementInstanceId.isAcceptableOrUnknown(
          data['replacement_instance_id']!,
          _replacementInstanceIdMeta,
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
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCalendarChangeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCalendarChangeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutInstanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_instance_id'],
      )!,
      changeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_type'],
      )!,
      fromLocalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_local_date'],
      ),
      toLocalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_local_date'],
      ),
      replacementInstanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}replacement_instance_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $LocalCalendarChangesTable createAlias(String alias) {
    return $LocalCalendarChangesTable(attachedDatabase, alias);
  }
}

class LocalCalendarChangeRow extends DataClass
    implements Insertable<LocalCalendarChangeRow> {
  final String id;
  final String workoutInstanceId;
  final String changeType;
  final String? fromLocalDate;
  final String? toLocalDate;
  final String? replacementInstanceId;
  final int createdAt;
  final String ownerId;
  final String syncState;
  const LocalCalendarChangeRow({
    required this.id,
    required this.workoutInstanceId,
    required this.changeType,
    this.fromLocalDate,
    this.toLocalDate,
    this.replacementInstanceId,
    required this.createdAt,
    required this.ownerId,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_instance_id'] = Variable<String>(workoutInstanceId);
    map['change_type'] = Variable<String>(changeType);
    if (!nullToAbsent || fromLocalDate != null) {
      map['from_local_date'] = Variable<String>(fromLocalDate);
    }
    if (!nullToAbsent || toLocalDate != null) {
      map['to_local_date'] = Variable<String>(toLocalDate);
    }
    if (!nullToAbsent || replacementInstanceId != null) {
      map['replacement_instance_id'] = Variable<String>(replacementInstanceId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['owner_id'] = Variable<String>(ownerId);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  LocalCalendarChangesCompanion toCompanion(bool nullToAbsent) {
    return LocalCalendarChangesCompanion(
      id: Value(id),
      workoutInstanceId: Value(workoutInstanceId),
      changeType: Value(changeType),
      fromLocalDate: fromLocalDate == null && nullToAbsent
          ? const Value.absent()
          : Value(fromLocalDate),
      toLocalDate: toLocalDate == null && nullToAbsent
          ? const Value.absent()
          : Value(toLocalDate),
      replacementInstanceId: replacementInstanceId == null && nullToAbsent
          ? const Value.absent()
          : Value(replacementInstanceId),
      createdAt: Value(createdAt),
      ownerId: Value(ownerId),
      syncState: Value(syncState),
    );
  }

  factory LocalCalendarChangeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCalendarChangeRow(
      id: serializer.fromJson<String>(json['id']),
      workoutInstanceId: serializer.fromJson<String>(json['workoutInstanceId']),
      changeType: serializer.fromJson<String>(json['changeType']),
      fromLocalDate: serializer.fromJson<String?>(json['fromLocalDate']),
      toLocalDate: serializer.fromJson<String?>(json['toLocalDate']),
      replacementInstanceId: serializer.fromJson<String?>(
        json['replacementInstanceId'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutInstanceId': serializer.toJson<String>(workoutInstanceId),
      'changeType': serializer.toJson<String>(changeType),
      'fromLocalDate': serializer.toJson<String?>(fromLocalDate),
      'toLocalDate': serializer.toJson<String?>(toLocalDate),
      'replacementInstanceId': serializer.toJson<String?>(
        replacementInstanceId,
      ),
      'createdAt': serializer.toJson<int>(createdAt),
      'ownerId': serializer.toJson<String>(ownerId),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  LocalCalendarChangeRow copyWith({
    String? id,
    String? workoutInstanceId,
    String? changeType,
    Value<String?> fromLocalDate = const Value.absent(),
    Value<String?> toLocalDate = const Value.absent(),
    Value<String?> replacementInstanceId = const Value.absent(),
    int? createdAt,
    String? ownerId,
    String? syncState,
  }) => LocalCalendarChangeRow(
    id: id ?? this.id,
    workoutInstanceId: workoutInstanceId ?? this.workoutInstanceId,
    changeType: changeType ?? this.changeType,
    fromLocalDate: fromLocalDate.present
        ? fromLocalDate.value
        : this.fromLocalDate,
    toLocalDate: toLocalDate.present ? toLocalDate.value : this.toLocalDate,
    replacementInstanceId: replacementInstanceId.present
        ? replacementInstanceId.value
        : this.replacementInstanceId,
    createdAt: createdAt ?? this.createdAt,
    ownerId: ownerId ?? this.ownerId,
    syncState: syncState ?? this.syncState,
  );
  LocalCalendarChangeRow copyWithCompanion(LocalCalendarChangesCompanion data) {
    return LocalCalendarChangeRow(
      id: data.id.present ? data.id.value : this.id,
      workoutInstanceId: data.workoutInstanceId.present
          ? data.workoutInstanceId.value
          : this.workoutInstanceId,
      changeType: data.changeType.present
          ? data.changeType.value
          : this.changeType,
      fromLocalDate: data.fromLocalDate.present
          ? data.fromLocalDate.value
          : this.fromLocalDate,
      toLocalDate: data.toLocalDate.present
          ? data.toLocalDate.value
          : this.toLocalDate,
      replacementInstanceId: data.replacementInstanceId.present
          ? data.replacementInstanceId.value
          : this.replacementInstanceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCalendarChangeRow(')
          ..write('id: $id, ')
          ..write('workoutInstanceId: $workoutInstanceId, ')
          ..write('changeType: $changeType, ')
          ..write('fromLocalDate: $fromLocalDate, ')
          ..write('toLocalDate: $toLocalDate, ')
          ..write('replacementInstanceId: $replacementInstanceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutInstanceId,
    changeType,
    fromLocalDate,
    toLocalDate,
    replacementInstanceId,
    createdAt,
    ownerId,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCalendarChangeRow &&
          other.id == this.id &&
          other.workoutInstanceId == this.workoutInstanceId &&
          other.changeType == this.changeType &&
          other.fromLocalDate == this.fromLocalDate &&
          other.toLocalDate == this.toLocalDate &&
          other.replacementInstanceId == this.replacementInstanceId &&
          other.createdAt == this.createdAt &&
          other.ownerId == this.ownerId &&
          other.syncState == this.syncState);
}

class LocalCalendarChangesCompanion
    extends UpdateCompanion<LocalCalendarChangeRow> {
  final Value<String> id;
  final Value<String> workoutInstanceId;
  final Value<String> changeType;
  final Value<String?> fromLocalDate;
  final Value<String?> toLocalDate;
  final Value<String?> replacementInstanceId;
  final Value<int> createdAt;
  final Value<String> ownerId;
  final Value<String> syncState;
  final Value<int> rowid;
  const LocalCalendarChangesCompanion({
    this.id = const Value.absent(),
    this.workoutInstanceId = const Value.absent(),
    this.changeType = const Value.absent(),
    this.fromLocalDate = const Value.absent(),
    this.toLocalDate = const Value.absent(),
    this.replacementInstanceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCalendarChangesCompanion.insert({
    required String id,
    required String workoutInstanceId,
    required String changeType,
    this.fromLocalDate = const Value.absent(),
    this.toLocalDate = const Value.absent(),
    this.replacementInstanceId = const Value.absent(),
    required int createdAt,
    this.ownerId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workoutInstanceId = Value(workoutInstanceId),
       changeType = Value(changeType),
       createdAt = Value(createdAt);
  static Insertable<LocalCalendarChangeRow> custom({
    Expression<String>? id,
    Expression<String>? workoutInstanceId,
    Expression<String>? changeType,
    Expression<String>? fromLocalDate,
    Expression<String>? toLocalDate,
    Expression<String>? replacementInstanceId,
    Expression<int>? createdAt,
    Expression<String>? ownerId,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutInstanceId != null) 'workout_instance_id': workoutInstanceId,
      if (changeType != null) 'change_type': changeType,
      if (fromLocalDate != null) 'from_local_date': fromLocalDate,
      if (toLocalDate != null) 'to_local_date': toLocalDate,
      if (replacementInstanceId != null)
        'replacement_instance_id': replacementInstanceId,
      if (createdAt != null) 'created_at': createdAt,
      if (ownerId != null) 'owner_id': ownerId,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCalendarChangesCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutInstanceId,
    Value<String>? changeType,
    Value<String?>? fromLocalDate,
    Value<String?>? toLocalDate,
    Value<String?>? replacementInstanceId,
    Value<int>? createdAt,
    Value<String>? ownerId,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return LocalCalendarChangesCompanion(
      id: id ?? this.id,
      workoutInstanceId: workoutInstanceId ?? this.workoutInstanceId,
      changeType: changeType ?? this.changeType,
      fromLocalDate: fromLocalDate ?? this.fromLocalDate,
      toLocalDate: toLocalDate ?? this.toLocalDate,
      replacementInstanceId:
          replacementInstanceId ?? this.replacementInstanceId,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutInstanceId.present) {
      map['workout_instance_id'] = Variable<String>(workoutInstanceId.value);
    }
    if (changeType.present) {
      map['change_type'] = Variable<String>(changeType.value);
    }
    if (fromLocalDate.present) {
      map['from_local_date'] = Variable<String>(fromLocalDate.value);
    }
    if (toLocalDate.present) {
      map['to_local_date'] = Variable<String>(toLocalDate.value);
    }
    if (replacementInstanceId.present) {
      map['replacement_instance_id'] = Variable<String>(
        replacementInstanceId.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCalendarChangesCompanion(')
          ..write('id: $id, ')
          ..write('workoutInstanceId: $workoutInstanceId, ')
          ..write('changeType: $changeType, ')
          ..write('fromLocalDate: $fromLocalDate, ')
          ..write('toLocalDate: $toLocalDate, ')
          ..write('replacementInstanceId: $replacementInstanceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('ownerId: $ownerId, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalWorkoutInstancesTable localWorkoutInstances =
      $LocalWorkoutInstancesTable(this);
  late final $LocalWorkoutSectionsTable localWorkoutSections =
      $LocalWorkoutSectionsTable(this);
  late final $LocalWorkoutStepsTable localWorkoutSteps =
      $LocalWorkoutStepsTable(this);
  late final $LocalSetPlansTable localSetPlans = $LocalSetPlansTable(this);
  late final $LocalWorkoutSessionsTable localWorkoutSessions =
      $LocalWorkoutSessionsTable(this);
  late final $LocalStepPerformancesTable localStepPerformances =
      $LocalStepPerformancesTable(this);
  late final $LocalSetPerformancesTable localSetPerformances =
      $LocalSetPerformancesTable(this);
  late final $LocalWorkoutFeedbackTable localWorkoutFeedback =
      $LocalWorkoutFeedbackTable(this);
  late final $LocalActivitySummariesTable localActivitySummaries =
      $LocalActivitySummariesTable(this);
  late final $LocalAppStateTable localAppState = $LocalAppStateTable(this);
  late final $LocalOutboxTable localOutbox = $LocalOutboxTable(this);
  late final $LocalSyncedVersionsTable localSyncedVersions =
      $LocalSyncedVersionsTable(this);
  late final $LocalSyncResolutionsTable localSyncResolutions =
      $LocalSyncResolutionsTable(this);
  late final $LocalUserSportsTable localUserSports = $LocalUserSportsTable(
    this,
  );
  late final $LocalGoalsTable localGoals = $LocalGoalsTable(this);
  late final $LocalAvailabilityRulesTable localAvailabilityRules =
      $LocalAvailabilityRulesTable(this);
  late final $LocalEquipmentItemsTable localEquipmentItems =
      $LocalEquipmentItemsTable(this);
  late final $LocalConstraintsTable localConstraints = $LocalConstraintsTable(
    this,
  );
  late final $LocalTrainingPlansTable localTrainingPlans =
      $LocalTrainingPlansTable(this);
  late final $LocalCalendarChangesTable localCalendarChanges =
      $LocalCalendarChangesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localWorkoutInstances,
    localWorkoutSections,
    localWorkoutSteps,
    localSetPlans,
    localWorkoutSessions,
    localStepPerformances,
    localSetPerformances,
    localWorkoutFeedback,
    localActivitySummaries,
    localAppState,
    localOutbox,
    localSyncedVersions,
    localSyncResolutions,
    localUserSports,
    localGoals,
    localAvailabilityRules,
    localEquipmentItems,
    localConstraints,
    localTrainingPlans,
    localCalendarChanges,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_workout_instances',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('local_workout_sections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_workout_sections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('local_workout_steps', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_workout_steps',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('local_set_plans', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_workout_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('local_step_performances', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_step_performances',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('local_set_performances', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_workout_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('local_workout_feedback', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$LocalWorkoutInstancesTableCreateCompanionBuilder =
    LocalWorkoutInstancesCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      Value<String?> purpose,
      required String workoutType,
      required String scheduledLocalDate,
      Value<int?> scheduledStartAt,
      Value<String?> timeZoneId,
      Value<int?> plannedDurationSeconds,
      required String status,
      required String sourceType,
      Value<String?> sourceReference,
      required int revisionNumber,
      Value<String?> startedSessionId,
      Value<int?> completedAt,
      required int createdAt,
      required int updatedAt,
      required int rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$LocalWorkoutInstancesTableUpdateCompanionBuilder =
    LocalWorkoutInstancesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<String?> purpose,
      Value<String> workoutType,
      Value<String> scheduledLocalDate,
      Value<int?> scheduledStartAt,
      Value<String?> timeZoneId,
      Value<int?> plannedDurationSeconds,
      Value<String> status,
      Value<String> sourceType,
      Value<String?> sourceReference,
      Value<int> revisionNumber,
      Value<String?> startedSessionId,
      Value<int?> completedAt,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });

final class $$LocalWorkoutInstancesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalWorkoutInstancesTable,
          LocalWorkoutInstanceRow
        > {
  $$LocalWorkoutInstancesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $LocalWorkoutSectionsTable,
    List<LocalWorkoutSectionRow>
  >
  _localWorkoutSectionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.localWorkoutSections,
    aliasName:
        'local_workout_instances__id__local_workout_sections__workout_instance_id',
  );

  $$LocalWorkoutSectionsTableProcessedTableManager
  get localWorkoutSectionsRefs {
    final manager =
        $$LocalWorkoutSectionsTableTableManager(
          $_db,
          $_db.localWorkoutSections,
        ).filter(
          (f) => f.workoutInstanceId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _localWorkoutSectionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $LocalWorkoutSessionsTable,
    List<LocalWorkoutSessionRow>
  >
  _localWorkoutSessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.localWorkoutSessions,
    aliasName:
        'local_workout_instances__id__local_workout_sessions__workout_instance_id',
  );

  $$LocalWorkoutSessionsTableProcessedTableManager
  get localWorkoutSessionsRefs {
    final manager =
        $$LocalWorkoutSessionsTableTableManager(
          $_db,
          $_db.localWorkoutSessions,
        ).filter(
          (f) => f.workoutInstanceId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _localWorkoutSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $LocalActivitySummariesTable,
    List<LocalActivitySummaryRow>
  >
  _localActivitySummariesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.localActivitySummaries,
    aliasName:
        'local_workout_instances__id__local_activity_summaries__workout_instance_id',
  );

  $$LocalActivitySummariesTableProcessedTableManager
  get localActivitySummariesRefs {
    final manager =
        $$LocalActivitySummariesTableTableManager(
          $_db,
          $_db.localActivitySummaries,
        ).filter(
          (f) => f.workoutInstanceId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _localActivitySummariesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalWorkoutInstancesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalWorkoutInstancesTable> {
  $$LocalWorkoutInstancesTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workoutType => $composableBuilder(
    column: $table.workoutType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduledLocalDate => $composableBuilder(
    column: $table.scheduledLocalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledStartAt => $composableBuilder(
    column: $table.scheduledStartAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceReference => $composableBuilder(
    column: $table.sourceReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revisionNumber => $composableBuilder(
    column: $table.revisionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedSessionId => $composableBuilder(
    column: $table.startedSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localWorkoutSectionsRefs(
    Expression<bool> Function($$LocalWorkoutSectionsTableFilterComposer f) f,
  ) {
    final $$LocalWorkoutSectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localWorkoutSections,
      getReferencedColumn: (t) => t.workoutInstanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalWorkoutSectionsTableFilterComposer(
            $db: $db,
            $table: $db.localWorkoutSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> localWorkoutSessionsRefs(
    Expression<bool> Function($$LocalWorkoutSessionsTableFilterComposer f) f,
  ) {
    final $$LocalWorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localWorkoutSessions,
      getReferencedColumn: (t) => t.workoutInstanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalWorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.localWorkoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> localActivitySummariesRefs(
    Expression<bool> Function($$LocalActivitySummariesTableFilterComposer f) f,
  ) {
    final $$LocalActivitySummariesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localActivitySummaries,
          getReferencedColumn: (t) => t.workoutInstanceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalActivitySummariesTableFilterComposer(
                $db: $db,
                $table: $db.localActivitySummaries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalWorkoutInstancesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalWorkoutInstancesTable> {
  $$LocalWorkoutInstancesTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workoutType => $composableBuilder(
    column: $table.workoutType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduledLocalDate => $composableBuilder(
    column: $table.scheduledLocalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledStartAt => $composableBuilder(
    column: $table.scheduledStartAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceReference => $composableBuilder(
    column: $table.sourceReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revisionNumber => $composableBuilder(
    column: $table.revisionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedSessionId => $composableBuilder(
    column: $table.startedSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalWorkoutInstancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalWorkoutInstancesTable> {
  $$LocalWorkoutInstancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get workoutType => $composableBuilder(
    column: $table.workoutType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduledLocalDate => $composableBuilder(
    column: $table.scheduledLocalDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledStartAt => $composableBuilder(
    column: $table.scheduledStartAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeZoneId => $composableBuilder(
    column: $table.timeZoneId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceReference => $composableBuilder(
    column: $table.sourceReference,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revisionNumber => $composableBuilder(
    column: $table.revisionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startedSessionId => $composableBuilder(
    column: $table.startedSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  Expression<T> localWorkoutSectionsRefs<T extends Object>(
    Expression<T> Function($$LocalWorkoutSectionsTableAnnotationComposer a) f,
  ) {
    final $$LocalWorkoutSectionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localWorkoutSections,
          getReferencedColumn: (t) => t.workoutInstanceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutSectionsTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutSections,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> localWorkoutSessionsRefs<T extends Object>(
    Expression<T> Function($$LocalWorkoutSessionsTableAnnotationComposer a) f,
  ) {
    final $$LocalWorkoutSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localWorkoutSessions,
          getReferencedColumn: (t) => t.workoutInstanceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> localActivitySummariesRefs<T extends Object>(
    Expression<T> Function($$LocalActivitySummariesTableAnnotationComposer a) f,
  ) {
    final $$LocalActivitySummariesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localActivitySummaries,
          getReferencedColumn: (t) => t.workoutInstanceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalActivitySummariesTableAnnotationComposer(
                $db: $db,
                $table: $db.localActivitySummaries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalWorkoutInstancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalWorkoutInstancesTable,
          LocalWorkoutInstanceRow,
          $$LocalWorkoutInstancesTableFilterComposer,
          $$LocalWorkoutInstancesTableOrderingComposer,
          $$LocalWorkoutInstancesTableAnnotationComposer,
          $$LocalWorkoutInstancesTableCreateCompanionBuilder,
          $$LocalWorkoutInstancesTableUpdateCompanionBuilder,
          (LocalWorkoutInstanceRow, $$LocalWorkoutInstancesTableReferences),
          LocalWorkoutInstanceRow,
          PrefetchHooks Function({
            bool localWorkoutSectionsRefs,
            bool localWorkoutSessionsRefs,
            bool localActivitySummariesRefs,
          })
        > {
  $$LocalWorkoutInstancesTableTableManager(
    _$AppDatabase db,
    $LocalWorkoutInstancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalWorkoutInstancesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalWorkoutInstancesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalWorkoutInstancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                Value<String> workoutType = const Value.absent(),
                Value<String> scheduledLocalDate = const Value.absent(),
                Value<int?> scheduledStartAt = const Value.absent(),
                Value<String?> timeZoneId = const Value.absent(),
                Value<int?> plannedDurationSeconds = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String?> sourceReference = const Value.absent(),
                Value<int> revisionNumber = const Value.absent(),
                Value<String?> startedSessionId = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowVersion = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWorkoutInstancesCompanion(
                id: id,
                title: title,
                description: description,
                purpose: purpose,
                workoutType: workoutType,
                scheduledLocalDate: scheduledLocalDate,
                scheduledStartAt: scheduledStartAt,
                timeZoneId: timeZoneId,
                plannedDurationSeconds: plannedDurationSeconds,
                status: status,
                sourceType: sourceType,
                sourceReference: sourceReference,
                revisionNumber: revisionNumber,
                startedSessionId: startedSessionId,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                required String workoutType,
                required String scheduledLocalDate,
                Value<int?> scheduledStartAt = const Value.absent(),
                Value<String?> timeZoneId = const Value.absent(),
                Value<int?> plannedDurationSeconds = const Value.absent(),
                required String status,
                required String sourceType,
                Value<String?> sourceReference = const Value.absent(),
                required int revisionNumber,
                Value<String?> startedSessionId = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required int rowVersion,
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWorkoutInstancesCompanion.insert(
                id: id,
                title: title,
                description: description,
                purpose: purpose,
                workoutType: workoutType,
                scheduledLocalDate: scheduledLocalDate,
                scheduledStartAt: scheduledStartAt,
                timeZoneId: timeZoneId,
                plannedDurationSeconds: plannedDurationSeconds,
                status: status,
                sourceType: sourceType,
                sourceReference: sourceReference,
                revisionNumber: revisionNumber,
                startedSessionId: startedSessionId,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalWorkoutInstancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                localWorkoutSectionsRefs = false,
                localWorkoutSessionsRefs = false,
                localActivitySummariesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (localWorkoutSectionsRefs) db.localWorkoutSections,
                    if (localWorkoutSessionsRefs) db.localWorkoutSessions,
                    if (localActivitySummariesRefs) db.localActivitySummaries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (localWorkoutSectionsRefs)
                        await $_getPrefetchedData<
                          LocalWorkoutInstanceRow,
                          $LocalWorkoutInstancesTable,
                          LocalWorkoutSectionRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$LocalWorkoutInstancesTableReferences
                                  ._localWorkoutSectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalWorkoutInstancesTableReferences(
                                db,
                                table,
                                p0,
                              ).localWorkoutSectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutInstanceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (localWorkoutSessionsRefs)
                        await $_getPrefetchedData<
                          LocalWorkoutInstanceRow,
                          $LocalWorkoutInstancesTable,
                          LocalWorkoutSessionRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$LocalWorkoutInstancesTableReferences
                                  ._localWorkoutSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalWorkoutInstancesTableReferences(
                                db,
                                table,
                                p0,
                              ).localWorkoutSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutInstanceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (localActivitySummariesRefs)
                        await $_getPrefetchedData<
                          LocalWorkoutInstanceRow,
                          $LocalWorkoutInstancesTable,
                          LocalActivitySummaryRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$LocalWorkoutInstancesTableReferences
                                  ._localActivitySummariesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalWorkoutInstancesTableReferences(
                                db,
                                table,
                                p0,
                              ).localActivitySummariesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutInstanceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LocalWorkoutInstancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalWorkoutInstancesTable,
      LocalWorkoutInstanceRow,
      $$LocalWorkoutInstancesTableFilterComposer,
      $$LocalWorkoutInstancesTableOrderingComposer,
      $$LocalWorkoutInstancesTableAnnotationComposer,
      $$LocalWorkoutInstancesTableCreateCompanionBuilder,
      $$LocalWorkoutInstancesTableUpdateCompanionBuilder,
      (LocalWorkoutInstanceRow, $$LocalWorkoutInstancesTableReferences),
      LocalWorkoutInstanceRow,
      PrefetchHooks Function({
        bool localWorkoutSectionsRefs,
        bool localWorkoutSessionsRefs,
        bool localActivitySummariesRefs,
      })
    >;
typedef $$LocalWorkoutSectionsTableCreateCompanionBuilder =
    LocalWorkoutSectionsCompanion Function({
      required String id,
      required String workoutInstanceId,
      required int position,
      required String title,
      required String sectionType,
      Value<String?> purpose,
      required String priority,
      required bool isOptional,
      Value<int?> plannedDurationSeconds,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$LocalWorkoutSectionsTableUpdateCompanionBuilder =
    LocalWorkoutSectionsCompanion Function({
      Value<String> id,
      Value<String> workoutInstanceId,
      Value<int> position,
      Value<String> title,
      Value<String> sectionType,
      Value<String?> purpose,
      Value<String> priority,
      Value<bool> isOptional,
      Value<int?> plannedDurationSeconds,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$LocalWorkoutSectionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalWorkoutSectionsTable,
          LocalWorkoutSectionRow
        > {
  $$LocalWorkoutSectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalWorkoutInstancesTable _workoutInstanceIdTable(
    _$AppDatabase db,
  ) => db.localWorkoutInstances.createAlias(
    'local_workout_sections__workout_instance_id__local_workout_instances__id',
  );

  $$LocalWorkoutInstancesTableProcessedTableManager get workoutInstanceId {
    final $_column = $_itemColumn<String>('workout_instance_id')!;

    final manager = $$LocalWorkoutInstancesTableTableManager(
      $_db,
      $_db.localWorkoutInstances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutInstanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LocalWorkoutStepsTable, List<LocalWorkoutStepRow>>
  _localWorkoutStepsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.localWorkoutSteps,
        aliasName:
            'local_workout_sections__id__local_workout_steps__section_id',
      );

  $$LocalWorkoutStepsTableProcessedTableManager get localWorkoutStepsRefs {
    final manager = $$LocalWorkoutStepsTableTableManager(
      $_db,
      $_db.localWorkoutSteps,
    ).filter((f) => f.sectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _localWorkoutStepsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalWorkoutSectionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalWorkoutSectionsTable> {
  $$LocalWorkoutSectionsTableFilterComposer({
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionType => $composableBuilder(
    column: $table.sectionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalWorkoutInstancesTableFilterComposer get workoutInstanceId {
    final $$LocalWorkoutInstancesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutInstanceId,
          referencedTable: $db.localWorkoutInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutInstancesTableFilterComposer(
                $db: $db,
                $table: $db.localWorkoutInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> localWorkoutStepsRefs(
    Expression<bool> Function($$LocalWorkoutStepsTableFilterComposer f) f,
  ) {
    final $$LocalWorkoutStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localWorkoutSteps,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalWorkoutStepsTableFilterComposer(
            $db: $db,
            $table: $db.localWorkoutSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalWorkoutSectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalWorkoutSectionsTable> {
  $$LocalWorkoutSectionsTableOrderingComposer({
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionType => $composableBuilder(
    column: $table.sectionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalWorkoutInstancesTableOrderingComposer get workoutInstanceId {
    final $$LocalWorkoutInstancesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutInstanceId,
          referencedTable: $db.localWorkoutInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutInstancesTableOrderingComposer(
                $db: $db,
                $table: $db.localWorkoutInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalWorkoutSectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalWorkoutSectionsTable> {
  $$LocalWorkoutSectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get sectionType => $composableBuilder(
    column: $table.sectionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LocalWorkoutInstancesTableAnnotationComposer get workoutInstanceId {
    final $$LocalWorkoutInstancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutInstanceId,
          referencedTable: $db.localWorkoutInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutInstancesTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> localWorkoutStepsRefs<T extends Object>(
    Expression<T> Function($$LocalWorkoutStepsTableAnnotationComposer a) f,
  ) {
    final $$LocalWorkoutStepsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localWorkoutSteps,
          getReferencedColumn: (t) => t.sectionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutStepsTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutSteps,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalWorkoutSectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalWorkoutSectionsTable,
          LocalWorkoutSectionRow,
          $$LocalWorkoutSectionsTableFilterComposer,
          $$LocalWorkoutSectionsTableOrderingComposer,
          $$LocalWorkoutSectionsTableAnnotationComposer,
          $$LocalWorkoutSectionsTableCreateCompanionBuilder,
          $$LocalWorkoutSectionsTableUpdateCompanionBuilder,
          (LocalWorkoutSectionRow, $$LocalWorkoutSectionsTableReferences),
          LocalWorkoutSectionRow,
          PrefetchHooks Function({
            bool workoutInstanceId,
            bool localWorkoutStepsRefs,
          })
        > {
  $$LocalWorkoutSectionsTableTableManager(
    _$AppDatabase db,
    $LocalWorkoutSectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalWorkoutSectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalWorkoutSectionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalWorkoutSectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutInstanceId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> sectionType = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<bool> isOptional = const Value.absent(),
                Value<int?> plannedDurationSeconds = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWorkoutSectionsCompanion(
                id: id,
                workoutInstanceId: workoutInstanceId,
                position: position,
                title: title,
                sectionType: sectionType,
                purpose: purpose,
                priority: priority,
                isOptional: isOptional,
                plannedDurationSeconds: plannedDurationSeconds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workoutInstanceId,
                required int position,
                required String title,
                required String sectionType,
                Value<String?> purpose = const Value.absent(),
                required String priority,
                required bool isOptional,
                Value<int?> plannedDurationSeconds = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalWorkoutSectionsCompanion.insert(
                id: id,
                workoutInstanceId: workoutInstanceId,
                position: position,
                title: title,
                sectionType: sectionType,
                purpose: purpose,
                priority: priority,
                isOptional: isOptional,
                plannedDurationSeconds: plannedDurationSeconds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalWorkoutSectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutInstanceId = false, localWorkoutStepsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (localWorkoutStepsRefs) db.localWorkoutSteps,
                  ],
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
                        if (workoutInstanceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutInstanceId,
                                    referencedTable:
                                        $$LocalWorkoutSectionsTableReferences
                                            ._workoutInstanceIdTable(db),
                                    referencedColumn:
                                        $$LocalWorkoutSectionsTableReferences
                                            ._workoutInstanceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (localWorkoutStepsRefs)
                        await $_getPrefetchedData<
                          LocalWorkoutSectionRow,
                          $LocalWorkoutSectionsTable,
                          LocalWorkoutStepRow
                        >(
                          currentTable: table,
                          referencedTable: $$LocalWorkoutSectionsTableReferences
                              ._localWorkoutStepsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalWorkoutSectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).localWorkoutStepsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LocalWorkoutSectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalWorkoutSectionsTable,
      LocalWorkoutSectionRow,
      $$LocalWorkoutSectionsTableFilterComposer,
      $$LocalWorkoutSectionsTableOrderingComposer,
      $$LocalWorkoutSectionsTableAnnotationComposer,
      $$LocalWorkoutSectionsTableCreateCompanionBuilder,
      $$LocalWorkoutSectionsTableUpdateCompanionBuilder,
      (LocalWorkoutSectionRow, $$LocalWorkoutSectionsTableReferences),
      LocalWorkoutSectionRow,
      PrefetchHooks Function({
        bool workoutInstanceId,
        bool localWorkoutStepsRefs,
      })
    >;
typedef $$LocalWorkoutStepsTableCreateCompanionBuilder =
    LocalWorkoutStepsCompanion Function({
      required String id,
      required String sectionId,
      Value<String?> parentStepId,
      required int position,
      required String stepType,
      required String title,
      Value<String?> instructions,
      Value<String?> purpose,
      required String priority,
      required bool isSkippable,
      required String prescriptionType,
      Value<int?> plannedDurationSeconds,
      Value<double?> plannedDistanceMeters,
      Value<int?> plannedRepetitions,
      Value<double?> plannedWeightKg,
      Value<String?> metadataJson,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$LocalWorkoutStepsTableUpdateCompanionBuilder =
    LocalWorkoutStepsCompanion Function({
      Value<String> id,
      Value<String> sectionId,
      Value<String?> parentStepId,
      Value<int> position,
      Value<String> stepType,
      Value<String> title,
      Value<String?> instructions,
      Value<String?> purpose,
      Value<String> priority,
      Value<bool> isSkippable,
      Value<String> prescriptionType,
      Value<int?> plannedDurationSeconds,
      Value<double?> plannedDistanceMeters,
      Value<int?> plannedRepetitions,
      Value<double?> plannedWeightKg,
      Value<String?> metadataJson,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$LocalWorkoutStepsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalWorkoutStepsTable,
          LocalWorkoutStepRow
        > {
  $$LocalWorkoutStepsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalWorkoutSectionsTable _sectionIdTable(_$AppDatabase db) =>
      db.localWorkoutSections.createAlias(
        'local_workout_steps__section_id__local_workout_sections__id',
      );

  $$LocalWorkoutSectionsTableProcessedTableManager get sectionId {
    final $_column = $_itemColumn<String>('section_id')!;

    final manager = $$LocalWorkoutSectionsTableTableManager(
      $_db,
      $_db.localWorkoutSections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LocalWorkoutStepsTable _parentStepIdTable(_$AppDatabase db) =>
      db.localWorkoutSteps.createAlias(
        'local_workout_steps__parent_step_id__local_workout_steps__id',
      );

  $$LocalWorkoutStepsTableProcessedTableManager? get parentStepId {
    final $_column = $_itemColumn<String>('parent_step_id');
    if ($_column == null) return null;
    final manager = $$LocalWorkoutStepsTableTableManager(
      $_db,
      $_db.localWorkoutSteps,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentStepIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LocalSetPlansTable, List<LocalSetPlanRow>>
  _localSetPlansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.localSetPlans,
    aliasName: 'local_workout_steps__id__local_set_plans__workout_step_id',
  );

  $$LocalSetPlansTableProcessedTableManager get localSetPlansRefs {
    final manager = $$LocalSetPlansTableTableManager(
      $_db,
      $_db.localSetPlans,
    ).filter((f) => f.workoutStepId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localSetPlansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $LocalStepPerformancesTable,
    List<LocalStepPerformanceRow>
  >
  _localStepPerformancesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.localStepPerformances,
        aliasName:
            'local_workout_steps__id__local_step_performances__workout_step_id',
      );

  $$LocalStepPerformancesTableProcessedTableManager
  get localStepPerformancesRefs {
    final manager = $$LocalStepPerformancesTableTableManager(
      $_db,
      $_db.localStepPerformances,
    ).filter((f) => f.workoutStepId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _localStepPerformancesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalWorkoutStepsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalWorkoutStepsTable> {
  $$LocalWorkoutStepsTableFilterComposer({
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepType => $composableBuilder(
    column: $table.stepType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSkippable => $composableBuilder(
    column: $table.isSkippable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prescriptionType => $composableBuilder(
    column: $table.prescriptionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedDistanceMeters => $composableBuilder(
    column: $table.plannedDistanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedRepetitions => $composableBuilder(
    column: $table.plannedRepetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalWorkoutSectionsTableFilterComposer get sectionId {
    final $$LocalWorkoutSectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.localWorkoutSections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalWorkoutSectionsTableFilterComposer(
            $db: $db,
            $table: $db.localWorkoutSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocalWorkoutStepsTableFilterComposer get parentStepId {
    final $$LocalWorkoutStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentStepId,
      referencedTable: $db.localWorkoutSteps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalWorkoutStepsTableFilterComposer(
            $db: $db,
            $table: $db.localWorkoutSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> localSetPlansRefs(
    Expression<bool> Function($$LocalSetPlansTableFilterComposer f) f,
  ) {
    final $$LocalSetPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localSetPlans,
      getReferencedColumn: (t) => t.workoutStepId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSetPlansTableFilterComposer(
            $db: $db,
            $table: $db.localSetPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> localStepPerformancesRefs(
    Expression<bool> Function($$LocalStepPerformancesTableFilterComposer f) f,
  ) {
    final $$LocalStepPerformancesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localStepPerformances,
          getReferencedColumn: (t) => t.workoutStepId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalStepPerformancesTableFilterComposer(
                $db: $db,
                $table: $db.localStepPerformances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalWorkoutStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalWorkoutStepsTable> {
  $$LocalWorkoutStepsTableOrderingComposer({
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepType => $composableBuilder(
    column: $table.stepType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSkippable => $composableBuilder(
    column: $table.isSkippable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prescriptionType => $composableBuilder(
    column: $table.prescriptionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedDistanceMeters => $composableBuilder(
    column: $table.plannedDistanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedRepetitions => $composableBuilder(
    column: $table.plannedRepetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalWorkoutSectionsTableOrderingComposer get sectionId {
    final $$LocalWorkoutSectionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sectionId,
          referencedTable: $db.localWorkoutSections,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutSectionsTableOrderingComposer(
                $db: $db,
                $table: $db.localWorkoutSections,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$LocalWorkoutStepsTableOrderingComposer get parentStepId {
    final $$LocalWorkoutStepsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentStepId,
      referencedTable: $db.localWorkoutSteps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalWorkoutStepsTableOrderingComposer(
            $db: $db,
            $table: $db.localWorkoutSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalWorkoutStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalWorkoutStepsTable> {
  $$LocalWorkoutStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get stepType =>
      $composableBuilder(column: $table.stepType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get isSkippable => $composableBuilder(
    column: $table.isSkippable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prescriptionType => $composableBuilder(
    column: $table.prescriptionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get plannedDistanceMeters => $composableBuilder(
    column: $table.plannedDistanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedRepetitions => $composableBuilder(
    column: $table.plannedRepetitions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LocalWorkoutSectionsTableAnnotationComposer get sectionId {
    final $$LocalWorkoutSectionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sectionId,
          referencedTable: $db.localWorkoutSections,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutSectionsTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutSections,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$LocalWorkoutStepsTableAnnotationComposer get parentStepId {
    final $$LocalWorkoutStepsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.parentStepId,
          referencedTable: $db.localWorkoutSteps,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutStepsTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutSteps,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> localSetPlansRefs<T extends Object>(
    Expression<T> Function($$LocalSetPlansTableAnnotationComposer a) f,
  ) {
    final $$LocalSetPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localSetPlans,
      getReferencedColumn: (t) => t.workoutStepId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSetPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.localSetPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> localStepPerformancesRefs<T extends Object>(
    Expression<T> Function($$LocalStepPerformancesTableAnnotationComposer a) f,
  ) {
    final $$LocalStepPerformancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localStepPerformances,
          getReferencedColumn: (t) => t.workoutStepId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalStepPerformancesTableAnnotationComposer(
                $db: $db,
                $table: $db.localStepPerformances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalWorkoutStepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalWorkoutStepsTable,
          LocalWorkoutStepRow,
          $$LocalWorkoutStepsTableFilterComposer,
          $$LocalWorkoutStepsTableOrderingComposer,
          $$LocalWorkoutStepsTableAnnotationComposer,
          $$LocalWorkoutStepsTableCreateCompanionBuilder,
          $$LocalWorkoutStepsTableUpdateCompanionBuilder,
          (LocalWorkoutStepRow, $$LocalWorkoutStepsTableReferences),
          LocalWorkoutStepRow,
          PrefetchHooks Function({
            bool sectionId,
            bool parentStepId,
            bool localSetPlansRefs,
            bool localStepPerformancesRefs,
          })
        > {
  $$LocalWorkoutStepsTableTableManager(
    _$AppDatabase db,
    $LocalWorkoutStepsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalWorkoutStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalWorkoutStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalWorkoutStepsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<String?> parentStepId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> stepType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> instructions = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<bool> isSkippable = const Value.absent(),
                Value<String> prescriptionType = const Value.absent(),
                Value<int?> plannedDurationSeconds = const Value.absent(),
                Value<double?> plannedDistanceMeters = const Value.absent(),
                Value<int?> plannedRepetitions = const Value.absent(),
                Value<double?> plannedWeightKg = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWorkoutStepsCompanion(
                id: id,
                sectionId: sectionId,
                parentStepId: parentStepId,
                position: position,
                stepType: stepType,
                title: title,
                instructions: instructions,
                purpose: purpose,
                priority: priority,
                isSkippable: isSkippable,
                prescriptionType: prescriptionType,
                plannedDurationSeconds: plannedDurationSeconds,
                plannedDistanceMeters: plannedDistanceMeters,
                plannedRepetitions: plannedRepetitions,
                plannedWeightKg: plannedWeightKg,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sectionId,
                Value<String?> parentStepId = const Value.absent(),
                required int position,
                required String stepType,
                required String title,
                Value<String?> instructions = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                required String priority,
                required bool isSkippable,
                required String prescriptionType,
                Value<int?> plannedDurationSeconds = const Value.absent(),
                Value<double?> plannedDistanceMeters = const Value.absent(),
                Value<int?> plannedRepetitions = const Value.absent(),
                Value<double?> plannedWeightKg = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalWorkoutStepsCompanion.insert(
                id: id,
                sectionId: sectionId,
                parentStepId: parentStepId,
                position: position,
                stepType: stepType,
                title: title,
                instructions: instructions,
                purpose: purpose,
                priority: priority,
                isSkippable: isSkippable,
                prescriptionType: prescriptionType,
                plannedDurationSeconds: plannedDurationSeconds,
                plannedDistanceMeters: plannedDistanceMeters,
                plannedRepetitions: plannedRepetitions,
                plannedWeightKg: plannedWeightKg,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalWorkoutStepsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sectionId = false,
                parentStepId = false,
                localSetPlansRefs = false,
                localStepPerformancesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (localSetPlansRefs) db.localSetPlans,
                    if (localStepPerformancesRefs) db.localStepPerformances,
                  ],
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
                        if (sectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sectionId,
                                    referencedTable:
                                        $$LocalWorkoutStepsTableReferences
                                            ._sectionIdTable(db),
                                    referencedColumn:
                                        $$LocalWorkoutStepsTableReferences
                                            ._sectionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (parentStepId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentStepId,
                                    referencedTable:
                                        $$LocalWorkoutStepsTableReferences
                                            ._parentStepIdTable(db),
                                    referencedColumn:
                                        $$LocalWorkoutStepsTableReferences
                                            ._parentStepIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (localSetPlansRefs)
                        await $_getPrefetchedData<
                          LocalWorkoutStepRow,
                          $LocalWorkoutStepsTable,
                          LocalSetPlanRow
                        >(
                          currentTable: table,
                          referencedTable: $$LocalWorkoutStepsTableReferences
                              ._localSetPlansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalWorkoutStepsTableReferences(
                                db,
                                table,
                                p0,
                              ).localSetPlansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutStepId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (localStepPerformancesRefs)
                        await $_getPrefetchedData<
                          LocalWorkoutStepRow,
                          $LocalWorkoutStepsTable,
                          LocalStepPerformanceRow
                        >(
                          currentTable: table,
                          referencedTable: $$LocalWorkoutStepsTableReferences
                              ._localStepPerformancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalWorkoutStepsTableReferences(
                                db,
                                table,
                                p0,
                              ).localStepPerformancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutStepId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LocalWorkoutStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalWorkoutStepsTable,
      LocalWorkoutStepRow,
      $$LocalWorkoutStepsTableFilterComposer,
      $$LocalWorkoutStepsTableOrderingComposer,
      $$LocalWorkoutStepsTableAnnotationComposer,
      $$LocalWorkoutStepsTableCreateCompanionBuilder,
      $$LocalWorkoutStepsTableUpdateCompanionBuilder,
      (LocalWorkoutStepRow, $$LocalWorkoutStepsTableReferences),
      LocalWorkoutStepRow,
      PrefetchHooks Function({
        bool sectionId,
        bool parentStepId,
        bool localSetPlansRefs,
        bool localStepPerformancesRefs,
      })
    >;
typedef $$LocalSetPlansTableCreateCompanionBuilder =
    LocalSetPlansCompanion Function({
      required String id,
      required String workoutStepId,
      required int position,
      Value<int?> plannedRepetitions,
      Value<int?> minimumRepetitions,
      Value<int?> maximumRepetitions,
      Value<double?> plannedWeightKg,
      Value<int?> plannedDurationSeconds,
      Value<int?> restAfterSeconds,
      Value<double?> targetRpe,
      Value<int> rowid,
    });
typedef $$LocalSetPlansTableUpdateCompanionBuilder =
    LocalSetPlansCompanion Function({
      Value<String> id,
      Value<String> workoutStepId,
      Value<int> position,
      Value<int?> plannedRepetitions,
      Value<int?> minimumRepetitions,
      Value<int?> maximumRepetitions,
      Value<double?> plannedWeightKg,
      Value<int?> plannedDurationSeconds,
      Value<int?> restAfterSeconds,
      Value<double?> targetRpe,
      Value<int> rowid,
    });

final class $$LocalSetPlansTableReferences
    extends
        BaseReferences<_$AppDatabase, $LocalSetPlansTable, LocalSetPlanRow> {
  $$LocalSetPlansTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalWorkoutStepsTable _workoutStepIdTable(_$AppDatabase db) => db
      .localWorkoutSteps
      .createAlias('local_set_plans__workout_step_id__local_workout_steps__id');

  $$LocalWorkoutStepsTableProcessedTableManager get workoutStepId {
    final $_column = $_itemColumn<String>('workout_step_id')!;

    final manager = $$LocalWorkoutStepsTableTableManager(
      $_db,
      $_db.localWorkoutSteps,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutStepIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $LocalSetPerformancesTable,
    List<LocalSetPerformanceRow>
  >
  _localSetPerformancesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.localSetPerformances,
        aliasName: 'local_set_plans__id__local_set_performances__set_plan_id',
      );

  $$LocalSetPerformancesTableProcessedTableManager
  get localSetPerformancesRefs {
    final manager = $$LocalSetPerformancesTableTableManager(
      $_db,
      $_db.localSetPerformances,
    ).filter((f) => f.setPlanId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _localSetPerformancesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalSetPlansTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSetPlansTable> {
  $$LocalSetPlansTableFilterComposer({
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedRepetitions => $composableBuilder(
    column: $table.plannedRepetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minimumRepetitions => $composableBuilder(
    column: $table.minimumRepetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maximumRepetitions => $composableBuilder(
    column: $table.maximumRepetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restAfterSeconds => $composableBuilder(
    column: $table.restAfterSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetRpe => $composableBuilder(
    column: $table.targetRpe,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalWorkoutStepsTableFilterComposer get workoutStepId {
    final $$LocalWorkoutStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutStepId,
      referencedTable: $db.localWorkoutSteps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalWorkoutStepsTableFilterComposer(
            $db: $db,
            $table: $db.localWorkoutSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> localSetPerformancesRefs(
    Expression<bool> Function($$LocalSetPerformancesTableFilterComposer f) f,
  ) {
    final $$LocalSetPerformancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localSetPerformances,
      getReferencedColumn: (t) => t.setPlanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSetPerformancesTableFilterComposer(
            $db: $db,
            $table: $db.localSetPerformances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalSetPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSetPlansTable> {
  $$LocalSetPlansTableOrderingComposer({
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedRepetitions => $composableBuilder(
    column: $table.plannedRepetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimumRepetitions => $composableBuilder(
    column: $table.minimumRepetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maximumRepetitions => $composableBuilder(
    column: $table.maximumRepetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restAfterSeconds => $composableBuilder(
    column: $table.restAfterSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetRpe => $composableBuilder(
    column: $table.targetRpe,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalWorkoutStepsTableOrderingComposer get workoutStepId {
    final $$LocalWorkoutStepsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutStepId,
      referencedTable: $db.localWorkoutSteps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalWorkoutStepsTableOrderingComposer(
            $db: $db,
            $table: $db.localWorkoutSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalSetPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSetPlansTable> {
  $$LocalSetPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get plannedRepetitions => $composableBuilder(
    column: $table.plannedRepetitions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minimumRepetitions => $composableBuilder(
    column: $table.minimumRepetitions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maximumRepetitions => $composableBuilder(
    column: $table.maximumRepetitions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restAfterSeconds => $composableBuilder(
    column: $table.restAfterSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetRpe =>
      $composableBuilder(column: $table.targetRpe, builder: (column) => column);

  $$LocalWorkoutStepsTableAnnotationComposer get workoutStepId {
    final $$LocalWorkoutStepsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutStepId,
          referencedTable: $db.localWorkoutSteps,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutStepsTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutSteps,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> localSetPerformancesRefs<T extends Object>(
    Expression<T> Function($$LocalSetPerformancesTableAnnotationComposer a) f,
  ) {
    final $$LocalSetPerformancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localSetPerformances,
          getReferencedColumn: (t) => t.setPlanId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalSetPerformancesTableAnnotationComposer(
                $db: $db,
                $table: $db.localSetPerformances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalSetPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSetPlansTable,
          LocalSetPlanRow,
          $$LocalSetPlansTableFilterComposer,
          $$LocalSetPlansTableOrderingComposer,
          $$LocalSetPlansTableAnnotationComposer,
          $$LocalSetPlansTableCreateCompanionBuilder,
          $$LocalSetPlansTableUpdateCompanionBuilder,
          (LocalSetPlanRow, $$LocalSetPlansTableReferences),
          LocalSetPlanRow,
          PrefetchHooks Function({
            bool workoutStepId,
            bool localSetPerformancesRefs,
          })
        > {
  $$LocalSetPlansTableTableManager(_$AppDatabase db, $LocalSetPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSetPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSetPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSetPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutStepId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int?> plannedRepetitions = const Value.absent(),
                Value<int?> minimumRepetitions = const Value.absent(),
                Value<int?> maximumRepetitions = const Value.absent(),
                Value<double?> plannedWeightKg = const Value.absent(),
                Value<int?> plannedDurationSeconds = const Value.absent(),
                Value<int?> restAfterSeconds = const Value.absent(),
                Value<double?> targetRpe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSetPlansCompanion(
                id: id,
                workoutStepId: workoutStepId,
                position: position,
                plannedRepetitions: plannedRepetitions,
                minimumRepetitions: minimumRepetitions,
                maximumRepetitions: maximumRepetitions,
                plannedWeightKg: plannedWeightKg,
                plannedDurationSeconds: plannedDurationSeconds,
                restAfterSeconds: restAfterSeconds,
                targetRpe: targetRpe,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workoutStepId,
                required int position,
                Value<int?> plannedRepetitions = const Value.absent(),
                Value<int?> minimumRepetitions = const Value.absent(),
                Value<int?> maximumRepetitions = const Value.absent(),
                Value<double?> plannedWeightKg = const Value.absent(),
                Value<int?> plannedDurationSeconds = const Value.absent(),
                Value<int?> restAfterSeconds = const Value.absent(),
                Value<double?> targetRpe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSetPlansCompanion.insert(
                id: id,
                workoutStepId: workoutStepId,
                position: position,
                plannedRepetitions: plannedRepetitions,
                minimumRepetitions: minimumRepetitions,
                maximumRepetitions: maximumRepetitions,
                plannedWeightKg: plannedWeightKg,
                plannedDurationSeconds: plannedDurationSeconds,
                restAfterSeconds: restAfterSeconds,
                targetRpe: targetRpe,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalSetPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutStepId = false, localSetPerformancesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (localSetPerformancesRefs) db.localSetPerformances,
                  ],
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
                        if (workoutStepId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutStepId,
                                    referencedTable:
                                        $$LocalSetPlansTableReferences
                                            ._workoutStepIdTable(db),
                                    referencedColumn:
                                        $$LocalSetPlansTableReferences
                                            ._workoutStepIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (localSetPerformancesRefs)
                        await $_getPrefetchedData<
                          LocalSetPlanRow,
                          $LocalSetPlansTable,
                          LocalSetPerformanceRow
                        >(
                          currentTable: table,
                          referencedTable: $$LocalSetPlansTableReferences
                              ._localSetPerformancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalSetPlansTableReferences(
                                db,
                                table,
                                p0,
                              ).localSetPerformancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.setPlanId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LocalSetPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSetPlansTable,
      LocalSetPlanRow,
      $$LocalSetPlansTableFilterComposer,
      $$LocalSetPlansTableOrderingComposer,
      $$LocalSetPlansTableAnnotationComposer,
      $$LocalSetPlansTableCreateCompanionBuilder,
      $$LocalSetPlansTableUpdateCompanionBuilder,
      (LocalSetPlanRow, $$LocalSetPlansTableReferences),
      LocalSetPlanRow,
      PrefetchHooks Function({
        bool workoutStepId,
        bool localSetPerformancesRefs,
      })
    >;
typedef $$LocalWorkoutSessionsTableCreateCompanionBuilder =
    LocalWorkoutSessionsCompanion Function({
      required String id,
      required String workoutInstanceId,
      required int instanceRevisionNumber,
      required String status,
      required int startedAt,
      Value<int?> lastResumedAt,
      Value<int?> pausedAt,
      Value<int?> completedAt,
      Value<String?> activeStepId,
      required int elapsedActiveSeconds,
      Value<String?> notes,
      required int createdAt,
      required int updatedAt,
      required int rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$LocalWorkoutSessionsTableUpdateCompanionBuilder =
    LocalWorkoutSessionsCompanion Function({
      Value<String> id,
      Value<String> workoutInstanceId,
      Value<int> instanceRevisionNumber,
      Value<String> status,
      Value<int> startedAt,
      Value<int?> lastResumedAt,
      Value<int?> pausedAt,
      Value<int?> completedAt,
      Value<String?> activeStepId,
      Value<int> elapsedActiveSeconds,
      Value<String?> notes,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });

final class $$LocalWorkoutSessionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalWorkoutSessionsTable,
          LocalWorkoutSessionRow
        > {
  $$LocalWorkoutSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalWorkoutInstancesTable _workoutInstanceIdTable(
    _$AppDatabase db,
  ) => db.localWorkoutInstances.createAlias(
    'local_workout_sessions__workout_instance_id__local_workout_instances__id',
  );

  $$LocalWorkoutInstancesTableProcessedTableManager get workoutInstanceId {
    final $_column = $_itemColumn<String>('workout_instance_id')!;

    final manager = $$LocalWorkoutInstancesTableTableManager(
      $_db,
      $_db.localWorkoutInstances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutInstanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $LocalStepPerformancesTable,
    List<LocalStepPerformanceRow>
  >
  _localStepPerformancesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.localStepPerformances,
    aliasName:
        'local_workout_sessions__id__local_step_performances__workout_session_id',
  );

  $$LocalStepPerformancesTableProcessedTableManager
  get localStepPerformancesRefs {
    final manager =
        $$LocalStepPerformancesTableTableManager(
          $_db,
          $_db.localStepPerformances,
        ).filter(
          (f) => f.workoutSessionId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _localStepPerformancesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $LocalWorkoutFeedbackTable,
    List<LocalWorkoutFeedbackRow>
  >
  _localWorkoutFeedbackRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.localWorkoutFeedback,
    aliasName:
        'local_workout_sessions__id__local_workout_feedback__workout_session_id',
  );

  $$LocalWorkoutFeedbackTableProcessedTableManager
  get localWorkoutFeedbackRefs {
    final manager =
        $$LocalWorkoutFeedbackTableTableManager(
          $_db,
          $_db.localWorkoutFeedback,
        ).filter(
          (f) => f.workoutSessionId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _localWorkoutFeedbackRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $LocalActivitySummariesTable,
    List<LocalActivitySummaryRow>
  >
  _localActivitySummariesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.localActivitySummaries,
    aliasName:
        'local_workout_sessions__id__local_activity_summaries__workout_session_id',
  );

  $$LocalActivitySummariesTableProcessedTableManager
  get localActivitySummariesRefs {
    final manager =
        $$LocalActivitySummariesTableTableManager(
          $_db,
          $_db.localActivitySummaries,
        ).filter(
          (f) => f.workoutSessionId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _localActivitySummariesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalWorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalWorkoutSessionsTable> {
  $$LocalWorkoutSessionsTableFilterComposer({
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

  ColumnFilters<int> get instanceRevisionNumber => $composableBuilder(
    column: $table.instanceRevisionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastResumedAt => $composableBuilder(
    column: $table.lastResumedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeStepId => $composableBuilder(
    column: $table.activeStepId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedActiveSeconds => $composableBuilder(
    column: $table.elapsedActiveSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalWorkoutInstancesTableFilterComposer get workoutInstanceId {
    final $$LocalWorkoutInstancesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutInstanceId,
          referencedTable: $db.localWorkoutInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutInstancesTableFilterComposer(
                $db: $db,
                $table: $db.localWorkoutInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> localStepPerformancesRefs(
    Expression<bool> Function($$LocalStepPerformancesTableFilterComposer f) f,
  ) {
    final $$LocalStepPerformancesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localStepPerformances,
          getReferencedColumn: (t) => t.workoutSessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalStepPerformancesTableFilterComposer(
                $db: $db,
                $table: $db.localStepPerformances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> localWorkoutFeedbackRefs(
    Expression<bool> Function($$LocalWorkoutFeedbackTableFilterComposer f) f,
  ) {
    final $$LocalWorkoutFeedbackTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localWorkoutFeedback,
      getReferencedColumn: (t) => t.workoutSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalWorkoutFeedbackTableFilterComposer(
            $db: $db,
            $table: $db.localWorkoutFeedback,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> localActivitySummariesRefs(
    Expression<bool> Function($$LocalActivitySummariesTableFilterComposer f) f,
  ) {
    final $$LocalActivitySummariesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localActivitySummaries,
          getReferencedColumn: (t) => t.workoutSessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalActivitySummariesTableFilterComposer(
                $db: $db,
                $table: $db.localActivitySummaries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalWorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalWorkoutSessionsTable> {
  $$LocalWorkoutSessionsTableOrderingComposer({
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

  ColumnOrderings<int> get instanceRevisionNumber => $composableBuilder(
    column: $table.instanceRevisionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastResumedAt => $composableBuilder(
    column: $table.lastResumedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeStepId => $composableBuilder(
    column: $table.activeStepId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedActiveSeconds => $composableBuilder(
    column: $table.elapsedActiveSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalWorkoutInstancesTableOrderingComposer get workoutInstanceId {
    final $$LocalWorkoutInstancesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutInstanceId,
          referencedTable: $db.localWorkoutInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutInstancesTableOrderingComposer(
                $db: $db,
                $table: $db.localWorkoutInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalWorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalWorkoutSessionsTable> {
  $$LocalWorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get instanceRevisionNumber => $composableBuilder(
    column: $table.instanceRevisionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get lastResumedAt => $composableBuilder(
    column: $table.lastResumedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeStepId => $composableBuilder(
    column: $table.activeStepId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedActiveSeconds => $composableBuilder(
    column: $table.elapsedActiveSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  $$LocalWorkoutInstancesTableAnnotationComposer get workoutInstanceId {
    final $$LocalWorkoutInstancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutInstanceId,
          referencedTable: $db.localWorkoutInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutInstancesTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> localStepPerformancesRefs<T extends Object>(
    Expression<T> Function($$LocalStepPerformancesTableAnnotationComposer a) f,
  ) {
    final $$LocalStepPerformancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localStepPerformances,
          getReferencedColumn: (t) => t.workoutSessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalStepPerformancesTableAnnotationComposer(
                $db: $db,
                $table: $db.localStepPerformances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> localWorkoutFeedbackRefs<T extends Object>(
    Expression<T> Function($$LocalWorkoutFeedbackTableAnnotationComposer a) f,
  ) {
    final $$LocalWorkoutFeedbackTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localWorkoutFeedback,
          getReferencedColumn: (t) => t.workoutSessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutFeedbackTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutFeedback,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> localActivitySummariesRefs<T extends Object>(
    Expression<T> Function($$LocalActivitySummariesTableAnnotationComposer a) f,
  ) {
    final $$LocalActivitySummariesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localActivitySummaries,
          getReferencedColumn: (t) => t.workoutSessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalActivitySummariesTableAnnotationComposer(
                $db: $db,
                $table: $db.localActivitySummaries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalWorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalWorkoutSessionsTable,
          LocalWorkoutSessionRow,
          $$LocalWorkoutSessionsTableFilterComposer,
          $$LocalWorkoutSessionsTableOrderingComposer,
          $$LocalWorkoutSessionsTableAnnotationComposer,
          $$LocalWorkoutSessionsTableCreateCompanionBuilder,
          $$LocalWorkoutSessionsTableUpdateCompanionBuilder,
          (LocalWorkoutSessionRow, $$LocalWorkoutSessionsTableReferences),
          LocalWorkoutSessionRow,
          PrefetchHooks Function({
            bool workoutInstanceId,
            bool localStepPerformancesRefs,
            bool localWorkoutFeedbackRefs,
            bool localActivitySummariesRefs,
          })
        > {
  $$LocalWorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $LocalWorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalWorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalWorkoutSessionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalWorkoutSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutInstanceId = const Value.absent(),
                Value<int> instanceRevisionNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> lastResumedAt = const Value.absent(),
                Value<int?> pausedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<String?> activeStepId = const Value.absent(),
                Value<int> elapsedActiveSeconds = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowVersion = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWorkoutSessionsCompanion(
                id: id,
                workoutInstanceId: workoutInstanceId,
                instanceRevisionNumber: instanceRevisionNumber,
                status: status,
                startedAt: startedAt,
                lastResumedAt: lastResumedAt,
                pausedAt: pausedAt,
                completedAt: completedAt,
                activeStepId: activeStepId,
                elapsedActiveSeconds: elapsedActiveSeconds,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workoutInstanceId,
                required int instanceRevisionNumber,
                required String status,
                required int startedAt,
                Value<int?> lastResumedAt = const Value.absent(),
                Value<int?> pausedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<String?> activeStepId = const Value.absent(),
                required int elapsedActiveSeconds,
                Value<String?> notes = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required int rowVersion,
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWorkoutSessionsCompanion.insert(
                id: id,
                workoutInstanceId: workoutInstanceId,
                instanceRevisionNumber: instanceRevisionNumber,
                status: status,
                startedAt: startedAt,
                lastResumedAt: lastResumedAt,
                pausedAt: pausedAt,
                completedAt: completedAt,
                activeStepId: activeStepId,
                elapsedActiveSeconds: elapsedActiveSeconds,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalWorkoutSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutInstanceId = false,
                localStepPerformancesRefs = false,
                localWorkoutFeedbackRefs = false,
                localActivitySummariesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (localStepPerformancesRefs) db.localStepPerformances,
                    if (localWorkoutFeedbackRefs) db.localWorkoutFeedback,
                    if (localActivitySummariesRefs) db.localActivitySummaries,
                  ],
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
                        if (workoutInstanceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutInstanceId,
                                    referencedTable:
                                        $$LocalWorkoutSessionsTableReferences
                                            ._workoutInstanceIdTable(db),
                                    referencedColumn:
                                        $$LocalWorkoutSessionsTableReferences
                                            ._workoutInstanceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (localStepPerformancesRefs)
                        await $_getPrefetchedData<
                          LocalWorkoutSessionRow,
                          $LocalWorkoutSessionsTable,
                          LocalStepPerformanceRow
                        >(
                          currentTable: table,
                          referencedTable: $$LocalWorkoutSessionsTableReferences
                              ._localStepPerformancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalWorkoutSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).localStepPerformancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutSessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (localWorkoutFeedbackRefs)
                        await $_getPrefetchedData<
                          LocalWorkoutSessionRow,
                          $LocalWorkoutSessionsTable,
                          LocalWorkoutFeedbackRow
                        >(
                          currentTable: table,
                          referencedTable: $$LocalWorkoutSessionsTableReferences
                              ._localWorkoutFeedbackRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalWorkoutSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).localWorkoutFeedbackRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutSessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (localActivitySummariesRefs)
                        await $_getPrefetchedData<
                          LocalWorkoutSessionRow,
                          $LocalWorkoutSessionsTable,
                          LocalActivitySummaryRow
                        >(
                          currentTable: table,
                          referencedTable: $$LocalWorkoutSessionsTableReferences
                              ._localActivitySummariesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalWorkoutSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).localActivitySummariesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutSessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LocalWorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalWorkoutSessionsTable,
      LocalWorkoutSessionRow,
      $$LocalWorkoutSessionsTableFilterComposer,
      $$LocalWorkoutSessionsTableOrderingComposer,
      $$LocalWorkoutSessionsTableAnnotationComposer,
      $$LocalWorkoutSessionsTableCreateCompanionBuilder,
      $$LocalWorkoutSessionsTableUpdateCompanionBuilder,
      (LocalWorkoutSessionRow, $$LocalWorkoutSessionsTableReferences),
      LocalWorkoutSessionRow,
      PrefetchHooks Function({
        bool workoutInstanceId,
        bool localStepPerformancesRefs,
        bool localWorkoutFeedbackRefs,
        bool localActivitySummariesRefs,
      })
    >;
typedef $$LocalStepPerformancesTableCreateCompanionBuilder =
    LocalStepPerformancesCompanion Function({
      required String id,
      required String workoutSessionId,
      required String workoutStepId,
      required String status,
      Value<int?> startedAt,
      Value<int?> completedAt,
      Value<int?> actualRepetitions,
      Value<int?> actualDurationSeconds,
      Value<double?> actualDistanceMeters,
      Value<double?> actualWeightKg,
      Value<double?> perceivedExertion,
      Value<String?> notes,
      required int updatedAt,
      required int rowVersion,
      Value<int> rowid,
    });
typedef $$LocalStepPerformancesTableUpdateCompanionBuilder =
    LocalStepPerformancesCompanion Function({
      Value<String> id,
      Value<String> workoutSessionId,
      Value<String> workoutStepId,
      Value<String> status,
      Value<int?> startedAt,
      Value<int?> completedAt,
      Value<int?> actualRepetitions,
      Value<int?> actualDurationSeconds,
      Value<double?> actualDistanceMeters,
      Value<double?> actualWeightKg,
      Value<double?> perceivedExertion,
      Value<String?> notes,
      Value<int> updatedAt,
      Value<int> rowVersion,
      Value<int> rowid,
    });

final class $$LocalStepPerformancesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalStepPerformancesTable,
          LocalStepPerformanceRow
        > {
  $$LocalStepPerformancesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalWorkoutSessionsTable _workoutSessionIdTable(
    _$AppDatabase db,
  ) => db.localWorkoutSessions.createAlias(
    'local_step_performances__workout_session_id__local_workout_sessions__id',
  );

  $$LocalWorkoutSessionsTableProcessedTableManager get workoutSessionId {
    final $_column = $_itemColumn<String>('workout_session_id')!;

    final manager = $$LocalWorkoutSessionsTableTableManager(
      $_db,
      $_db.localWorkoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutSessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LocalWorkoutStepsTable _workoutStepIdTable(_$AppDatabase db) =>
      db.localWorkoutSteps.createAlias(
        'local_step_performances__workout_step_id__local_workout_steps__id',
      );

  $$LocalWorkoutStepsTableProcessedTableManager get workoutStepId {
    final $_column = $_itemColumn<String>('workout_step_id')!;

    final manager = $$LocalWorkoutStepsTableTableManager(
      $_db,
      $_db.localWorkoutSteps,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutStepIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $LocalSetPerformancesTable,
    List<LocalSetPerformanceRow>
  >
  _localSetPerformancesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.localSetPerformances,
    aliasName:
        'local_step_performances__id__local_set_performances__step_performance_id',
  );

  $$LocalSetPerformancesTableProcessedTableManager
  get localSetPerformancesRefs {
    final manager =
        $$LocalSetPerformancesTableTableManager(
          $_db,
          $_db.localSetPerformances,
        ).filter(
          (f) => f.stepPerformanceId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _localSetPerformancesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalStepPerformancesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalStepPerformancesTable> {
  $$LocalStepPerformancesTableFilterComposer({
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualRepetitions => $composableBuilder(
    column: $table.actualRepetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualDurationSeconds => $composableBuilder(
    column: $table.actualDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualDistanceMeters => $composableBuilder(
    column: $table.actualDistanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualWeightKg => $composableBuilder(
    column: $table.actualWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get perceivedExertion => $composableBuilder(
    column: $table.perceivedExertion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalWorkoutSessionsTableFilterComposer get workoutSessionId {
    final $$LocalWorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutSessionId,
      referencedTable: $db.localWorkoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalWorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.localWorkoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocalWorkoutStepsTableFilterComposer get workoutStepId {
    final $$LocalWorkoutStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutStepId,
      referencedTable: $db.localWorkoutSteps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalWorkoutStepsTableFilterComposer(
            $db: $db,
            $table: $db.localWorkoutSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> localSetPerformancesRefs(
    Expression<bool> Function($$LocalSetPerformancesTableFilterComposer f) f,
  ) {
    final $$LocalSetPerformancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localSetPerformances,
      getReferencedColumn: (t) => t.stepPerformanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSetPerformancesTableFilterComposer(
            $db: $db,
            $table: $db.localSetPerformances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalStepPerformancesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalStepPerformancesTable> {
  $$LocalStepPerformancesTableOrderingComposer({
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualRepetitions => $composableBuilder(
    column: $table.actualRepetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualDurationSeconds => $composableBuilder(
    column: $table.actualDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualDistanceMeters => $composableBuilder(
    column: $table.actualDistanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualWeightKg => $composableBuilder(
    column: $table.actualWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get perceivedExertion => $composableBuilder(
    column: $table.perceivedExertion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalWorkoutSessionsTableOrderingComposer get workoutSessionId {
    final $$LocalWorkoutSessionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutSessionId,
          referencedTable: $db.localWorkoutSessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutSessionsTableOrderingComposer(
                $db: $db,
                $table: $db.localWorkoutSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$LocalWorkoutStepsTableOrderingComposer get workoutStepId {
    final $$LocalWorkoutStepsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutStepId,
      referencedTable: $db.localWorkoutSteps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalWorkoutStepsTableOrderingComposer(
            $db: $db,
            $table: $db.localWorkoutSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalStepPerformancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalStepPerformancesTable> {
  $$LocalStepPerformancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualRepetitions => $composableBuilder(
    column: $table.actualRepetitions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualDurationSeconds => $composableBuilder(
    column: $table.actualDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualDistanceMeters => $composableBuilder(
    column: $table.actualDistanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualWeightKg => $composableBuilder(
    column: $table.actualWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get perceivedExertion => $composableBuilder(
    column: $table.perceivedExertion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  $$LocalWorkoutSessionsTableAnnotationComposer get workoutSessionId {
    final $$LocalWorkoutSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutSessionId,
          referencedTable: $db.localWorkoutSessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$LocalWorkoutStepsTableAnnotationComposer get workoutStepId {
    final $$LocalWorkoutStepsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutStepId,
          referencedTable: $db.localWorkoutSteps,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutStepsTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutSteps,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> localSetPerformancesRefs<T extends Object>(
    Expression<T> Function($$LocalSetPerformancesTableAnnotationComposer a) f,
  ) {
    final $$LocalSetPerformancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localSetPerformances,
          getReferencedColumn: (t) => t.stepPerformanceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalSetPerformancesTableAnnotationComposer(
                $db: $db,
                $table: $db.localSetPerformances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalStepPerformancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalStepPerformancesTable,
          LocalStepPerformanceRow,
          $$LocalStepPerformancesTableFilterComposer,
          $$LocalStepPerformancesTableOrderingComposer,
          $$LocalStepPerformancesTableAnnotationComposer,
          $$LocalStepPerformancesTableCreateCompanionBuilder,
          $$LocalStepPerformancesTableUpdateCompanionBuilder,
          (LocalStepPerformanceRow, $$LocalStepPerformancesTableReferences),
          LocalStepPerformanceRow,
          PrefetchHooks Function({
            bool workoutSessionId,
            bool workoutStepId,
            bool localSetPerformancesRefs,
          })
        > {
  $$LocalStepPerformancesTableTableManager(
    _$AppDatabase db,
    $LocalStepPerformancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalStepPerformancesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalStepPerformancesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalStepPerformancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutSessionId = const Value.absent(),
                Value<String> workoutStepId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> startedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int?> actualRepetitions = const Value.absent(),
                Value<int?> actualDurationSeconds = const Value.absent(),
                Value<double?> actualDistanceMeters = const Value.absent(),
                Value<double?> actualWeightKg = const Value.absent(),
                Value<double?> perceivedExertion = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalStepPerformancesCompanion(
                id: id,
                workoutSessionId: workoutSessionId,
                workoutStepId: workoutStepId,
                status: status,
                startedAt: startedAt,
                completedAt: completedAt,
                actualRepetitions: actualRepetitions,
                actualDurationSeconds: actualDurationSeconds,
                actualDistanceMeters: actualDistanceMeters,
                actualWeightKg: actualWeightKg,
                perceivedExertion: perceivedExertion,
                notes: notes,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workoutSessionId,
                required String workoutStepId,
                required String status,
                Value<int?> startedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int?> actualRepetitions = const Value.absent(),
                Value<int?> actualDurationSeconds = const Value.absent(),
                Value<double?> actualDistanceMeters = const Value.absent(),
                Value<double?> actualWeightKg = const Value.absent(),
                Value<double?> perceivedExertion = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int updatedAt,
                required int rowVersion,
                Value<int> rowid = const Value.absent(),
              }) => LocalStepPerformancesCompanion.insert(
                id: id,
                workoutSessionId: workoutSessionId,
                workoutStepId: workoutStepId,
                status: status,
                startedAt: startedAt,
                completedAt: completedAt,
                actualRepetitions: actualRepetitions,
                actualDurationSeconds: actualDurationSeconds,
                actualDistanceMeters: actualDistanceMeters,
                actualWeightKg: actualWeightKg,
                perceivedExertion: perceivedExertion,
                notes: notes,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalStepPerformancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutSessionId = false,
                workoutStepId = false,
                localSetPerformancesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (localSetPerformancesRefs) db.localSetPerformances,
                  ],
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
                        if (workoutSessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutSessionId,
                                    referencedTable:
                                        $$LocalStepPerformancesTableReferences
                                            ._workoutSessionIdTable(db),
                                    referencedColumn:
                                        $$LocalStepPerformancesTableReferences
                                            ._workoutSessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (workoutStepId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutStepId,
                                    referencedTable:
                                        $$LocalStepPerformancesTableReferences
                                            ._workoutStepIdTable(db),
                                    referencedColumn:
                                        $$LocalStepPerformancesTableReferences
                                            ._workoutStepIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (localSetPerformancesRefs)
                        await $_getPrefetchedData<
                          LocalStepPerformanceRow,
                          $LocalStepPerformancesTable,
                          LocalSetPerformanceRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$LocalStepPerformancesTableReferences
                                  ._localSetPerformancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalStepPerformancesTableReferences(
                                db,
                                table,
                                p0,
                              ).localSetPerformancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stepPerformanceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LocalStepPerformancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalStepPerformancesTable,
      LocalStepPerformanceRow,
      $$LocalStepPerformancesTableFilterComposer,
      $$LocalStepPerformancesTableOrderingComposer,
      $$LocalStepPerformancesTableAnnotationComposer,
      $$LocalStepPerformancesTableCreateCompanionBuilder,
      $$LocalStepPerformancesTableUpdateCompanionBuilder,
      (LocalStepPerformanceRow, $$LocalStepPerformancesTableReferences),
      LocalStepPerformanceRow,
      PrefetchHooks Function({
        bool workoutSessionId,
        bool workoutStepId,
        bool localSetPerformancesRefs,
      })
    >;
typedef $$LocalSetPerformancesTableCreateCompanionBuilder =
    LocalSetPerformancesCompanion Function({
      required String id,
      required String stepPerformanceId,
      Value<String?> setPlanId,
      required int position,
      required String status,
      Value<int?> actualRepetitions,
      Value<double?> actualWeightKg,
      Value<int?> actualDurationSeconds,
      Value<double?> actualRpe,
      Value<int?> completedAt,
      Value<String?> notes,
      required int updatedAt,
      required int rowVersion,
      Value<int> rowid,
    });
typedef $$LocalSetPerformancesTableUpdateCompanionBuilder =
    LocalSetPerformancesCompanion Function({
      Value<String> id,
      Value<String> stepPerformanceId,
      Value<String?> setPlanId,
      Value<int> position,
      Value<String> status,
      Value<int?> actualRepetitions,
      Value<double?> actualWeightKg,
      Value<int?> actualDurationSeconds,
      Value<double?> actualRpe,
      Value<int?> completedAt,
      Value<String?> notes,
      Value<int> updatedAt,
      Value<int> rowVersion,
      Value<int> rowid,
    });

final class $$LocalSetPerformancesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalSetPerformancesTable,
          LocalSetPerformanceRow
        > {
  $$LocalSetPerformancesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalStepPerformancesTable _stepPerformanceIdTable(
    _$AppDatabase db,
  ) => db.localStepPerformances.createAlias(
    'local_set_performances__step_performance_id__local_step_performances__id',
  );

  $$LocalStepPerformancesTableProcessedTableManager get stepPerformanceId {
    final $_column = $_itemColumn<String>('step_performance_id')!;

    final manager = $$LocalStepPerformancesTableTableManager(
      $_db,
      $_db.localStepPerformances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stepPerformanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LocalSetPlansTable _setPlanIdTable(_$AppDatabase db) => db
      .localSetPlans
      .createAlias('local_set_performances__set_plan_id__local_set_plans__id');

  $$LocalSetPlansTableProcessedTableManager? get setPlanId {
    final $_column = $_itemColumn<String>('set_plan_id');
    if ($_column == null) return null;
    final manager = $$LocalSetPlansTableTableManager(
      $_db,
      $_db.localSetPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_setPlanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalSetPerformancesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSetPerformancesTable> {
  $$LocalSetPerformancesTableFilterComposer({
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualRepetitions => $composableBuilder(
    column: $table.actualRepetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualWeightKg => $composableBuilder(
    column: $table.actualWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualDurationSeconds => $composableBuilder(
    column: $table.actualDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualRpe => $composableBuilder(
    column: $table.actualRpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalStepPerformancesTableFilterComposer get stepPerformanceId {
    final $$LocalStepPerformancesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.stepPerformanceId,
          referencedTable: $db.localStepPerformances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalStepPerformancesTableFilterComposer(
                $db: $db,
                $table: $db.localStepPerformances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$LocalSetPlansTableFilterComposer get setPlanId {
    final $$LocalSetPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setPlanId,
      referencedTable: $db.localSetPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSetPlansTableFilterComposer(
            $db: $db,
            $table: $db.localSetPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalSetPerformancesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSetPerformancesTable> {
  $$LocalSetPerformancesTableOrderingComposer({
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualRepetitions => $composableBuilder(
    column: $table.actualRepetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualWeightKg => $composableBuilder(
    column: $table.actualWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualDurationSeconds => $composableBuilder(
    column: $table.actualDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualRpe => $composableBuilder(
    column: $table.actualRpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalStepPerformancesTableOrderingComposer get stepPerformanceId {
    final $$LocalStepPerformancesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.stepPerformanceId,
          referencedTable: $db.localStepPerformances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalStepPerformancesTableOrderingComposer(
                $db: $db,
                $table: $db.localStepPerformances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$LocalSetPlansTableOrderingComposer get setPlanId {
    final $$LocalSetPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setPlanId,
      referencedTable: $db.localSetPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSetPlansTableOrderingComposer(
            $db: $db,
            $table: $db.localSetPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalSetPerformancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSetPerformancesTable> {
  $$LocalSetPerformancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get actualRepetitions => $composableBuilder(
    column: $table.actualRepetitions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualWeightKg => $composableBuilder(
    column: $table.actualWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualDurationSeconds => $composableBuilder(
    column: $table.actualDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualRpe =>
      $composableBuilder(column: $table.actualRpe, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  $$LocalStepPerformancesTableAnnotationComposer get stepPerformanceId {
    final $$LocalStepPerformancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.stepPerformanceId,
          referencedTable: $db.localStepPerformances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalStepPerformancesTableAnnotationComposer(
                $db: $db,
                $table: $db.localStepPerformances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$LocalSetPlansTableAnnotationComposer get setPlanId {
    final $$LocalSetPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setPlanId,
      referencedTable: $db.localSetPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalSetPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.localSetPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalSetPerformancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSetPerformancesTable,
          LocalSetPerformanceRow,
          $$LocalSetPerformancesTableFilterComposer,
          $$LocalSetPerformancesTableOrderingComposer,
          $$LocalSetPerformancesTableAnnotationComposer,
          $$LocalSetPerformancesTableCreateCompanionBuilder,
          $$LocalSetPerformancesTableUpdateCompanionBuilder,
          (LocalSetPerformanceRow, $$LocalSetPerformancesTableReferences),
          LocalSetPerformanceRow,
          PrefetchHooks Function({bool stepPerformanceId, bool setPlanId})
        > {
  $$LocalSetPerformancesTableTableManager(
    _$AppDatabase db,
    $LocalSetPerformancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSetPerformancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSetPerformancesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalSetPerformancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> stepPerformanceId = const Value.absent(),
                Value<String?> setPlanId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> actualRepetitions = const Value.absent(),
                Value<double?> actualWeightKg = const Value.absent(),
                Value<int?> actualDurationSeconds = const Value.absent(),
                Value<double?> actualRpe = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSetPerformancesCompanion(
                id: id,
                stepPerformanceId: stepPerformanceId,
                setPlanId: setPlanId,
                position: position,
                status: status,
                actualRepetitions: actualRepetitions,
                actualWeightKg: actualWeightKg,
                actualDurationSeconds: actualDurationSeconds,
                actualRpe: actualRpe,
                completedAt: completedAt,
                notes: notes,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String stepPerformanceId,
                Value<String?> setPlanId = const Value.absent(),
                required int position,
                required String status,
                Value<int?> actualRepetitions = const Value.absent(),
                Value<double?> actualWeightKg = const Value.absent(),
                Value<int?> actualDurationSeconds = const Value.absent(),
                Value<double?> actualRpe = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int updatedAt,
                required int rowVersion,
                Value<int> rowid = const Value.absent(),
              }) => LocalSetPerformancesCompanion.insert(
                id: id,
                stepPerformanceId: stepPerformanceId,
                setPlanId: setPlanId,
                position: position,
                status: status,
                actualRepetitions: actualRepetitions,
                actualWeightKg: actualWeightKg,
                actualDurationSeconds: actualDurationSeconds,
                actualRpe: actualRpe,
                completedAt: completedAt,
                notes: notes,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalSetPerformancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({stepPerformanceId = false, setPlanId = false}) {
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
                        if (stepPerformanceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.stepPerformanceId,
                                    referencedTable:
                                        $$LocalSetPerformancesTableReferences
                                            ._stepPerformanceIdTable(db),
                                    referencedColumn:
                                        $$LocalSetPerformancesTableReferences
                                            ._stepPerformanceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (setPlanId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.setPlanId,
                                    referencedTable:
                                        $$LocalSetPerformancesTableReferences
                                            ._setPlanIdTable(db),
                                    referencedColumn:
                                        $$LocalSetPerformancesTableReferences
                                            ._setPlanIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$LocalSetPerformancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSetPerformancesTable,
      LocalSetPerformanceRow,
      $$LocalSetPerformancesTableFilterComposer,
      $$LocalSetPerformancesTableOrderingComposer,
      $$LocalSetPerformancesTableAnnotationComposer,
      $$LocalSetPerformancesTableCreateCompanionBuilder,
      $$LocalSetPerformancesTableUpdateCompanionBuilder,
      (LocalSetPerformanceRow, $$LocalSetPerformancesTableReferences),
      LocalSetPerformanceRow,
      PrefetchHooks Function({bool stepPerformanceId, bool setPlanId})
    >;
typedef $$LocalWorkoutFeedbackTableCreateCompanionBuilder =
    LocalWorkoutFeedbackCompanion Function({
      required String id,
      required String workoutSessionId,
      Value<double?> overallEffort,
      Value<String?> feeling,
      required bool painReported,
      Value<String?> notes,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$LocalWorkoutFeedbackTableUpdateCompanionBuilder =
    LocalWorkoutFeedbackCompanion Function({
      Value<String> id,
      Value<String> workoutSessionId,
      Value<double?> overallEffort,
      Value<String?> feeling,
      Value<bool> painReported,
      Value<String?> notes,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$LocalWorkoutFeedbackTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalWorkoutFeedbackTable,
          LocalWorkoutFeedbackRow
        > {
  $$LocalWorkoutFeedbackTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalWorkoutSessionsTable _workoutSessionIdTable(
    _$AppDatabase db,
  ) => db.localWorkoutSessions.createAlias(
    'local_workout_feedback__workout_session_id__local_workout_sessions__id',
  );

  $$LocalWorkoutSessionsTableProcessedTableManager get workoutSessionId {
    final $_column = $_itemColumn<String>('workout_session_id')!;

    final manager = $$LocalWorkoutSessionsTableTableManager(
      $_db,
      $_db.localWorkoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutSessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalWorkoutFeedbackTableFilterComposer
    extends Composer<_$AppDatabase, $LocalWorkoutFeedbackTable> {
  $$LocalWorkoutFeedbackTableFilterComposer({
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

  ColumnFilters<double> get overallEffort => $composableBuilder(
    column: $table.overallEffort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feeling => $composableBuilder(
    column: $table.feeling,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get painReported => $composableBuilder(
    column: $table.painReported,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalWorkoutSessionsTableFilterComposer get workoutSessionId {
    final $$LocalWorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutSessionId,
      referencedTable: $db.localWorkoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalWorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.localWorkoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalWorkoutFeedbackTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalWorkoutFeedbackTable> {
  $$LocalWorkoutFeedbackTableOrderingComposer({
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

  ColumnOrderings<double> get overallEffort => $composableBuilder(
    column: $table.overallEffort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feeling => $composableBuilder(
    column: $table.feeling,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get painReported => $composableBuilder(
    column: $table.painReported,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalWorkoutSessionsTableOrderingComposer get workoutSessionId {
    final $$LocalWorkoutSessionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutSessionId,
          referencedTable: $db.localWorkoutSessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutSessionsTableOrderingComposer(
                $db: $db,
                $table: $db.localWorkoutSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalWorkoutFeedbackTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalWorkoutFeedbackTable> {
  $$LocalWorkoutFeedbackTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get overallEffort => $composableBuilder(
    column: $table.overallEffort,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feeling =>
      $composableBuilder(column: $table.feeling, builder: (column) => column);

  GeneratedColumn<bool> get painReported => $composableBuilder(
    column: $table.painReported,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LocalWorkoutSessionsTableAnnotationComposer get workoutSessionId {
    final $$LocalWorkoutSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutSessionId,
          referencedTable: $db.localWorkoutSessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalWorkoutFeedbackTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalWorkoutFeedbackTable,
          LocalWorkoutFeedbackRow,
          $$LocalWorkoutFeedbackTableFilterComposer,
          $$LocalWorkoutFeedbackTableOrderingComposer,
          $$LocalWorkoutFeedbackTableAnnotationComposer,
          $$LocalWorkoutFeedbackTableCreateCompanionBuilder,
          $$LocalWorkoutFeedbackTableUpdateCompanionBuilder,
          (LocalWorkoutFeedbackRow, $$LocalWorkoutFeedbackTableReferences),
          LocalWorkoutFeedbackRow,
          PrefetchHooks Function({bool workoutSessionId})
        > {
  $$LocalWorkoutFeedbackTableTableManager(
    _$AppDatabase db,
    $LocalWorkoutFeedbackTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalWorkoutFeedbackTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalWorkoutFeedbackTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalWorkoutFeedbackTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutSessionId = const Value.absent(),
                Value<double?> overallEffort = const Value.absent(),
                Value<String?> feeling = const Value.absent(),
                Value<bool> painReported = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWorkoutFeedbackCompanion(
                id: id,
                workoutSessionId: workoutSessionId,
                overallEffort: overallEffort,
                feeling: feeling,
                painReported: painReported,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workoutSessionId,
                Value<double?> overallEffort = const Value.absent(),
                Value<String?> feeling = const Value.absent(),
                required bool painReported,
                Value<String?> notes = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalWorkoutFeedbackCompanion.insert(
                id: id,
                workoutSessionId: workoutSessionId,
                overallEffort: overallEffort,
                feeling: feeling,
                painReported: painReported,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalWorkoutFeedbackTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutSessionId = false}) {
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
                    if (workoutSessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workoutSessionId,
                                referencedTable:
                                    $$LocalWorkoutFeedbackTableReferences
                                        ._workoutSessionIdTable(db),
                                referencedColumn:
                                    $$LocalWorkoutFeedbackTableReferences
                                        ._workoutSessionIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$LocalWorkoutFeedbackTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalWorkoutFeedbackTable,
      LocalWorkoutFeedbackRow,
      $$LocalWorkoutFeedbackTableFilterComposer,
      $$LocalWorkoutFeedbackTableOrderingComposer,
      $$LocalWorkoutFeedbackTableAnnotationComposer,
      $$LocalWorkoutFeedbackTableCreateCompanionBuilder,
      $$LocalWorkoutFeedbackTableUpdateCompanionBuilder,
      (LocalWorkoutFeedbackRow, $$LocalWorkoutFeedbackTableReferences),
      LocalWorkoutFeedbackRow,
      PrefetchHooks Function({bool workoutSessionId})
    >;
typedef $$LocalActivitySummariesTableCreateCompanionBuilder =
    LocalActivitySummariesCompanion Function({
      required String id,
      required String workoutInstanceId,
      required String workoutSessionId,
      required String titleSnapshot,
      required String workoutType,
      required int startedAt,
      required int completedAt,
      required int activeDurationSeconds,
      required int completedStepCount,
      required int totalStepCount,
      Value<double?> overallEffort,
      required int createdAt,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$LocalActivitySummariesTableUpdateCompanionBuilder =
    LocalActivitySummariesCompanion Function({
      Value<String> id,
      Value<String> workoutInstanceId,
      Value<String> workoutSessionId,
      Value<String> titleSnapshot,
      Value<String> workoutType,
      Value<int> startedAt,
      Value<int> completedAt,
      Value<int> activeDurationSeconds,
      Value<int> completedStepCount,
      Value<int> totalStepCount,
      Value<double?> overallEffort,
      Value<int> createdAt,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });

final class $$LocalActivitySummariesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalActivitySummariesTable,
          LocalActivitySummaryRow
        > {
  $$LocalActivitySummariesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalWorkoutInstancesTable _workoutInstanceIdTable(
    _$AppDatabase db,
  ) => db.localWorkoutInstances.createAlias(
    'local_activity_summaries__workout_instance_id__local_workout_instances__id',
  );

  $$LocalWorkoutInstancesTableProcessedTableManager get workoutInstanceId {
    final $_column = $_itemColumn<String>('workout_instance_id')!;

    final manager = $$LocalWorkoutInstancesTableTableManager(
      $_db,
      $_db.localWorkoutInstances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutInstanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LocalWorkoutSessionsTable _workoutSessionIdTable(
    _$AppDatabase db,
  ) => db.localWorkoutSessions.createAlias(
    'local_activity_summaries__workout_session_id__local_workout_sessions__id',
  );

  $$LocalWorkoutSessionsTableProcessedTableManager get workoutSessionId {
    final $_column = $_itemColumn<String>('workout_session_id')!;

    final manager = $$LocalWorkoutSessionsTableTableManager(
      $_db,
      $_db.localWorkoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutSessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalActivitySummariesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalActivitySummariesTable> {
  $$LocalActivitySummariesTableFilterComposer({
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

  ColumnFilters<String> get titleSnapshot => $composableBuilder(
    column: $table.titleSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workoutType => $composableBuilder(
    column: $table.workoutType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeDurationSeconds => $composableBuilder(
    column: $table.activeDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedStepCount => $composableBuilder(
    column: $table.completedStepCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalStepCount => $composableBuilder(
    column: $table.totalStepCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overallEffort => $composableBuilder(
    column: $table.overallEffort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalWorkoutInstancesTableFilterComposer get workoutInstanceId {
    final $$LocalWorkoutInstancesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutInstanceId,
          referencedTable: $db.localWorkoutInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutInstancesTableFilterComposer(
                $db: $db,
                $table: $db.localWorkoutInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$LocalWorkoutSessionsTableFilterComposer get workoutSessionId {
    final $$LocalWorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutSessionId,
      referencedTable: $db.localWorkoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalWorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.localWorkoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalActivitySummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalActivitySummariesTable> {
  $$LocalActivitySummariesTableOrderingComposer({
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

  ColumnOrderings<String> get titleSnapshot => $composableBuilder(
    column: $table.titleSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workoutType => $composableBuilder(
    column: $table.workoutType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeDurationSeconds => $composableBuilder(
    column: $table.activeDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedStepCount => $composableBuilder(
    column: $table.completedStepCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalStepCount => $composableBuilder(
    column: $table.totalStepCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overallEffort => $composableBuilder(
    column: $table.overallEffort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalWorkoutInstancesTableOrderingComposer get workoutInstanceId {
    final $$LocalWorkoutInstancesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutInstanceId,
          referencedTable: $db.localWorkoutInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutInstancesTableOrderingComposer(
                $db: $db,
                $table: $db.localWorkoutInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$LocalWorkoutSessionsTableOrderingComposer get workoutSessionId {
    final $$LocalWorkoutSessionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutSessionId,
          referencedTable: $db.localWorkoutSessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutSessionsTableOrderingComposer(
                $db: $db,
                $table: $db.localWorkoutSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalActivitySummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalActivitySummariesTable> {
  $$LocalActivitySummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titleSnapshot => $composableBuilder(
    column: $table.titleSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workoutType => $composableBuilder(
    column: $table.workoutType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeDurationSeconds => $composableBuilder(
    column: $table.activeDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedStepCount => $composableBuilder(
    column: $table.completedStepCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalStepCount => $composableBuilder(
    column: $table.totalStepCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overallEffort => $composableBuilder(
    column: $table.overallEffort,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  $$LocalWorkoutInstancesTableAnnotationComposer get workoutInstanceId {
    final $$LocalWorkoutInstancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutInstanceId,
          referencedTable: $db.localWorkoutInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutInstancesTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$LocalWorkoutSessionsTableAnnotationComposer get workoutSessionId {
    final $$LocalWorkoutSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutSessionId,
          referencedTable: $db.localWorkoutSessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalActivitySummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalActivitySummariesTable,
          LocalActivitySummaryRow,
          $$LocalActivitySummariesTableFilterComposer,
          $$LocalActivitySummariesTableOrderingComposer,
          $$LocalActivitySummariesTableAnnotationComposer,
          $$LocalActivitySummariesTableCreateCompanionBuilder,
          $$LocalActivitySummariesTableUpdateCompanionBuilder,
          (LocalActivitySummaryRow, $$LocalActivitySummariesTableReferences),
          LocalActivitySummaryRow,
          PrefetchHooks Function({
            bool workoutInstanceId,
            bool workoutSessionId,
          })
        > {
  $$LocalActivitySummariesTableTableManager(
    _$AppDatabase db,
    $LocalActivitySummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalActivitySummariesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalActivitySummariesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalActivitySummariesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutInstanceId = const Value.absent(),
                Value<String> workoutSessionId = const Value.absent(),
                Value<String> titleSnapshot = const Value.absent(),
                Value<String> workoutType = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> completedAt = const Value.absent(),
                Value<int> activeDurationSeconds = const Value.absent(),
                Value<int> completedStepCount = const Value.absent(),
                Value<int> totalStepCount = const Value.absent(),
                Value<double?> overallEffort = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalActivitySummariesCompanion(
                id: id,
                workoutInstanceId: workoutInstanceId,
                workoutSessionId: workoutSessionId,
                titleSnapshot: titleSnapshot,
                workoutType: workoutType,
                startedAt: startedAt,
                completedAt: completedAt,
                activeDurationSeconds: activeDurationSeconds,
                completedStepCount: completedStepCount,
                totalStepCount: totalStepCount,
                overallEffort: overallEffort,
                createdAt: createdAt,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workoutInstanceId,
                required String workoutSessionId,
                required String titleSnapshot,
                required String workoutType,
                required int startedAt,
                required int completedAt,
                required int activeDurationSeconds,
                required int completedStepCount,
                required int totalStepCount,
                Value<double?> overallEffort = const Value.absent(),
                required int createdAt,
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalActivitySummariesCompanion.insert(
                id: id,
                workoutInstanceId: workoutInstanceId,
                workoutSessionId: workoutSessionId,
                titleSnapshot: titleSnapshot,
                workoutType: workoutType,
                startedAt: startedAt,
                completedAt: completedAt,
                activeDurationSeconds: activeDurationSeconds,
                completedStepCount: completedStepCount,
                totalStepCount: totalStepCount,
                overallEffort: overallEffort,
                createdAt: createdAt,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalActivitySummariesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutInstanceId = false, workoutSessionId = false}) {
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
                        if (workoutInstanceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutInstanceId,
                                    referencedTable:
                                        $$LocalActivitySummariesTableReferences
                                            ._workoutInstanceIdTable(db),
                                    referencedColumn:
                                        $$LocalActivitySummariesTableReferences
                                            ._workoutInstanceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (workoutSessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutSessionId,
                                    referencedTable:
                                        $$LocalActivitySummariesTableReferences
                                            ._workoutSessionIdTable(db),
                                    referencedColumn:
                                        $$LocalActivitySummariesTableReferences
                                            ._workoutSessionIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$LocalActivitySummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalActivitySummariesTable,
      LocalActivitySummaryRow,
      $$LocalActivitySummariesTableFilterComposer,
      $$LocalActivitySummariesTableOrderingComposer,
      $$LocalActivitySummariesTableAnnotationComposer,
      $$LocalActivitySummariesTableCreateCompanionBuilder,
      $$LocalActivitySummariesTableUpdateCompanionBuilder,
      (LocalActivitySummaryRow, $$LocalActivitySummariesTableReferences),
      LocalActivitySummaryRow,
      PrefetchHooks Function({bool workoutInstanceId, bool workoutSessionId})
    >;
typedef $$LocalAppStateTableCreateCompanionBuilder =
    LocalAppStateCompanion Function({
      required String key,
      required String value,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$LocalAppStateTableUpdateCompanionBuilder =
    LocalAppStateCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$LocalAppStateTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAppStateTable> {
  $$LocalAppStateTableFilterComposer({
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

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAppStateTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAppStateTable> {
  $$LocalAppStateTableOrderingComposer({
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

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAppStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAppStateTable> {
  $$LocalAppStateTableAnnotationComposer({
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

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalAppStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAppStateTable,
          LocalAppStateRow,
          $$LocalAppStateTableFilterComposer,
          $$LocalAppStateTableOrderingComposer,
          $$LocalAppStateTableAnnotationComposer,
          $$LocalAppStateTableCreateCompanionBuilder,
          $$LocalAppStateTableUpdateCompanionBuilder,
          (
            LocalAppStateRow,
            BaseReferences<
              _$AppDatabase,
              $LocalAppStateTable,
              LocalAppStateRow
            >,
          ),
          LocalAppStateRow,
          PrefetchHooks Function()
        > {
  $$LocalAppStateTableTableManager(_$AppDatabase db, $LocalAppStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAppStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAppStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAppStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAppStateCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalAppStateCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAppStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAppStateTable,
      LocalAppStateRow,
      $$LocalAppStateTableFilterComposer,
      $$LocalAppStateTableOrderingComposer,
      $$LocalAppStateTableAnnotationComposer,
      $$LocalAppStateTableCreateCompanionBuilder,
      $$LocalAppStateTableUpdateCompanionBuilder,
      (
        LocalAppStateRow,
        BaseReferences<_$AppDatabase, $LocalAppStateTable, LocalAppStateRow>,
      ),
      LocalAppStateRow,
      PrefetchHooks Function()
    >;
typedef $$LocalOutboxTableCreateCompanionBuilder =
    LocalOutboxCompanion Function({
      required String id,
      Value<String> ownerId,
      required String entityType,
      required String entityId,
      required String operationType,
      required String idempotencyKey,
      required int sequence,
      Value<String> status,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$LocalOutboxTableUpdateCompanionBuilder =
    LocalOutboxCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operationType,
      Value<String> idempotencyKey,
      Value<int> sequence,
      Value<String> status,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$LocalOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $LocalOutboxTable> {
  $$LocalOutboxTableFilterComposer({
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

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalOutboxTable> {
  $$LocalOutboxTableOrderingComposer({
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

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalOutboxTable> {
  $$LocalOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalOutboxTable,
          LocalOutboxRow,
          $$LocalOutboxTableFilterComposer,
          $$LocalOutboxTableOrderingComposer,
          $$LocalOutboxTableAnnotationComposer,
          $$LocalOutboxTableCreateCompanionBuilder,
          $$LocalOutboxTableUpdateCompanionBuilder,
          (
            LocalOutboxRow,
            BaseReferences<_$AppDatabase, $LocalOutboxTable, LocalOutboxRow>,
          ),
          LocalOutboxRow,
          PrefetchHooks Function()
        > {
  $$LocalOutboxTableTableManager(_$AppDatabase db, $LocalOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalOutboxCompanion(
                id: id,
                ownerId: ownerId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                idempotencyKey: idempotencyKey,
                sequence: sequence,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> ownerId = const Value.absent(),
                required String entityType,
                required String entityId,
                required String operationType,
                required String idempotencyKey,
                required int sequence,
                Value<String> status = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalOutboxCompanion.insert(
                id: id,
                ownerId: ownerId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                idempotencyKey: idempotencyKey,
                sequence: sequence,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalOutboxTable,
      LocalOutboxRow,
      $$LocalOutboxTableFilterComposer,
      $$LocalOutboxTableOrderingComposer,
      $$LocalOutboxTableAnnotationComposer,
      $$LocalOutboxTableCreateCompanionBuilder,
      $$LocalOutboxTableUpdateCompanionBuilder,
      (
        LocalOutboxRow,
        BaseReferences<_$AppDatabase, $LocalOutboxTable, LocalOutboxRow>,
      ),
      LocalOutboxRow,
      PrefetchHooks Function()
    >;
typedef $$LocalSyncedVersionsTableCreateCompanionBuilder =
    LocalSyncedVersionsCompanion Function({
      required String entityType,
      required String entityId,
      required int serverVersion,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$LocalSyncedVersionsTableUpdateCompanionBuilder =
    LocalSyncedVersionsCompanion Function({
      Value<String> entityType,
      Value<String> entityId,
      Value<int> serverVersion,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$LocalSyncedVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSyncedVersionsTable> {
  $$LocalSyncedVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSyncedVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSyncedVersionsTable> {
  $$LocalSyncedVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSyncedVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSyncedVersionsTable> {
  $$LocalSyncedVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalSyncedVersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSyncedVersionsTable,
          LocalSyncedVersionRow,
          $$LocalSyncedVersionsTableFilterComposer,
          $$LocalSyncedVersionsTableOrderingComposer,
          $$LocalSyncedVersionsTableAnnotationComposer,
          $$LocalSyncedVersionsTableCreateCompanionBuilder,
          $$LocalSyncedVersionsTableUpdateCompanionBuilder,
          (
            LocalSyncedVersionRow,
            BaseReferences<
              _$AppDatabase,
              $LocalSyncedVersionsTable,
              LocalSyncedVersionRow
            >,
          ),
          LocalSyncedVersionRow,
          PrefetchHooks Function()
        > {
  $$LocalSyncedVersionsTableTableManager(
    _$AppDatabase db,
    $LocalSyncedVersionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSyncedVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSyncedVersionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalSyncedVersionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int> serverVersion = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncedVersionsCompanion(
                entityType: entityType,
                entityId: entityId,
                serverVersion: serverVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                required String entityId,
                required int serverVersion,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncedVersionsCompanion.insert(
                entityType: entityType,
                entityId: entityId,
                serverVersion: serverVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSyncedVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSyncedVersionsTable,
      LocalSyncedVersionRow,
      $$LocalSyncedVersionsTableFilterComposer,
      $$LocalSyncedVersionsTableOrderingComposer,
      $$LocalSyncedVersionsTableAnnotationComposer,
      $$LocalSyncedVersionsTableCreateCompanionBuilder,
      $$LocalSyncedVersionsTableUpdateCompanionBuilder,
      (
        LocalSyncedVersionRow,
        BaseReferences<
          _$AppDatabase,
          $LocalSyncedVersionsTable,
          LocalSyncedVersionRow
        >,
      ),
      LocalSyncedVersionRow,
      PrefetchHooks Function()
    >;
typedef $$LocalSyncResolutionsTableCreateCompanionBuilder =
    LocalSyncResolutionsCompanion Function({
      required String outboxId,
      required String decision,
      required int resolvedAt,
      Value<int> rowid,
    });
typedef $$LocalSyncResolutionsTableUpdateCompanionBuilder =
    LocalSyncResolutionsCompanion Function({
      Value<String> outboxId,
      Value<String> decision,
      Value<int> resolvedAt,
      Value<int> rowid,
    });

class $$LocalSyncResolutionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSyncResolutionsTable> {
  $$LocalSyncResolutionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get outboxId => $composableBuilder(
    column: $table.outboxId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSyncResolutionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSyncResolutionsTable> {
  $$LocalSyncResolutionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get outboxId => $composableBuilder(
    column: $table.outboxId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSyncResolutionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSyncResolutionsTable> {
  $$LocalSyncResolutionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get outboxId =>
      $composableBuilder(column: $table.outboxId, builder: (column) => column);

  GeneratedColumn<String> get decision =>
      $composableBuilder(column: $table.decision, builder: (column) => column);

  GeneratedColumn<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$LocalSyncResolutionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSyncResolutionsTable,
          LocalSyncResolutionRow,
          $$LocalSyncResolutionsTableFilterComposer,
          $$LocalSyncResolutionsTableOrderingComposer,
          $$LocalSyncResolutionsTableAnnotationComposer,
          $$LocalSyncResolutionsTableCreateCompanionBuilder,
          $$LocalSyncResolutionsTableUpdateCompanionBuilder,
          (
            LocalSyncResolutionRow,
            BaseReferences<
              _$AppDatabase,
              $LocalSyncResolutionsTable,
              LocalSyncResolutionRow
            >,
          ),
          LocalSyncResolutionRow,
          PrefetchHooks Function()
        > {
  $$LocalSyncResolutionsTableTableManager(
    _$AppDatabase db,
    $LocalSyncResolutionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSyncResolutionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSyncResolutionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalSyncResolutionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> outboxId = const Value.absent(),
                Value<String> decision = const Value.absent(),
                Value<int> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncResolutionsCompanion(
                outboxId: outboxId,
                decision: decision,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String outboxId,
                required String decision,
                required int resolvedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncResolutionsCompanion.insert(
                outboxId: outboxId,
                decision: decision,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSyncResolutionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSyncResolutionsTable,
      LocalSyncResolutionRow,
      $$LocalSyncResolutionsTableFilterComposer,
      $$LocalSyncResolutionsTableOrderingComposer,
      $$LocalSyncResolutionsTableAnnotationComposer,
      $$LocalSyncResolutionsTableCreateCompanionBuilder,
      $$LocalSyncResolutionsTableUpdateCompanionBuilder,
      (
        LocalSyncResolutionRow,
        BaseReferences<
          _$AppDatabase,
          $LocalSyncResolutionsTable,
          LocalSyncResolutionRow
        >,
      ),
      LocalSyncResolutionRow,
      PrefetchHooks Function()
    >;
typedef $$LocalUserSportsTableCreateCompanionBuilder =
    LocalUserSportsCompanion Function({
      required String id,
      Value<String?> sportCode,
      Value<String?> customName,
      Value<String?> customCategory,
      required String role,
      required String priority,
      Value<String> experienceLevel,
      Value<String?> lastRegularActivityDate,
      Value<bool> returnAfterPause,
      Value<String?> note,
      Value<int?> frequencyPerWeek,
      Value<int?> typicalDurationMinutes,
      Value<String?> typicalIntensity,
      Value<String?> environment,
      Value<String?> fixedDays,
      Value<String> status,
      required int createdAt,
      required int updatedAt,
      required int rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$LocalUserSportsTableUpdateCompanionBuilder =
    LocalUserSportsCompanion Function({
      Value<String> id,
      Value<String?> sportCode,
      Value<String?> customName,
      Value<String?> customCategory,
      Value<String> role,
      Value<String> priority,
      Value<String> experienceLevel,
      Value<String?> lastRegularActivityDate,
      Value<bool> returnAfterPause,
      Value<String?> note,
      Value<int?> frequencyPerWeek,
      Value<int?> typicalDurationMinutes,
      Value<String?> typicalIntensity,
      Value<String?> environment,
      Value<String?> fixedDays,
      Value<String> status,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });

final class $$LocalUserSportsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalUserSportsTable,
          LocalUserSportRow
        > {
  $$LocalUserSportsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$LocalGoalsTable, List<LocalGoalRow>>
  _localGoalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.localGoals,
    aliasName: 'local_user_sports__id__local_goals__user_sport_id',
  );

  $$LocalGoalsTableProcessedTableManager get localGoalsRefs {
    final manager = $$LocalGoalsTableTableManager(
      $_db,
      $_db.localGoals,
    ).filter((f) => f.userSportId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localGoalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalUserSportsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUserSportsTable> {
  $$LocalUserSportsTableFilterComposer({
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

  ColumnFilters<String> get sportCode => $composableBuilder(
    column: $table.sportCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customCategory => $composableBuilder(
    column: $table.customCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get experienceLevel => $composableBuilder(
    column: $table.experienceLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastRegularActivityDate => $composableBuilder(
    column: $table.lastRegularActivityDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get returnAfterPause => $composableBuilder(
    column: $table.returnAfterPause,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frequencyPerWeek => $composableBuilder(
    column: $table.frequencyPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get typicalDurationMinutes => $composableBuilder(
    column: $table.typicalDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typicalIntensity => $composableBuilder(
    column: $table.typicalIntensity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get environment => $composableBuilder(
    column: $table.environment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fixedDays => $composableBuilder(
    column: $table.fixedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localGoalsRefs(
    Expression<bool> Function($$LocalGoalsTableFilterComposer f) f,
  ) {
    final $$LocalGoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localGoals,
      getReferencedColumn: (t) => t.userSportId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalGoalsTableFilterComposer(
            $db: $db,
            $table: $db.localGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalUserSportsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUserSportsTable> {
  $$LocalUserSportsTableOrderingComposer({
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

  ColumnOrderings<String> get sportCode => $composableBuilder(
    column: $table.sportCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customCategory => $composableBuilder(
    column: $table.customCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get experienceLevel => $composableBuilder(
    column: $table.experienceLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastRegularActivityDate => $composableBuilder(
    column: $table.lastRegularActivityDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get returnAfterPause => $composableBuilder(
    column: $table.returnAfterPause,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequencyPerWeek => $composableBuilder(
    column: $table.frequencyPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get typicalDurationMinutes => $composableBuilder(
    column: $table.typicalDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typicalIntensity => $composableBuilder(
    column: $table.typicalIntensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get environment => $composableBuilder(
    column: $table.environment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fixedDays => $composableBuilder(
    column: $table.fixedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUserSportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUserSportsTable> {
  $$LocalUserSportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sportCode =>
      $composableBuilder(column: $table.sportCode, builder: (column) => column);

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customCategory => $composableBuilder(
    column: $table.customCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get experienceLevel => $composableBuilder(
    column: $table.experienceLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastRegularActivityDate => $composableBuilder(
    column: $table.lastRegularActivityDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get returnAfterPause => $composableBuilder(
    column: $table.returnAfterPause,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get frequencyPerWeek => $composableBuilder(
    column: $table.frequencyPerWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get typicalDurationMinutes => $composableBuilder(
    column: $table.typicalDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get typicalIntensity => $composableBuilder(
    column: $table.typicalIntensity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get environment => $composableBuilder(
    column: $table.environment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fixedDays =>
      $composableBuilder(column: $table.fixedDays, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  Expression<T> localGoalsRefs<T extends Object>(
    Expression<T> Function($$LocalGoalsTableAnnotationComposer a) f,
  ) {
    final $$LocalGoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localGoals,
      getReferencedColumn: (t) => t.userSportId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalGoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.localGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalUserSportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUserSportsTable,
          LocalUserSportRow,
          $$LocalUserSportsTableFilterComposer,
          $$LocalUserSportsTableOrderingComposer,
          $$LocalUserSportsTableAnnotationComposer,
          $$LocalUserSportsTableCreateCompanionBuilder,
          $$LocalUserSportsTableUpdateCompanionBuilder,
          (LocalUserSportRow, $$LocalUserSportsTableReferences),
          LocalUserSportRow,
          PrefetchHooks Function({bool localGoalsRefs})
        > {
  $$LocalUserSportsTableTableManager(
    _$AppDatabase db,
    $LocalUserSportsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUserSportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUserSportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUserSportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> sportCode = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String?> customCategory = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> experienceLevel = const Value.absent(),
                Value<String?> lastRegularActivityDate = const Value.absent(),
                Value<bool> returnAfterPause = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> frequencyPerWeek = const Value.absent(),
                Value<int?> typicalDurationMinutes = const Value.absent(),
                Value<String?> typicalIntensity = const Value.absent(),
                Value<String?> environment = const Value.absent(),
                Value<String?> fixedDays = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowVersion = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUserSportsCompanion(
                id: id,
                sportCode: sportCode,
                customName: customName,
                customCategory: customCategory,
                role: role,
                priority: priority,
                experienceLevel: experienceLevel,
                lastRegularActivityDate: lastRegularActivityDate,
                returnAfterPause: returnAfterPause,
                note: note,
                frequencyPerWeek: frequencyPerWeek,
                typicalDurationMinutes: typicalDurationMinutes,
                typicalIntensity: typicalIntensity,
                environment: environment,
                fixedDays: fixedDays,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> sportCode = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String?> customCategory = const Value.absent(),
                required String role,
                required String priority,
                Value<String> experienceLevel = const Value.absent(),
                Value<String?> lastRegularActivityDate = const Value.absent(),
                Value<bool> returnAfterPause = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> frequencyPerWeek = const Value.absent(),
                Value<int?> typicalDurationMinutes = const Value.absent(),
                Value<String?> typicalIntensity = const Value.absent(),
                Value<String?> environment = const Value.absent(),
                Value<String?> fixedDays = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required int rowVersion,
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUserSportsCompanion.insert(
                id: id,
                sportCode: sportCode,
                customName: customName,
                customCategory: customCategory,
                role: role,
                priority: priority,
                experienceLevel: experienceLevel,
                lastRegularActivityDate: lastRegularActivityDate,
                returnAfterPause: returnAfterPause,
                note: note,
                frequencyPerWeek: frequencyPerWeek,
                typicalDurationMinutes: typicalDurationMinutes,
                typicalIntensity: typicalIntensity,
                environment: environment,
                fixedDays: fixedDays,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalUserSportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localGoalsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (localGoalsRefs) db.localGoals],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localGoalsRefs)
                    await $_getPrefetchedData<
                      LocalUserSportRow,
                      $LocalUserSportsTable,
                      LocalGoalRow
                    >(
                      currentTable: table,
                      referencedTable: $$LocalUserSportsTableReferences
                          ._localGoalsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LocalUserSportsTableReferences(
                            db,
                            table,
                            p0,
                          ).localGoalsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.userSportId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LocalUserSportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUserSportsTable,
      LocalUserSportRow,
      $$LocalUserSportsTableFilterComposer,
      $$LocalUserSportsTableOrderingComposer,
      $$LocalUserSportsTableAnnotationComposer,
      $$LocalUserSportsTableCreateCompanionBuilder,
      $$LocalUserSportsTableUpdateCompanionBuilder,
      (LocalUserSportRow, $$LocalUserSportsTableReferences),
      LocalUserSportRow,
      PrefetchHooks Function({bool localGoalsRefs})
    >;
typedef $$LocalGoalsTableCreateCompanionBuilder =
    LocalGoalsCompanion Function({
      required String id,
      required String title,
      required String goalType,
      required String priority,
      Value<String> horizon,
      Value<String> status,
      Value<String?> userSportId,
      Value<String?> targetLocalDate,
      Value<String?> note,
      required int createdAt,
      required int updatedAt,
      required int rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$LocalGoalsTableUpdateCompanionBuilder =
    LocalGoalsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> goalType,
      Value<String> priority,
      Value<String> horizon,
      Value<String> status,
      Value<String?> userSportId,
      Value<String?> targetLocalDate,
      Value<String?> note,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });

final class $$LocalGoalsTableReferences
    extends BaseReferences<_$AppDatabase, $LocalGoalsTable, LocalGoalRow> {
  $$LocalGoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalUserSportsTable _userSportIdTable(_$AppDatabase db) => db
      .localUserSports
      .createAlias('local_goals__user_sport_id__local_user_sports__id');

  $$LocalUserSportsTableProcessedTableManager? get userSportId {
    final $_column = $_itemColumn<String>('user_sport_id');
    if ($_column == null) return null;
    final manager = $$LocalUserSportsTableTableManager(
      $_db,
      $_db.localUserSports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userSportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalGoalsTable> {
  $$LocalGoalsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get horizon => $composableBuilder(
    column: $table.horizon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetLocalDate => $composableBuilder(
    column: $table.targetLocalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalUserSportsTableFilterComposer get userSportId {
    final $$LocalUserSportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userSportId,
      referencedTable: $db.localUserSports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalUserSportsTableFilterComposer(
            $db: $db,
            $table: $db.localUserSports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalGoalsTable> {
  $$LocalGoalsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get horizon => $composableBuilder(
    column: $table.horizon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetLocalDate => $composableBuilder(
    column: $table.targetLocalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalUserSportsTableOrderingComposer get userSportId {
    final $$LocalUserSportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userSportId,
      referencedTable: $db.localUserSports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalUserSportsTableOrderingComposer(
            $db: $db,
            $table: $db.localUserSports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalGoalsTable> {
  $$LocalGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get goalType =>
      $composableBuilder(column: $table.goalType, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get horizon =>
      $composableBuilder(column: $table.horizon, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get targetLocalDate => $composableBuilder(
    column: $table.targetLocalDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  $$LocalUserSportsTableAnnotationComposer get userSportId {
    final $$LocalUserSportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userSportId,
      referencedTable: $db.localUserSports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalUserSportsTableAnnotationComposer(
            $db: $db,
            $table: $db.localUserSports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalGoalsTable,
          LocalGoalRow,
          $$LocalGoalsTableFilterComposer,
          $$LocalGoalsTableOrderingComposer,
          $$LocalGoalsTableAnnotationComposer,
          $$LocalGoalsTableCreateCompanionBuilder,
          $$LocalGoalsTableUpdateCompanionBuilder,
          (LocalGoalRow, $$LocalGoalsTableReferences),
          LocalGoalRow,
          PrefetchHooks Function({bool userSportId})
        > {
  $$LocalGoalsTableTableManager(_$AppDatabase db, $LocalGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> goalType = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> horizon = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> userSportId = const Value.absent(),
                Value<String?> targetLocalDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowVersion = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalGoalsCompanion(
                id: id,
                title: title,
                goalType: goalType,
                priority: priority,
                horizon: horizon,
                status: status,
                userSportId: userSportId,
                targetLocalDate: targetLocalDate,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String goalType,
                required String priority,
                Value<String> horizon = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> userSportId = const Value.absent(),
                Value<String?> targetLocalDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required int rowVersion,
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalGoalsCompanion.insert(
                id: id,
                title: title,
                goalType: goalType,
                priority: priority,
                horizon: horizon,
                status: status,
                userSportId: userSportId,
                targetLocalDate: targetLocalDate,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalGoalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userSportId = false}) {
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
                    if (userSportId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userSportId,
                                referencedTable: $$LocalGoalsTableReferences
                                    ._userSportIdTable(db),
                                referencedColumn: $$LocalGoalsTableReferences
                                    ._userSportIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$LocalGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalGoalsTable,
      LocalGoalRow,
      $$LocalGoalsTableFilterComposer,
      $$LocalGoalsTableOrderingComposer,
      $$LocalGoalsTableAnnotationComposer,
      $$LocalGoalsTableCreateCompanionBuilder,
      $$LocalGoalsTableUpdateCompanionBuilder,
      (LocalGoalRow, $$LocalGoalsTableReferences),
      LocalGoalRow,
      PrefetchHooks Function({bool userSportId})
    >;
typedef $$LocalAvailabilityRulesTableCreateCompanionBuilder =
    LocalAvailabilityRulesCompanion Function({
      required String id,
      required String dayOfWeek,
      required String level,
      Value<int?> budgetMinutes,
      Value<String?> preferredPartOfDay,
      Value<String?> note,
      required int createdAt,
      required int updatedAt,
      required int rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$LocalAvailabilityRulesTableUpdateCompanionBuilder =
    LocalAvailabilityRulesCompanion Function({
      Value<String> id,
      Value<String> dayOfWeek,
      Value<String> level,
      Value<int?> budgetMinutes,
      Value<String?> preferredPartOfDay,
      Value<String?> note,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });

class $$LocalAvailabilityRulesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAvailabilityRulesTable> {
  $$LocalAvailabilityRulesTableFilterComposer({
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

  ColumnFilters<String> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get budgetMinutes => $composableBuilder(
    column: $table.budgetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredPartOfDay => $composableBuilder(
    column: $table.preferredPartOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAvailabilityRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAvailabilityRulesTable> {
  $$LocalAvailabilityRulesTableOrderingComposer({
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

  ColumnOrderings<String> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get budgetMinutes => $composableBuilder(
    column: $table.budgetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredPartOfDay => $composableBuilder(
    column: $table.preferredPartOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAvailabilityRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAvailabilityRulesTable> {
  $$LocalAvailabilityRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get budgetMinutes => $composableBuilder(
    column: $table.budgetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredPartOfDay => $composableBuilder(
    column: $table.preferredPartOfDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$LocalAvailabilityRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAvailabilityRulesTable,
          LocalAvailabilityRuleRow,
          $$LocalAvailabilityRulesTableFilterComposer,
          $$LocalAvailabilityRulesTableOrderingComposer,
          $$LocalAvailabilityRulesTableAnnotationComposer,
          $$LocalAvailabilityRulesTableCreateCompanionBuilder,
          $$LocalAvailabilityRulesTableUpdateCompanionBuilder,
          (
            LocalAvailabilityRuleRow,
            BaseReferences<
              _$AppDatabase,
              $LocalAvailabilityRulesTable,
              LocalAvailabilityRuleRow
            >,
          ),
          LocalAvailabilityRuleRow,
          PrefetchHooks Function()
        > {
  $$LocalAvailabilityRulesTableTableManager(
    _$AppDatabase db,
    $LocalAvailabilityRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAvailabilityRulesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalAvailabilityRulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalAvailabilityRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dayOfWeek = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<int?> budgetMinutes = const Value.absent(),
                Value<String?> preferredPartOfDay = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowVersion = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAvailabilityRulesCompanion(
                id: id,
                dayOfWeek: dayOfWeek,
                level: level,
                budgetMinutes: budgetMinutes,
                preferredPartOfDay: preferredPartOfDay,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String dayOfWeek,
                required String level,
                Value<int?> budgetMinutes = const Value.absent(),
                Value<String?> preferredPartOfDay = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required int rowVersion,
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAvailabilityRulesCompanion.insert(
                id: id,
                dayOfWeek: dayOfWeek,
                level: level,
                budgetMinutes: budgetMinutes,
                preferredPartOfDay: preferredPartOfDay,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAvailabilityRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAvailabilityRulesTable,
      LocalAvailabilityRuleRow,
      $$LocalAvailabilityRulesTableFilterComposer,
      $$LocalAvailabilityRulesTableOrderingComposer,
      $$LocalAvailabilityRulesTableAnnotationComposer,
      $$LocalAvailabilityRulesTableCreateCompanionBuilder,
      $$LocalAvailabilityRulesTableUpdateCompanionBuilder,
      (
        LocalAvailabilityRuleRow,
        BaseReferences<
          _$AppDatabase,
          $LocalAvailabilityRulesTable,
          LocalAvailabilityRuleRow
        >,
      ),
      LocalAvailabilityRuleRow,
      PrefetchHooks Function()
    >;
typedef $$LocalEquipmentItemsTableCreateCompanionBuilder =
    LocalEquipmentItemsCompanion Function({
      required String id,
      Value<String?> equipmentCode,
      Value<String?> customName,
      Value<String?> note,
      Value<String> status,
      required int createdAt,
      required int updatedAt,
      required int rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$LocalEquipmentItemsTableUpdateCompanionBuilder =
    LocalEquipmentItemsCompanion Function({
      Value<String> id,
      Value<String?> equipmentCode,
      Value<String?> customName,
      Value<String?> note,
      Value<String> status,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });

class $$LocalEquipmentItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalEquipmentItemsTable> {
  $$LocalEquipmentItemsTableFilterComposer({
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

  ColumnFilters<String> get equipmentCode => $composableBuilder(
    column: $table.equipmentCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalEquipmentItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalEquipmentItemsTable> {
  $$LocalEquipmentItemsTableOrderingComposer({
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

  ColumnOrderings<String> get equipmentCode => $composableBuilder(
    column: $table.equipmentCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalEquipmentItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalEquipmentItemsTable> {
  $$LocalEquipmentItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get equipmentCode => $composableBuilder(
    column: $table.equipmentCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$LocalEquipmentItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalEquipmentItemsTable,
          LocalEquipmentItemRow,
          $$LocalEquipmentItemsTableFilterComposer,
          $$LocalEquipmentItemsTableOrderingComposer,
          $$LocalEquipmentItemsTableAnnotationComposer,
          $$LocalEquipmentItemsTableCreateCompanionBuilder,
          $$LocalEquipmentItemsTableUpdateCompanionBuilder,
          (
            LocalEquipmentItemRow,
            BaseReferences<
              _$AppDatabase,
              $LocalEquipmentItemsTable,
              LocalEquipmentItemRow
            >,
          ),
          LocalEquipmentItemRow,
          PrefetchHooks Function()
        > {
  $$LocalEquipmentItemsTableTableManager(
    _$AppDatabase db,
    $LocalEquipmentItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalEquipmentItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalEquipmentItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalEquipmentItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> equipmentCode = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowVersion = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalEquipmentItemsCompanion(
                id: id,
                equipmentCode: equipmentCode,
                customName: customName,
                note: note,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> equipmentCode = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required int rowVersion,
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalEquipmentItemsCompanion.insert(
                id: id,
                equipmentCode: equipmentCode,
                customName: customName,
                note: note,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalEquipmentItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalEquipmentItemsTable,
      LocalEquipmentItemRow,
      $$LocalEquipmentItemsTableFilterComposer,
      $$LocalEquipmentItemsTableOrderingComposer,
      $$LocalEquipmentItemsTableAnnotationComposer,
      $$LocalEquipmentItemsTableCreateCompanionBuilder,
      $$LocalEquipmentItemsTableUpdateCompanionBuilder,
      (
        LocalEquipmentItemRow,
        BaseReferences<
          _$AppDatabase,
          $LocalEquipmentItemsTable,
          LocalEquipmentItemRow
        >,
      ),
      LocalEquipmentItemRow,
      PrefetchHooks Function()
    >;
typedef $$LocalConstraintsTableCreateCompanionBuilder =
    LocalConstraintsCompanion Function({
      required String id,
      required String title,
      Value<String?> note,
      Value<String> status,
      required int createdAt,
      required int updatedAt,
      required int rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$LocalConstraintsTableUpdateCompanionBuilder =
    LocalConstraintsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> note,
      Value<String> status,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });

class $$LocalConstraintsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalConstraintsTable> {
  $$LocalConstraintsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalConstraintsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalConstraintsTable> {
  $$LocalConstraintsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalConstraintsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalConstraintsTable> {
  $$LocalConstraintsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$LocalConstraintsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalConstraintsTable,
          LocalConstraintRow,
          $$LocalConstraintsTableFilterComposer,
          $$LocalConstraintsTableOrderingComposer,
          $$LocalConstraintsTableAnnotationComposer,
          $$LocalConstraintsTableCreateCompanionBuilder,
          $$LocalConstraintsTableUpdateCompanionBuilder,
          (
            LocalConstraintRow,
            BaseReferences<
              _$AppDatabase,
              $LocalConstraintsTable,
              LocalConstraintRow
            >,
          ),
          LocalConstraintRow,
          PrefetchHooks Function()
        > {
  $$LocalConstraintsTableTableManager(
    _$AppDatabase db,
    $LocalConstraintsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalConstraintsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalConstraintsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalConstraintsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowVersion = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalConstraintsCompanion(
                id: id,
                title: title,
                note: note,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required int rowVersion,
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalConstraintsCompanion.insert(
                id: id,
                title: title,
                note: note,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalConstraintsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalConstraintsTable,
      LocalConstraintRow,
      $$LocalConstraintsTableFilterComposer,
      $$LocalConstraintsTableOrderingComposer,
      $$LocalConstraintsTableAnnotationComposer,
      $$LocalConstraintsTableCreateCompanionBuilder,
      $$LocalConstraintsTableUpdateCompanionBuilder,
      (
        LocalConstraintRow,
        BaseReferences<
          _$AppDatabase,
          $LocalConstraintsTable,
          LocalConstraintRow
        >,
      ),
      LocalConstraintRow,
      PrefetchHooks Function()
    >;
typedef $$LocalTrainingPlansTableCreateCompanionBuilder =
    LocalTrainingPlansCompanion Function({
      required String id,
      required String title,
      Value<String?> note,
      Value<String> status,
      required int createdAt,
      required int updatedAt,
      required int rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$LocalTrainingPlansTableUpdateCompanionBuilder =
    LocalTrainingPlansCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> note,
      Value<String> status,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowVersion,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });

class $$LocalTrainingPlansTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTrainingPlansTable> {
  $$LocalTrainingPlansTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTrainingPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTrainingPlansTable> {
  $$LocalTrainingPlansTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTrainingPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTrainingPlansTable> {
  $$LocalTrainingPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$LocalTrainingPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTrainingPlansTable,
          LocalTrainingPlanRow,
          $$LocalTrainingPlansTableFilterComposer,
          $$LocalTrainingPlansTableOrderingComposer,
          $$LocalTrainingPlansTableAnnotationComposer,
          $$LocalTrainingPlansTableCreateCompanionBuilder,
          $$LocalTrainingPlansTableUpdateCompanionBuilder,
          (
            LocalTrainingPlanRow,
            BaseReferences<
              _$AppDatabase,
              $LocalTrainingPlansTable,
              LocalTrainingPlanRow
            >,
          ),
          LocalTrainingPlanRow,
          PrefetchHooks Function()
        > {
  $$LocalTrainingPlansTableTableManager(
    _$AppDatabase db,
    $LocalTrainingPlansTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTrainingPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTrainingPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTrainingPlansTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowVersion = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTrainingPlansCompanion(
                id: id,
                title: title,
                note: note,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required int rowVersion,
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTrainingPlansCompanion.insert(
                id: id,
                title: title,
                note: note,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowVersion: rowVersion,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTrainingPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTrainingPlansTable,
      LocalTrainingPlanRow,
      $$LocalTrainingPlansTableFilterComposer,
      $$LocalTrainingPlansTableOrderingComposer,
      $$LocalTrainingPlansTableAnnotationComposer,
      $$LocalTrainingPlansTableCreateCompanionBuilder,
      $$LocalTrainingPlansTableUpdateCompanionBuilder,
      (
        LocalTrainingPlanRow,
        BaseReferences<
          _$AppDatabase,
          $LocalTrainingPlansTable,
          LocalTrainingPlanRow
        >,
      ),
      LocalTrainingPlanRow,
      PrefetchHooks Function()
    >;
typedef $$LocalCalendarChangesTableCreateCompanionBuilder =
    LocalCalendarChangesCompanion Function({
      required String id,
      required String workoutInstanceId,
      required String changeType,
      Value<String?> fromLocalDate,
      Value<String?> toLocalDate,
      Value<String?> replacementInstanceId,
      required int createdAt,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$LocalCalendarChangesTableUpdateCompanionBuilder =
    LocalCalendarChangesCompanion Function({
      Value<String> id,
      Value<String> workoutInstanceId,
      Value<String> changeType,
      Value<String?> fromLocalDate,
      Value<String?> toLocalDate,
      Value<String?> replacementInstanceId,
      Value<int> createdAt,
      Value<String> ownerId,
      Value<String> syncState,
      Value<int> rowid,
    });

final class $$LocalCalendarChangesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalCalendarChangesTable,
          LocalCalendarChangeRow
        > {
  $$LocalCalendarChangesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalWorkoutInstancesTable _workoutInstanceIdTable(
    _$AppDatabase db,
  ) => db.localWorkoutInstances.createAlias(
    'local_calendar_changes__workout_instance_id__local_workout_instances__id',
  );

  $$LocalWorkoutInstancesTableProcessedTableManager get workoutInstanceId {
    final $_column = $_itemColumn<String>('workout_instance_id')!;

    final manager = $$LocalWorkoutInstancesTableTableManager(
      $_db,
      $_db.localWorkoutInstances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutInstanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LocalWorkoutInstancesTable _replacementInstanceIdTable(
    _$AppDatabase db,
  ) => db.localWorkoutInstances.createAlias(
    'local_calendar_changes__replacement_instance_id__local_workout_instances__id',
  );

  $$LocalWorkoutInstancesTableProcessedTableManager? get replacementInstanceId {
    final $_column = $_itemColumn<String>('replacement_instance_id');
    if ($_column == null) return null;
    final manager = $$LocalWorkoutInstancesTableTableManager(
      $_db,
      $_db.localWorkoutInstances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _replacementInstanceIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalCalendarChangesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCalendarChangesTable> {
  $$LocalCalendarChangesTableFilterComposer({
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

  ColumnFilters<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromLocalDate => $composableBuilder(
    column: $table.fromLocalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toLocalDate => $composableBuilder(
    column: $table.toLocalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalWorkoutInstancesTableFilterComposer get workoutInstanceId {
    final $$LocalWorkoutInstancesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutInstanceId,
          referencedTable: $db.localWorkoutInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutInstancesTableFilterComposer(
                $db: $db,
                $table: $db.localWorkoutInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$LocalWorkoutInstancesTableFilterComposer get replacementInstanceId {
    final $$LocalWorkoutInstancesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.replacementInstanceId,
          referencedTable: $db.localWorkoutInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutInstancesTableFilterComposer(
                $db: $db,
                $table: $db.localWorkoutInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalCalendarChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCalendarChangesTable> {
  $$LocalCalendarChangesTableOrderingComposer({
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

  ColumnOrderings<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromLocalDate => $composableBuilder(
    column: $table.fromLocalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toLocalDate => $composableBuilder(
    column: $table.toLocalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalWorkoutInstancesTableOrderingComposer get workoutInstanceId {
    final $$LocalWorkoutInstancesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutInstanceId,
          referencedTable: $db.localWorkoutInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutInstancesTableOrderingComposer(
                $db: $db,
                $table: $db.localWorkoutInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$LocalWorkoutInstancesTableOrderingComposer get replacementInstanceId {
    final $$LocalWorkoutInstancesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.replacementInstanceId,
          referencedTable: $db.localWorkoutInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutInstancesTableOrderingComposer(
                $db: $db,
                $table: $db.localWorkoutInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalCalendarChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCalendarChangesTable> {
  $$LocalCalendarChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fromLocalDate => $composableBuilder(
    column: $table.fromLocalDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toLocalDate => $composableBuilder(
    column: $table.toLocalDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  $$LocalWorkoutInstancesTableAnnotationComposer get workoutInstanceId {
    final $$LocalWorkoutInstancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutInstanceId,
          referencedTable: $db.localWorkoutInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutInstancesTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$LocalWorkoutInstancesTableAnnotationComposer get replacementInstanceId {
    final $$LocalWorkoutInstancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.replacementInstanceId,
          referencedTable: $db.localWorkoutInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalWorkoutInstancesTableAnnotationComposer(
                $db: $db,
                $table: $db.localWorkoutInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalCalendarChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCalendarChangesTable,
          LocalCalendarChangeRow,
          $$LocalCalendarChangesTableFilterComposer,
          $$LocalCalendarChangesTableOrderingComposer,
          $$LocalCalendarChangesTableAnnotationComposer,
          $$LocalCalendarChangesTableCreateCompanionBuilder,
          $$LocalCalendarChangesTableUpdateCompanionBuilder,
          (LocalCalendarChangeRow, $$LocalCalendarChangesTableReferences),
          LocalCalendarChangeRow,
          PrefetchHooks Function({
            bool workoutInstanceId,
            bool replacementInstanceId,
          })
        > {
  $$LocalCalendarChangesTableTableManager(
    _$AppDatabase db,
    $LocalCalendarChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCalendarChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCalendarChangesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalCalendarChangesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutInstanceId = const Value.absent(),
                Value<String> changeType = const Value.absent(),
                Value<String?> fromLocalDate = const Value.absent(),
                Value<String?> toLocalDate = const Value.absent(),
                Value<String?> replacementInstanceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCalendarChangesCompanion(
                id: id,
                workoutInstanceId: workoutInstanceId,
                changeType: changeType,
                fromLocalDate: fromLocalDate,
                toLocalDate: toLocalDate,
                replacementInstanceId: replacementInstanceId,
                createdAt: createdAt,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workoutInstanceId,
                required String changeType,
                Value<String?> fromLocalDate = const Value.absent(),
                Value<String?> toLocalDate = const Value.absent(),
                Value<String?> replacementInstanceId = const Value.absent(),
                required int createdAt,
                Value<String> ownerId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCalendarChangesCompanion.insert(
                id: id,
                workoutInstanceId: workoutInstanceId,
                changeType: changeType,
                fromLocalDate: fromLocalDate,
                toLocalDate: toLocalDate,
                replacementInstanceId: replacementInstanceId,
                createdAt: createdAt,
                ownerId: ownerId,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalCalendarChangesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutInstanceId = false, replacementInstanceId = false}) {
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
                        if (workoutInstanceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutInstanceId,
                                    referencedTable:
                                        $$LocalCalendarChangesTableReferences
                                            ._workoutInstanceIdTable(db),
                                    referencedColumn:
                                        $$LocalCalendarChangesTableReferences
                                            ._workoutInstanceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (replacementInstanceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.replacementInstanceId,
                                    referencedTable:
                                        $$LocalCalendarChangesTableReferences
                                            ._replacementInstanceIdTable(db),
                                    referencedColumn:
                                        $$LocalCalendarChangesTableReferences
                                            ._replacementInstanceIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$LocalCalendarChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCalendarChangesTable,
      LocalCalendarChangeRow,
      $$LocalCalendarChangesTableFilterComposer,
      $$LocalCalendarChangesTableOrderingComposer,
      $$LocalCalendarChangesTableAnnotationComposer,
      $$LocalCalendarChangesTableCreateCompanionBuilder,
      $$LocalCalendarChangesTableUpdateCompanionBuilder,
      (LocalCalendarChangeRow, $$LocalCalendarChangesTableReferences),
      LocalCalendarChangeRow,
      PrefetchHooks Function({
        bool workoutInstanceId,
        bool replacementInstanceId,
      })
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalWorkoutInstancesTableTableManager get localWorkoutInstances =>
      $$LocalWorkoutInstancesTableTableManager(_db, _db.localWorkoutInstances);
  $$LocalWorkoutSectionsTableTableManager get localWorkoutSections =>
      $$LocalWorkoutSectionsTableTableManager(_db, _db.localWorkoutSections);
  $$LocalWorkoutStepsTableTableManager get localWorkoutSteps =>
      $$LocalWorkoutStepsTableTableManager(_db, _db.localWorkoutSteps);
  $$LocalSetPlansTableTableManager get localSetPlans =>
      $$LocalSetPlansTableTableManager(_db, _db.localSetPlans);
  $$LocalWorkoutSessionsTableTableManager get localWorkoutSessions =>
      $$LocalWorkoutSessionsTableTableManager(_db, _db.localWorkoutSessions);
  $$LocalStepPerformancesTableTableManager get localStepPerformances =>
      $$LocalStepPerformancesTableTableManager(_db, _db.localStepPerformances);
  $$LocalSetPerformancesTableTableManager get localSetPerformances =>
      $$LocalSetPerformancesTableTableManager(_db, _db.localSetPerformances);
  $$LocalWorkoutFeedbackTableTableManager get localWorkoutFeedback =>
      $$LocalWorkoutFeedbackTableTableManager(_db, _db.localWorkoutFeedback);
  $$LocalActivitySummariesTableTableManager get localActivitySummaries =>
      $$LocalActivitySummariesTableTableManager(
        _db,
        _db.localActivitySummaries,
      );
  $$LocalAppStateTableTableManager get localAppState =>
      $$LocalAppStateTableTableManager(_db, _db.localAppState);
  $$LocalOutboxTableTableManager get localOutbox =>
      $$LocalOutboxTableTableManager(_db, _db.localOutbox);
  $$LocalSyncedVersionsTableTableManager get localSyncedVersions =>
      $$LocalSyncedVersionsTableTableManager(_db, _db.localSyncedVersions);
  $$LocalSyncResolutionsTableTableManager get localSyncResolutions =>
      $$LocalSyncResolutionsTableTableManager(_db, _db.localSyncResolutions);
  $$LocalUserSportsTableTableManager get localUserSports =>
      $$LocalUserSportsTableTableManager(_db, _db.localUserSports);
  $$LocalGoalsTableTableManager get localGoals =>
      $$LocalGoalsTableTableManager(_db, _db.localGoals);
  $$LocalAvailabilityRulesTableTableManager get localAvailabilityRules =>
      $$LocalAvailabilityRulesTableTableManager(
        _db,
        _db.localAvailabilityRules,
      );
  $$LocalEquipmentItemsTableTableManager get localEquipmentItems =>
      $$LocalEquipmentItemsTableTableManager(_db, _db.localEquipmentItems);
  $$LocalConstraintsTableTableManager get localConstraints =>
      $$LocalConstraintsTableTableManager(_db, _db.localConstraints);
  $$LocalTrainingPlansTableTableManager get localTrainingPlans =>
      $$LocalTrainingPlansTableTableManager(_db, _db.localTrainingPlans);
  $$LocalCalendarChangesTableTableManager get localCalendarChanges =>
      $$LocalCalendarChangesTableTableManager(_db, _db.localCalendarChanges);
}
