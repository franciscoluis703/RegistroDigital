import 'package:flutter/material.dart';

class CalendarioEscolarScreen extends StatelessWidget {
  const CalendarioEscolarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Calendario Escolar 2025-2026'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Información general
          _InfoCard(
            icon: Icons.school,
            title: 'Año Escolar 2025-2026',
            color: Colors.green,
            children: [
              _InfoRow('Inicio docentes:', '4 de agosto de 2025'),
              _InfoRow('Inicio estudiantes:', '25 de agosto de 2025'),
              _InfoRow('Fin del año escolar:', '26 de junio de 2026'),
              const SizedBox(height: 8),
              _InfoRow('Días laborales estudiantes:', '191 días (40 semanas)'),
              _InfoRow('Días laborales docentes:', '210 días (45 semanas)'),
            ],
          ),

          const SizedBox(height: 16),

          // Vacaciones
          _InfoCard(
            icon: Icons.beach_access,
            title: 'Vacaciones y Recesos',
            color: Colors.blue,
            children: [
              _InfoRow('Receso Navideño:', '22 dic 2025 - 6 ene 2026'),
              _InfoRow('Semana Santa:', '30 mar - 3 abr 2026'),
              _InfoRow('Fin del 1er semestre:', '19 de diciembre de 2025'),
              _InfoRow('Reanudación de clases:', '7 de enero de 2026'),
            ],
          ),

          const SizedBox(height: 16),

          // Feriados 2025
          _FeriadosCard(
            title: 'Feriados Nacionales 2025',
            year: '2025',
            feriados: [
              _Feriado('1 de enero', 'Año Nuevo', 'Miércoles'),
              _Feriado('6 de enero', 'Día de los Santos Reyes', 'Lunes'),
              _Feriado('21 de enero', 'Día de Nuestra Señora de la Altagracia', 'Martes'),
              _Feriado('26 de enero', 'Día de Juan Pablo Duarte', 'Lunes'),
              _Feriado('27 de febrero', 'Día de la Independencia Nacional', 'Jueves'),
              _Feriado('18 de abril', 'Viernes Santo', 'Viernes'),
              _Feriado('5 de mayo', 'Día del Trabajo (trasladado)', 'Lunes'),
              _Feriado('19 de junio', 'Corpus Christi', 'Jueves'),
              _Feriado('16 de agosto', 'Día de la Restauración', 'Sábado'),
              _Feriado('24 de septiembre', 'Nuestra Señora de las Mercedes', 'Miércoles'),
              _Feriado('10 de noviembre', 'Día de la Constitución (trasladado)', 'Lunes'),
              _Feriado('25 de diciembre', 'Navidad', 'Jueves'),
            ],
          ),

          const SizedBox(height: 16),

          // Feriados 2026
          _FeriadosCard(
            title: 'Feriados Nacionales 2026',
            year: '2026',
            feriados: [
              _Feriado('1 de enero', 'Año Nuevo', 'Jueves'),
              _Feriado('5 de enero', 'Día de los Santos Reyes (trasladado)', 'Lunes'),
              _Feriado('21 de enero', 'Día de la Altagracia', 'Miércoles'),
              _Feriado('26 de enero', 'Natalicio de Juan Pablo Duarte', 'Lunes'),
              _Feriado('27 de febrero', 'Independencia Nacional', 'Viernes'),
              _Feriado('3 de abril', 'Viernes Santo', 'Viernes'),
              _Feriado('4 de mayo', 'Día del Trabajo (trasladado)', 'Lunes'),
              _Feriado('11 de junio', 'Corpus Christi', 'Jueves'),
              _Feriado('16 de agosto', 'Día de la Restauración', 'Domingo'),
              _Feriado('24 de septiembre', 'Nuestra Señora de las Mercedes', 'Jueves'),
              _Feriado('9 de noviembre', 'Día de la Constitución (trasladado)', 'Lunes'),
              _Feriado('25 de diciembre', 'Navidad', 'Viernes'),
            ],
          ),

          const SizedBox(height: 16),

          // Evaluaciones
          _InfoCard(
            icon: Icons.assignment,
            title: 'Evaluaciones Nacionales',
            color: Colors.orange,
            children: [
              _InfoRow('Exámenes Nacionales:', '24-27 de junio de 2026'),
            ],
          ),

          const SizedBox(height: 16),

          // Información adicional
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Información Legal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Calendario aprobado mediante Resolución 12/2025 del Ministerio de Educación.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ley 139-97: Los feriados que caigan en martes, miércoles, jueves o viernes serán trasladados al lunes.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<Widget> children;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeriadosCard extends StatefulWidget {
  final String title;
  final String year;
  final List<_Feriado> feriados;

  const _FeriadosCard({
    required this.title,
    required this.year,
    required this.feriados,
  });

  @override
  State<_FeriadosCard> createState() => _FeriadosCardState();
}

class _FeriadosCardState extends State<_FeriadosCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: _expanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      )
                    : BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.celebration, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: widget.feriados
                    .map((f) => _FeriadoItem(feriado: f))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _Feriado {
  final String fecha;
  final String nombre;
  final String dia;

  _Feriado(this.fecha, this.nombre, this.dia);
}

class _FeriadoItem extends StatelessWidget {
  final _Feriado feriado;

  const _FeriadoItem({required this.feriado});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              feriado.fecha,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feriado.nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  feriado.dia,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
