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
  static int contDescartes = 0; // Variable para determinar el turno actual.
  static int contAccion = 0;
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

    if (contDescartes == 3 || contAccion == 1) {
      return;
    }

    if (!esTurnoJugador1) {
      print("Acción denegada");
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
        final organoPlayer = organoJugadorSeleccionado;
        print("Estado del órgano antes de curar: ${organoPlayer.estadoOrgano}");

        switch (organoPlayer.estado) {
          case EstadoOrgano.sano:
            organoPlayer.estado = EstadoOrgano.vacunado;
            contAccion++;

            print(
                "El órgano ha sido curado y ahora está ${organoPlayer.estadoOrgano}");
            moverCartaADescartes(
                cartasJugador, descartes, cartaSeleccionadaIndexJugador);
            break;
          case EstadoOrgano.infectado:
            organoPlayer.estado = EstadoOrgano.sano;
            contAccion++;

            print("El órgano ha sido curado.");
            moverCartaADescartes(
                cartasJugador, descartes, cartaSeleccionadaIndexJugador);
            break;
          case EstadoOrgano.vacunado:
            organoPlayer.estado = EstadoOrgano.inmune;
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
          final organoOponente = organoOponenteSeleccionada;
          print(
              "Estado del órgano antes de infectar: ${organoOponente.estadoOrgano}");
          switch (organoOponente.estado) {
            case EstadoOrgano.sano:
              organoOponente.estado = EstadoOrgano.infectado;
              print(
                  "El órgano ha sido infectado y ahora está ${organoOponente.estadoOrgano}");
              moverCartaADescartes(
                  cartasJugador, descartes, cartaSeleccionadaIndexJugador);
              contAccion++;
              break;
            case EstadoOrgano.infectado:
              organoOponente.estado = EstadoOrgano.muerto;
              print("El órgano ha muerto.");
              moverCartaADescartes(
                  cartasJugador, descartes, cartaSeleccionadaIndexJugador);
              contAccion++;
              break;
            case EstadoOrgano.vacunado:
              organoOponente.estado = EstadoOrgano.sano;
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
                // Verificar que el órgano no esté inmune
                bool organoOponenteInmune =
                    organoOponente?.estadoOrgano == EstadoOrgano.inmune;

                // Verificar que el jugador no tenga un órgano del mismo tipo
                bool yaTieneEsteOrgano = cartasJugadorOrganos.any((organo) {
                  print(
                      "Comparando: ${organo.tipoOrgano} con ${organoOponente?.tipoOrgano}");
                  return organo.tipoOrgano == organoOponente?.tipoOrgano;
                });

                // Si el órgano no está inmune y el jugador no tiene uno del mismo tipo, puede robarlo
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

              // Clonar las listas para evitar referencias compartidas
              List<Carta> tempJugador = List.from(cartasJugador);
              List<Organo> tempOrganos = List.from(cartasJugadorOrganos);

              // Realizar el intercambio de cartas
              cartasJugador.clear();
              cartasJugador.addAll(cartasOponente);
              cartasOponente.clear();
              cartasOponente.addAll(tempJugador);

              // Intercambiar órganos
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
              // Mueve la carta seleccionada a los descartes
              moverCartaADescartes(
                  cartasJugador, descartes, cartaSeleccionadaIndexJugador!);

              // Reemplaza la mano del oponente con tres nuevas cartas de la baraja
              cartasOponente = baraja.robarVariasCartas(3);
              contAccion++;
              print(
                  "La mano del oponente ha sido eliminada y se han robado 3 nuevas cartas.");
            });
            break;

          case TipoEspecial.transplante:
            print("El jugador puede realizar un trasplante de cartas.");
            int indiceTransplante = cartaSeleccionadaIndexJugador;
            // Primero, no eliminamos la carta de Error Médico hasta que se verifique la validez.
            () async {
              var (organoJugador, organoOponente) = await seleccionarOrgano();

              if (organoJugador != null && organoOponente != null) {
                // Obtén los órganos seleccionados:
                var organoJugadorSeleccionado =
                    cartasJugadorOrganos[organoJugador];
                var organoOponenteSeleccionado =
                    cartasOponenteOrganos[organoOponente];

                // Verifica que ninguno de los órganos esté inmunizado:
                if (organoJugadorSeleccionado.estado == EstadoOrgano.inmune ||
                    organoOponenteSeleccionado.estado == EstadoOrgano.inmune) {
                  print(
                      "Error: No se puede realizar el trasplante porque uno de los órganos está inmunizado.");
                  return; // No se realiza el trasplante
                }

                // Simula el intercambio para verificar duplicados en colores
                List<Organo> nuevosOrganosJugador =
                    List.from(cartasJugadorOrganos);
                List<Organo> nuevosOrganosOponente =
                    List.from(cartasOponenteOrganos);

                nuevosOrganosJugador[organoJugador] =
                    organoOponenteSeleccionado;
                nuevosOrganosOponente[organoOponente] =
                    organoJugadorSeleccionado;

                // Función auxiliar para detectar duplicados por color
                bool tieneDuplicados(List<Organo> lista) {
                  var colores =
                      <dynamic>{}; // Usa dynamic o el tipo que uses para "color"
                  for (var o in lista) {
                    if (!colores.add(o.tipoOrgano)) return true;
                  }
                  return false;
                }

                if (tieneDuplicados(nuevosOrganosJugador) ||
                    tieneDuplicados(nuevosOrganosOponente)) {
                  print(
                      "Error: No se puede realizar el trasplante porque resultaría en dos órganos del mismo color en algún jugador.");
                  return; // Cancelamos el trasplante sin quitar la carta
                }
                moverCartaADescartes(
                    cartasJugador, descartes, indiceTransplante);
                // Si pasa las validaciones, procedemos con el intercambio:
                setState(() {
                  var temp = cartasJugadorOrganos[organoJugador];
                  cartasJugadorOrganos[organoJugador] =
                      cartasOponenteOrganos[organoOponente];
                  cartasOponenteOrganos[organoOponente] = temp;
                });

                // Ahora, mueve la carta de trasplante (Error Médico o similar) a descartes.
                //moverCartaADescartes(cartasJugador, descartes, cartaSeleccionadaIndexJugador!);
                contAccion++;
                print(
                    "Trasplante realizado: Órgano $organoJugador del jugador intercambiado con el órgano $organoOponente del oponente.");
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

  static void _iniciarContadorRobar() {
    // Si ya existe un Timer, lo cancelamos para reiniciar
    if (_timerRobar != null && _timerRobar!.isActive) {
      _timerRobar!.cancel();
    }

    // Iniciamos un nuevo Timer para enviar un mensaje cada 15 segundos
    _timerRobar = Timer.periodic(Duration(seconds: 15), (timer) {
      if (_mensajeRobarEnviado) {
        print("Recuerda que debes robar más cartas.");
      } else {
        print("El jugador debe robar más cartas.");
        _mensajeRobarEnviado = true; // Evitar mensaje repetido
      }
    });
  }

  // Mover carta a descartes
  static void moverCartaADescartes(
      List<Carta> listaCartas, List<Carta> descartes, int index) {
    if (contDescartes >= 3 && !esTurnoJugador1) {
      print("Contador de descartes llego a su limite para su turno");
      ;
      contDescartes = 0; // No más de 3 descartes.
    }
    if (contDescartes < 3) {
      descartes.add(listaCartas.removeAt(index));
      contDescartes++;
      print("Contador de descartes $contDescartes");
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
        String ganador = sanosJugador ? "Jugador" : "Oponente";
        MusicaJuego.detenerMusica();
        MusicaJuego.iniciarMusicaWin();
        showDialog(
          context: context,
          barrierDismissible: false, // Para que no se cierre tocando fuera
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
        String ganador = sanosOponente ? "Oponente" : "Jugador";
        MusicaJuego.detenerMusica();
        MusicaJuego.iniciarMusicaDerrota();
        showDialog(
          context: context,
          barrierDismissible: false, // Para que no se cierre tocando fuera
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

    // Si el jugador tiene menos de 3 cartas, esperar a que robe hasta tener 3
    while (cartasJugador.length < 3) {
      print("El jugador necesita robar más cartas.");
      await Future.delayed(
          Duration(seconds: 1)); // Espera 1 segundo antes de volver a comprobar
    }

    // Cuando el jugador tiene 3 cartas, podemos proceder con el cambio de turno
    esTurnoJugador1 = !esTurnoJugador1;

    // Espera 1 segundo para el cambio de turno
    await Future.delayed(Duration(seconds: 1));

    // Imprime el mensaje de cambio de turno
    print("Es el turno del ${esTurnoJugador1 ? 'Jugador 1' : 'Jugador 2'}");

    // Esto asegura que siempre se revisa el cambio de turno
    setState(() {}); // Llamada a setState para forzar la actualización de la UI
  }
}
