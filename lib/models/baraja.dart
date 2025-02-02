// ignore_for_file: avoid_print

import 'package:disease/models/carta.dart';
import 'package:disease/models/carta_especial.dart';
import 'package:disease/models/mano.dart';
import 'package:disease/models/organo.dart';

class Baraja {
  List<Carta> cartas = []; // ✅ Lista mutable

  // Constructor
  Baraja({required List<Carta> cartass})
      : cartas = List.from(cartass); // Asegura que sea mutable

  // Método estático para repartir la mano
  static Mano repartirMano(List<Carta> mazo) {
    Mano mano = Mano();

    for (int i = 0; i < 3; i++) {
      if (mazo.isNotEmpty) {
        Carta carta = mazo.removeLast(); // Saca carta del mazo
        mano.agregarCarta(carta);
      }
    }

    return mano;
  }

  // Método para agregar cartas de descartes al mazo
  void reponerCartas(List<Carta> cartasADescartar) {
    cartas.addAll(cartasADescartar);
    cartas.shuffle(); // Mezclar el mazo después de reponer
  }

  // Método para generar el mazo
  static List<Carta> generarMazo() {
    List<Carta> mazo = [];

    List<String> organos = ["corazon", "cerebro", "hueso", "estomago"];

    for (String organo in organos) {
      for (int i = 0; i < 4; i++) {
        mazo.add(Carta(
          tipo: TipoCarta.virus,
          organo: organo,
          descripcion: "Virus para el $organo",
        ));
      }

      for (int i = 0; i < 4; i++) {
        mazo.add(Carta(
          tipo: TipoCarta.curacion,
          organo: organo,
          descripcion: "Curación para el $organo",
        ));
      }

      for (var tipo in TipoOrgano.values) {
        for (int i = 0; i < 5; i++) {
          mazo.add(Organo(
            tipo: TipoCarta.organo,
            organo: tipo.toString().split('.').last,
            descripcion: "Órgano de ${tipo.toString().split('.').last}",
            tipoOrgano: tipo,
          ));
        }
      }
    }

    // Cartas especiales
    for (int i = 0; i < 2; i++) {
      mazo.add(CartaEspecial(
        tipoEspecial: TipoEspecial.contagio,
        descripcion: "Traslada virus a los órganos de los demás jugadores.",
      ));
    }

    mazo.addAll([
      CartaEspecial(
        tipoEspecial: TipoEspecial.guanteLatex,
        descripcion: "Todos los jugadores cambian su mano.",
      ),
      CartaEspecial(
        tipoEspecial: TipoEspecial.errorMedico,
        descripcion: "Intercambia el cuerpo y la mano con un oponente.",
      )
    ]);

    for (int i = 0; i < 3; i++) {
      mazo.add(CartaEspecial(
        tipoEspecial: TipoEspecial.transplante,
        descripcion: "Intercambia un órgano con otro jugador.",
      ));
      mazo.add(CartaEspecial(
        tipoEspecial: TipoEspecial.ladronDeOrganos,
        descripcion: "Roba un órgano del oponente.",
      ));
    }

    mazo.shuffle();
    return mazo;
  }

  // Robar una carta del mazo (elimina la carta del mazo)
  Carta robarCarta() {
    if (cartas.isNotEmpty) {
      return cartas.removeAt(0);
    } else {
      throw Exception("El mazo está vacío.");
    }
  }

  // Robar varias cartas
  List<Carta> robarVariasCartas(int cantidad) {
    List<Carta> nuevasCartas = [];
    for (int i = 0; i < cantidad; i++) {
      if (cartas.isNotEmpty) {
        nuevasCartas.add(cartas.removeAt(0));
      }
    }
    return nuevasCartas;
  }

  // Método para contar las cartas por tipo
  void contarCartas() {
    int contadorVirus = 0;
    int contadorCuracion = 0;
    int contadorEspecial = 0;
    int contadorOrgano = 0;

    for (var carta in cartas) {
      if (carta.tipo == TipoCarta.virus) {
        contadorVirus++;
      } else if (carta.tipo == TipoCarta.curacion) {
        contadorCuracion++;
      } else if (carta is CartaEspecial) {
        contadorEspecial++;
      } else if (carta is Organo) {
        contadorOrgano++;
      }
    }

    print("Cartas de Virus: $contadorVirus");
    print("Cartas de Curación: $contadorCuracion");
    print("Cartas Especiales: $contadorEspecial");
    print("Cartas de Órgano: $contadorOrgano");
    print("Total de cartas: ${cartas.length}");
  }
}

void main() {
  // Generar mazo
  List<Carta> mazo = Baraja.generarMazo();

  // Crear la baraja
  Baraja baraja = Baraja(cartass: mazo);

  // Contar cartas
  baraja.contarCartas();

  // Robar una carta
  try {
    Carta cartaRobada = baraja.robarCarta();
    print("Carta robada: ${cartaRobada.descripcion}");
  } catch (e) {
    print(e);
  }

  // Robar varias cartas
  List<Carta> cartasRobadas = baraja.robarVariasCartas(3);
  print("Cartas robadas:");
  for (var carta in cartasRobadas) {
    print("- ${carta.descripcion}");
  }
}
