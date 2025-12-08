import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Source of a command field
class FieldSource extends Equatable {
  const FieldSource._({
    required this.type,
    this.readModelId,
    this.fieldPath,
    this.entityId,
    this.expression,
  });

  const FieldSource.uiInput()
      : this._(
          type: FieldSourceType.uiInput,
        );

  const FieldSource.readModel({
    required String readModelId,
    required String fieldPath,
  }) : this._(
          type: FieldSourceType.readModel,
          readModelId: readModelId,
          fieldPath: fieldPath,
        );

  const FieldSource.entity({
    required String entityId,
    required String fieldPath,
  }) : this._(
          type: FieldSourceType.entity,
          entityId: entityId,
          fieldPath: fieldPath,
        );

  const FieldSource.computed({required String expression})
      : this._(
          type: FieldSourceType.computed,
          expression: expression,
        );

  const FieldSource.custom()
      : this._(
          type: FieldSourceType.custom,
        );

  final FieldSourceType type;
  final String? readModelId;
  final String? fieldPath;
  final String? entityId;
  final String? expression;

  Map<String, dynamic> toJson() {
    switch (type) {
      case FieldSourceType.uiInput:
        return {'type': 'UiInput'};
      case FieldSourceType.readModel:
        return {
          'type': 'ReadModel',
          'readModelId': readModelId,
          'fieldPath': fieldPath,
        };
      case FieldSourceType.entity:
        return {
          'type': 'Entity',
          'entityId': entityId,
          'fieldPath': fieldPath,
        };
      case FieldSourceType.computed:
        return {
          'type': 'Computed',
          'expression': expression,
        };
      case FieldSourceType.custom:
        return {'type': 'Custom'};
    }
  }

  factory FieldSource.fromJson(dynamic json) {
    if (json is String) {
      // Handle simple string case (legacy)
      if (json == 'UiInput') return const FieldSource.uiInput();
      if (json == 'Custom') return const FieldSource.custom();
      return const FieldSource.uiInput();
    }

    if (json is! Map<String, dynamic>) {
      return const FieldSource.uiInput();
    }

    final type = json['type'] as String?;
    switch (type) {
      case 'UiInput':
        return const FieldSource.uiInput();
      case 'ReadModel':
        return FieldSource.readModel(
          readModelId: json['readModelId'] as String,
          fieldPath: json['fieldPath'] as String,
        );
      case 'Entity':
        return FieldSource.entity(
          entityId: json['entityId'] as String,
          fieldPath: json['fieldPath'] as String,
        );
      case 'Computed':
        return FieldSource.computed(
          expression: json['expression'] as String,
        );
      case 'Custom':
        return const FieldSource.custom();
      default:
        return const FieldSource.uiInput();
    }
  }

  @override
  List<Object?> get props => [type, readModelId, fieldPath, entityId, expression];
}

enum FieldSourceType {
  uiInput,
  readModel,
  entity,
  computed,
  custom,
}

/// Validation operator
enum ValidationOperator {
  equals,
  notEquals,
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  inList,
  notIn,
  matches,
  minLength,
  maxLength,
  range;

  String toJson() => name;

  static ValidationOperator fromJson(String value) {
    return ValidationOperator.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ValidationOperator.equals,
    );
  }
}

/// Validation rule for command fields
class CommandValidationRule extends Equatable {
  const CommandValidationRule({
    required this.fieldName,
    required this.operator,
    required this.value,
    required this.errorMessage,
  });

  final String fieldName;
  final ValidationOperator operator;
  final dynamic value;
  final String errorMessage;

  CommandValidationRule copyWith({
    String? fieldName,
    ValidationOperator? operator,
    dynamic value,
    String? errorMessage,
  }) {
    return CommandValidationRule(
      fieldName: fieldName ?? this.fieldName,
      operator: operator ?? this.operator,
      value: value ?? this.value,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'operator': operator.toJson(),
      'value': value,
      'errorMessage': errorMessage,
    };
  }

