// ignore_for_file: avoid_print

import 'dart:async';
import 'package:disease/models/carta.dart';
import 'package:disease/models/carta_especial.dart';
import 'package:disease/models/organo.dart';
import 'package:disease/models/baraja.dart';
import 'package:flutter/material.dart';
import '../models/musica_juego.dart';

class Juego {
  static bool esTurnoJugador1 =
      true; // Variable para determinar el turno actual.
  static int contDescartes = 0; // Contador de descartes por turno.
  static int contAccion = 0; // Contador de acciones por turno.
  Juego._(); // Constructor privado, la clase ahora es estática.

  static Future<void> realizarAccion(
    BuildContext context, // Agregado
    int? cartaSeleccionadaIndexJugador,
    int? cartaSeleccionadaIndexOponente,
    int? organoSeleccionadoIndexJugador,
    int? organoSeleccionadoIndexOponente,
    void Function(void Function()) setState,
    Future<Organo?> Function() seleccionarOrganoParaRobo,
    Future<(int?, int?)> Function() seleccionarOrgano,
    List<Carta> cartasJugador, // Agregado
    List<Organo> cartasJugadorOrganos, // Agregado
    List<Carta> cartasOponente, // Agregado
    List<Organo> cartasOponenteOrganos, // Agregado
    List<Carta> descartes, // Agregado
    Baraja baraja, // Agregado
  ) async {
    print("Index Jugador: $cartaSeleccionadaIndexJugador");
    print("Index Oponente: $cartaSeleccionadaIndexOponente");
    print("Index Organos Jugador: $organoSeleccionadoIndexJugador");
    print("Index Organos Oponente: $organoSeleccionadoIndexOponente");

    // Si ya se ha realizado una acción o se ha descartado 3 cartas, se ignora.
    if (contDescartes == 3 || contAccion == 1) {
      return;
    }

    if (!esTurnoJugador1) {
      print("Acción denegada: no es tu turno.");
      return;
    }
    // --- Acción de CURACIÓN ---
    if (cartaSeleccionadaIndexJugador != null &&
        organoSeleccionadoIndexJugador != null) {
      final cartaJugadorSeleccionada =
          cartasJugador[cartaSeleccionadaIndexJugador];
      final organoJugadorSeleccionado =
          cartasJugadorOrganos[organoSeleccionadoIndexJugador];

      if (cartaJugadorSeleccionada.tipo == TipoCarta.curacion) {
        print(
            "Estado del órgano antes de curar: ${organoJugadorSeleccionado.estadoOrgano}");
        switch (organoJugadorSeleccionado.estado) {
          case EstadoOrgano.sano:
            organoJugadorSeleccionado.estado = EstadoOrgano.vacunado;
            contAccion++;
            print(
                "El órgano ha sido curado y ahora está ${organoJugadorSeleccionado.estadoOrgano}");
            moverCartaADescartes(
                cartasJugador, descartes, cartaSeleccionadaIndexJugador);
            break;
          case EstadoOrgano.infectado:
            organoJugadorSeleccionado.estado = EstadoOrgano.sano;
            contAccion++;
            print("El órgano ha sido curado.");
            moverCartaADescartes(
                cartasJugador, descartes, cartaSeleccionadaIndexJugador);
            break;
          case EstadoOrgano.vacunado:
            organoJugadorSeleccionado.estado = EstadoOrgano.inmune;
            contAccion++;
            moverCartaADescartes(
                cartasJugador, descartes, cartaSeleccionadaIndexJugador);
            print("El órgano ahora es inmune.");
            break;
          case EstadoOrgano.inmune:
            print("El órgano ya está inmune.");
            break;
          case EstadoOrgano.muerto:
            print("El órgano ya está muerto.");
            break;
        }
      }
    }
    // --- Acción de INFECTAR ---
    else if (cartaSeleccionadaIndexJugador != null &&
        organoSeleccionadoIndexOponente != null) {
      final cartaJugadorSeleccionada =
          cartasJugador[cartaSeleccionadaIndexJugador];
      final organoOponenteSeleccionada =
          cartasOponenteOrganos[organoSeleccionadoIndexOponente];

      if (cartaJugadorSeleccionada.tipo == TipoCarta.virus) {
        print(
            "Carta de virus seleccionada: ${cartaJugadorSeleccionada.organo}");
        if (cartaJugadorSeleccionada.organo ==
            organoOponenteSeleccionada.organo) {
          print(
              "Estado del órgano antes de infectar: ${organoOponenteSeleccionada.estadoOrgano}");
          switch (organoOponenteSeleccionada.estado) {
            case EstadoOrgano.sano:
              organoOponenteSeleccionada.estado = EstadoOrgano.infectado;
              print(
                  "El órgano ha sido infectado y ahora está ${organoOponenteSeleccionada.estadoOrgano}");
              moverCartaADescartes(
                  cartasJugador, descartes, cartaSeleccionadaIndexJugador);
              contAccion++;
              break;
            case EstadoOrgano.infectado:
              organoOponenteSeleccionada.estado = EstadoOrgano.muerto;
              print("El órgano ha muerto.");
              moverCartaADescartes(
                  cartasJugador, descartes, cartaSeleccionadaIndexJugador);
              contAccion++;
              break;
            case EstadoOrgano.vacunado:
              organoOponenteSeleccionada.estado = EstadoOrgano.sano;
              print("El órgano está vacunado, no se puede infectar.");
              moverCartaADescartes(
                  cartasJugador, descartes, cartaSeleccionadaIndexJugador);
              contAccion++;
              break;
            case EstadoOrgano.inmune:
              print("El órgano ya está inmune, no se puede infectar.");
              break;
            case EstadoOrgano.muerto:
              print("El órgano ya está muerto.");
              break;
          }
        }
      }
    }
    // --- Acción para agregar un órgano (cuando la carta seleccionada es un órgano) ---
    else if (cartaSeleccionadaIndexJugador != null) {
      final cartaJugadorSeleccionada =
          cartasJugador[cartaSeleccionadaIndexJugador];

      if (cartasJugador.contains(cartaJugadorSeleccionada)) {
        if (cartaJugadorSeleccionada is Organo) {
          Organo organo = cartaJugadorSeleccionada;
          bool yaTieneOrgano = cartasJugadorOrganos
              .any((o) => o.tipoOrgano == organo.tipoOrgano);
          if (!yaTieneOrgano) {
            cartasJugadorOrganos.add(organo);
            contAccion++;
            moverCartaADescartes(
                cartasJugador, descartes, cartaSeleccionadaIndexJugador);
          } else {
            print("Ya tienes un órgano de este tipo, no puedes agregar otro.");
          }
        }
      } else {
        print("No puedes jugar cartas del oponente.");
      }

      // --- Acciones especiales ---
      if (cartaJugadorSeleccionada is CartaEspecial) {
        switch (cartaJugadorSeleccionada.tipoEspecial) {
          case TipoEspecial.ladronDeOrganos:
            print("El jugador puede robar un órgano de otro jugador.");
            () async {
              // Buscamos la carta "Ladrón de Órganos" en la mano del jugador
              Carta? cartaLadron = cartasJugador.firstWhere(
                (carta) =>
                    carta is CartaEspecial &&
                    carta.tipoEspecial == TipoEspecial.ladronDeOrganos,
              );
              // Pedimos seleccionar un órgano del oponente
              var organoOponente = await seleccionarOrganoParaRobo();
              setState(() {
                bool organoOponenteInmune =
                    organoOponente?.estadoOrgano == EstadoOrgano.inmune;
                bool yaTieneEsteOrgano = cartasJugadorOrganos.any((organo) {
                  print(
                      "Comparando: ${organo.tipoOrgano} con ${organoOponente?.tipoOrgano}");
                  return organo.tipoOrgano == organoOponente?.tipoOrgano;
                });
                if (organoOponente != null &&
                    !organoOponenteInmune &&
                    !yaTieneEsteOrgano) {
                  cartasJugadorOrganos.add(organoOponente);
                  cartasOponenteOrganos.remove(organoOponente);
                  cartasJugador.remove(cartaLadron);
                  contAccion++;
                  print(
                      "Órgano robado del oponente: ${organoOponente.tipoOrgano}.");
                } else {
                  if (organoOponenteInmune) {
                    print("No se puede robar este órgano. Está inmune.");
                  } else if (yaTieneEsteOrgano) {
                    print(
                        "No se puede robar este órgano. Ya tienes uno del mismo tipo.");
                  }
                }
              });
              print("El jugador ha intentado robar un órgano del oponente.");
            }();
            break;
          case TipoEspecial.contagio:
            List<Organo> organosInfectadosJugador = [];
            List<Organo> organosSanosOponente = [];
            // Obtener órganos infectados del jugador
            for (int i = 0; i < cartasJugadorOrganos.length; i++) {
              Organo organo = cartasJugadorOrganos[i];
              if (organo.estado == EstadoOrgano.infectado) {
                organosInfectadosJugador.add(organo);
              }
            }
            // Obtener órganos sanos del oponente
            for (int i = 0; i < cartasOponenteOrganos.length; i++) {
              Organo organo = cartasOponenteOrganos[i];
              if (organo.estado == EstadoOrgano.sano) {
                organosSanosOponente.add(organo);
              }
            }
            for (var organoJugador in organosInfectadosJugador) {
              if (organosSanosOponente.isNotEmpty) {
                List<Organo> organosCoincidentes = organosSanosOponente
                    .where((organoOponente) =>
                        organoOponente.tipoOrgano == organoJugador.tipoOrgano)
                    .toList();
                if (organosCoincidentes.isNotEmpty) {
                  Organo organoOponente = organosCoincidentes.first;
                  organoOponente.estado = EstadoOrgano.infectado;
                  print(
                      "Órgano del oponente (${organoOponente.tipoOrgano}) ha sido infectado.");
                  organoJugador.estado = EstadoOrgano.sano;
                  print(
                      "Órgano del jugador (${organoJugador.tipoOrgano}) ha sido curado y está sano.");
                  organosSanosOponente.remove(organoOponente);
                  contAccion++;
                  moverCartaADescartes(
                      cartasJugador, descartes, cartaSeleccionadaIndexJugador);
                } else {
                  print(
                      "No hay órganos sanos del tipo ${organoJugador.tipoOrgano} para infectar.");
                }
              } else {
                print("Ya no hay más órganos sanos para infectar.");
                break;
              }
            }
            break;
          case TipoEspecial.errorMedico:
            setState(() {
              moverCartaADescartes(
                  cartasJugador, descartes, cartaSeleccionadaIndexJugador!);
              List<Carta> tempJugador = List.from(cartasJugador);
              List<Organo> tempOrganos = List.from(cartasJugadorOrganos);
              cartasJugador.clear();
              cartasJugador.addAll(cartasOponente);
              cartasOponente.clear();
              cartasOponente.addAll(tempJugador);
              cartasJugadorOrganos.clear();
              cartasJugadorOrganos.addAll(cartasOponenteOrganos);
              cartasOponenteOrganos.clear();
              cartasOponenteOrganos.addAll(tempOrganos);
            });
            contAccion++;
            print("Intercambio de cartas con otro jugador.");
            break;
          case TipoEspecial.guanteLatex:
            setState(() {
              moverCartaADescartes(
                  cartasJugador, descartes, cartaSeleccionadaIndexJugador!);
              cartasOponente = baraja.robarVariasCartas(3);
              contAccion++;
              print(
                  "La mano del oponente ha sido eliminada y se han robado 3 nuevas cartas.");
            });
            break;
          case TipoEspecial.transplante:
            print("El jugador puede realizar un trasplante de cartas.");
            int indiceTransplante = cartaSeleccionadaIndexJugador;
            () async {
              var (organoJugador, organoOponente) = await seleccionarOrgano();
              if (organoJugador != null && organoOponente != null) {
                var organoJugadorSeleccionado =
                    cartasJugadorOrganos[organoJugador];
                var organoOponenteSeleccionado =
                    cartasOponenteOrganos[organoOponente];
                if (organoJugadorSeleccionado.estado == EstadoOrgano.inmune ||
                    organoOponenteSeleccionado.estado == EstadoOrgano.inmune) {
                  print(
                      "Error: No se puede realizar el trasplante porque uno de los órganos está inmunizado.");
                  return;
                }
                List<Organo> nuevosOrganosJugador =
                    List.from(cartasJugadorOrganos);
                List<Organo> nuevosOrganosOponente =
                    List.from(cartasOponenteOrganos);
                nuevosOrganosJugador[organoJugador] =
                    organoOponenteSeleccionado;
                nuevosOrganosOponente[organoOponente] =
                    organoJugadorSeleccionado;
                bool tieneDuplicados(List<Organo> lista) {
                  var colores = <dynamic>{};
                  for (var o in lista) {
                    if (!colores.add(o.tipoOrgano)) return true;
                  }
                  return false;
                }

                if (tieneDuplicados(nuevosOrganosJugador) ||
                    tieneDuplicados(nuevosOrganosOponente)) {
                  print(
                      "Error: Trasplante inválido por duplicados en algún jugador.");
                  return;
                }
                moverCartaADescartes(
                    cartasJugador, descartes, indiceTransplante);
                setState(() {
                  var temp = cartasJugadorOrganos[organoJugador];
                  cartasJugadorOrganos[organoJugador] =
                      cartasOponenteOrganos[organoOponente];
                  cartasOponenteOrganos[organoOponente] = temp;
                });
                contAccion++;
                print(
                    "Trasplante realizado: Órgano $organoJugador intercambiado con órgano $organoOponente.");
              }
            }();
            break;
        }
      } else {
        print("La carta seleccionada no es especial.");
      }
    }

    // Resetea los índices después de realizar la acción
    cartaSeleccionadaIndexJugador = null;
    cartaSeleccionadaIndexOponente = null;
    organoSeleccionadoIndexJugador = null;
    organoSeleccionadoIndexOponente = null;

    finTurno(context, cartasJugador, descartes, baraja, setState,
        cartasJugadorOrganos, cartasOponenteOrganos);
  }

