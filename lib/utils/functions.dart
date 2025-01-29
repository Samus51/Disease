import 'dart:async';

import 'package:disease/models/baraja.dart';
import 'package:disease/models/carta.dart';
import 'package:disease/models/organo.dart';
import 'package:flutter/material.dart';

void main() => runApp(const Functions());

class Functions extends StatelessWidget {
  const Functions({super.key});
  static esperarClickEnCarta(List<Carta> cartasOponenteOrganos,
      BuildContext context, int? organoSeleccionadoIndexOponente) {
    Completer<int?> completer = Completer<int?>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Selecciona una carta"),
        content: Wrap(
          children: cartasOponenteOrganos.map((carta) {
            return GestureDetector(
              onTap: () {
                completer.complete(organoSeleccionadoIndexOponente);
                Navigator.pop(context);
              },
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Carta $carta"),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );

    return completer.future;
  }

static void descartarCarta(int index, Baraja barajaOriginal, List<Carta> pilaDescartes) {
  // Validamos que la carta en el índice exista
  if (index >= 0 && index < barajaOriginal.cartas.length) {
    // Sacamos la carta y la agregamos a la pila de descartes
    pilaDescartes.add(barajaOriginal.cartas.removeAt(index));
    print("Carta descartada.");
  } else {
    print("Índice no válido.");
  }
}


  

  // Diseño de la carta, mostrando el borde si está seleccionada
 static Widget _disenoCarta(Carta carta, bool esSeleccionada) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 70,
      height: 98,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: carta.obtenerImagen(),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
        border: esSeleccionada
            ? Border.all(
                color: Colors.yellow,
                width: 4) // Borde amarillo si está seleccionada
            : null,
      ),
    );
  }

 static Widget _disenoOrgano(Organo organo, bool esSeleccionado) {
    // Determina el color del borde según el estado del órgano
    Color bordeColor;
    switch (organo.estado) {
      case EstadoOrgano.infectado:
        bordeColor = Colors.red; // Rojo para infectado
        break;
      case EstadoOrgano.inmune:
        bordeColor = Colors.blue; // Azul para inmune
        break;
      case EstadoOrgano.vacunado:
        bordeColor = Colors.green; // Verde para vacunado
        break;
      default:
        bordeColor = Colors.transparent; // Sin borde si no tiene estado
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 70,
      height: 98,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: organo.obtenerImagen(),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
        border: esSeleccionado
            ? Border.all(
                color: Colors.yellow,
                width: 4) // Borde amarillo si está seleccionado
            : Border.all(color: bordeColor, width: 4), // Borde del estado
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Material App Bar'),
        ),
        body: const Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}
