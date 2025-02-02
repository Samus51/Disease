import 'package:disease/models/baraja.dart';
import 'package:disease/models/carta.dart';
import 'package:disease/models/juego.dart';
import 'package:disease/models/organo.dart';
import 'package:flutter/material.dart';

class Bot {
  static Future<void> realizarAccionBot(
    BuildContext context,
    int? cartaSeleccionadaIndexJugador,
    int? cartaSeleccionadaIndexOponente,
    int? organoSeleccionadoIndexJugador,
    int? organoSeleccionadoIndexOponente,
    void Function(void Function()) setState,
    Future<Organo?> Function() seleccionarOrganoParaRobo,
    Future<(int?, int?)> Function() seleccionarOrgano,
    List<Carta> cartasJugador,
    List<Organo> cartasJugadorOrganos,
    List<Carta> cartasOponente,
    List<Organo> cartasOponenteOrganos,
    List<Carta> descartes,
    Baraja baraja,
  ) async {
    bool haJugado = false;

    // 1. Si el bot tiene un virus, intenta infectar un órgano compatible del jugador
    int virusIndex =
        cartasOponente.indexWhere((carta) => carta.tipo == TipoCarta.virus);
    if (virusIndex != -1) {
      Carta virus = cartasOponente[virusIndex];
      Organo? organoParaInfectar;
      try {
        organoParaInfectar = cartasJugadorOrganos.firstWhere(
          (organo) =>
              organo.tipoOrgano == virus.organo &&
              organo.estado != EstadoOrgano.inmune, // No debe estar inmunizado
        );

        if (organoParaInfectar != null) {
          switch (organoParaInfectar.estado) {
            case EstadoOrgano.sano:
              organoParaInfectar.estado = EstadoOrgano.infectado;
              print(
                  "El órgano ha sido infectado y ahora está ${organoParaInfectar.estadoOrgano}");
              break;
            case EstadoOrgano.infectado:
              organoParaInfectar.estado = EstadoOrgano.muerto;
              cartasJugadorOrganos.remove(organoParaInfectar);
              print("El órgano ha muerto.");
              break;
            case EstadoOrgano.vacunado:
              organoParaInfectar.estado = EstadoOrgano.sano;
              print("El órgano está vacunado, no se puede infectar.");
              break;
            case EstadoOrgano.inmune:
              print("El órgano ya está inmune, no se puede infectar.");
              break;
            case EstadoOrgano.muerto:
              print("El órgano ya está muerto.");
              break;
          }
        }
      } catch (e) {
        // No hay órgano válido para infectar, sigue con la siguiente opción
      }

      if (organoParaInfectar != null) {
        cartaSeleccionadaIndexOponente = virusIndex;
        organoSeleccionadoIndexJugador =
            cartasJugadorOrganos.indexOf(organoParaInfectar);
        haJugado = true;
      }
    }

    int medicinaIndex =
        cartasOponente.indexWhere((carta) => carta.tipo == TipoCarta.curacion);
    if (medicinaIndex != -1) {
      Carta medicina = cartasOponente[medicinaIndex];
      Organo? organoInfectado;

      try {
        organoInfectado = cartasOponenteOrganos.firstWhere(
          (organo) =>
              organo.tipoOrgano == medicina.organo &&
              organo.estado != EstadoOrgano.inmune,
        );
      } catch (e) {
        organoInfectado = null; // No hay órgano infectado compatible
      }

      if (organoInfectado != null) {
        cartaSeleccionadaIndexOponente = medicinaIndex;
        organoSeleccionadoIndexOponente =
            cartasOponenteOrganos.indexOf(organoInfectado);
        haJugado = true;
      }
    }
// 3. Si el bot tiene menos de 2 órganos, intenta jugar un órgano
    if (!haJugado) {
      int organoIndex =
          cartasOponente.indexWhere((carta) => carta.tipo == TipoCarta.organo);
      if (organoIndex != -1) {
        Carta organo = cartasOponente[organoIndex];

        if (organo is Organo) {
          cartasOponenteOrganos.add(organo);
          cartasOponente.removeAt(organoIndex);
          haJugado = true;

          // No cambiamos el turno aún, dejamos que el bot termine todo su turno
          await _robarCartasYActualizarTurno(baraja, cartasOponente, setState);
        }
      }
    }
  }

  static Future<void> _robarCartasYActualizarTurno(
      Baraja baraja,
      List<Carta> cartasOponente,
      void Function(void Function()) setState) async {
    List<Carta> cartasRobadas = baraja.robarVariasCartas(1);
    cartasOponente.addAll(cartasRobadas);

    await Future.delayed(Duration(seconds: 1));

    // Ahora, cambiamos el turno después de que el bot termine
    Juego.esTurnoJugador1 = true; // Cambiar el turno a jugador 1
    setState(
        () {}); // Actualizamos la interfaz para reflejar el cambio de turno
  }
}
