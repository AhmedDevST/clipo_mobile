import 'package:drift/drift.dart';

// Links table
class Links extends Table {
  TextColumn get id => text()();
  TextColumn get url => text().unique()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get favicon => text().nullable()();
  TextColumn get thumbnail => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastVisited => dateTime().nullable()();
  IntColumn get visitCount => integer().withDefault(const Constant(0))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get notes => text().nullable()();
  TextColumn get metadata => text().nullable()(); // JSON string

  @override
  Set<Column> get primaryKey => {id};
}

// Categories table
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  TextColumn get description => text().nullable()();
  TextColumn get color => text()();
  TextColumn get icon => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get linkCount => integer().withDefault(const Constant(0))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Tags table
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  TextColumn get color => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// Junction table for many-to-many relationship between Links and Tags
class LinkTags extends Table {
  TextColumn get linkId => text().references(Links, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {linkId, tagId};
}
