import 'package:flutter/foundation.dart';
import '../models/purchase.dart';
import '../services/purchase_service.dart';

class PurchaseProvider with ChangeNotifier {
  final PurchaseService _purchaseService;
  List<Purchase> _purchases = [];
  bool _isLoading = false;
  String? _error;

  PurchaseProvider(this._purchaseService);

  List<Purchase> get purchases => _purchases;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPurchases() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _purchases = await _purchaseService.getPurchases();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPurchase(Purchase purchase) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPurchase = await _purchaseService.createPurchase(purchase);
      _purchases.add(newPurchase);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePurchase(String id, Purchase purchase) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedPurchase = await _purchaseService.updatePurchase(
        id,
        purchase,
      );
      final index = _purchases.indexWhere((p) => p.id == id);
      if (index != -1) {
        _purchases[index] = updatedPurchase;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePurchase(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _purchaseService.deletePurchase(id);
      _purchases.removeWhere((p) => p.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
