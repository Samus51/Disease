import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OlvidarPasswordPage extends StatefulWidget {
  const OlvidarPasswordPage({super.key});

  @override
  State createState() {
    return _OlvidarPasswordPageState();
  }
}

class _OlvidarPasswordPageState extends State<OlvidarPasswordPage> {
  late String email;
  final _formKey = GlobalKey<FormState>();
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/fondoVerde.png'), // Fondo de la pantalla
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Recuperar Contraseña",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.6),
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Offstage(
                      offstage: error.isEmpty,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          error,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            buildEmail(),
                            const SizedBox(height: 20),
                            enviarCorreo(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Icono flotante para volver
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context); // Volver al login
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmail() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Correo electrónico",
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.deepPurple.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.purpleAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.greenAccent),
        ),
        prefixIcon: const Icon(
          Icons.email,
          color: Colors.purpleAccent,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      onSaved: (String? value) {
        email = value!;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return "Por favor, ingresa tu correo";
        }
        return null;
      },
    );
  }

  Widget enviarCorreo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Container(
        width: 300, // Establecemos un ancho fijo para el botón
        child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              try {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);
                setState(() {
                  error =
                      "Se ha enviado un correo para restablecer tu contraseña.";
                });
              } on FirebaseAuthException catch (e) {
                setState(() {
                  error = "Hubo un error: ${e.message}";
                });
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purpleAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.0),
          ),
          child: const Text(
            "Enviar correo",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
