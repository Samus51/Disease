import 'dart:async';
import 'package:disease/models/carta.dart';
import 'package:disease/models/carta_especial.dart';
import 'package:disease/models/juego.dart';
import 'package:disease/models/organo.dart';
import 'package:disease/models/baraja.dart';
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
    if (!haJugado) {
      Carta? virusCompatible;
      Organo? organoParaInfectar;
      int virusIndexFound = -1;

      // Itera por todas las cartas del oponente para buscar un virus que sea compatible
      for (int i = 0; i < cartasOponente.length; i++) {
        if (cartasOponente[i].tipo == TipoCarta.virus) {
          Carta virusCandidate = cartasOponente[i];
          try {
            // Intenta buscar un órgano en la mano del jugador que sea compatible
            organoParaInfectar = cartasJugadorOrganos.firstWhere(
              (organo) =>
                  organo.organo == virusCandidate.organo &&
                  organo.estado != EstadoOrgano.inmune,
            );
            // Si lo encuentra, ese virus es compatible
            virusCompatible = virusCandidate;
            virusIndexFound = i;
            break; // Sal del bucle
          } catch (e) {
            // Si no se encuentra un órgano compatible, sigue con el siguiente virus
            continue;
          }
        }
      }

      if (virusCompatible != null && organoParaInfectar != null) {
        // Ejecuta la acción de infección
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
        cartaSeleccionadaIndexOponente = virusIndexFound;
        organoSeleccionadoIndexJugador =
            cartasJugadorOrganos.indexOf(organoParaInfectar);
        haJugado = true;
      }
    }

    // 2. Si el bot tiene medicina y no ha jugado, intenta curar un órgano compatible
    if (!haJugado) {
      int medicinaIndex = cartasOponente
          .indexWhere((carta) => carta.tipo == TipoCarta.curacion);
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
    }

    // 3. Si el bot tiene menos de 2 órganos y no ha jugado, intenta jugar un órgano
    if (!haJugado) {
      int organoIndex =
          cartasOponente.indexWhere((carta) => carta.tipo == TipoCarta.organo);
      if (organoIndex != -1) {
        Carta organo = cartasOponente[organoIndex];
        if (organo is Organo) {
          // Solo juega el órgano si no lo tiene ya (aunque en este caso normalmente no debería repetirse)
          if (!cartasOponenteOrganos.contains(organo)) {
            cartasOponenteOrganos.add(organo);
            cartasOponente.removeAt(organoIndex);
            haJugado = true;
            // Realiza la acción de robar cartas y cambiar turno después de jugar el órgano
            await _robarCartasYActualizarTurno(
                baraja, cartasOponente, setState);
          }
        }
      }
    }

    // Si ha jugado alguna acción, puedes llamar a la función de acción correspondiente en el juego
    // (esto es lo que ya tenías en tu lógica)
  }

  static Future<void> _robarCartasYActualizarTurno(
      Baraja baraja,
      List<Carta> cartasOponente,
      void Function(void Function()) setState) async {
    List<Carta> cartasRobadas = baraja.robarVariasCartas(1);
    cartasOponente.addAll(cartasRobadas);
    await Future.delayed(Duration(seconds: 1));
    // Cambiamos el turno al jugador
    Juego.esTurnoJugador1 = true;
    setState(() {});
  }
}
