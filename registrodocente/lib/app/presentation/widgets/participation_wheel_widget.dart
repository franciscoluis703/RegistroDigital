import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Widget de ruleta de participación que selecciona aleatoriamente
/// un estudiante de la lista proporcionada
class ParticipationWheelWidget extends StatefulWidget {
  final List<String> studentNames;

  const ParticipationWheelWidget({
    super.key,
    required this.studentNames,
  });

  @override
  State<ParticipationWheelWidget> createState() =>
      _ParticipationWheelWidgetState();
}

class _ParticipationWheelWidgetState extends State<ParticipationWheelWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _selectedStudent;
  bool _isSpinning = false;
  final Random _random = Random();
  double _duration = 3.0; // Duración inicial en segundos

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_duration * 1000).toInt()),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  void _updateDuration(double newDuration) {
    setState(() {
      _duration = newDuration;
      _controller.duration = Duration(milliseconds: (newDuration * 1000).toInt());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    // Filtrar estudiantes que tengan nombre
    final validStudents =
        widget.studentNames.where((name) => name.trim().isNotEmpty).toList();

    if (validStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay estudiantes registrados en Datos Generales'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSpinning = true;
      _selectedStudent = null;
    });

    _controller.reset();
    _controller.forward();

    // Simular selección aleatoria durante el giro
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isSpinning) {
        timer.cancel();
        return;
      }

      setState(() {
        _selectedStudent = validStudents[_random.nextInt(validStudents.length)];
      });
    });

    // Detener después de la duración seleccionada
    Timer(Duration(milliseconds: (_duration * 1000).toInt()), () {
      if (mounted) {
        setState(() {
          _isSpinning = false;
          _selectedStudent =
              validStudents[_random.nextInt(validStudents.length)];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.casino,
                color: Colors.purple[700],
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Ruleta de Participación',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Círculo de la ruleta
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animation.value * 4 * pi,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple[400]!,
                        Colors.purple[600]!,
                        Colors.deepPurple[700]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.casino,
                      size: 60,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Estudiante seleccionado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.purple[200]!,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Estudiante Seleccionado:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.purple[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedStudent ?? '---',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[900],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Control de duración
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Duración de la ruleta:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_duration.toStringAsFixed(0)} seg',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[900],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.purple[600],
                    inactiveTrackColor: Colors.purple[200],
                    thumbColor: Colors.purple[700],
                    overlayColor: Colors.purple.withValues(alpha: 0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _duration,
                    min: 3.0,
                    max: 30.0,
                    divisions: 27,
                    onChanged: _isSpinning ? null : _updateDuration,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '3 seg',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '30 seg',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Botón para girar
          ElevatedButton.icon(
            onPressed: _isSpinning ? null : _spinWheel,
            icon: Icon(_isSpinning ? Icons.hourglass_top : Icons.play_arrow),
            label: Text(
              _isSpinning ? 'Girando...' : 'Girar Ruleta',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
          ),
          const SizedBox(height: 12),

          // Info de estudiantes
          Text(
            'Total de estudiantes: ${widget.studentNames.where((name) => name.trim().isNotEmpty).length}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