  factory CommandValidationRule.fromJson(Map<String, dynamic> json) {
    return CommandValidationRule(
      fieldName: json['fieldName'] as String,
      operator: ValidationOperator.fromJson(json['operator'] as String),
      value: json['value'],
      errorMessage: json['errorMessage'] as String,
    );
  }

  @override
  List<Object?> get props => [fieldName, operator, value, errorMessage];
}

/// Precondition operator
enum PreconditionOperator {
  equals,
  notEquals,
  greaterThan,
  lessThan,
  exists,
  notExists,
  custom;

  String toJson() => name;

  static PreconditionOperator fromJson(String value) {
    return PreconditionOperator.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PreconditionOperator.custom,
    );
  }
}

/// Precondition for command execution
class Precondition extends Equatable {
  const Precondition({
    required this.description,
    required this.expression,
    required this.operator,
    required this.errorMessage,
  });

  final String description;
  final String expression;
  final PreconditionOperator operator;
  final String errorMessage;

  Precondition copyWith({
    String? description,
    String? expression,
    PreconditionOperator? operator,
    String? errorMessage,
  }) {
    return Precondition(
      description: description ?? this.description,
      expression: expression ?? this.expression,
      operator: operator ?? this.operator,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'expression': expression,
      'operator': operator.toJson(),
      'errorMessage': errorMessage,
    };
  }

  factory Precondition.fromJson(Map<String, dynamic> json) {
    return Precondition(
      description: json['description'] as String,
      expression: json['expression'] as String,
      operator: PreconditionOperator.fromJson(json['operator'] as String),
      errorMessage: json['errorMessage'] as String,
    );
  }

  @override
  List<Object?> get props => [description, expression, operator, errorMessage];
}

/// Command field definition
class CommandField extends Equatable {
  const CommandField({
    required this.id,
    required this.name,
    required this.fieldType,
    required this.required,
    required this.source,
    this.defaultValue,
    this.description,
    required this.validations,
    required this.displayOrder,
  });

  final String id;
  final String name;
  final String fieldType;
  final bool required;
  final FieldSource source;
  final dynamic defaultValue;
  final String? description;
  final List<CommandValidationRule> validations;
  final int displayOrder;

  factory CommandField.create({
    required String name,
    required String fieldType,
    bool required = false,
    FieldSource source = const FieldSource.uiInput(),
  }) {
    return CommandField(
      id: const Uuid().v4(),
      name: name,
      fieldType: fieldType,
      required: required,
      source: source,
      validations: const [],
      displayOrder: 0,
    );
  }

  CommandField copyWith({
    String? id,
    String? name,
    String? fieldType,
    bool? required,
    FieldSource? source,
    dynamic defaultValue,
    String? description,
    List<CommandValidationRule>? validations,
    int? displayOrder,
  }) {
    return CommandField(
      id: id ?? this.id,
      name: name ?? this.name,
      fieldType: fieldType ?? this.fieldType,
      required: required ?? this.required,
      source: source ?? this.source,
      defaultValue: defaultValue ?? this.defaultValue,
      description: description ?? this.description,
      validations: validations ?? this.validations,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fieldType': fieldType,
      'required': required,
      'source': source.toJson(),
      if (defaultValue != null) 'defaultValue': defaultValue,
      if (description != null) 'description': description,
      'validations': validations.map((v) => v.toJson()).toList(),
      'displayOrder': displayOrder,
    };
  }

