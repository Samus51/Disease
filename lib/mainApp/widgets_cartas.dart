// ignore_for_file: avoid_print

import 'dart:math';

import 'package:flutter/material.dart';

import '../models/carta.dart';
import '../models/carta_especial.dart';
import '../models/baraja.dart';
import '../models/organo.dart';

class CartasWidget extends StatefulWidget {
  const CartasWidget({super.key});

  @override
  State<CartasWidget> createState() => _CartasWidgetState();
}

class _CartasWidgetState extends State<CartasWidget> {
  int?
      cartaSeleccionadaIndexJugador; // Índice de la carta seleccionada por el jugador
  int?
      cartaSeleccionadaIndexOponente; // Índice de la carta seleccionada por el oponente
  int?
      organoSeleccionadoIndexJugador; // Índice del órgano seleccionado por el jugador
  int?
      organoSeleccionadoIndexOponente; // Índice del órgano seleccionado por el oponente

  bool modoSeleccionAvanzada = true;

  // Crear la baraja con las cartas generadas
  Baraja baraja = Baraja(cartas: Baraja.generarMazo());
  // Lista de cartas del jugador
  List<Carta> cartasJugador = [
    Carta(
        tipo: TipoCarta.virus,
        organo: "cerebro",
        descripcion: "virus para el cerebro"),
    Carta(
        tipo: TipoCarta.virus,
        organo: "corazon",
        descripcion: "Virus para el corazon"),
    CartaEspecial(
        tipoEspecial: TipoEspecial.contagio,
        descripcion: "Contagia a los demas organos del oponente"),
  ];
  List<Carta> cartasJugadorOrganos = [
    Organo(
        organo: "hueso",
        descripcion: "Organo hueso",
        tipoOrgano: TipoOrgano.hueso,
        tipo: TipoCarta.organo,
        estado: EstadoOrgano.sano),
    Organo(
        organo: "corazon",
        descripcion: "Organo corazón",
        tipoOrgano: TipoOrgano.corazon,
        tipo: TipoCarta.organo,
        estado: EstadoOrgano.vacunado),
    Organo(
        organo: "cerebro",
        descripcion: "Organo cerebro",
        tipoOrgano: TipoOrgano.cerebro,
        tipo: TipoCarta.organo,
        estado: EstadoOrgano.infectado),
    Organo(
        organo: "estomago",
        descripcion: "Organo estomago",
        tipoOrgano: TipoOrgano.estomago,
        tipo: TipoCarta.organo,
        estado: EstadoOrgano.infectado),
  ];

  List<Carta> cartasOponenteOrganos = [
    Organo(
        organo: "hueso",
        descripcion: "Organo hueso",
        tipoOrgano: TipoOrgano.hueso,
        tipo: TipoCarta.organo,
        estado: EstadoOrgano.sano),
    Organo(
        organo: "corazon",
        descripcion: "Organo corazón",
        tipoOrgano: TipoOrgano.corazon,
        tipo: TipoCarta.organo,
        estado: EstadoOrgano.sano),
    Organo(
        organo: "cerebro",
        descripcion: "Organo cerebro",
        tipoOrgano: TipoOrgano.cerebro,
        tipo: TipoCarta.organo,
        estado: EstadoOrgano.sano),
  ];

  // Lista de cartas del oponente
  List<Carta> cartasOponente = [
    Carta(
        tipo: TipoCarta.curacion,
        organo: "estomago",
        descripcion: "Curación para el estómago"),
    Carta(
        tipo: TipoCarta.virus,
        organo: "estomago",
        descripcion: "Virus para el estomago"),
    CartaEspecial(
        tipoEspecial: TipoEspecial.errorMedico,
        descripcion: "Intercambia una carta con el oponente"),
  ];

  double cartaSize = 70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo negro sólido
          Positioned.fill(
            child: Container(
              color: Colors.black, // Fondo negro por si la imagen no cubre
            ),
          ),

