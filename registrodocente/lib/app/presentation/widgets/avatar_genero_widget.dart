import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarGeneroWidget extends StatefulWidget {
  final double radius;

  const AvatarGeneroWidget({
    super.key,
    this.radius = 40,
  });

  @override
  State<AvatarGeneroWidget> createState() => _AvatarGeneroWidgetState();
}

class _AvatarGeneroWidgetState extends State<AvatarGeneroWidget> {
  String? _genero;

  @override
  void initState() {
    super.initState();
    _cargarGenero();
  }

  Future<void> _cargarGenero() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _genero = prefs.getString('usuario_genero');
    });
  }

  IconData _getIconForGenero() {
    switch (_genero) {
      case 'Masculino':
        return Icons.person;
      case 'Femenino':
        return Icons.person_outline;
      case 'Otro':
        return Icons.person_pin;
      default:
        return Icons.account_circle;
    }
  }

  Color _getColorForGenero() {
    switch (_genero) {
      case 'Masculino':
        return Colors.blue;
      case 'Femenino':
        return Colors.pink;
      case 'Otro':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: _getColorForGenero().withValues(alpha: 0.2),
      child: Icon(
        _getIconForGenero(),
        size: widget.radius * 1.2,
        color: _getColorForGenero(),
      ),
    );
  }
}
