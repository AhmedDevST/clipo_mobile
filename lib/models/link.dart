import 'package:clipo_app/models/Category.dart';
import 'package:clipo_app/database/local/db/appDatabase.dart';
import 'package:drift/drift.dart';

class LinkModel {
  final String id;
  final String url;
  final String title;
  final String? description;
  final String? favicon;
  final String? thumbnail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastVisited;
  final int visitCount;
  final bool isFavorite;
  final bool isArchived;
  final CategoryModel? category;
  final String? notes;
  final String? metadata; // JSON string

  LinkModel({
    required this.id,
    required this.url,
    required this.title,
    this.description,
    this.favicon,
    this.thumbnail,
    required this.createdAt,
    required this.updatedAt,
    this.lastVisited,
    this.visitCount = 0,
    this.isFavorite = false,
    this.isArchived = false,
    this.category,
    this.notes,
    this.metadata,
  });

  @override
String toString() {
  return 'LinkModel(id: $id, url: $url, title: $title, description: $description, favicon: $favicon, thumbnail: $thumbnail, createdAt: $createdAt, updatedAt: $updatedAt, lastVisited: $lastVisited, visitCount: $visitCount, isFavorite: $isFavorite, isArchived: $isArchived, category: $category, notes: $notes, metadata: $metadata)';
}
 LinkModel copyWith({
    String? id,
    String? title,
    String? url,
    bool? isFavorite,
    DateTime? lastVisited ,
  }) {
    return LinkModel(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description,
      lastVisited : lastVisited ?? this.lastVisited,
      favicon: favicon,
      thumbnail: thumbnail,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

// Drift -> Model
extension LinkMapper on Link {
  LinkModel toModel(Category? category) => LinkModel(
    id: id,
    url: url,
    title: title,
    description: description,
    favicon: favicon,
    thumbnail: thumbnail,
    createdAt: createdAt,
    updatedAt: updatedAt,
    lastVisited: lastVisited,
    visitCount: visitCount,
    isFavorite: isFavorite,
    isArchived: isArchived,
    category: category?.toModel(),
    notes: notes,
    metadata: metadata,
  );
}

// Model -> Drift Companion
extension LinkModelCompanion on LinkModel {
  LinksCompanion toCompanion() => LinksCompanion(
    id: Value(id),
    url: Value(url),
    title: Value(title),
    description: Value(description),
    favicon: Value(favicon),
    thumbnail: Value(thumbnail),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    lastVisited: Value(lastVisited),
    visitCount: Value(visitCount),
    isFavorite: Value(isFavorite),
    isArchived: Value(isArchived),
    categoryId: category != null 
      ? Value(category!.id) 
      : const Value.absent(),
    notes: Value(notes),
    metadata: Value(metadata),
  );
}