  factory CommandField.fromJson(Map<String, dynamic> json) {
    return CommandField(
      id: json['id'] as String,
      name: json['name'] as String,
      fieldType: json['fieldType'] as String,
      required: json['required'] as bool,
      source: FieldSource.fromJson(json['source']),
      defaultValue: json['defaultValue'],
      description: json['description'] as String?,
      validations: (json['validations'] as List<dynamic>?)
              ?.map((v) => CommandValidationRule.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      displayOrder: json['displayOrder'] as int,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        fieldType,
        required,
        source,
        defaultValue,
        description,
        validations,
        displayOrder,
      ];
}

/// Command payload definition
class CommandPayload extends Equatable {
  const CommandPayload({
    required this.fields,
  });

  final List<CommandField> fields;

  factory CommandPayload.empty() {
    return const CommandPayload(fields: []);
  }

  CommandPayload copyWith({
    List<CommandField>? fields,
  }) {
    return CommandPayload(
      fields: fields ?? this.fields,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fields': fields.map((f) => f.toJson()).toList(),
    };
  }

  factory CommandPayload.fromJson(Map<String, dynamic> json) {
    return CommandPayload(
      fields: (json['fields'] as List<dynamic>?)
              ?.map((f) => CommandField.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [fields];
}

/// Command metadata
class CommandMetadata extends Equatable {
  const CommandMetadata({
    required this.version,
    this.tags,
  });

  final String version;
  final List<String>? tags;

  factory CommandMetadata.create() {
    return const CommandMetadata(version: '1.0.0');
  }

  CommandMetadata copyWith({
    String? version,
    List<String>? tags,
  }) {
    return CommandMetadata(
      version: version ?? this.version,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      if (tags != null) 'tags': tags,
    };
  }

  factory CommandMetadata.fromJson(Map<String, dynamic> json) {
    return CommandMetadata(
      version: json['version'] as String? ?? '1.0.0',
      tags: (json['tags'] as List<dynamic>?)?.map((t) => t as String).toList(),
    );
  }

  @override
  List<Object?> get props => [version, tags];
}

/// Command definition
class CommandDefinition extends Equatable {
  const CommandDefinition({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    this.aggregateId,
    required this.payload,
    required this.validations,
    required this.preconditions,
    required this.producedEvents,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final String name;
  final String? description;
  final String? aggregateId;
  final CommandPayload payload;
  final List<CommandValidationRule> validations;
  final List<Precondition> preconditions;
  final List<String> producedEvents;
  final CommandMetadata metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CommandDefinition.create({
    required String projectId,
    required String name,
  }) {
    final now = DateTime.now();
    return CommandDefinition(
      id: const Uuid().v4(),
      projectId: projectId,
      name: name,
      payload: CommandPayload.empty(),
      validations: const [],
      preconditions: const [],
      producedEvents: const [],
      metadata: CommandMetadata.create(),
      createdAt: now,
      updatedAt: now,
    );
  }

  CommandDefinition copyWith({
    String? id,
    String? projectId,
    String? name,
    String? description,
    String? aggregateId,
    CommandPayload? payload,
    List<CommandValidationRule>? validations,
    List<Precondition>? preconditions,
    List<String>? producedEvents,
    CommandMetadata? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommandDefinition(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      aggregateId: aggregateId ?? this.aggregateId,
      payload: payload ?? this.payload,
      validations: validations ?? this.validations,
      preconditions: preconditions ?? this.preconditions,
      producedEvents: producedEvents ?? this.producedEvents,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'projectId': projectId,
      'name': name,
      if (description != null) 'description': description,
      if (aggregateId != null) 'aggregateId': aggregateId,
      'payload': payload.toJson(),
      'validations': validations.map((v) => v.toJson()).toList(),
      'preconditions': preconditions.map((p) => p.toJson()).toList(),
      'producedEvents': producedEvents,
      'metadata': metadata.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CommandDefinition.fromJson(Map<String, dynamic> json) {
    return CommandDefinition(
      id: json['_id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      aggregateId: json['aggregateId'] as String?,
      payload: CommandPayload.fromJson(json['payload'] as Map<String, dynamic>),
      validations: (json['validations'] as List<dynamic>?)
              ?.map((v) => CommandValidationRule.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      preconditions: (json['preconditions'] as List<dynamic>?)
              ?.map((p) => Precondition.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      producedEvents:
          (json['producedEvents'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      metadata: CommandMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        name,
        description,
        aggregateId,
        payload,
        validations,
        preconditions,
        producedEvents,
        metadata,
        createdAt,
        updatedAt,
      ];
}
