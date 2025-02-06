import 'package:disease/screens/home.dart';
import 'package:disease/screens/olvidar_password.dart';
import 'package:disease/screens/registro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State createState() {
    return _LoginState();
  }
}

class _LoginState extends State<LoginPage> {
  late String email, password;
  final _formKey = GlobalKey<FormState>();
  String error = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('assets/images/fondoVerde.png'), // Ruta de la imagen
            fit: BoxFit.cover, // Hace que la imagen cubra toda la pantalla
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
                    "Disease",
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
                butonLogin(),
                nuevoAqui(),
                olvidoContrasena(), // Aquí agregamos el botón
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget nuevoAqui() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "¿Eres nuevo?",
          style: TextStyle(color: Colors.white),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateUserPage()),
            );
          },
          child: Text(
            "Pulsa aquí para registrarte",
            style: TextStyle(color: Colors.purpleAccent),
          ),
        ),
      ],
    );
  }

  Widget olvidoContrasena() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OlvidarPasswordPage()),
        );
      },
      child: Text(
        "¿Olvidaste tu contraseña?",
        style: TextStyle(color: Colors.purpleAccent),
      ),
    );
  }

  Widget formulario() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmail(),
          const Padding(padding: EdgeInsets.only(top: 12)),
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
      keyboardType: TextInputType.emailAddress,
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
      keyboardType: TextInputType.text,
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

  Widget butonLogin() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              UserCredential? credenciales = await login(email, password);
              if (credenciales != null) {
                if (credenciales.user != null) {
                  if (credenciales.user!.emailVerified) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                      (Route<dynamic> route) => false,
                    );
                  } else {
                    setState(() {
                      error = "Debes verificar tu correo antes de acceder";
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Debes verificar tu correo")),
                    );
                  }
                }
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
            "Iniciar sesión",
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

  Future<UserCredential?> login(String email, String passwd) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          error = "Usuario no encontrado";
        });
      }
      if (e.code == 'wrong-password') {
        setState(() {
          error = "Contraseña incorrecta";
        });
      }
    }
    return null;
  }
}
