import 'dart:async';
import 'package:flutter/foundation.dart';

/// Estados de guardado
enum SaveStatus {
  idle,       // Sin cambios
  pending,    // Cambios pendientes de guardar
  saving,     // Guardando...
  saved,      // Guardado exitoso
  error,      // Error al guardar
}

/// Controlador para manejar el autoguardado con debouncing
class AutoSaveController extends ChangeNotifier {
  Timer? _debounceTimer;
  SaveStatus _status = SaveStatus.idle;
  String? _errorMessage;

  final Duration debounceDuration;
  final Future<bool> Function() onSave;

  AutoSaveController({
    this.debounceDuration = const Duration(seconds: 2),
    required this.onSave,
  });

  SaveStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isSaving => _status == SaveStatus.saving;
  bool get hasPendingChanges => _status == SaveStatus.pending;
  bool get hasError => _status == SaveStatus.error;

  /// Marca que hay cambios pendientes y programa el guardado
  void markAsChanged() {
    _debounceTimer?.cancel();

    if (_status != SaveStatus.saving) {
      _setStatus(SaveStatus.pending);
    }

    _debounceTimer = Timer(debounceDuration, () {
      _saveNow();
    });
  }

  /// Guarda inmediatamente sin esperar el debounce
  Future<void> saveNow() async {
    _debounceTimer?.cancel();
    await _saveNow();
  }

  Future<void> _saveNow() async {
    if (_status == SaveStatus.saving) return;

    _setStatus(SaveStatus.saving);

    try {
      final success = await onSave();

      if (success) {
        _setStatus(SaveStatus.saved);
        _errorMessage = null;

        // Volver a idle después de 2 segundos
        Timer(const Duration(seconds: 2), () {
          if (_status == SaveStatus.saved) {
            _setStatus(SaveStatus.idle);
          }
        });
      } else {
        _setStatus(SaveStatus.error);
        _errorMessage = 'Error al guardar los cambios';
      }
    } catch (e) {
      _setStatus(SaveStatus.error);
      _errorMessage = e.toString();
    }
  }

  void _setStatus(SaveStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }

  /// Resetear el estado
  void reset() {
    _debounceTimer?.cancel();
    _setStatus(SaveStatus.idle);
    _errorMessage = null;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
