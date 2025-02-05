import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State createState() {
    return _CreateUserState();
  }
}

class _CreateUserState extends State<CreateUserPage> {
  late String email, password;
  final _formKey = GlobalKey<FormState>();
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondoVerde.png'),
            fit: BoxFit
                .cover, // Esto asegura que la imagen cubra toda la pantalla
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
                    "Regístrate",
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
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: formulario(),
                ),
                botonCrearUsuario(),
                regresarLogin(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget formulario() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmail(),
          const SizedBox(height: 12),
          buildPassword(),
        ],
      ),
    );
  }

  Widget buildEmail() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Email",
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
      keyboardType:
          TextInputType.emailAddress, // Aquí está el tipo de teclado para email
      onSaved: (String? value) {
        email = value!;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
    );
  }

  Widget buildPassword() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Contraseña",
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
          Icons.lock,
          color: Colors.purpleAccent,
        ),
      ),
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      keyboardType:
          TextInputType.text, // Para asegurar que se muestre el teclado normal
      validator: (value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
      onSaved: (String? value) {
        password = value!;
      },
    );
  }

  Widget botonCrearUsuario() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              UserCredential? credenciales = await crear(email, password);
              if (credenciales != null && credenciales.user != null) {
                await credenciales.user!.sendEmailVerification();
                Navigator.pop(context);
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purpleAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
          child: const Text(
            "Registrarse",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget regresarLogin() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text(
        "¿Ya tienes una cuenta? Inicia sesión",
        style: TextStyle(color: Colors.purpleAccent),
      ),
    );
  }

  Future<UserCredential?> crear(String email, String passwd) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Guardar en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential
              .user!.uid) // Usamos el UID del usuario como ID del documento
          .set({
        'email': email,
        'victorias': 0,
        'derrotas': 0,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          error = "El correo ya se encuentra en uso";
        });
      } else if (e.code == 'weak-password') {
        setState(() {
          error = "La contraseña es demasiado débil";
        });
      }
    }
    return null;
  }
}
