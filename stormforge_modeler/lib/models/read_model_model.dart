import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Join type for data sources
enum JoinType {
  inner,
  left,
  right;

  String toJson() => name;

  static JoinType fromJson(String value) {
    return JoinType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => JoinType.inner,
    );
  }
}

/// Join operator for join conditions
enum JoinOperator {
  equals,
  notEquals;

  String toJson() => name;

  static JoinOperator fromJson(String value) {
    return JoinOperator.values.firstWhere(
      (e) => e.name == value,
      orElse: () => JoinOperator.equals,
    );
  }
}

/// Join condition for multi-entity joins
class JoinCondition extends Equatable {
  const JoinCondition({
    required this.leftProperty,
    required this.rightProperty,
    required this.operator,
  });

  final String leftProperty;
  final String rightProperty;
  final JoinOperator operator;

  JoinCondition copyWith({
    String? leftProperty,
    String? rightProperty,
    JoinOperator? operator,
  }) {
    return JoinCondition(
      leftProperty: leftProperty ?? this.leftProperty,
      rightProperty: rightProperty ?? this.rightProperty,
      operator: operator ?? this.operator,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leftProperty': leftProperty,
      'rightProperty': rightProperty,
      'operator': operator.toJson(),
    };
  }

  factory JoinCondition.fromJson(Map<String, dynamic> json) {
    return JoinCondition(
      leftProperty: json['leftProperty'] as String,
      rightProperty: json['rightProperty'] as String,
      operator: JoinOperator.fromJson(json['operator'] as String),
    );
  }

  @override
  List<Object?> get props => [leftProperty, rightProperty, operator];
}

/// Data source for read model
class DataSource extends Equatable {
  const DataSource({
    required this.entityId,
    required this.alias,
    this.joinCondition,
    required this.joinType,
    required this.displayOrder,
  });

  final String entityId;
  final String alias;
  final JoinCondition? joinCondition;
  final JoinType joinType;
  final int displayOrder;

  DataSource copyWith({
    String? entityId,
    String? alias,
    JoinCondition? joinCondition,
    JoinType? joinType,
    int? displayOrder,
  }) {
    return DataSource(
      entityId: entityId ?? this.entityId,
      alias: alias ?? this.alias,
      joinCondition: joinCondition ?? this.joinCondition,
      joinType: joinType ?? this.joinType,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entityId': entityId,
      'alias': alias,
      if (joinCondition != null) 'joinCondition': joinCondition!.toJson(),
      'joinType': joinType.toJson(),
      'displayOrder': displayOrder,
    };
  }

  factory DataSource.fromJson(Map<String, dynamic> json) {
    return DataSource(
      entityId: json['entityId'] as String,
      alias: json['alias'] as String,
      joinCondition: json['joinCondition'] != null
          ? JoinCondition.fromJson(json['joinCondition'] as Map<String, dynamic>)
          : null,
      joinType: JoinType.fromJson(json['joinType'] as String),
      displayOrder: json['displayOrder'] as int,
    );
  }

  @override
  List<Object?> get props =>
      [entityId, alias, joinCondition, joinType, displayOrder];
}

/// Field source type
enum FieldSourceType {
  direct,
  computed,
  aggregated;

  String toJson() => name;

  static FieldSourceType fromJson(String value) {
    return FieldSourceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FieldSourceType.direct,
    );
  }
}

/// Transform type for fields
enum TransformType {
  rename,
  format,
  compute,
  aggregate;

  String toJson() => name;

  static TransformType fromJson(String value) {
    return TransformType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransformType.rename,
    );
  }
}

/// Field transform definition
class FieldTransform extends Equatable {
  const FieldTransform({
    required this.transformType,
    this.expression,
    this.parameters,
  });

  final TransformType transformType;
  final String? expression;
  final Map<String, dynamic>? parameters;

  FieldTransform copyWith({
    TransformType? transformType,
    String? expression,
    Map<String, dynamic>? parameters,
  }) {
    return FieldTransform(
      transformType: transformType ?? this.transformType,
      expression: expression ?? this.expression,
      parameters: parameters ?? this.parameters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transformType': transformType.toJson(),
      if (expression != null) 'expression': expression,
      if (parameters != null) 'parameters': parameters,
    };
  }

