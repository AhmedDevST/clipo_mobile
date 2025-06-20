import 'package:clipo_app/database/local/db/appDatabase.dart';
import 'package:clipo_app/models/Link.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

class LinkRepo {
  final AppDatabase db;
  LinkRepo(this.db);

  Future<void> saveSingleEntity(LinkModel model) {
    return db.into(db.links).insertOnConflictUpdate(model.toCompanion());
  }

  Future<void> saveListOfEntity(List<LinkModel> models) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.links,
        models.map((e) => e.toCompanion()).toList(),
      );
    });
  }

  Future<List<LinkModel>> getAllLinks() async {
    final query = db.select(db.links).join([
      leftOuterJoin(
          db.categories, db.categories.id.equalsExp(db.links.categoryId))
    ]);

    final rows = await query.get();

    return rows.map((row) {
      final linkRow = row.readTable(db.links);
      final categoryRow = row.readTableOrNull(db.categories);

      return linkRow.toModel(categoryRow);
    }).toList();
  }

  Future<List<LinkModel>> searchLinks(String queryText) async {
    final query = db.select(db.links).join([
      leftOuterJoin(
          db.categories, db.categories.id.equalsExp(db.links.categoryId)),
    ])
      ..where((db.links.title.like('%$queryText%')) |
          (db.links.url.like('%$queryText%')) |
          (db.links.description.like('%$queryText%')))
      ..orderBy([
        OrderingTerm.desc(db.links.createdAt),
      ]);

    final rows = await query.get();

    return rows.map((row) {
      final linkRow = row.readTable(db.links);
      final categoryRow = row.readTableOrNull(db.categories);
      return linkRow.toModel(categoryRow);
    }).toList();
  }

  /// Advanced search with multiple filters
  Future<List<LinkModel>> searchLinksAdvanced({
    String? queryText,
    String? categoryId,
    DateTimeRange? dateRange,
    bool favoritesOnly = false,
    bool archivedOnly = false,
  }) async {
    // Start with base query joining categories
    final query = db.select(db.links).join([
      leftOuterJoin(
          db.categories, db.categories.id.equalsExp(db.links.categoryId)),
    ]);

    // Build where conditions
    Expression<bool>? whereCondition;

    // Text search condition
    if (queryText != null && queryText.isNotEmpty) {
      final textCondition = (db.links.title.like('%$queryText%')) |
          (db.links.url.like('%$queryText%')) |
          (db.links.description.like('%$queryText%')) |
          (db.links.notes.like('%$queryText%'));
      whereCondition = whereCondition == null
          ? textCondition
          : whereCondition & textCondition;
    }

    // Category filter
    if (categoryId != null) {
      final categoryCondition = db.links.categoryId.equals(categoryId);
      whereCondition = whereCondition == null
          ? categoryCondition
          : whereCondition & categoryCondition;
    }

    // Date range filter
    if (dateRange != null) {
      final startDate = dateRange.start;
      final endDate =
          dateRange.end.add(const Duration(days: 1)); // Include end date
      final dateCondition =
          db.links.createdAt.isBetweenValues(startDate, endDate);
      whereCondition = whereCondition == null
          ? dateCondition
          : whereCondition & dateCondition;
    }

    // Favorites filter
    if (favoritesOnly) {
      final favoritesCondition = db.links.isFavorite.equals(true);
      whereCondition = whereCondition == null
          ? favoritesCondition
          : whereCondition & favoritesCondition;
    }

    // Archived filter
    if (archivedOnly) {
      final archivedCondition = db.links.isArchived.equals(true);
      whereCondition = whereCondition == null
          ? archivedCondition
          : whereCondition & archivedCondition;
    }

    // Apply where condition if any filters are set
    if (whereCondition != null) {
      query.where(whereCondition);
    }

    // Order by creation date (newest first) by default
    query.orderBy([
      OrderingTerm.desc(db.links.createdAt),
    ]);

    final rows = await query.get();

    return rows.map((row) {
      final linkRow = row.readTable(db.links);
      final categoryRow = row.readTableOrNull(db.categories);
      return linkRow.toModel(categoryRow);
    }).toList();
  }

  Future<void> toggleIsFavorite(String id) async {
    final link = await (db.select(db.links)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (link != null) {
      await (db.update(db.links)..where((tbl) => tbl.id.equals(id))).write(
        LinksCompanion(
          isFavorite: Value(!link.isFavorite),
        ),
      );
    }
  }

  Future<void> updateLastVisite(String id) async {
    final link = await (db.select(db.links)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (link != null) {
      await (db.update(db.links)..where((tbl) => tbl.id.equals(id))).write(
        LinksCompanion(
          visitCount: Value(link.visitCount + 1),
          lastVisited: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<List<LinkModel>> getFavoriteLinks() async {
    final query = db.select(db.links).join([
      leftOuterJoin(
          db.categories, db.categories.id.equalsExp(db.links.categoryId))
    ])
      ..where(db.links.isFavorite.equals(true));

    final rows = await query.get();

    return rows.map((row) {
      final linkRow = row.readTable(db.links);
      final categoryRow = row.readTableOrNull(db.categories);

      return linkRow.toModel(categoryRow);
    }).toList();
  }

  Future<void> deleteLink(String id) {
    return (db.delete(db.links)..where((tbl) => tbl.id.equals(id))).go();
  }
}
