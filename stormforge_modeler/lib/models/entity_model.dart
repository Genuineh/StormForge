import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Entity type classification
enum EntityType {
  entity,
  aggregateRoot,
  valueObject;

  String toJson() => name;

  static EntityType fromJson(String value) {
    return EntityType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EntityType.entity,
    );
  }
}

/// Validation rule type
enum ValidationType {
  required,
  minLength,
  maxLength,
  min,
  max,
  pattern,
  email,
  url,
  custom;

  String toJson() => name;

  static ValidationType fromJson(String value) {
    return ValidationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ValidationType.required,
    );
  }
}

/// Validation rule for entity properties
class ValidationRule extends Equatable {
  const ValidationRule({
    required this.id,
    required this.validationType,
    this.value,
    this.errorMessage,
  });

  final String id;
  final ValidationType validationType;
  final dynamic value;
  final String? errorMessage;

  factory ValidationRule.create({
    required ValidationType validationType,
    dynamic value,
    String? errorMessage,
  }) {
    return ValidationRule(
      id: const Uuid().v4(),
      validationType: validationType,
      value: value,
      errorMessage: errorMessage,
    );
  }

  ValidationRule copyWith({
    String? id,
    ValidationType? validationType,
    dynamic value,
    String? errorMessage,
  }) {
    return ValidationRule(
      id: id ?? this.id,
      validationType: validationType ?? this.validationType,
      value: value ?? this.value,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'validationType': validationType.toJson(),
      if (value != null) 'value': value,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  factory ValidationRule.fromJson(Map<String, dynamic> json) {
    return ValidationRule(
      id: json['id'] as String? ?? '',
      validationType: ValidationType.fromJson(json['validationType'] as String? ?? 'required'),
      value: json['value'],
      errorMessage: json['errorMessage'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, validationType, value, errorMessage];
}

/// Entity property definition
class EntityProperty extends Equatable {
  const EntityProperty({
    required this.id,
    required this.name,
    required this.propertyType,
    this.required = false,
    this.isIdentifier = false,
    this.isReadOnly = false,
    this.defaultValue,
    this.description,
    this.displayOrder = 0,
    this.validations = const [],
  });

  final String id;
  final String name;
  final String propertyType;
  final bool required;
  final bool isIdentifier;
  final bool isReadOnly;
  final dynamic defaultValue;
  final String? description;
  final int displayOrder;
  final List<ValidationRule> validations;

  factory EntityProperty.create({
    required String name,
    required String propertyType,
    bool required = false,
    bool isIdentifier = false,
    bool isReadOnly = false,
    dynamic defaultValue,
    String? description,
    int displayOrder = 0,
  }) {
    return EntityProperty(
      id: const Uuid().v4(),
      name: name,
      propertyType: propertyType,
      required: required,
      isIdentifier: isIdentifier,
      isReadOnly: isReadOnly,
      defaultValue: defaultValue,
      description: description,
      displayOrder: displayOrder,
    );
  }

  EntityProperty copyWith({
    String? id,
    String? name,
    String? propertyType,
    bool? required,
    bool? isIdentifier,
    bool? isReadOnly,
    dynamic defaultValue,
    String? description,
    int? displayOrder,
    List<ValidationRule>? validations,
  }) {
    return EntityProperty(
      id: id ?? this.id,
      name: name ?? this.name,
      propertyType: propertyType ?? this.propertyType,
      required: required ?? this.required,
      isIdentifier: isIdentifier ?? this.isIdentifier,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      defaultValue: defaultValue ?? this.defaultValue,
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
      validations: validations ?? this.validations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'propertyType': propertyType,
      'required': required,
      'isIdentifier': isIdentifier,
      'isReadOnly': isReadOnly,
      if (defaultValue != null) 'defaultValue': defaultValue,
      if (description != null) 'description': description,
      'displayOrder': displayOrder,
      'validations': validations.map((v) => v.toJson()).toList(),
    };
  }

  factory EntityProperty.fromJson(Map<String, dynamic> json) {
    return EntityProperty(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      propertyType: json['propertyType'] as String? ?? '',
      required: json['required'] as bool? ?? false,
      isIdentifier: json['isIdentifier'] as bool? ?? false,
      isReadOnly: json['isReadOnly'] as bool? ?? false,
      defaultValue: json['defaultValue'],
      description: json['description'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 0,
      validations: (json['validations'] as List<dynamic>?)
              ?.map((v) => ValidationRule.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        propertyType,
        required,
        isIdentifier,
        isReadOnly,
        defaultValue,
        description,
        displayOrder,
        validations,
      ];
}

/// Method parameter definition
class MethodParameter extends Equatable {
  const MethodParameter({
    required this.name,
    required this.parameterType,
    this.required = true,
    this.defaultValue,
  });

  final String name;
  final String parameterType;
  final bool required;
  final dynamic defaultValue;

  MethodParameter copyWith({
    String? name,
    String? parameterType,
    bool? required,
    dynamic defaultValue,
  }) {
    return MethodParameter(
      name: name ?? this.name,
      parameterType: parameterType ?? this.parameterType,
      required: required ?? this.required,
      defaultValue: defaultValue ?? this.defaultValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parameterType': parameterType,
      'required': required,
      if (defaultValue != null) 'defaultValue': defaultValue,
    };
  }

  factory MethodParameter.fromJson(Map<String, dynamic> json) {
    return MethodParameter(
      name: json['name'] as String? ?? '',
      parameterType: json['parameterType'] as String? ?? '',
      required: json['required'] as bool? ?? true,
      defaultValue: json['defaultValue'],
    );
  }

  @override
  List<Object?> get props => [name, parameterType, required, defaultValue];
}

/// Method type classification
enum MethodType {
  constructor,
  command,
  query,
  domainLogic;

  String toJson() => name;

  static MethodType fromJson(String value) {
    return MethodType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MethodType.domainLogic,
    );
  }
}

/// Entity method definition
class EntityMethod extends Equatable {
  const EntityMethod({
    required this.id,
    required this.name,
    required this.methodType,
    required this.returnType,
    this.parameters = const [],
    this.description,
  });

  final String id;
  final String name;
  final MethodType methodType;
  final String returnType;
  final List<MethodParameter> parameters;
  final String? description;

  factory EntityMethod.create({
    required String name,
    required MethodType methodType,
    required String returnType,
    List<MethodParameter> parameters = const [],
    String? description,
  }) {
    return EntityMethod(
      id: const Uuid().v4(),
      name: name,
      methodType: methodType,
      returnType: returnType,
      parameters: parameters,
      description: description,
    );
  }

  EntityMethod copyWith({
    String? id,
    String? name,
    MethodType? methodType,
    String? returnType,
    List<MethodParameter>? parameters,
    String? description,
  }) {
    return EntityMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      methodType: methodType ?? this.methodType,
      returnType: returnType ?? this.returnType,
      parameters: parameters ?? this.parameters,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'methodType': methodType.toJson(),
      'returnType': returnType,
      'parameters': parameters.map((p) => p.toJson()).toList(),
      if (description != null) 'description': description,
    };
  }

  factory EntityMethod.fromJson(Map<String, dynamic> json) {
    return EntityMethod(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      methodType: MethodType.fromJson(json['methodType'] as String? ?? 'domainLogic'),
      returnType: json['returnType'] as String? ?? '',
      parameters: (json['parameters'] as List<dynamic>?)
              ?.map((p) => MethodParameter.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      description: json['description'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, methodType, returnType, parameters, description];
}

/// Entity invariant (business rule)
class EntityInvariant extends Equatable {
  const EntityInvariant({
    required this.id,
    required this.name,
    required this.expression,
    required this.errorMessage,
    this.enabled = true,
  });

  final String id;
  final String name;
  final String expression;
  final String errorMessage;
  final bool enabled;

  factory EntityInvariant.create({
    required String name,
    required String expression,
    required String errorMessage,
    bool enabled = true,
  }) {
    return EntityInvariant(
      id: const Uuid().v4(),
      name: name,
      expression: expression,
      errorMessage: errorMessage,
      enabled: enabled,
    );
  }

  EntityInvariant copyWith({
    String? id,
    String? name,
    String? expression,
    String? errorMessage,
    bool? enabled,
  }) {
    return EntityInvariant(
      id: id ?? this.id,
      name: name ?? this.name,
      expression: expression ?? this.expression,
      errorMessage: errorMessage ?? this.errorMessage,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'expression': expression,
      'errorMessage': errorMessage,
      'enabled': enabled,
    };
  }

  factory EntityInvariant.fromJson(Map<String, dynamic> json) {
    return EntityInvariant(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      expression: json['expression'] as String? ?? '',
      errorMessage: json['errorMessage'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, expression, errorMessage, enabled];
}

/// Complete entity definition
class EntityDefinition extends Equatable {
  const EntityDefinition({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    this.aggregateId,
    required this.entityType,
    this.properties = const [],
    this.methods = const [],
    this.invariants = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final String name;
  final String? description;
  final String? aggregateId;
  final EntityType entityType;
  final List<EntityProperty> properties;
  final List<EntityMethod> methods;
  final List<EntityInvariant> invariants;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory EntityDefinition.create({
    required String projectId,
    required String name,
    EntityType entityType = EntityType.entity,
    String? description,
    String? aggregateId,
  }) {
    final now = DateTime.now();
    return EntityDefinition(
      id: const Uuid().v4(),
      projectId: projectId,
      name: name,
      description: description,
      aggregateId: aggregateId,
      entityType: entityType,
      createdAt: now,
      updatedAt: now,
    );
  }

  EntityDefinition copyWith({
    String? id,
    String? projectId,
    String? name,
    String? description,
    String? aggregateId,
    EntityType? entityType,
    List<EntityProperty>? properties,
    List<EntityMethod>? methods,
    List<EntityInvariant>? invariants,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EntityDefinition(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      aggregateId: aggregateId ?? this.aggregateId,
      entityType: entityType ?? this.entityType,
      properties: properties ?? this.properties,
      methods: methods ?? this.methods,
      invariants: invariants ?? this.invariants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      if (description != null) 'description': description,
      if (aggregateId != null) 'aggregateId': aggregateId,
      'entityType': entityType.toJson(),
      'properties': properties.map((p) => p.toJson()).toList(),
      'methods': methods.map((m) => m.toJson()).toList(),
      'invariants': invariants.map((i) => i.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory EntityDefinition.fromJson(Map<String, dynamic> json) {
    return EntityDefinition(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      aggregateId: json['aggregateId'] as String?,
      entityType: EntityType.fromJson(json['entityType'] as String? ?? 'entity'),
      properties: (json['properties'] as List<dynamic>?)
              ?.map((p) => EntityProperty.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      methods: (json['methods'] as List<dynamic>?)
              ?.map((m) => EntityMethod.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      invariants: (json['invariants'] as List<dynamic>?)
              ?.map((i) => EntityInvariant.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        name,
        description,
        aggregateId,
        entityType,
        properties,
        methods,
        invariants,
        createdAt,
        updatedAt,
      ];
}
