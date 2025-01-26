import 'dart:math';

import 'package:disease/models/carta.dart';
import 'package:disease/models/organo.dart';

class Jugador {
  List<Organo> organosJugador;

  Jugador({required this.organosJugador});

  // Método para seleccionar un órgano
  String seleccionarOrgano() {
    // Seleccionar un órgano del jugador (por ahora, aleatorio)
    Organo organoSeleccionado =
        organosJugador[Random().nextInt(organosJugador.length)];
    return organoSeleccionado.tipo.toString().split('.').last;
  }

  // Método para aplicar curación
  void aplicarCuracion(String organoNombre) {
    // Encontrar el órgano seleccionado
    Organo organo = organosJugador.firstWhere(
      (organo) => organo.tipo.toString().split('.').last == organoNombre,
      orElse: () => throw Exception("Órgano no encontrado"),
    );

    // Verificar si el órgano está muerto
    if (organo.estado == EstadoOrgano.infectado) {
      // Solo curamos órganos infectados
      organo.estado = EstadoOrgano.sano;
      print('El órgano $organoNombre ha sido curado y ahora está sano.');
    } else if (organo.estado == EstadoOrgano.sano) {
      // Solo curamos órganos infectados
      organo.estado = EstadoOrgano.vacunado;
      print('El órgano $organoNombre ha sido curado y ahora está vacunado.');
    } else if (organo.estado == EstadoOrgano.vacunado) {
      // Solo curamos órganos infectados
      organo.estado = EstadoOrgano.inmune;
      print('El órgano $organoNombre ha sido curado y ahora está inmune.');
    } else {
      print(
          'El órgano $organoNombre ya está sano o tiene otro estado que no requiere curación.');
    }
  }
}
