import 'package:drift/drift.dart';

/// جدول الحسابات - بنية هرمية محاسبية كاملة.
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get parentId => text().nullable()();
  BoolColumn get isPostable => boolean().withDefault(const Constant(true))();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get description => text().nullable()();
  BoolColumn get isBank => boolean().withDefault(const Constant(false))();
  BoolColumn get isCash => boolean().withDefault(const Constant(false))();
  BoolColumn get isWallet => boolean().withDefault(const Constant(false))();
  TextColumn get bankName => text().nullable()();
  TextColumn get accountNumber => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('YER'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
