import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/customer.dart';
import '../models/expense.dart';
import '../models/payment.dart';
import '../models/work_entry.dart';
import '../repositories/customer_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/work_repository.dart';
import '../utils/formatters.dart';

class DailyChartPoint {
  final String label;
  final double revenue;
  final double expense;

  const DailyChartPoint({
    required this.label,
    required this.revenue,
    required this.expense,
  });
}

class BusinessDataProvider extends ChangeNotifier {
  final CustomerRepository _customerRepo;
  final WorkRepository _workRepo;
  final PaymentRepository _paymentRepo;
  final ExpenseRepository _expenseRepo;
  final Uuid _uuid = const Uuid();

  BusinessDataProvider({
    CustomerRepository? customerRepo,
    WorkRepository? workRepo,
    PaymentRepository? paymentRepo,
    ExpenseRepository? expenseRepo,
  })  : _customerRepo = customerRepo ?? CustomerRepository(),
        _workRepo = workRepo ?? WorkRepository(),
        _paymentRepo = paymentRepo ?? PaymentRepository(),
        _expenseRepo = expenseRepo ?? ExpenseRepository();

  List<Customer> _customers = [];
  List<WorkEntry> _workEntries = [];
  List<Payment> _payments = [];
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<Customer> get customers => List.unmodifiable(_customers);
  List<WorkEntry> get workEntries => List.unmodifiable(_workEntries);
  List<Payment> get payments => List.unmodifiable(_payments);
  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _customerRepo.getAll(),
        _workRepo.getAll(),
        _paymentRepo.getAll(),
        _expenseRepo.getAll(),
      ]);
      _customers = results[0] as List<Customer>;
      _workEntries = results[1] as List<WorkEntry>;
      _payments = results[2] as List<Payment>;
      _expenses = results[3] as List<Expense>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Dashboard Metrics ---
  double get totalRevenue =>
      _workEntries.fold(0.0, (sum, w) => sum + w.totalAmount);

  double get totalCollected =>
      _workEntries.fold(0.0, (sum, w) => sum + w.receivedAmount);

  double get totalExpenses =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get netProfit => totalRevenue - totalExpenses;

  double get totalProductionTons =>
      _workEntries.fold(0.0, (sum, w) => sum + w.quantityTons);

  int get totalCustomers => _customers.length;

  double get totalPendingPayments =>
      _workEntries.fold(0.0, (sum, w) => sum + w.remainingBalance);

  List<WorkEntry> get todaysWorks {
    final now = DateTime.now();
    return _workEntries
        .where((w) => AppFormatters.isSameDay(w.workDate, now))
        .toList();
  }

  double get todaysWorkTons =>
      todaysWorks.fold(0.0, (sum, w) => sum + w.quantityTons);

  double get todaysWorkAmount =>
      todaysWorks.fold(0.0, (sum, w) => sum + w.totalAmount);

  List<WorkEntry> get thisMonthsWorks {
    final now = DateTime.now();
    return _workEntries
        .where((w) => AppFormatters.isSameMonth(w.workDate, now))
        .toList();
  }

  double get thisMonthWorkTons =>
      thisMonthsWorks.fold(0.0, (sum, w) => sum + w.quantityTons);

  double get thisMonthWorkAmount =>
      thisMonthsWorks.fold(0.0, (sum, w) => sum + w.totalAmount);

  List<WorkEntry> get pendingWorkEntries =>
      _workEntries.where((w) => w.remainingBalance > 0.01).toList();

  List<String> get distinctVillages {
    final set = _customers
        .map((c) => c.village.trim())
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList();
    set.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return set;
  }

  // --- Customer Aggregates ---
  double customerTotalBilled(String customerId) => _workEntries
      .where((w) => w.customerId == customerId)
      .fold(0.0, (sum, w) => sum + w.totalAmount);

  double customerTotalReceived(String customerId) => _workEntries
      .where((w) => w.customerId == customerId)
      .fold(0.0, (sum, w) => sum + w.receivedAmount);

  double customerRemainingBalance(String customerId) => _workEntries
      .where((w) => w.customerId == customerId)
      .fold(0.0, (sum, w) => sum + w.remainingBalance);

  double customerTotalTons(String customerId) => _workEntries
      .where((w) => w.customerId == customerId)
      .fold(0.0, (sum, w) => sum + w.quantityTons);

  List<WorkEntry> workEntriesForCustomer(String customerId) =>
      _workEntries.where((w) => w.customerId == customerId).toList();

  List<Payment> paymentsForCustomer(String customerId) =>
      _payments.where((p) => p.customerId == customerId).toList();

  List<Payment> paymentsForWork(String workId) =>
      _payments.where((p) => p.workEntryId == workId).toList();

  // --- Chart Data ---
  List<DailyChartPoint> getChartPoints({required bool isWeekly}) {
    final now = DateTime.now();
    final List<DailyChartPoint> points = [];

    if (isWeekly) {
      for (int i = 6; i >= 0; i--) {
        final day = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: i));
        final rev = _workEntries
            .where((w) => AppFormatters.isSameDay(w.workDate, day))
            .fold(0.0, (s, w) => s + w.totalAmount);
        final exp = _expenses
            .where((e) => AppFormatters.isSameDay(e.expenseDate, day))
            .fold(0.0, (s, e) => s + e.amount);
        points.add(
          DailyChartPoint(
            label: '${day.day}/${day.month}',
            revenue: rev,
            expense: exp,
          ),
        );
      }
    } else {
      for (int i = 5; i >= 0; i--) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final rev = _workEntries
            .where((w) => AppFormatters.isSameMonth(w.workDate, monthDate))
            .fold(0.0, (s, w) => s + w.totalAmount);
        final exp = _expenses
            .where((e) => AppFormatters.isSameMonth(e.expenseDate, monthDate))
            .fold(0.0, (s, e) => s + e.amount);
        const monthNames = [
          'जाने', 'फेब्रु', 'मार्च', 'एप्रिल', 'मे', 'जून',
          'जुलै', 'ऑग', 'सप्टें', 'ऑक्टो', 'नोव्हें', 'डिसें'
        ];
        points.add(
          DailyChartPoint(
            label: monthNames[monthDate.month - 1],
            revenue: rev,
            expense: exp,
          ),
        );
      }
    }
    return points;
  }

  // --- Customer CRUD ---
  Future<Customer> addCustomer({
    required String name,
    required String mobile,
    required String village,
    String address = '',
  }) async {
    final customer = Customer(
      id: _uuid.v4(),
      name: name.trim(),
      mobile: mobile.trim(),
      village: village.trim(),
      address: address.trim(),
      createdAt: DateTime.now(),
    );
    await _customerRepo.insert(customer);
    _customers.add(customer);
    _customers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    notifyListeners();
    return customer;
  }

  Future<void> updateCustomer(Customer customer) async {
    await _customerRepo.update(customer);
    final idx = _customers.indexWhere((c) => c.id == customer.id);
    if (idx != -1) {
      _customers[idx] = customer;
      _customers.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }
    // Sync denormalized customer info on existing work entries
    for (int i = 0; i < _workEntries.length; i++) {
      if (_workEntries[i].customerId == customer.id) {
        final updatedWork = _workEntries[i].copyWith(
          customerName: customer.name,
          customerMobile: customer.mobile,
          village: customer.village,
        );
        _workEntries[i] = updatedWork;
        await _workRepo.update(updatedWork);
      }
    }
    notifyListeners();
  }

  Future<void> deleteCustomer(String id) async {
    await _customerRepo.delete(id);
    _customers.removeWhere((c) => c.id == id);
    _workEntries.removeWhere((w) => w.customerId == id);
    _payments.removeWhere((p) => p.customerId == id);
    notifyListeners();
  }

  // --- Work Entry CRUD ---
  Future<WorkEntry> addWorkEntry({
    required Customer customer,
    required DateTime workDate,
    required String machineName,
    required double quantityTons,
    required double ratePerTon,
    double additionalCharges = 0.0,
    double discount = 0.0,
    double advancePayment = 0.0,
    PaymentMethod advanceMethod = PaymentMethod.cash,
    String notes = '',
  }) async {
    final total = WorkEntry.calculateTotal(
      quantityTons: quantityTons,
      ratePerTon: ratePerTon,
      additionalCharges: additionalCharges,
      discount: discount,
    );
    final safeAdvance = min(max(0.0, advancePayment), total);
    final remaining = WorkEntry.calculateRemaining(
      totalAmount: total,
      receivedAmount: safeAdvance,
    );

    final entry = WorkEntry(
      id: _uuid.v4(),
      customerId: customer.id,
      customerName: customer.name,
      customerMobile: customer.mobile,
      village: customer.village,
      workDate: workDate,
      machineName: machineName.trim(),
      quantityTons: quantityTons,
      ratePerTon: ratePerTon,
      additionalCharges: additionalCharges,
      discount: discount,
      totalAmount: total,
      receivedAmount: safeAdvance,
      remainingBalance: remaining,
      notes: notes.trim(),
      createdAt: DateTime.now(),
    );

    await _workRepo.insert(entry);
    _workEntries.insert(0, entry);
    _sortWorkEntries();

    if (safeAdvance > 0) {
      final payment = Payment(
        id: _uuid.v4(),
        customerId: customer.id,
        customerName: customer.name,
        workEntryId: entry.id,
        amount: safeAdvance,
        paymentDate: workDate,
        method: advanceMethod,
        notes: 'कामासाठी अॅडव्हान्स पेमेंट',
        isAdvance: true,
        createdAt: DateTime.now(),
      );
      await _paymentRepo.insert(payment);
      _payments.insert(0, payment);
      _sortPayments();
    }

    notifyListeners();
    return entry;
  }

  Future<void> updateWorkEntry(WorkEntry updated) async {
    final total = WorkEntry.calculateTotal(
      quantityTons: updated.quantityTons,
      ratePerTon: updated.ratePerTon,
      additionalCharges: updated.additionalCharges,
      discount: updated.discount,
    );
    final safeReceived = min(updated.receivedAmount, total);
    final remaining = WorkEntry.calculateRemaining(
      totalAmount: total,
      receivedAmount: safeReceived,
    );
    final finalEntry = updated.copyWith(
      totalAmount: total,
      receivedAmount: safeReceived,
      remainingBalance: remaining,
    );
    await _workRepo.update(finalEntry);
    final idx = _workEntries.indexWhere((w) => w.id == finalEntry.id);
    if (idx != -1) {
      _workEntries[idx] = finalEntry;
    }
    _sortWorkEntries();
    notifyListeners();
  }

  Future<void> deleteWorkEntry(String id) async {
    await _paymentRepo.deleteByWorkEntryId(id);
    await _workRepo.delete(id);
    _payments.removeWhere((p) => p.workEntryId == id);
    _workEntries.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  // --- Payment CRUD ---
  Future<String?> addPayment({
    required Customer customer,
    WorkEntry? workEntry,
    required double amount,
    required DateTime paymentDate,
    required PaymentMethod method,
    String notes = '',
  }) async {
    if (amount <= 0) {
      return 'पेमेंट रक्कम शून्यापेक्षा जास्त असावी.';
    }

    if (workEntry != null) {
      if (amount > workEntry.remainingBalance + 0.01) {
        return 'रक्कम बाकी रकमेपेक्षा (${AppFormatters.currency(workEntry.remainingBalance)}) जास्त असू शकत नाही.';
      }

      final newReceived = workEntry.receivedAmount + amount;
      final newRemaining = WorkEntry.calculateRemaining(
        totalAmount: workEntry.totalAmount,
        receivedAmount: newReceived,
      );

      final updatedWork = workEntry.copyWith(
        receivedAmount: newReceived,
        remainingBalance: newRemaining,
      );
      await _workRepo.update(updatedWork);
      final idx = _workEntries.indexWhere((w) => w.id == workEntry.id);
      if (idx != -1) _workEntries[idx] = updatedWork;

      final payment = Payment(
        id: _uuid.v4(),
        customerId: customer.id,
        customerName: customer.name,
        workEntryId: workEntry.id,
        amount: amount,
        paymentDate: paymentDate,
        method: method,
        notes: notes.trim(),
        createdAt: DateTime.now(),
      );
      await _paymentRepo.insert(payment);
      _payments.insert(0, payment);
      _sortPayments();
      notifyListeners();
      return null;
    } else {
      // Allocate across unpaid work entries for customer (oldest first)
      final totalCustomerPending = customerRemainingBalance(customer.id);
      if (amount > totalCustomerPending + 0.01) {
        return 'रक्कम एकूण बाकी रकमेपेक्षा (${AppFormatters.currency(totalCustomerPending)}) जास्त असू शकत नाही.';
      }

      double remainingToAllocate = amount;
      final unpaidWorks = _workEntries
          .where((w) => w.customerId == customer.id && w.remainingBalance > 0.01)
          .toList()
        ..sort((a, b) => a.workDate.compareTo(b.workDate));

      for (final w in unpaidWorks) {
        if (remainingToAllocate <= 0.01) break;
        final applyAmount = min(remainingToAllocate, w.remainingBalance);
        final updatedWork = w.copyWith(
          receivedAmount: w.receivedAmount + applyAmount,
          remainingBalance: WorkEntry.calculateRemaining(
            totalAmount: w.totalAmount,
            receivedAmount: w.receivedAmount + applyAmount,
          ),
        );
        await _workRepo.update(updatedWork);
        final idx = _workEntries.indexWhere((item) => item.id == w.id);
        if (idx != -1) _workEntries[idx] = updatedWork;

        final payment = Payment(
          id: _uuid.v4(),
          customerId: customer.id,
          customerName: customer.name,
          workEntryId: w.id,
          amount: applyAmount,
          paymentDate: paymentDate,
          method: method,
          notes: notes.trim(),
          createdAt: DateTime.now(),
        );
        await _paymentRepo.insert(payment);
        _payments.insert(0, payment);
        remainingToAllocate -= applyAmount;
      }
      _sortPayments();
      notifyListeners();
      return null;
    }
  }

  Future<void> deletePayment(Payment payment) async {
    if (payment.workEntryId != null) {
      final idx =
          _workEntries.indexWhere((w) => w.id == payment.workEntryId);
      if (idx != -1) {
        final w = _workEntries[idx];
        final newReceived = max(0.0, w.receivedAmount - payment.amount);
        final updated = w.copyWith(
          receivedAmount: newReceived,
          remainingBalance: WorkEntry.calculateRemaining(
            totalAmount: w.totalAmount,
            receivedAmount: newReceived,
          ),
        );
        await _workRepo.update(updated);
        _workEntries[idx] = updated;
      }
    }
    await _paymentRepo.delete(payment.id);
    _payments.removeWhere((p) => p.id == payment.id);
    notifyListeners();
  }

  // --- Expense CRUD ---
  Future<void> addExpense({
    required DateTime expenseDate,
    required ExpenseCategory category,
    required double amount,
    String description = '',
    String? receiptPath,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      expenseDate: expenseDate,
      category: category,
      amount: amount,
      description: description.trim(),
      receiptPath: receiptPath,
      createdAt: DateTime.now(),
    );
    await _expenseRepo.insert(expense);
    _expenses.insert(0, expense);
    _sortExpenses();
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await _expenseRepo.update(expense);
    final idx = _expenses.indexWhere((e) => e.id == expense.id);
    if (idx != -1) {
      _expenses[idx] = expense;
    }
    _sortExpenses();
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _expenseRepo.delete(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void _sortWorkEntries() {
    _workEntries.sort((a, b) {
      final cmp = b.workDate.compareTo(a.workDate);
      return cmp != 0 ? cmp : b.createdAt.compareTo(a.createdAt);
    });
  }

  void _sortPayments() {
    _payments.sort((a, b) {
      final cmp = b.paymentDate.compareTo(a.paymentDate);
      return cmp != 0 ? cmp : b.createdAt.compareTo(a.createdAt);
    });
  }

  void _sortExpenses() {
    _expenses.sort((a, b) {
      final cmp = b.expenseDate.compareTo(a.expenseDate);
      return cmp != 0 ? cmp : b.createdAt.compareTo(a.createdAt);
    });
  }
}
