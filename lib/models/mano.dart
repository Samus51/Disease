import 'package:disease/models/carta.dart';

class Mano {
  final List<Carta> _cartas;

  // Constructor, aseguramos que la mano comienza con 3 cartas
  Mano({List<Carta> cartas = const []})
      : _cartas = List.from(
            cartas.take(3)); // Toma solo las primeras 3 cartas si hay más de 3

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