  factory FieldTransform.fromJson(Map<String, dynamic> json) {
    return FieldTransform(
      transformType: TransformType.fromJson(json['transformType'] as String),
      expression: json['expression'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [transformType, expression, parameters];
}

/// Read model field definition
class ReadModelField extends Equatable {
  const ReadModelField({
    required this.id,
    required this.name,
    required this.fieldType,
    required this.sourceType,
    required this.sourcePath,
    this.transform,
    required this.nullable,
    this.description,
    required this.displayOrder,
  });

  final String id;
  final String name;
  final String fieldType;
  final FieldSourceType sourceType;
  final String sourcePath;
  final FieldTransform? transform;
  final bool nullable;
  final String? description;
  final int displayOrder;

  factory ReadModelField.create({
    required String name,
    required String fieldType,
    required String sourcePath,
    FieldSourceType? sourceType,
    FieldTransform? transform,
    bool? nullable,
    String? description,
  }) {
    return ReadModelField(
      id: const Uuid().v4(),
      name: name,
      fieldType: fieldType,
      sourceType: sourceType ?? FieldSourceType.direct,
      sourcePath: sourcePath,
      transform: transform,
      nullable: nullable ?? false,
      description: description,
      displayOrder: 0,
    );
  }

  ReadModelField copyWith({
    String? id,
    String? name,
    String? fieldType,
    FieldSourceType? sourceType,
    String? sourcePath,
    FieldTransform? transform,
    bool? nullable,
    String? description,
    int? displayOrder,
  }) {
    return ReadModelField(
      id: id ?? this.id,
      name: name ?? this.name,
      fieldType: fieldType ?? this.fieldType,
      sourceType: sourceType ?? this.sourceType,
      sourcePath: sourcePath ?? this.sourcePath,
      transform: transform ?? this.transform,
      nullable: nullable ?? this.nullable,
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fieldType': fieldType,
      'sourceType': sourceType.toJson(),
      'sourcePath': sourcePath,
      if (transform != null) 'transform': transform!.toJson(),
      'nullable': nullable,
      if (description != null) 'description': description,
      'displayOrder': displayOrder,
    };
  }

  factory ReadModelField.fromJson(Map<String, dynamic> json) {
    return ReadModelField(
      id: json['id'] as String,
      name: json['name'] as String,
      fieldType: json['fieldType'] as String,
      sourceType: FieldSourceType.fromJson(json['sourceType'] as String),
      sourcePath: json['sourcePath'] as String,
      transform: json['transform'] != null
          ? FieldTransform.fromJson(json['transform'] as Map<String, dynamic>)
          : null,
      nullable: json['nullable'] as bool,
      description: json['description'] as String?,
      displayOrder: json['displayOrder'] as int,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        fieldType,
        sourceType,
        sourcePath,
        transform,
        nullable,
        description,
        displayOrder
      ];
}

/// Read model metadata
class ReadModelMetadata extends Equatable {
  const ReadModelMetadata({
    required this.version,
    this.tags,
  });

  final String version;
  final List<String>? tags;

  factory ReadModelMetadata.defaults() {
    return const ReadModelMetadata(version: '1.0.0');
  }

  ReadModelMetadata copyWith({
    String? version,
    List<String>? tags,
  }) {
    return ReadModelMetadata(
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

  factory ReadModelMetadata.fromJson(Map<String, dynamic> json) {
    return ReadModelMetadata(
      version: json['version'] as String,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
    );
  }

  @override
  List<Object?> get props => [version, tags];
}

/// Read model definition
class ReadModelDefinition extends Equatable {
  const ReadModelDefinition({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    required this.sources,
    required this.fields,
    required this.updatedByEvents,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final String name;
  final String? description;
  final List<DataSource> sources;
  final List<ReadModelField> fields;
  final List<String> updatedByEvents;
  final ReadModelMetadata metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ReadModelDefinition.create({
    required String projectId,
    required String name,
    String? description,
  }) {
    return ReadModelDefinition(
      id: const Uuid().v4(),
      projectId: projectId,
      name: name,
      description: description,
      sources: [],
      fields: [],
      updatedByEvents: [],
      metadata: ReadModelMetadata.defaults(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  bool isValid() {
    return name.isNotEmpty &&
        sources.isNotEmpty &&
        fields.isNotEmpty &&
        !hasDuplicateFieldNames();
  }

  bool hasDuplicateFieldNames() {
    final names = <String>{};
    for (final field in fields) {
      if (!names.add(field.name)) {
        return true;
      }
    }
    return false;
  }

  Set<String> get entityDependencies {
    return sources.map((s) => s.entityId).toSet();
  }

  ReadModelDefinition copyWith({
    String? id,
    String? projectId,
    String? name,
    String? description,
    List<DataSource>? sources,
    List<ReadModelField>? fields,
    List<String>? updatedByEvents,
    ReadModelMetadata? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReadModelDefinition(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      sources: sources ?? this.sources,
      fields: fields ?? this.fields,
      updatedByEvents: updatedByEvents ?? this.updatedByEvents,
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
      'sources': sources.map((s) => s.toJson()).toList(),
      'fields': fields.map((f) => f.toJson()).toList(),
      'updatedByEvents': updatedByEvents,
      'metadata': metadata.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ReadModelDefinition.fromJson(Map<String, dynamic> json) {
    return ReadModelDefinition(
      id: json['_id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sources: (json['sources'] as List)
          .map((s) => DataSource.fromJson(s as Map<String, dynamic>))
          .toList(),
      fields: (json['fields'] as List)
          .map((f) => ReadModelField.fromJson(f as Map<String, dynamic>))
          .toList(),
      updatedByEvents: List<String>.from(json['updatedByEvents'] as List),
      metadata: ReadModelMetadata.fromJson(
          json['metadata'] as Map<String, dynamic>),
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
        sources,
        fields,
        updatedByEvents,
        metadata,
        createdAt,
        updatedAt
      ];
}
