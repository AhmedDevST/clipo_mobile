import 'package:clipo_app/database/local/db/appDatabase.dart';
import 'package:drift/drift.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String color;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int linkCount;
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
    this.linkCount = 0,
    this.isDefault = false,
  });
}

// Mapping between CategoryModel and Category
extension CategoryMapper on Category {
  CategoryModel toModel() => CategoryModel(
        id: id,
        name: name,
        description: description,
        color: color,
        icon: icon,
        createdAt: createdAt,
        updatedAt: updatedAt,
        linkCount: linkCount,
        isDefault: isDefault,
      );
}

// Mapping for Drift Companion
extension CategoryModelCompanion on CategoryModel {
  CategoriesCompanion toCompanion() => CategoriesCompanion(
        id: Value(id),
        name: Value(name),
        description: Value(description),
        color: Value(color),
        icon: Value(icon),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        linkCount: Value(linkCount),
        isDefault: Value(isDefault),
      );
}

