// ignore_for_file: avoid_print

import 'package:disease/models/carta.dart';
import 'package:disease/models/carta_especial.dart';
import 'package:disease/models/organo.dart';

class Baraja {
  List<Carta> cartas = []; // ✅ Lista mutable

  // Constructor
  Baraja({required List<Carta> cartass})
      : cartas = List.from(cartass); // Asegura que sea mutable

  // Método para agregar cartas de descartes al mazo
  void reponerCartas(List<Carta> cartasADescartar) {
    cartas.addAll(cartasADescartar);
    cartas.shuffle(); // Mezclar el mazo después de reponer
  }

// Método para generar el mazo
  static List<Carta> generarMazo() {
    List<Carta> mazo = [];

    List<String> organos = ["corazon", "cerebro", "hueso", "estomago"];

    // Agregar cartas de virus y de curación para cada órgano.
    for (String organo in organos) {
      // 4 cartas de virus para cada órgano.
      for (int i = 0; i < 4; i++) {
        mazo.add(Carta(
          tipo: TipoCarta.virus,
          organo: organo,
          descripcion: "Virus para el $organo",
        ));
      }
      // 4 cartas de curación para cada órgano.
      for (int i = 0; i < 4; i++) {
        mazo.add(Carta(
          tipo: TipoCarta.curacion,
          organo: organo,
          descripcion: "Curación para el $organo",
        ));
      }
    }

    // Agregar cartas de órgano:
    // Se hace una sola vez para cada tipo de órgano (suponiendo que TipoOrgano.values tiene 4 elementos).
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

    // Cartas especiales
    // 2 cartas de contagio
    for (int i = 0; i < 2; i++) {
      mazo.add(CartaEspecial(
        tipoEspecial: TipoEspecial.contagio,
        descripcion: "Traslada virus a los órganos de los demás jugadores.",
      ));
    }

    // 2 cartas: guanteLatex y errorMedico
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

    // 3 cartas de trasplante y 3 de ladrón de órganos (total 6)
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
