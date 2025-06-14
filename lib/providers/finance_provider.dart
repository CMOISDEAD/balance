import 'package:flutter/foundation.dart';
import '../database/database.dart';

class FinanceProvider with ChangeNotifier {
  final AppDatabase _database = AppDatabase();

  double _balance = 0.0;
  double _totalBalance = 0.0;
  List<Transaction> _transactions = [];
  List<CardWithBalance> _cardsWithBalances = [];
  bool _isLoading = false;

  // Getters
  double get balance => _balance;
  double get totalBalance => _totalBalance;
  List<Transaction> get transactions => _transactions;
  List<CardWithBalance> get cardsWithBalances => _cardsWithBalances;
  bool get isLoading => _isLoading;
  AppDatabase get database => _database;

  // Constructor
  FinanceProvider() {
    _loadData();
  }

  /*
   * initialization y update
   */

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _refreshData();
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshData() async {
    await _updateBalance();
    await _loadTransactions();
    await loadCardsWithBalances();
    notifyListeners();
  }

  Future<void> _updateBalance() async {
    _balance = await _database.getMainBalance();
    _totalBalance = await _database.getTotalBalance();
  }

  Future<void> _loadTransactions() async {
    _transactions = await _database.getAllTransactions();
  }

  /*
   * Transactions: incomes, expenses y delete
   */

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
      debugPrint('Error deleting all transactions: $e');
      rethrow;
    }
  }

  Future<List<Transaction>> getRecentTransactions(int days) async {
    return await _database.getRecentTransactions(days);
  }

  Future<Map<DateTime, List<Transaction>>> getTransactionByDate() async {
    return await _database.getTransactionsGroupedByDate();
  }

  /*
   * Cards
   */

  Future<void> createCard({
    required String name,
    required double? targetAmount,
  }) async {
    await _database.createCard(name: name, targetAmount: targetAmount);
    await _refreshData();
  }

  Future<void> deleteCard(int cardId) async {
    await _database.deleteCard(cardId);
    await _refreshData();
  }

  Future<void> loadCardsWithBalances() async {
    final cards = await _database.getAllCards();
    _cardsWithBalances = await Future.wait(
      cards.map((card) async {
        final balance = await _database.getCardBalance(card.id);
        return CardWithBalance(card: card, balance: balance);
      }),
    );
  }

  Future<List<Card>> getAllCards() async {
    return await _database.getAllCards();
  }

  Future<double> getCardBalance(int cardId) async {
    return await _database.getCardBalance(cardId);
  }

  /*
   * Transfers
   */

  Future<void> transferToCard({
    required int cardId,
    required double amount,
    String? description,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Amount must be positive');
    }

    final mainBalance = await _database.getMainBalance();
    if (mainBalance < amount) {
      throw StateError('Insufficient funds in main balance');
    }

    await _database.addTransaction(
      amount: amount,
      type: 'transfer_to',
      description: description ?? 'Transfer to card',
      cardId: cardId,
    );

    await _refreshData();
  }

  Future<void> transferFromCard({
    required int cardId,
    required double amount,
    String? description,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Amount must be positive');
    }

    final cardBalance = await _database.getCardBalance(cardId);
    if (cardBalance < amount) {
      throw StateError('Insufficient funds in card');
    }

    await _database.addTransaction(
      amount: amount,
      type: 'transfer_from',
      description: description ?? 'Transfer from card',
      cardId: cardId,
    );

    await _refreshData();
  }

  /*
   * Stats
   */

  Future<Map<String, double>> getStatistics() async {
    final totalIncome = await _database.getTotalIncome();
    final totalExpenses = await _database.getTotalExpenses();

    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': totalIncome - totalExpenses,
    };
  }

  /*
   * Helpers
   */

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }
}

class CardWithBalance {
  final Card card;
  final double balance;

  CardWithBalance({required this.card, required this.balance});
}
