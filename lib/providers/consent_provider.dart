import 'package:flutter/material.dart';
import '../services/consent_service.dart';

class ConsentProvider with ChangeNotifier {
  bool _consentGiven = true;
  bool _isLoading = false;
  bool _hasCheckedConsent = false;

  bool get consentGiven => _consentGiven;
  bool get isLoading => _isLoading;
  bool get hasCheckedConsent => _hasCheckedConsent;

  /// Fetch consent from server
  Future<void> fetchConsentState() async {
    _isLoading = true;
    notifyListeners();

    try {
      final consent = await ConsentService.fetchUserConsent();
      if (consent != null) {
        _consentGiven = consent.consentGiven;
        _hasCheckedConsent = true;
      }
    } catch (e) {
      debugPrint('[ConsentProvider] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create initial consent
  Future<void> createInitialConsent(bool given) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ConsentService.createConsent(given);
      _consentGiven = given;
      _hasCheckedConsent = true;
    } catch (e) {
      debugPrint('[ConsentProvider] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle consent (updates on server)
  Future<void> toggleConsent(bool given) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ConsentService.updateConsent(given);
      _consentGiven = given;
    } catch (e) {
      debugPrint('[ConsentProvider] Error toggle: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
