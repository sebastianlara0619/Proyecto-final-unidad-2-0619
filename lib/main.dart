import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'views/login_screen.dart';
import 'views/worker_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LaraPhonesApp());
}

class LaraPhonesApp extends StatelessWidget {
  const LaraPhonesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Lara Phone's",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light, // MODO CLARO ACTIVADO
        
        // Sinergia Visual: Azul y Violeta mediante códigos Hexadecimales
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A11CB), // Violeta
          brightness: Brightness.light,
          primary: const Color(0xFF2575FC),   // Azul
          secondary: const Color(0xFF6A11CB), // Violeta
          surface: const Color(0xFFFFFFFF),   // Fondo Blanco
        ),

        scaffoldBackgroundColor: const Color(0xFFFFFFFF),

        // Fuente Montserrat: Limpia y moderna
        textTheme: GoogleFonts.montserratTextTheme(
          ThemeData.light().textTheme,
        ).apply(
          bodyColor: const Color(0xFF2D3436),    // Texto oscuro para lectura
          displayColor: const Color(0xFF2575FC), // Títulos en Azul
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// Este widget controla si el usuario ya está logueado o debe ir al Login
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras Firebase responde
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF2575FC)),
            ),
          );
        }
        // Si hay un usuario activo, vamos a la lista
        if (snapshot.hasData) {
          return const WorkerList();
        }
        // Si no hay sesión, vamos al Login
        return const LoginScreen();
      },
    );
  }
}