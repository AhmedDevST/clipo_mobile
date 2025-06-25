import 'package:clipo_app/database/local/db/appDatabase.dart';
import 'package:clipo_app/models/Category.dart';
import 'package:drift/drift.dart';

class CategoryRepo {
  final AppDatabase db;
  CategoryRepo(this.db);

  Future<void> saveSingleEntity(CategoryModel model) {
    return db.into(db.categories).insertOnConflictUpdate(model.toCompanion());
  }

  Future<void> saveListOfEntity(List<CategoryModel> models) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.categories,
        models.map((e) => e.toCompanion()).toList(),
      );
    });
  }

  Future<void> updateLinkCount(String id, int updateCount) async {
    final category = await (db.select(db.categories)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (category != null) {
      final newLinkCount = (category.linkCount + updateCount).clamp(0, double.infinity).toInt();
      await (db.update(db.categories)..where((tbl) => tbl.id.equals(id))).write(
        CategoriesCompanion(
          linkCount: Value(newLinkCount),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }
  Future<List<CategoryModel>> getAllCategories() async {
    final rows = await db.select(db.categories).get();
    return rows.map((e) => e.toModel()).toList();
  }


  Future<void> deleteCategory(String id) {
    return (db.delete(db.categories)..where((tbl) => tbl.id.equals(id))).go();
  }
}
