import 'package:flutter/material.dart';
import '../../../../../data/services/firebase/centro_educativo_firestore_service.dart';

class CentroEducativoScreen extends StatefulWidget {
  const CentroEducativoScreen({super.key});

  @override
  State<CentroEducativoScreen> createState() => _CentroEducativoScreenState();
}

class _CentroEducativoScreenState extends State<CentroEducativoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _centroService = CentroEducativoFirestoreService();
  bool _isLoading = true;

  // Controllers básicos
  final _nombreCentroController = TextEditingController();
  final _direccionController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoCentroController = TextEditingController();
  final _codigoGestionController = TextEditingController();
  final _codigoCartografiaController = TextEditingController();

  // Director
  final _directorNombreController = TextEditingController();
  final _directorCorreoController = TextEditingController();
  final _directorTelefonoController = TextEditingController();

  // Docente encargado
  final _docenteNombreController = TextEditingController();
  final _docenteCorreoController = TextEditingController();
  final _docenteTelefonoController = TextEditingController();

  // Regional y Distrito
  final _regionalController = TextEditingController();
  final _distritoController = TextEditingController();

  // Radio buttons
  String? _sectorSeleccionado;
  String? _zonaSeleccionada;
  String? _jornadaSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    final datos = await _centroService.obtenerDatosCentro();

    if (mounted) {
      setState(() {
        if (datos != null) {
          _nombreCentroController.text = datos['nombre_centro'] ?? '';
          _direccionController.text = datos['direccion'] ?? '';
          _correoController.text = datos['correo'] ?? '';
          _telefonoCentroController.text = datos['telefono_centro'] ?? '';
          _codigoGestionController.text = datos['codigo_gestion'] ?? '';
          _codigoCartografiaController.text = datos['codigo_cartografia'] ?? '';
          _directorNombreController.text = datos['director_nombre'] ?? '';
          _directorCorreoController.text = datos['director_correo'] ?? '';
          _directorTelefonoController.text = datos['director_telefono'] ?? '';
          _docenteNombreController.text = datos['docente_nombre'] ?? '';
          _docenteCorreoController.text = datos['docente_correo'] ?? '';
          _docenteTelefonoController.text = datos['docente_telefono'] ?? '';
          _regionalController.text = datos['regional'] ?? '';
          _distritoController.text = datos['distrito'] ?? '';
          _sectorSeleccionado = datos['sector'];
          _zonaSeleccionada = datos['zona'];
          _jornadaSeleccionada = datos['jornada'];
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarDatos() async {
    final datos = {
      'nombre_centro': _nombreCentroController.text,
      'direccion': _direccionController.text,
      'correo': _correoController.text,
      'telefono_centro': _telefonoCentroController.text,
      'codigo_gestion': _codigoGestionController.text,
      'codigo_cartografia': _codigoCartografiaController.text,
      'director_nombre': _directorNombreController.text,
      'director_correo': _directorCorreoController.text,
      'director_telefono': _directorTelefonoController.text,
      'docente_nombre': _docenteNombreController.text,
      'docente_correo': _docenteCorreoController.text,
      'docente_telefono': _docenteTelefonoController.text,
      'regional': _regionalController.text,
      'distrito': _distritoController.text,
      'sector': _sectorSeleccionado,
      'zona': _zonaSeleccionada,
      'jornada': _jornadaSeleccionada,
    };

    await _centroService.guardarDatosCentro(datos);
  }

  @override
  void dispose() {
    _nombreCentroController.dispose();
    _direccionController.dispose();
    _correoController.dispose();
    _telefonoCentroController.dispose();
    _codigoGestionController.dispose();
    _codigoCartografiaController.dispose();
    _directorNombreController.dispose();
    _directorCorreoController.dispose();
    _directorTelefonoController.dispose();
    _docenteNombreController.dispose();
    _docenteCorreoController.dispose();
    _docenteTelefonoController.dispose();
    _regionalController.dispose();
    _distritoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Datos del Centro Educativo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar',
            onPressed: _guardarDatos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              const Center(
                child: Text(
                  'Datos del Centro Educativo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Nombre del centro
              _buildLabeledTextField(
                label: 'Nombre del centro',
                controller: _nombreCentroController,
              ),
              const SizedBox(height: 16),

              // Dirección
              _buildLabeledTextField(
                label: 'Dirección',
                controller: _direccionController,
              ),
              const SizedBox(height: 16),

              // Correo y Teléfono
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildLabeledTextField(
                      label: 'Correo electrónico',
                      controller: _correoController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLabeledTextField(
                      label: 'Teléfono',
                      controller: _telefonoCentroController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Códigos
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildLabeledTextField(
                      label: 'Código de gestión SIGERD',
                      controller: _codigoGestionController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLabeledTextField(
                      label: 'Código de cartografía',
                      controller: _codigoCartografiaController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Director del centro
              _buildLabeledTextField(
                label: 'Director del centro',
                controller: _directorNombreController,
              ),
              const SizedBox(height: 16),

              // Correo y Teléfono Director
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildLabeledTextField(
                      label: 'Correo electrónico',
                      controller: _directorCorreoController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLabeledTextField(
                      label: 'Teléfono',
                      controller: _directorTelefonoController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Docente encargado de curso
              _buildLabeledTextField(
                label: 'Docente encargado de curso',
                controller: _docenteNombreController,
              ),
              const SizedBox(height: 16),

              // Correo y Teléfono Docente
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildLabeledTextField(
                      label: 'Correo electrónico',
                      controller: _docenteCorreoController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLabeledTextField(
                      label: 'Teléfono',
                      controller: _docenteTelefonoController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sector
              _buildRadioGroup(
                label: 'Sector',
                options: ['Público', 'Privado', 'Semioficial'],
                selectedValue: _sectorSeleccionado,
                onChanged: (value) {
                  setState(() {
                    _sectorSeleccionado = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Zona
              _buildRadioGroup(
                label: 'Zona',
                options: ['Urbana', 'Urbana marginal', 'Urbana turística', 'Rural', 'Rural aislada', 'Rural turística'],
                selectedValue: _zonaSeleccionada,
                onChanged: (value) {
                  setState(() {
                    _zonaSeleccionada = value;
                  });
                },
                columns: 3,
              ),
              const SizedBox(height: 16),

              // Jornada
              _buildRadioGroup(
                label: 'Jornada',
                options: ['Jee', 'Matutina', 'Vespertina', 'Nocturna'],
                selectedValue: _jornadaSeleccionada,
                onChanged: (value) {
                  setState(() {
                    _jornadaSeleccionada = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Regional y Distrito
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildLabeledTextField(
                      label: 'Regional',
                      controller: _regionalController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLabeledTextField(
                      label: 'Distrito',
                      controller: _distritoController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Botón Guardar
              Center(
                child: SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _guardarDatos();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Datos guardados en la base de datos'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFbfa661),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[400],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!, width: 1),
          ),
          child: TextField(
            controller: controller,
            onChanged: (_) => _guardarDatos(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioGroup({
    required String label,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    int columns = 4,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[400],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Wrap(
            spacing: 24,
            runSpacing: 8,
            children: options.map((option) {
              return InkWell(
                onTap: () {
                  onChanged(option);
                  _guardarDatos();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedValue == option ? const Color(0xFF2196F3) : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: selectedValue == option
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF2196F3),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
