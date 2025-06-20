import 'package:clipo_app/database/local/db/appDatabase.dart';
import 'package:clipo_app/models/Category.dart';

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

  Future<List<CategoryModel>> getAllCategories() async {
    final rows = await db.select(db.categories).get();
    return rows.map((e) => e.toModel()).toList();
  }


  Future<void> deleteCategory(String id) {
    return (db.delete(db.categories)..where((tbl) => tbl.id.equals(id))).go();
  }
}
