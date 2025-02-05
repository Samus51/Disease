import 'dart:async';
import 'package:disease/models/carta.dart';
import 'package:disease/models/juego.dart';
import 'package:disease/models/organo.dart';
import 'package:disease/models/baraja.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

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
      {int intentos = 0} // Agregamos un contador de intentos
      ) async {
    bool haJugado = false;

    if (intentos > 3) {
      // Evitamos que el bot intente jugar infinitamente
      print("El bot no encontró jugadas válidas tras varios intentos.");
      Juego.esTurnoJugador1 = true;
      return;
    }

    if (!haJugado) {
      Carta? virusCompatible;
      Organo? organoParaInfectar;
      int virusIndexFound = -1;

      for (int i = 0; i < cartasOponente.length; i++) {
        if (cartasOponente[i].tipo == TipoCarta.virus) {
          Carta virusCandidate = cartasOponente[i];
          organoParaInfectar = cartasJugadorOrganos.firstWhereOrNull(
            (organo) =>
                organo.organo == virusCandidate.organo &&
                organo.estado != EstadoOrgano.inmune,
          );

          if (organoParaInfectar != null) {
            virusCompatible = virusCandidate;
            virusIndexFound = i;
            break;
          }
        }
      }

      if (virusCompatible != null && organoParaInfectar != null) {
        switch (organoParaInfectar.estado) {
          case EstadoOrgano.sano:
            organoParaInfectar.estado = EstadoOrgano.infectado;
            cartasOponente.removeAt(virusIndexFound);
            haJugado = true;
            break;
          case EstadoOrgano.infectado:
            organoParaInfectar.estado = EstadoOrgano.muerto;
            cartasJugadorOrganos.remove(organoParaInfectar);
            haJugado = true;
            break;
          case EstadoOrgano.vacunado:
            organoParaInfectar.estado = EstadoOrgano.sano;
            cartasOponente.removeAt(virusIndexFound);
            haJugado = true;

            break;
          case EstadoOrgano.inmune:
          case EstadoOrgano.muerto:
            break;
        }
        cartaSeleccionadaIndexOponente = virusIndexFound;
        organoSeleccionadoIndexJugador =
            cartasJugadorOrganos.indexOf(organoParaInfectar);
        haJugado = true;
      }
    }

    if (!haJugado) {
      int medicinaIndex = cartasOponente
          .indexWhere((carta) => carta.tipo == TipoCarta.curacion);
      if (medicinaIndex != -1) {
        Carta medicina = cartasOponente[medicinaIndex];
        Organo? organoInfectado = cartasOponenteOrganos.firstWhereOrNull(
          (organo) =>
              organo.tipoOrgano == medicina.organo &&
              organo.estado == EstadoOrgano.infectado,
        );

        if (organoInfectado != null) {
          organoInfectado.estado = EstadoOrgano.sano;
          cartaSeleccionadaIndexOponente = medicinaIndex;
          organoSeleccionadoIndexOponente =
              cartasOponenteOrganos.indexOf(organoInfectado);
          haJugado = true;
        }
      }
    }

    if (!haJugado) {
      int organoIndex =
          cartasOponente.indexWhere((carta) => carta.tipo == TipoCarta.organo);

      if (organoIndex != -1) {
        Carta organo = cartasOponente[organoIndex];

        if (organo is Organo) {
          // Comprobar si ya tiene un órgano del mismo tipo
          bool yaTieneMismoOrgano = cartasOponenteOrganos
              .any((o) => o.tipoOrgano == organo.tipoOrgano);

          if (!yaTieneMismoOrgano) {
            cartasOponenteOrganos.add(organo);
            cartasOponente.removeAt(organoIndex);
            haJugado = true;

            await _robarCartasYActualizarTurno(
                baraja, cartasOponente, setState);
          }
        }
      }
    }

    if (!haJugado) {
      if (cartasOponente.isNotEmpty) {
        cartasOponente.removeAt(0); // Descarta una carta
      }

      // El bot roba cartas para quedarse con 3
      await _robarCartasYActualizarTurno(baraja, cartasOponente, setState);
    }
  }

  static Future<void> _robarCartasYActualizarTurno(
      Baraja baraja,
      List<Carta> cartasOponente,
      void Function(void Function()) setState) async {
    int cartasFaltantes = 3 - cartasOponente.length;
    if (cartasFaltantes > 0) {
      List<Carta> cartasRobadas = baraja.robarVariasCartas(cartasFaltantes);
      cartasOponente.addAll(cartasRobadas);
    }

    await Future.delayed(Duration(seconds: 1));

    // Cambiamos el turno al jugador
    Juego.esTurnoJugador1 = true;
    setState(() {});
  }
}
