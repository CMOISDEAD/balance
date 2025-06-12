import 'package:flutter/foundation.dart';
import '../database/database.dart';

class FinanceProvider with ChangeNotifier {
  final AppDatabase _database = AppDatabase();

  double _balance = 0.0;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  // Getters
  double get balance => _balance;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  AppDatabase get database => _database;

  // Constructor
  FinanceProvider() {
    _loadData();
  }

  // Cargar datos iniciales
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _updateBalance();
      await _loadTransactions();
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar el balance
  Future<void> _updateBalance() async {
    _balance = await _database.getTotalBalance();
  }

  // Cargar las transacciones
  Future<void> _loadTransactions() async {
    _transactions = await _database.getAllTransactions();
  }

  // Agregar ingreso
  Future<void> addIncome({
    required double amount,
    required String description,
    String? category,
  }) async {
    if (amount <= 0) return;

    try {
      await _database.addTransaction(
        amount: amount,
        type: 'income',
        description: description,
        category: category,
      );

      await _refreshData();
    } catch (e) {
      debugPrint('Error adding income: $e');
      rethrow;
    }
  }

  // Agregar gasto
  Future<void> addExpense({
    required double amount,
    required String description,
    String? category,
  }) async {
    if (amount <= 0) return;

    try {
      await _database.addTransaction(
        amount: amount,
        type: 'expense',
        description: description,
        category: category,
      );

      await _refreshData();
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }

  // Eliminar transacción
  Future<void> deleteTransaction(int transactionId) async {
    try {
      await _database.deleteTransaction(transactionId);
      await _refreshData();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteAllTransactions() async {
    try {
      await _database.deleteAllTransactions();
      await _refreshData();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  // Refrescar todos los datos
  Future<void> _refreshData() async {
    await _updateBalance();
    await _loadTransactions();
    notifyListeners();
  }

  // Obtener estadísticas
  Future<Map<String, double>> getStatistics() async {
    final totalIncome = await _database.getTotalIncome();
    final totalExpenses = await _database.getTotalExpenses();

    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': totalIncome - totalExpenses,
    };
  }

  // Obtener transacciones recientes
  Future<List<Transaction>> getRecentTransactions(int days) async {
    return await _database.getRecentTransactions(days);
  }

  Future<Map<DateTime, List<Transaction>>> getTransactionByDate() async {
    return await _database.getTransactionsGroupedByDate();
  }

  // Limpiar recursos
  @override
  void dispose() {
    _database.close();
    super.dispose();
  }
}
