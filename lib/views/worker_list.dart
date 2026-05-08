import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
// Esta es la línea que ya no te marcará error porque ahora usamos la clase Worker abajo
import '../models/worker.dart'; 
import 'worker_form.dart';
import 'login_screen.dart';

class WorkerList extends StatelessWidget {
  const WorkerList({super.key});

  // FUNCIÓN NUEVA: Muestra el cuadro de diálogo de confirmación
  void _confirmarBorrado(BuildContext context, String id, String nombre) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar borrado"),
          content: Text("¿Estás seguro que quieres borrar a $nombre?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cierra el diálogo sin hacer nada
              child: const Text("CANCELAR"),
            ),
            TextButton(
              onPressed: () {
                // Borra directamente de Firebase
                FirebaseFirestore.instance.collection('empleados').doc(id).delete();
                Navigator.pop(context); // Cierra el diálogo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$nombre eliminado correctamente")),
                );
              },
              child: const Text("BORRAR", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("STAFF LARA PHONES", 
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2575FC),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()), 
                  (route) => false
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder(
        // Se conecta a tu colección 'empleados' en Firebase Console
        stream: FirebaseFirestore.instance.collection('empleados').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error de conexión"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              // --- AQUÍ ESTÁ LA PARTE QUE SOLUCIONA TU ERROR ---
              // Creamos el objeto Worker usando los datos de Firebase
              final empleado = Worker(
                id: doc.id, 
                name: data['name'] ?? '', 
                position: data['position'] ?? '', 
                phone: data['phone'] ?? '',
              );
              // -------------------------------------------------

              return Card(
                color: Colors.white,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  // AL TOCAR LA TARJETA: Abre el formulario en modo EDICIÓN
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => WorkerForm(
                        id: empleado.id, 
                        name: empleado.name, 
                        position: empleado.position, 
                        phone: empleado.phone,
                      )
                    )
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF6A11CB),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(empleado.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${empleado.position} • ${empleado.phone}"),
                  // BOTÓN BORRAR: Ahora pide confirmación antes de ir a Firebase
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 20, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                        onPressed: () {
                          // LLAMADA A LA FUNCIÓN DE CONFIRMACIÓN
                          _confirmarBorrado(context, empleado.id, empleado.name);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2575FC),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerForm())),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}