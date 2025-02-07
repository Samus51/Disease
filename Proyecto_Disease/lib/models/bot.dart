import 'dart:async';
import 'package:disease/models/carta.dart';
import 'package:disease/models/carta_especial.dart';
import 'package:disease/models/juego.dart';
import 'package:disease/models/organo.dart';
import 'package:disease/models/baraja.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class Bot {
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

    Juego.esTurnoJugador1 = true;

    setState(() {});
  }

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
      {int intentos = 0}) async {
    bool haJugado = false;

    if (intentos > 3) {
      print("El bot no encontró jugadas válidas tras varios intentos.");
      Juego.esTurnoJugador1 = true;
      return;
    }

// 1. Buscar si puede infectar un órgano del jugador
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
            await _robarCartasYActualizarTurno(
                baraja, cartasOponente, setState);
            break;
          case EstadoOrgano.infectado:
            organoParaInfectar.estado = EstadoOrgano.muerto;
            cartasJugadorOrganos.remove(organoParaInfectar);
            haJugado = true;
            await _robarCartasYActualizarTurno(
                baraja, cartasOponente, setState);
            break;
          case EstadoOrgano.vacunado:
            organoParaInfectar.estado = EstadoOrgano.sano;
            cartasOponente.removeAt(virusIndexFound);
            haJugado = true;
            await _robarCartasYActualizarTurno(
                baraja, cartasOponente, setState);
            break;
          case EstadoOrgano.inmune:
          case EstadoOrgano.muerto:
            break;
        }
        cartaSeleccionadaIndexOponente = virusIndexFound;
        organoSeleccionadoIndexJugador =
            cartasJugadorOrganos.indexOf(organoParaInfectar);
      }
    }

    // 2. Si no jugó, ver si puede curar un órgano infectado
    if (!haJugado) {
      int medicinaIndex = cartasOponente
          .indexWhere((carta) => carta.tipo == TipoCarta.curacion);
      if (medicinaIndex != -1) {
        Carta medicina = cartasOponente[medicinaIndex];
        Organo? organoAcurar = cartasOponenteOrganos.firstWhereOrNull(
          (organo) =>
              organo.tipoOrgano == medicina.organo &&
              (organo.estado == EstadoOrgano.infectado ||
                  organo.estado != EstadoOrgano.inmune),
        );

        if (organoAcurar != null) {
          // Si el órgano está infectado, lo curamos. Si no, lo inmunizamos.
          if (organoAcurar.estado == EstadoOrgano.infectado) {
            organoAcurar.estado = EstadoOrgano.sano;
          } else {
            organoAcurar.estado = EstadoOrgano.inmune; // Inmunizamos
          }

          haJugado = true;
        }
      }
    }

