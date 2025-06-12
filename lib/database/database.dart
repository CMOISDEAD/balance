import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Incluir el archivo generado
part 'database.g.dart';

// Definir la tabla de transacciones
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get type =>
      text().withLength(min: 1, max: 20)(); // 'income' o 'expense'
  TextColumn get description => text().withLength(min: 1, max: 200)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get category => text().withLength(min: 1, max: 50).nullable()();
}

@DriftDatabase(tables: [Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Método para obtener el balance total
  Future<double> getTotalBalance() async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.amount.sum(), transactions.type])
      ..groupBy([transactions.type]);

    final results = await query.get();

    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    for (final result in results) {
      final sum = result.read(transactions.amount.sum()) ?? 0.0;
      final type = result.read(transactions.type);

      if (type == 'income') {
        totalIncome = sum;
      } else if (type == 'expense') {
        totalExpenses = sum;
      }
    }

    return totalIncome - totalExpenses;
  }

  // Método para agregar una transacción
  Future<int> addTransaction({
    required double amount,
    required String type,
    required String description,
    String? category,
  }) async {
    return await into(transactions).insert(
      TransactionsCompanion(
        amount: Value(amount),
        type: Value(type),
        description: Value(description),
        category: Value(category),
      ),
    );
  }

  // Método para obtener todas las transacciones ordenadas por fecha
  Future<List<Transaction>> getAllTransactions() async {
    return await (select(
      transactions,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  // Método para obtener transacciones por tipo
  Future<List<Transaction>> getTransactionsByType(String type) async {
    return await (select(transactions)
          ..where((t) => t.type.equals(type))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  // Método para eliminar una transacción
  Future<int> deleteTransaction(int id) async {
    return await (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  // Método para eliminar todas las transacciones
  Future<int> deleteAllTransactions() async {
    return await delete(transactions).go();
  }

  // Método para obtener transacciones de los últimos N días
  Future<List<Transaction>> getRecentTransactions(int days) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return await (select(transactions)
          ..where((t) => t.createdAt.isBiggerThanValue(cutoffDate))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  // Método para obtener transacciones agrupadas por fecha
  Future<Map<DateTime, List<Transaction>>>
  getTransactionsGroupedByDate() async {
    final transactions = await getAllTransactions();
    final Map<DateTime, List<Transaction>> groupedTransactions = {};

    for (final transaction in transactions) {
      // Crear una fecha solo con año, mes y día (sin hora)
      final dateOnly = DateTime(
        transaction.createdAt.year,
        transaction.createdAt.month,
        transaction.createdAt.day,
      );

      if (groupedTransactions.containsKey(dateOnly)) {
        groupedTransactions[dateOnly]!.add(transaction);
      } else {
        groupedTransactions[dateOnly] = [transaction];
      }
    }

    return groupedTransactions;
  }

  // Método para obtener el total de ingresos
  Future<double> getTotalIncome() async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.type.equals('income'));

    final result = await query.getSingleOrNull();
    return result?.read(transactions.amount.sum()) ?? 0.0;
  }

  // Método para obtener el total de gastos
  Future<double> getTotalExpenses() async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.type.equals('expense'));

    final result = await query.getSingleOrNull();
    return result?.read(transactions.amount.sum()) ?? 0.0;
  }
}

// Configuración de conexión a la base de datos
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'finance_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
