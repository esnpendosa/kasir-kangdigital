import 'package:equatable/equatable.dart';

/// Category domain entity with optional parent-child hierarchy.
class Category extends Equatable {
  const Category({
    this.id,
    required this.name,
    this.description,
    this.parentId,
    this.colorHex,
    this.iconName,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String name;
  final String? description;
  final int? parentId;
  final String? colorHex;
  final String? iconName;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasParent => parentId != null;

  @override
  List<Object?> get props => [id, name, parentId, isActive];
}