// 3. Si no jugó, ver si puede añadir un órgano nuevo
    if (!haJugado) {
      List<int> organoIndices = [];
      for (int i = 0; i < cartasOponente.length; i++) {
        if (cartasOponente[i].tipo == TipoCarta.organo) {
          Carta organo = cartasOponente[i];
          if (organo is Organo) {
            bool yaTieneMismoOrgano = cartasOponenteOrganos
                .any((o) => o.tipoOrgano == organo.tipoOrgano);

            if (!yaTieneMismoOrgano) {
              organoIndices.add(i);
            }
          }
        }
      }

      if (organoIndices.isNotEmpty && !haJugado) {
        // Solo permite añadir un órgano
        int organoIndex = organoIndices.first;
        Carta organo = cartasOponente[organoIndex];

        if (organo is Organo && !cartasOponenteOrganos.contains(organo)) {
          cartasOponenteOrganos.add(organo);
          cartasOponente.remove(organo);
          haJugado = true;

          // Realiza el robo de cartas y actualización del turno después de añadir un órgano
          await _robarCartasYActualizarTurno(baraja, cartasOponente, setState);
        }
      }
    }

    // 4. Si no jugó, ver si puede usar una carta especial
    if (!haJugado) {
      int especialIndex = cartasOponente
          .indexWhere((carta) => carta.tipo == TipoCarta.especial);

      if (especialIndex != -1) {
        Carta especial = cartasOponente[especialIndex];

        if (especial is CartaEspecial) {
          switch (especial.tipoEspecial) {
            case TipoEspecial.contagio:
              // Ejecutar la acción de contagio y curación dentro de setState
              setState(() {
                // Obtener órganos infectados del oponente
                List<Organo> organosInfectadosOponente = cartasOponenteOrganos
                    .where((organo) => organo.estado == EstadoOrgano.infectado)
                    .toList();

                // Para cada órgano infectado del oponente, buscamos los órganos compatibles en el jugador
                for (var organoOponente in organosInfectadosOponente) {
                  // Buscamos todos los órganos del jugador del mismo tipo que estén sanos o ya infectados
                  List<Organo> organosCompatiblesJugador = cartasJugadorOrganos
                      .where((organoJugador) =>
                          organoJugador.tipoOrgano ==
                              organoOponente.tipoOrgano &&
                          (organoJugador.estado == EstadoOrgano.sano ||
                              organoJugador.estado == EstadoOrgano.infectado))
                      .toList();

                  if (organosCompatiblesJugador.isNotEmpty) {
                    for (var organoJugador in organosCompatiblesJugador) {
                      // Si el órgano del jugador está sano, lo infectamos
                      if (organoJugador.estado == EstadoOrgano.sano) {
                        organoJugador.estado = EstadoOrgano.infectado;
                        print(
                            "El órgano del jugador (${organoJugador.tipoOrgano}) estaba sano y ahora se infecta.");
                      }
                      // Si ya estaba infectado, se considera muerto y se elimina de la lista
                      else if (organoJugador.estado == EstadoOrgano.infectado) {
                        cartasJugadorOrganos.remove(organoJugador);
                        print(
                            "El órgano del jugador (${organoJugador.tipoOrgano}) ya estaba infectado y se elimina (muere).");
                      }
                      // En ambos casos, el órgano del oponente se cura:
                      organoOponente.estado = EstadoOrgano.sano;
                      print(
                          "El órgano del oponente (${organoOponente.tipoOrgano}) se cura.");
                      Juego.contAccion++;
                      _robarCartasYActualizarTurno(
                          baraja, cartasOponente, setState);
                    }
                  } else {
                    print(
                        "No hay órganos compatibles para el órgano infectado del oponente (${organoOponente.tipoOrgano}).");
                  }
                }
              });
            case TipoEspecial.errorMedico:
              setState(() {
                // Intercambiar cartas en mano
                Juego.moverCartaADescartes(
                    cartasOponente, descartes, especialIndex);

                // Intercambio de cartas en mano entre el jugador y el oponente
                List<Carta> tempCartas = List.from(cartasJugador);
                cartasJugador.clear();
                cartasJugador.addAll(cartasOponente);
                cartasOponente.clear();
                cartasOponente.addAll(tempCartas);

                // Intercambio de órganos en juego
                List<Organo> tempOrganos = List.from(cartasJugadorOrganos);
                cartasJugadorOrganos.clear();
                cartasJugadorOrganos.addAll(cartasOponenteOrganos);
                cartasOponenteOrganos.clear();
                cartasOponenteOrganos.addAll(tempOrganos);
              });

              Juego.contAccion++;
              print(
                  "Error Médico: Se intercambiaron todas las cartas y órganos entre jugadores.");
              break;
            case TipoEspecial.guanteLatex:
              setState(() {
                // Descartar la mano del oponente: vaciamos la lista de cartas del oponente.
                cartasJugador.clear();
                cartasJugador.addAll(baraja.robarVariasCartas(3));
                Juego.moverCartaADescartes(
                    cartasOponente, descartes, especialIndex);
              });
              Juego.contAccion++;
              print(
                  "Guante de látex: La mano del oponente ha sido descartada, perdiendo un turno.");
              break;
            case TipoEspecial.ladronDeOrganos:
              print("El bot intenta robar un órgano del jugador.");

              // Filtrar los órganos del jugador que el bot no tenga ni en su mano ni en sus órganos colocados.
              List<Organo> organosDisponibles =
                  cartasJugadorOrganos.where((organoJugador) {
                bool yaLoTieneEnOrganos = cartasOponenteOrganos.any(
                    (organoBot) =>
                        organoBot.tipoOrgano == organoJugador.tipoOrgano);
                bool yaLoTieneEnMano = cartasOponente.any((carta) =>
                    carta is Organo &&
                    carta.tipoOrgano == organoJugador.tipoOrgano);
                return !(yaLoTieneEnOrganos || yaLoTieneEnMano);
              }).toList();

              if (organosDisponibles.isNotEmpty) {
                // Seleccionamos el primero disponible
                Organo organoRobado = organosDisponibles.first;
                setState(() {
                  // Como el bot es el que roba, lo agregamos a su lista (cartasOponenteOrganos)
                  cartasOponenteOrganos.add(organoRobado);
                  // Y lo removemos de la lista del jugador (cartasJugadorOrganos)
                  cartasJugadorOrganos.remove(organoRobado);
                  int indexEspecial = cartasOponente.indexWhere((carta) =>
                      carta is CartaEspecial &&
                      carta.tipoEspecial == TipoEspecial.ladronDeOrganos);
                  if (indexEspecial != -1) {
                    Juego.moverCartaADescartes(
                        cartasOponente, descartes, indexEspecial);
                  }
                  Juego.contAccion++;
                });
                print(
                    "Ladrón de Órganos (bot): se ha robado el órgano ${organoRobado.tipoOrgano} del jugador.");
              } else {
                print(
                    "Ladrón de Órganos (bot): no hay órganos disponibles para robar que el bot no tenga.");
              }
              break;
            case TipoEspecial.transplante:
              print("El bot va a realizar un trasplante de órganos.");

              // Definir la función para verificar duplicados
              bool tieneDuplicados(List<Organo> lista) {
                var colores = <dynamic>{};
                for (var o in lista) {
                  if (!colores.add(o.tipoOrgano)) return true;
                }
                return false;
              }

              // Filtrar órganos válidos (no inmunizados y sin duplicados en la mano)
              List<Organo> obtenerOrganoValido(List<Organo> listaOrgano) {
                return listaOrgano
                    .where((organo) => organo.estado != EstadoOrgano.inmune)
                    .toList();
              }

              // Filtrar órganos válidos del jugador y del oponente
              List<Organo> organosJugadorValidos =
                  obtenerOrganoValido(cartasJugadorOrganos);
              List<Organo> organosOponenteValidos =
                  obtenerOrganoValido(cartasOponenteOrganos);

              // Verificar que ambos jugadores tengan órganos válidos
              if (organosJugadorValidos.isEmpty ||
                  organosOponenteValidos.isEmpty) {
                print("Error: No hay órganos válidos para el trasplante.");
                Juego.esTurnoJugador1 = true;
              }

              // Buscamos el primer órgano válido para el trasplante
              Organo? organoJugadorSeleccionado;
              Organo? organoOponenteSeleccionado;

              // Buscar el primer órgano válido en la mano del jugador
              for (var organoJugador in organosJugadorValidos) {
                // Buscar el primer órgano válido en la mano del oponente
                for (var organoOponente in organosOponenteValidos) {
                  // Si los órganos son diferentes, seleccionamos este par
                  // Verificar que no haya órganos del mismo tipo
                  if (organoJugador.tipoOrgano != organoOponente.tipoOrgano &&
                      !cartasJugadorOrganos.any((organo) =>
                          organo.tipoOrgano == organoOponente.tipoOrgano) &&
                      !cartasOponenteOrganos.any((organo) =>
                          organo.tipoOrgano == organoJugador.tipoOrgano)) {
                    // Realizar el trasplante
                    organoJugadorSeleccionado = organoJugador;
                    organoOponenteSeleccionado = organoOponente;
                  }
                }
                // Si encontramos un par válido, salimos del bucle
                if (organoJugadorSeleccionado != null &&
                    organoOponenteSeleccionado != null) {
                  break;
                }
              }

              // Si hemos encontrado órganos válidos para el trasplante
              if (organoJugadorSeleccionado != null &&
                  organoOponenteSeleccionado != null) {
                List<Organo> nuevosOrganosJugador =
                    List.from(cartasJugadorOrganos);
                List<Organo> nuevosOrganosOponente =
                    List.from(cartasOponenteOrganos);

                // Realizamos el intercambio de los órganos seleccionados
                nuevosOrganosJugador[cartasJugadorOrganos.indexOf(
                    organoJugadorSeleccionado)] = organoOponenteSeleccionado;
                nuevosOrganosOponente[cartasOponenteOrganos.indexOf(
                    organoOponenteSeleccionado)] = organoJugadorSeleccionado;

                // Verificamos que no haya duplicados después del trasplante
                if (tieneDuplicados(nuevosOrganosJugador) ||
                    tieneDuplicados(nuevosOrganosOponente)) {
                  print("Error: Trasplante inválido por duplicados.");
                }

                // Realizamos el trasplante
                setState(() {
                  cartasJugadorOrganos[cartasJugadorOrganos
                          .indexOf(organoJugadorSeleccionado!)] =
                      organoOponenteSeleccionado!;
                  cartasOponenteOrganos[cartasOponenteOrganos.indexOf(
                      organoOponenteSeleccionado)] = organoJugadorSeleccionado;
                });

                Juego.contAccion++;
                print("Trasplante realizado con éxito.");

                // Llamamos a finTurno y terminamos la función aquí
                await Juego.finTurno(context, cartasJugador, descartes, baraja,
                    setState, cartasJugadorOrganos, cartasOponenteOrganos);
              }
          }
        }
      }

      // Si no jugó en ninguno de los casos anteriores, pasar al siguiente turno
      if (!haJugado) {
        if (cartasOponente.isNotEmpty) {
          cartasOponente.removeAt(0);
        }
        await _robarCartasYActualizarTurno(baraja, cartasOponente, setState);
      }

      Juego.esTurnoJugador1 = true;
      print("Turno siguiente para Jugador 1 $Juego.esTurnoJugador1");
    }
  }
}