  // Variable global para controlar el mensaje de robar
  static Timer? _timerRobar;
  static bool _mensajeRobarEnviado = false;

  static void moverCartaADescartes(
      List<Carta> listaCartas, List<Carta> descartes, int index) {
    if (contDescartes >= 3 && !esTurnoJugador1) {
      print("Contador de descartes llegó a su límite para este turno.");
      contDescartes = 0;
      esTurnoJugador1 = false;
    }
    if (contDescartes < 3) {
      descartes.add(listaCartas.removeAt(index));
      contDescartes++;
      print("Contador de descartes: $contDescartes");
    }
  }

  static Future<void> finTurno(
    BuildContext context,
    List<Carta> cartasJugador,
    List<Carta> descartes,
    Baraja baraja,
    void Function(void Function()) setState,
    List<Organo> cartasJugadorOrganos,
    List<Organo> cartasOponenteOrganos,
  ) async {
    // Primero comprobamos si algún jugador tiene 4 órganos
    if (cartasJugadorOrganos.length == 4 || cartasOponenteOrganos.length == 4) {
      bool sanosJugador = cartasJugadorOrganos
          .every((organo) => organo.estado == EstadoOrgano.sano);
      bool sanosOponente = cartasOponenteOrganos
          .every((organo) => organo.estado == EstadoOrgano.sano);

      if (sanosJugador) {
        String ganador = "Jugador";
        MusicaJuego.detenerMusica();
        MusicaJuego.iniciarMusicaWin();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text("¡Ganador!"),
              content: Text("¡El $ganador ha ganado la partida!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        return;
      } else if (sanosOponente) {
        String ganador = "Oponente";
        MusicaJuego.detenerMusica();
        MusicaJuego.iniciarMusicaDerrota();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text("¡Derrota!"),
              content: Text("¡El $ganador ha ganado la partida!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        return;
      }
    }

    // Si el jugador tiene menos de 3 cartas, espera a que robe hasta tener 3
    while (cartasJugador.length < 3) {
      print("El jugador necesita robar más cartas.");
      await Future.delayed(Duration(seconds: 1));
    }

    // Al finalizar el turno, reiniciamos los contadores para el siguiente turno
    contDescartes = 0;
    contAccion = 0;
    _mensajeRobarEnviado = false; // Reiniciamos el flag del temporizador

    // Cambiar turno
    esTurnoJugador1 = !esTurnoJugador1;
    await Future.delayed(Duration(seconds: 1));

    print("Es el turno del ${esTurnoJugador1 ? 'Jugador 1' : 'Jugador 2'}");

    setState(() {});
  }
}
