import 'dart:math';

import 'carta.dart';

class Turno {
  List<Carta> cartasJugador;
  int cartasDescartadas;
  bool esTurnoJugador;

  Turno({required this.cartasJugador})
      : cartasDescartadas = 0,
        esTurnoJugador = true;

  // Función para usar una carta
  void usarCarta(Carta carta) {
    if (cartasJugador.contains(carta)) {
      // Aquí puedes agregar la lógica de "usar" la carta
      print('Carta usada: ${carta.descripcion}');
    } else {
      print('No tienes esa carta');
    }
  }

  // Función para descartar una carta
  void descartarCarta(int cartaIndex) {
    if (cartasDescartadas < 3) {
      cartasJugador.removeAt(cartaIndex);
      cartasDescartadas++;
      print('Carta descartada');
    } else {
      print('No puedes descartar más de 3 cartas por turno');
    }
  }

  // Función para robar hasta tener 3 cartas
  void robarCartas(List<Carta> baraja) {
    while (cartasJugador.length < 3) {
      cartasJugador.add(baraja[Random().nextInt(baraja.length)]);
      print('Carta robada');
    }
  }

  // Función para finalizar el turno
  void finalizarTurno() {
    esTurnoJugador = !esTurnoJugador;
    cartasDescartadas = 0; // Reseteamos los descartes al cambiar el turno
    print('Turno finalizado');
  }
}
