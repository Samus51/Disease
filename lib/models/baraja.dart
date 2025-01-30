// ignore_for_file: avoid_print

import 'dart:math';

import 'package:disease/models/carta.dart';
import 'package:disease/models/carta_especial.dart';
import 'package:disease/models/mano.dart';
import 'package:disease/models/organo.dart';

class Baraja {
  final List<Carta> _cartas;

  // Constructor
  Baraja({required List<Carta> cartas}) : _cartas = cartas;

  // Método estático para repartir la mano
  static Mano repartirMano(List<Carta> mazo) {
    // Crear una nueva mano
    Mano mano = Mano();

    // Agregar cartas a la mano
    // Supongo que repartirás algunas cartas del mazo (p.ej. 5 cartas)
    for (int i = 0; i < 3; i++) {
      if (mazo.isNotEmpty) {
        Carta carta = mazo.removeLast(); // Extraemos una carta del mazo
        mano.agregarCarta(carta); // Agregamos la carta a la mano
      }
    }

    // Retornar la mano repartida
    return mano;
  }

  // Método para agregar las cartas de los descartes a la baraja
  void reponerCartas(List<Carta> cartasADescartar) {
    cartas.addAll(cartasADescartar);
  }

  // Método para generar el mazo
  static List<Carta> generarMazo() {
    List<Carta> mazo = [];

    // Definir los órganos disponibles
    List<String> organos = ["Corazon", "Cerebro", "Hueso", "Estomago"];

    // Generar cartas de virus y curación para cada órgano
    for (String organo in organos) {
      // 4 cartas de virus para cada órgano
      for (int i = 0; i < 4; i++) {
        mazo.add(Carta(
          tipo: TipoCarta.virus,
          organo: organo,
          descripcion: "Virus para el $organo",
        ));
      }

      // 4 cartas de curación para cada órgano
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

    // Generar cartas especiales
    // Tipo Contagio - 2 cartas
    for (int i = 0; i < 2; i++) {
      mazo.add(CartaEspecial(
        tipoEspecial: TipoEspecial.contagio,
        descripcion:
            "Traslada tantos virus como puedas de tus órganos infectados a los órganos de los demás jugadores.",
      ) as Carta);
    }

    // Tipo Guante de Látex y Error Médico - 1 carta cada uno
    mazo.add(CartaEspecial(
      tipoEspecial: TipoEspecial.guanteLatex,
      descripcion:
          'Todos los jugadores oponentes sueltan sus cartas y roban una nueva mano.',
    ) as Carta);
    mazo.add(CartaEspecial(
      tipoEspecial: TipoEspecial.errorMedico,
      descripcion:
          'Cambia el cuerpo y mano por completo del jugador por el del oponente.',
    ) as Carta);

    // Tipo Transplante y Ladrón de Órganos - 3 cartas cada uno
    for (int i = 0; i < 3; i++) {
      mazo.add(CartaEspecial(
        tipoEspecial: TipoEspecial.transplante,
        descripcion:
            "Carta especial que cambia un órgano del jugador por otro del oponente.",
      ) as Carta);
      mazo.add(CartaEspecial(
        tipoEspecial: TipoEspecial.ladronDeOrganos,
        descripcion: "Roba un órgano del oponente.",
      ) as Carta);
    }

    // Mezclar el mazo para que las cartas no estén ordenadas
    mazo.shuffle();

    return mazo;
  }

  Carta darCarta(Baraja mazo) {
    return mazo._cartas[Random().nextInt(mazo._cartas.length)];
  }

  List<Carta> darVariasCartas(Baraja mazo, int cartasAPedir) {
    List<Carta> nuevaMano = [];
    for (int i = 0; i < cartasAPedir; i++) {
      nuevaMano.add(mazo._cartas[Random().nextInt(mazo._cartas.length)]);
    }
    return nuevaMano;
  }

  // Getter para acceder a las cartas
  List<Carta> get cartas => List.unmodifiable(_cartas);

  // Método para contar las cartas por tipo
  void contarCartas() {
    int contadorVirus = 0;
    int contadorCuracion = 0;
    int contadorEspecial = 0;
    int contadorOrgano = 0;

    for (var carta in _cartas) {
      if (carta.tipo == TipoCarta.virus) {
        contadorVirus++;
      } else if (carta.tipo == TipoCarta.curacion) {
        contadorCuracion++;
        // ignore: unrelated_type_equality_checks
      } else if (carta.tipo == TipoCarta.especial) {
        contadorEspecial++;
      }

      // En caso de que tenga órgano en su tipo
      // Verificar si la carta tiene un órgano
      contadorOrgano++;
    }

    print("Cartas de tipo 'Virus': $contadorVirus");
    print("Cartas de tipo 'Curación': $contadorCuracion");
    print("Cartas de tipo 'Especial': $contadorEspecial");
    print("Cartas de tipo 'Órgano': $contadorOrgano");
    print("Total de cartas: ${_cartas.length}");
  }
}

void main() {
  // Generar mazo
  List<Carta> mazo = Baraja.generarMazo();

  // Crear la baraja
  Baraja baraja = Baraja(cartas: mazo);

  // Contar cartas
  baraja.contarCartas();
}