          // Imagen de fondo opaca, ajustada sin márgenes
          Positioned.fill(
            child: Opacity(
              opacity: 0.5, // Nivel de opacidad
              child: Image.asset(
                'assets/images/fondo_disease.png',
                fit: BoxFit.cover, // Asegura que cubra todo el espacio
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            // Asegura que el contenido no se meta debajo de la barra de estado
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _mazoDeCartas(),
                    SizedBox(width: 20),
                  ],
                ),
                _construirFilaCartas(cartasOponente, false, false),
                _construirFilaCartas(cartasOponenteOrganos, false, true),
                SizedBox(height: 180),
                _construirFilaCartas(cartasJugadorOrganos, true, true),
                _construirFilaCartas(cartasJugador, true, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirFilaCartas(
      List<Carta> cartas, bool esJugador, bool esOrgano) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(cartas.length, (index) {
          final carta = cartas[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: esJugador
                ? _construirCarta(
                    carta, index, esOrgano, esJugador) // Cartas del jugador
                : _construirCartaOponente(
                    carta, index, esOrgano), // Cartas del oponente
          );
        }),
      ),
    );
  }

  // Para las cartas del jugador
  Widget _construirCarta(
      Carta carta, int index, bool esOrgano, bool esJugador) {
    bool esSeleccionada = esOrgano
        ? organoSeleccionadoIndexJugador == index
        : cartaSeleccionadaIndexJugador == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (modoSeleccionAvanzada || esJugador) {
            if (esOrgano) {
              organoSeleccionadoIndexJugador =
                  organoSeleccionadoIndexJugador == index ? null : index;
            } else {
              cartaSeleccionadaIndexJugador =
                  cartaSeleccionadaIndexJugador == index ? null : index;
            }
          }
        });
      },
      onLongPressStart: (details) {
        _mostrarMenuEmergente(context, carta, details.globalPosition);
      },
      child: esOrgano
          ? _disenoOrgano(carta as Organo,
              esSeleccionada) // Aquí llamamos _disenoOrgano si la carta es un órgano
          : _disenoCarta(
              carta, esSeleccionada), // Si no es órgano, usamos _disenoCarta
    );
  }

  // Para las cartas del oponente
  Widget _construirCartaOponente(Carta carta, int index, bool esOrgano) {
    bool esSeleccionada = esOrgano
        ? organoSeleccionadoIndexOponente == index
        : cartaSeleccionadaIndexOponente == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (modoSeleccionAvanzada) {
            if (esOrgano) {
              organoSeleccionadoIndexOponente =
                  esSeleccionada ? null : index; // Alternar selección
            } else {
              cartaSeleccionadaIndexOponente =
                  esSeleccionada ? null : index; // Alternar selección
            }
          }
        });
      },
      onLongPressStart: (details) {
        _mostrarMenuEmergente(context, carta, details.globalPosition);
      },
      child: esOrgano
          ? _disenoOrgano(carta as Organo,
              esSeleccionada) // Aquí llamamos _disenoOrgano si la carta es un órgano
          : _disenoCarta(
              carta, esSeleccionada), // Si no es órgano, usamos _disenoCarta
    );
  }

  // Diseño de la carta, mostrando el borde si está seleccionada
  Widget _disenoCarta(Carta carta, bool esSeleccionada) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 70,
      height: 98,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: carta.obtenerImagen(),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
        border: esSeleccionada
            ? Border.all(
                color: Colors.yellow,
                width: 4) // Borde amarillo si está seleccionada
            : null,
      ),
    );
  }

  Widget _disenoOrgano(Organo organo, bool esSeleccionado) {
    // Determina el color del borde según el estado del órgano
    Color bordeColor;
    switch (organo.estado) {
      case EstadoOrgano.infectado:
        bordeColor = Colors.red; // Rojo para infectado
        break;
      case EstadoOrgano.inmune:
        bordeColor = Colors.blue; // Azul para inmune
        break;
      case EstadoOrgano.vacunado:
        bordeColor = Colors.green; // Verde para vacunado
        break;
      default:
        bordeColor = Colors.transparent; // Sin borde si no tiene estado
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 70,
      height: 98,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: organo.obtenerImagen(),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
        border: esSeleccionado
            ? Border.all(
                color: Colors.yellow,
                width: 4) // Borde amarillo si está seleccionado
            : Border.all(color: bordeColor, width: 4), // Borde del estado
      ),
    );
  }

  _mazoDeCartas() {
    return SizedBox(
      width: 80,
      height: 100,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (cartasJugador.length < 3) {
              cartasJugador.add(baraja.cartas[Random().nextInt(62)]);
              print("Carta añadida");
            }
            print("Pila de cartas tocada");
          });
        },
        child: Stack(
          alignment: Alignment.centerLeft,
          children: List.generate(5, (index) {
            return Positioned(
              left: index * 2.0,
              top: index * 2.0,
              child: Image.asset(
                'assets/images/carta_parte_trasera.png',
                width: 80,
                height: 80,
              ),
            );
          }),
        ),
      ),
    );
  }

  void _mostrarMenuEmergente(
      BuildContext context, Carta carta, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(
          value: 'eliminar_carta',
          child: Text('Eliminar carta'),
          onTap: () {
            setState(() {
              // Eliminar la carta seleccionada, si está seleccionada
              if (cartaSeleccionadaIndexJugador != null) {
                cartasJugador.removeAt(cartaSeleccionadaIndexJugador!);
                cartaSeleccionadaIndexJugador = null;
              }
            });
          },
        ),
        PopupMenuItem(
          value: 'usar_carta',
          child: Text('Usar carta'),
          onTap: () {
            setState(() {
              // Depuración
              print("Index Jugador: $cartaSeleccionadaIndexJugador");
              print("Index Oponente: $cartaSeleccionadaIndexOponente");
              print("Index Organos Jugador: $organoSeleccionadoIndexJugador");
              print("Index Organos Oponente: $organoSeleccionadoIndexOponente");

              // Verifica si el jugador tiene seleccionada una carta y un órgano
              if (cartaSeleccionadaIndexJugador != null &&
                  organoSeleccionadoIndexJugador != null) {
                final cartaJugadorSeleccionada =
                    cartasJugador[cartaSeleccionadaIndexJugador!];
                final organoJugadorSeleccionado =
                    cartasJugadorOrganos[organoSeleccionadoIndexJugador!];

                // Lógica de CURACIÓN
                if (cartaJugadorSeleccionada.tipo == TipoCarta.curacion) {
                  if (organoJugadorSeleccionado is Organo) {
                    final organoPlayer = organoJugadorSeleccionado;
                    print(
                        "Estado del órgano antes de curar: ${organoPlayer.estadoOrgano}");

                    switch (organoPlayer.estado) {
                      case EstadoOrgano.sano:
                        organoPlayer.estado = EstadoOrgano.vacunado;
                        print(
                            "El órgano ha sido curado y ahora está ${organoPlayer.estadoOrgano}");
                        break;
                      case EstadoOrgano.infectado:
                        organoPlayer.estado = EstadoOrgano.sano;
                        print("El órgano ha sido curado.");
                        break;
                      case EstadoOrgano.vacunado:
                        organoPlayer.estado = EstadoOrgano.inmune;
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
              }
              // Verifica si el jugador tiene seleccionada una carta y el oponente tiene un órgano seleccionado
              else if (cartaSeleccionadaIndexJugador != null &&
                  organoSeleccionadoIndexOponente != null) {
                final cartaJugadorSeleccionada =
                    cartasJugador[cartaSeleccionadaIndexJugador!];
                final organoOponenteSeleccionada =
                    cartasOponenteOrganos[organoSeleccionadoIndexOponente!];

                // Lógica de INFECTAR
                if (cartaJugadorSeleccionada.tipo == TipoCarta.virus) {
                  print(
                      "Carta de virus seleccionada: ${cartaJugadorSeleccionada.organo}");
                  if (cartaJugadorSeleccionada.organo ==
                      organoOponenteSeleccionada.organo) {
                    if (organoOponenteSeleccionada is Organo) {
                      final organoOponente = organoOponenteSeleccionada;
                      print(
                          "Estado del órgano antes de infectar: ${organoOponente.estadoOrgano}");

                      switch (organoOponente.estado) {
                        case EstadoOrgano.sano:
                          organoOponente.estado = EstadoOrgano.infectado;
                          print(
                              "El órgano ha sido infectado y ahora está ${organoOponente.estadoOrgano}");
                          break;
                        case EstadoOrgano.infectado:
                          organoOponente.estado = EstadoOrgano.muerto;
                          print("El órgano ha muerto.");
                          cartasOponenteOrganos
                              .removeAt(organoSeleccionadoIndexOponente!);
                          break;
                        case EstadoOrgano.vacunado:
                          print(
                              "El órgano está vacunado, no se puede infectar.");
                          break;
                        case EstadoOrgano.inmune:
                          print(
                              "El órgano ya está inmune, no se puede infectar.");
                          break;
                        case EstadoOrgano.muerto:
                          print("El órgano ya está muerto.");
                          break;
                      }
                    }
                  }
                }
              }
              // Verifica si el jugador tiene seleccionada una carta especial
              else if (cartaSeleccionadaIndexJugador != null) {
                final cartaJugadorSeleccionada =
                    cartasJugador[cartaSeleccionadaIndexJugador!];

                if (cartaJugadorSeleccionada is CartaEspecial) {
                  // Cast seguro a CartaEspecial y actuamos según el tipo especial
                  switch (cartaJugadorSeleccionada.tipoEspecial) {
                    case TipoEspecial.ladronDeOrganos:
                      // Acción para "Ladrón de órganos"
                      print("El jugador debe robar dos cartas.");
                      break;

                    case TipoEspecial.contagio:
                      // Acción para "Contagio"
                      List<Organo> organosInfectadosJugador = [];
                      List<Organo> organosSanosOponente = [];

                      // Obtener órganos infectados del jugador
                      for (int i = 0; i < cartasJugadorOrganos.length; i++) {
                        if (cartasJugadorOrganos[i] is Organo) {
                          Organo organo = cartasJugadorOrganos[i] as Organo;
                          if (organo.estado == EstadoOrgano.infectado) {
                            organosInfectadosJugador.add(organo);
                          }
                        }
                      }

                      // Obtener órganos sanos del oponente
                      for (int i = 0; i < cartasOponenteOrganos.length; i++) {
                        if (cartasOponenteOrganos[i] is Organo) {
                          Organo organo = cartasOponenteOrganos[i] as Organo;
                          if (organo.estado == EstadoOrgano.sano) {
                            organosSanosOponente.add(organo);
                          }
                        }
                      }

                      // Infectar órganos sanos del oponente y dejar los del jugador sanos, pero solo si coinciden en tipo
                      for (var organoJugador in organosInfectadosJugador) {
                        if (organosSanosOponente.isNotEmpty) {
                          // Filtramos los órganos sanos del oponente que coinciden con el tipo del órgano infectado del jugador
                          List<Organo> organosCoincidentes =
                              organosSanosOponente
                                  .where((organoOponente) =>
                                      organoOponente.tipoOrgano ==
                                      organoJugador.tipoOrgano)
                                  .toList();

                          if (organosCoincidentes.isNotEmpty) {
                            // Tomamos el primer órgano coincidente del oponente
                            Organo organoOponente = organosCoincidentes.first;

                            // Infectamos el órgano del oponente
                            organoOponente.estado = EstadoOrgano.infectado;
                            print(
                                "Órgano del oponente (${organoOponente.tipoOrgano}) ha sido infectado.");

                            // Curamos el órgano del jugador
                            organoJugador.estado = EstadoOrgano.sano;
                            print(
                                "Órgano del jugador (${organoJugador.tipoOrgano}) ha sido curado y está sano.");

                            // Eliminamos el órgano sano del oponente de la lista
                            organosSanosOponente.remove(organoOponente);
                          } else {
                            print(
                                "No hay órganos sanos del tipo ${organoJugador.tipoOrgano} para infectar.");
                          }
                        } else {
                          print("Ya no hay más órganos sanos para infectar.");
                          break; // Salimos del bucle si no hay más órganos sanos en el oponente
                        }
                      }

                      break;

                    case TipoEspecial.errorMedico:
                      // Acción para "Error médico"
                      print("Intercambio de cartas con otro jugador.");
                      break;

                    case TipoEspecial.guanteLatex:
                      // Acción para "Guante de látex"
                      print("El jugador puede eliminar una carta.");
                      break;

                    case TipoEspecial.transplante:
                      // Acción para "Transplante"
                      print(
                          "El jugador puede realizar un transplante de cartas.");
                      break;

                    default:
                      // Caso por defecto si no se reconoce el tipo
                      print("Tipo de carta especial no reconocido.");
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
            });
          },
        )
      ],
    );
  }
}
