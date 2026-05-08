import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/views/worker_list.dart';

class WorkerForm extends StatefulWidget {
  final String? id, name, position, phone;
  const WorkerForm({super.key, this.id, this.name, this.position, this.phone});

  @override
  State<WorkerForm> createState() => _WorkerFormState();
}

class _WorkerFormState extends State<WorkerForm> {
  late TextEditingController _nameController;
  late TextEditingController _posController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _posController = TextEditingController(text: widget.position);
    _phoneController = TextEditingController(text: widget.phone);
  }

  // FUNCIÓN CONECTADA A FIREBASE QUE REDIRECCIONA AL TERMINAR
  void _saveAndGoBack() async {
    if (_nameController.text.isEmpty) return;

    final data = {
      'name': _nameController.text, 
      'position': _posController.text, 
      'phone': _phoneController.text
    };
    
    if (widget.id == null) {
      // Crea nuevo en la consola de Firebase
      await FirebaseFirestore.instance.collection('empleados').add(data);
    } else {
      // Actualiza el existente en la consola de Firebase
      await FirebaseFirestore.instance.collection('empleados').doc(widget.id).update(data);
    }

    // ESTA LÍNEA ES LA QUE TE ENVÍA DE REGRESO A LA PÁGINA DE STAFF
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WorkerList()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.id == null ? "Nuevo Registro" : "Editar Empleado", 
          style: GoogleFonts.montserrat(color: Colors.white)),
        backgroundColor: const Color(0xFF2575FC),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView( // Evita el error de "Overflow"
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildField(_nameController, "Nombre Completo", Icons.person),
            const SizedBox(height: 20),
            _buildField(_posController, "Puesto", Icons.work),
            const SizedBox(height: 20),
            _buildField(_phoneController, "Teléfono", Icons.phone, isPhone: true),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2575FC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: _saveAndGoBack, // Llama a la función de guardado y regreso
                child: const Text("CONFIRMAR Y GUARDAR", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool isPhone = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6A11CB)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}