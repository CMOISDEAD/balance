import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Incluir el archivo generado
part 'database.g.dart';

class Cards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  RealColumn get targetAmount => real().nullable()(); // Meta opcional
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Definir la tabla de transacciones
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get type => text().withLength(
    min: 1,
    max: 20,
  )(); // 'income', 'expense', 'transfer_to', 'transfer_from'
  TextColumn get description => text().withLength(min: 1, max: 200)();
  TextColumn get category => text().withLength(min: 1, max: 50).nullable()();
  IntColumn get cardId => integer().nullable().references(Cards, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Cards, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) {
      return m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from == 1) {
        // Crear tabla Cards
        await m.createTable(cards);
        // Agregar columna cardId a transacciones existentes
        await m.addColumn(transactions, transactions.cardId);
      }
    },
  );

  // Método para obtener el balance total
  Future<double> getTotalBalance() async {
    final incomes = await _getSumByType("income", null);
    final expenses = await _getSumByType("expense", null);
    return incomes - expenses;
  }

  Future<double> getMainBalance() async {
    final income = await _getSumByType('income', null);
    final expenses = await _getSumByType('expense', null);
    final transfersToCards = await _getSumByType('transfer_to', null);
    final transfersFromCards = await _getSumByType('transfer_from', null);

    print(
      'income: $income - expenses: $expenses - transfersToCards: $transfersToCards - transfersFromCards: $transfersFromCards',
    );
    print(
      'Main Balance: ${income - expenses - transfersToCards + transfersFromCards}',
    );
    return income - expenses - transfersToCards + transfersFromCards;
  }

  /*
   * Transactions
   */

  // Método para agregar una transacción
  Future<int> addTransaction({
    required double amount,
    required String type,
    required String description,
    String? category,
    int? cardId,
  }) async {
    return await into(transactions).insert(
      TransactionsCompanion(
        amount: Value(amount),
        type: Value(type),
        description: Value(description),
        category: Value(category),
        cardId: Value(cardId),
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

  // Obtener transacciones de una card específica
  Future<List<Transaction>> getCardTransactions(int cardId) async {
    return await (select(transactions)
          ..where((t) => t.cardId.equals(cardId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  // Obtener solo transacciones del balance principal
  Future<List<Transaction>> getMainBalanceTransactions() async {
    return await (select(transactions)
          ..where((t) => t.cardId.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /*
   * Cards
   */

  // Crear una nueva card
  Future<int> createCard({
    required String name,
    double? targetAmount,
    String? color,
  }) async {
    return await into(cards).insert(
      CardsCompanion(name: Value(name), targetAmount: Value(targetAmount)),
    );
  }

  Future<double> getCardBalance(int cardId) async {
    final income = await _getSumByType('income', cardId);
    final expenses = await _getSumByType('expense', cardId);
    final transfersTo = await _getSumByType('transfer_to', cardId);
    final transfersFrom = await _getSumByType('transfer_from', cardId);

    return income - expenses + transfersTo - transfersFrom;
  }

  Future<int> addCard({required String name, double? targetAmount}) async {
    return await into(cards).insert(
      CardsCompanion(name: Value(name), targetAmount: Value(targetAmount)),
    );
  }

  // Obtener todas las cards
  Future<List<Card>> getAllCards() async {
    return await (select(
      cards,
    )..orderBy([(c) => OrderingTerm.asc(c.createdAt)])).get();
  }

  // Obtener una card por ID
  Future<Card?> getCardById(int id) async {
    return await (select(
      cards,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  // Actualizar una card
  Future<bool> updateCard(
    int id, {
    String? name,
    double? targetAmount,
    String? color,
  }) async {
    final companion = CardsCompanion(
      id: Value(id),
      name: name != null ? Value(name) : const Value.absent(),
      targetAmount: targetAmount != null
          ? Value(targetAmount)
          : const Value.absent(),
    );

    return await (update(
          cards,
        )..where((c) => c.id.equals(id))).write(companion) >
        0;
  }

  // Verificar si una card se puede eliminar (balance = 0)
  Future<bool> canDeleteCard(int cardId) async {
    final balance = await getCardBalance(cardId);
    return balance == 0;
  }

  // Eliminar card (con opción de devolver dinero)
  Future<bool> deleteCard(int cardId, {bool returnMoney = true}) async {
    final cardBalance = await getCardBalance(cardId);

    if (returnMoney && cardBalance > 0) {
      // Devolver dinero al balance principal
      await addTransaction(
        amount: cardBalance,
        type: 'transfer_from',
        description: 'Card deleted',
        cardId: cardId,
      );
    }

    // Eliminar la card
    final deletedRows = await (delete(
      cards,
    )..where((c) => c.id.equals(cardId))).go();
    return deletedRows > 0;
  }

  /*
   * Helpers
   */

  Future<double> _getSumByType(String type, int? cardId) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.type.equals(type));

    if (cardId != null) {
      query.where(transactions.cardId.equals(cardId));
    }

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
