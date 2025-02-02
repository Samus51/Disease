import 'package:disease/models/organo.dart';
import 'package:flutter/material.dart';

import '../models/baraja.dart';
import '../models/carta.dart';

class Functions {
  // Diseño de la carta, ahora siempre visible
  static Widget disenoCarta(Carta carta, bool esSeleccionada, bool esOponente) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 70,
      height: 98,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: esOponente
              ? AssetImage('assets/images/carta_parte_trasera.png')
              : carta.obtenerImagen(),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
        border:
            esSeleccionada ? Border.all(color: Colors.yellow, width: 4) : null,
      ),
    );
  }

  // Diseño del órgano
  static Widget disenoOrgano(Organo organo, bool esSeleccionado) {
    Color bordeColor;
    switch (organo.estado) {
      case EstadoOrgano.infectado:
        bordeColor = Colors.red;
        break;
      case EstadoOrgano.inmune:
        bordeColor = Colors.blue;
        break;
      case EstadoOrgano.vacunado:
        bordeColor = Colors.green;
        break;
      default:
        bordeColor = Colors.transparent;
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
            ? Border.all(color: Colors.yellow, width: 4)
            : Border.all(color: bordeColor, width: 4),
      ),
    );
  }

  // Mazo de cartas, mostrando las cartas del mazo
  static Widget mazoDeCartas(List<Carta> cartasJugador, Baraja baraja,
      List<Carta> descartes, Function setState) {
    return SizedBox(
      width: 80,
      height: 100,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (cartasJugador.length < 3) {
              if (baraja.cartas.isEmpty) {
                baraja.reponerCartas(descartes);
                baraja.cartas.shuffle();
                descartes.clear();
              }

              Carta cartaRobada = baraja.cartas.removeAt(0);
              cartasJugador.add(cartaRobada);
              print("Carta añadida: ${cartaRobada.descripcion}");
            } else {
              print("Ya tienes 3 cartas en mano. No puedes robar más.");
            }

            print("Pila de cartas tocada");
          });
        },
        child: Stack(
          alignment: Alignment.centerLeft,
          children: List.generate(5, (index) {
            return Positioned(
              left: index * 2.0,
              top: index * 2.0,
              child: Image.asset(
                'assets/images/carta_parte_trasera.png',
                width: 80,
                height: 80,
              ),
            );
          }),
        ),
      ),
    );
  }

  // Función que genera una carta de órgano y la muestra para todos
  static Widget construirOrgano(Organo organo, bool esSeleccionada) {
    return disenoOrgano(organo, esSeleccionada);
  }

  // Función que genera una carta y la muestra para todos
  static Widget construirCarta(
      Carta carta, bool esSeleccionada, bool esOponente) {
    return disenoCarta(carta, esSeleccionada, false);
  }
}
