import 'package:flutter/material.dart';
import '../utils/auto_save_controller.dart';

/// Widget que muestra el estado del autoguardado
class AutoSaveIndicator extends StatelessWidget {
  final AutoSaveController controller;
  final bool compact;

  const AutoSaveIndicator({
    super.key,
    required this.controller,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final status = controller.status;

        if (status == SaveStatus.idle && !compact) {
          return const SizedBox.shrink();
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildContent(context, status),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, SaveStatus status) {
    final theme = Theme.of(context);

    switch (status) {
      case SaveStatus.idle:
        return compact
            ? Icon(Icons.check_circle, color: Colors.grey[400], size: 16, key: const ValueKey('idle'))
            : const SizedBox.shrink(key: ValueKey('idle'));

      case SaveStatus.pending:
        return Row(
          key: const ValueKey('pending'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, color: Colors.orange[700], size: compact ? 16 : 18),
            if (!compact) ...[
              const SizedBox(width: 6),
              Text(
                'Cambios pendientes...',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );

      case SaveStatus.saving:
        return Row(
          key: const ValueKey('saving'),
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: compact ? 14 : 16,
              height: compact ? 14 : 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 8),
              Text(
                'Guardando...',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );

      case SaveStatus.saved:
        return Row(
          key: const ValueKey('saved'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: compact ? 16 : 18),
            if (!compact) ...[
              const SizedBox(width: 6),
              Text(
                'Guardado',
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );

      case SaveStatus.error:
        return Row(
          key: const ValueKey('error'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red[600], size: compact ? 16 : 18),
            if (!compact) ...[
              const SizedBox(width: 6),
              Text(
                'Error al guardar',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
    }
  }
}
