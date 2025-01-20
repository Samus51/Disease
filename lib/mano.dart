import 'package:disease/carta.dart';

class Mano {
  final List<Carta> _cartas;

  // Constructor, aseguramos que la mano comienza con 3 cartas
  Mano({List<Carta> cartas = const []})
      : _cartas = List.from(cartas.isEmpty
            ? []
            : cartas.take(3)); // Toma solo las primeras 3 cartas

  List<Carta> get cartas => List.unmodifiable(_cartas);

  // Agregar una carta a la mano si no excede las 3 cartas
  void agregarCarta(Carta carta) {
    if (_cartas.length < 3) {
      _cartas.add(carta);
    } else {
      throw Exception('No se pueden tener más de 3 cartas en la mano');
    }
  }

  // Eliminar una carta de la mano
  bool eliminarCarta(Carta carta) {
    return _cartas.remove(carta);
  }

  // Intercambiar cartas entre dos índices
  void intercambiarCartas(int indice1, int indice2) {
    if (indice1 >= 0 &&
        indice1 < _cartas.length &&
        indice2 >= 0 &&
        indice2 < _cartas.length) {
      final temp = _cartas[indice1];
      _cartas[indice1] = _cartas[indice2];
      _cartas[indice2] = temp;
    } else {
      throw RangeError('Índices fuera de rango');
    }
  }

  // Obtener carta por índice
  Carta obtenerCarta(int indice) {
    if (indice >= 0 && indice < _cartas.length) {
      return _cartas[indice];
    } else {
      throw RangeError('Índice fuera de rango');
    }
  }

  // Contar el número de cartas en la mano
  int contarCartas() {
    return _cartas.length;
  }

  // Vaciar la mano (eliminar todas las cartas)
  void vaciarMano() {
    _cartas.clear();
  }

  // Reemplazar la mano con nuevas cartas (cuando se reparten cartas)
  void reemplazarCartas(List<Carta> nuevasCartas) {
    _cartas.clear();
    _cartas.addAll(nuevasCartas.take(3)); // Solo toma las 3 primeras cartas
  }

  // Método para intercambiar las manos de dos jugadores
  void cambiarMano(Mano manoJugador, Mano manoOponente) {
    final cartasTemp = List<Carta>.from(manoOponente.cartas);
    manoOponente._cartas.clear();
    manoOponente._cartas.addAll(manoJugador.cartas);
    manoJugador._cartas.clear();
    manoJugador._cartas.addAll(cartasTemp);
  }
}

class Baraja {
  final List<Carta> _cartas;

  Baraja({required List<Carta> cartas}) : _cartas = cartas;

  static List<Carta> generarMazo() {
    List<Carta> mazo = [];

    // Definir los órganos disponibles
    List<String> organos = ["Corazón", "Cerebro", "Huesos", "Estómago"];

    // Generar 5 cartas de virus y 5 de curación para cada órgano
    for (String organo in organos) {
      for (int i = 0; i < 4; i++) {
        mazo.add(Carta(
            tipo: TipoCarta.virus,
            organo: organo,
            descripcion: "Virus para el $organo"));
      }
      for (int i = 0; i < 4; i++) {
        mazo.add(Carta(
            tipo: TipoCarta.curacion,
            organo: organo,
            descripcion: "Curación para el $organo"));
      }
      for (int i = 0; i < 5; i++) {
        mazo.add(Carta(
            tipo: TipoCarta.virus,
            organo: organo,
            descripcion: "Órgano de $organo"));
      }
    }

    // Generar cartas especiales
    for (int i = 0; i < 2; i++) {
      mazo.add(Carta(
          tipo: TipoCarta.especial,
          tipoEspecial: TipoEspecial.contagio,
          descripcion:
              "Traslada tantos virus como puedas de tus órganos infectados a los órganos de los demás jugadores."));
    }
    mazo.add(Carta(
        tipo: TipoCarta.especial,
        tipoEspecial: TipoEspecial.guanteLatex,
        descripcion:
            'Todos los jugadores oponentes sueltan sus cartas y roban una nueva mano'));
    mazo.add(Carta(
        tipo: TipoCarta.especial,
        tipoEspecial: TipoEspecial.errorMedico,
        descripcion:
            'Cambia el cuerpo y mano por completo del jugador por el del oponente'));

    for (int i = 0; i < 3; i++) {
      mazo.add(Carta(
          tipo: TipoCarta.especial,
          tipoEspecial: TipoEspecial.transplante,
          descripcion:
              "Carta especial que cambia un organo del jugador por otro del oponente"));
      mazo.add(Carta(
          tipo: TipoCarta.especial,
          tipoEspecial: TipoEspecial.ladronDeOrganos,
          descripcion: "Roba un órgano del Oponente"));
    }

    mazo.shuffle();
    return mazo;
  }

  // Repartir las cartas a los jugadores
  List<Mano> repartirCartas(List<Mano> jugadores) {
    // Barajar el mazo antes de repartir
    _cartas.shuffle();

    for (var jugador in jugadores) {
      // Dar 3 cartas a cada jugador
      jugador.reemplazarCartas(_cartas.take(3).toList());
      _cartas.removeRange(0, 3); // Eliminar las cartas repartidas del mazo
    }

    return jugadores;
  }
}
