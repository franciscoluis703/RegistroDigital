import 'package:flutter/material.dart';
import '../utils/auto_save_controller.dart';

/// Mixin para agregar funcionalidad de autoguardado a cualquier StatefulWidget
mixin AutoSaveMixin<T extends StatefulWidget> on State<T> {
  AutoSaveController? _autoSaveController;

  /// Obtener el controlador de autoguardado
  AutoSaveController get autoSaveController {
    _autoSaveController ??= createAutoSaveController();
    return _autoSaveController!;
  }

  /// Crear el controlador de autoguardado
  /// Debe ser implementado por la clase que use este mixin
  AutoSaveController createAutoSaveController();

  /// Notificar que hubo un cambio
  void notifyChange() {
    autoSaveController.markAsChanged();
  }

  /// Guardar ahora sin esperar el debounce
  Future<void> saveNow() async {
    await autoSaveController.saveNow();
  }

  /// Crear un TextFormField con autoguardado
  Widget buildAutoSaveTextField({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    int? maxLines,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool enabled = true,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      onChanged: (value) {
        notifyChange();
        onChanged?.call(value);
      },
    );
  }

  /// Crear un Checkbox con autoguardado
  Widget buildAutoSaveCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      title: Text(label),
      onChanged: (newValue) {
        onChanged(newValue);
        notifyChange();
      },
    );
  }

  /// Crear un DropdownButton con autoguardado
  Widget buildAutoSaveDropdown<E>({
    required E? initialValue,
    required List<E> items,
    required String Function(E) itemLabel,
    required ValueChanged<E?> onChanged,
    String? labelText,
  }) {
    return DropdownButtonFormField<E>(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem<E>(
          value: item,
          child: Text(itemLabel(item)),
        );
      }).toList(),
      onChanged: (newValue) {
        onChanged(newValue);
        notifyChange();
      },
    );
  }

  @override
  void dispose() {
    _autoSaveController?.dispose();
    super.dispose();
  }
}
