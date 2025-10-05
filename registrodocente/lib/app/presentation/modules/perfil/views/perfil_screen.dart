import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String fotoPerfil = 'https://i.pravatar.cc/150?img=3';
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _centroController = TextEditingController(
    text: 'Centro Educativo Eugenio M. de Hostos',
  );
  final TextEditingController _regionalController = TextEditingController(
    text: '17',
  );
  final TextEditingController _distritoController = TextEditingController(
    text: '04',
  );

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final nombre = prefs.getString('usuario_nombre') ?? 'Usuario';
    final centro = prefs.getString('centro_educativo') ?? 'Centro Educativo Eugenio M. de Hostos';
    final regional = prefs.getString('regional') ?? '17';
    final distrito = prefs.getString('distrito') ?? '04';
    final foto = prefs.getString('foto_perfil') ?? 'https://i.pravatar.cc/150?img=3';

    setState(() {
      _nombreController.text = nombre;
      _centroController.text = centro;
      _regionalController.text = regional;
      _distritoController.text = distrito;
      fotoPerfil = foto;
    });
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario_nombre', _nombreController.text);
    await prefs.setString('centro_educativo', _centroController.text);
    await prefs.setString('regional', _regionalController.text);
    await prefs.setString('distrito', _distritoController.text);
    await prefs.setString('foto_perfil', fotoPerfil);
  }

  void _mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cambiar foto de perfil',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de cámara en desarrollo')),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.green),
                ),
                title: const Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de galería en desarrollo')),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.link, color: Colors.orange),
                ),
                title: const Text('Usar URL de imagen'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDialogoURL();
                },
              ),
              if (fotoPerfil != 'https://i.pravatar.cc/150?img=3')
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  title: const Text(
                    'Eliminar foto',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    setState(() {
                      fotoPerfil = 'https://i.pravatar.cc/150?img=3';
                    });
                    await _guardarDatos();
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Foto de perfil restaurada'),
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogoURL() {
    final TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('URL de la imagen'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              labelText: 'URL',
              hintText: 'https://ejemplo.com/imagen.jpg',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (urlController.text.isNotEmpty) {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  setState(() {
                    fotoPerfil = urlController.text;
                  });
                  await _guardarDatos();

                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Foto de perfil actualizada'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _guardarCambios() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cambios guardados correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _guardarCambios,
            tooltip: 'Guardar cambios',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Foto de perfil
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.blue,
                          width: 4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(fotoPerfil),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _mostrarOpcionesFoto,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.blueAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Formulario de datos
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre completo',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _centroController,
                label: 'Centro educativo',
                icon: Icons.school,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _regionalController,
                      label: 'Regional',
                      icon: Icons.location_on,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _distritoController,
                      label: 'Distrito',
                      icon: Icons.location_city,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Botón de guardar
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _guardarCambios,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Guardar cambios',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => _guardarDatos(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.3), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.3), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _centroController.dispose();
    _regionalController.dispose();
    _distritoController.dispose();
    super.dispose();
  }
}
