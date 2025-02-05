// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:disease/models/bot.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/carta.dart';
import '../models/baraja.dart';
import '../models/juego.dart';
import '../models/organo.dart';
import '../utils/functions.dart';

class CartasWidget extends StatefulWidget {
  const CartasWidget({super.key});

  @override
  State<CartasWidget> createState() => _CartasWidgetState();
}

class _CartasWidgetState extends State<CartasWidget> {
  String nombreOponente = "Cargando..."; // Nombre por defecto mientras carga
  int? cartaSeleccionadaIndexJugador;
  int? cartaSeleccionadaIndexOponente;
  int? organoSeleccionadoIndexJugador;
  int? organoSeleccionadoIndexOponente;

  bool modoSeleccionAvanzada = true;

  Baraja baraja = Baraja(cartass: Baraja.generarMazo());

  List<Carta> descartes = [];
  List<Organo> cartasJugadorOrganos = [];
  List<Organo> cartasOponenteOrganos = [];
  List<Carta> cartasJugador = [];
  List<Carta> cartasOponente = [];

  double cartaSize = 70;

  @override
  void initState() {
    super.initState();
    _obtenerNombreOponente();
    cartasJugador = baraja.robarVariasCartas(3);
    cartasOponente = baraja.robarVariasCartas(3);
    //  MusicaJuego.iniciarMusica();
  }

  Future<void> _obtenerNombreOponente() async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final nombre = data['results'][0]['name']['first']; // Extraemos el nombre
      setState(() {
        nombreOponente = nombre;
      });
    } else {
      setState(() {
        nombreOponente = "Desconocido"; // Si hay error, pone un nombre genérico
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Solo ejecutar la lógica del bot si es el turno del oponente, fuera del ciclo de construcción.
    if (!Juego.esTurnoJugador1) {
      _realizarAccionBot();
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black,
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/fondo_disease.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Functions.mazoDeCartas(
                                cartasJugador, baraja, descartes, setState),
                            SizedBox(width: 20),
                          ],
                        ),
                        SizedBox(height: 10),
                        // Rectángulo curvo con el nombre del oponente
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.purpleAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 5,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            nombreOponente, // Aquí debe ir el nombre del bot de la API
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        _construirFilaCartas(cartasOponente, false, false),
                        _construirFilaCartas(
                            cartasOponenteOrganos, false, true),
                        SizedBox(height: 180),
                        _construirFilaCartas(cartasJugadorOrganos, true, true),
                        _construirFilaCartas(cartasJugador, true, false),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Aquí movemos la lógica del bot fuera de `build` para evitar su ejecución innecesaria.
  void _realizarAccionBot() {
    Bot.realizarAccionBot(
      context,
      cartaSeleccionadaIndexJugador,
      cartaSeleccionadaIndexOponente,
      organoSeleccionadoIndexJugador,
      organoSeleccionadoIndexOponente,
      setState,
      seleccionarOrganoParaRobo,
      seleccionarOrgano,
      cartasJugador,
      cartasJugadorOrganos,
      cartasOponente,
      cartasOponenteOrganos,
      descartes,
      baraja,
    );
  }

  // Métodos originales que mencionaste (con los nombres exactos que me diste)
  Future<(int?, int?)> seleccionarOrgano() async {
    while (organoSeleccionadoIndexJugador == null ||
        organoSeleccionadoIndexOponente == null) {
      print("Esperando a que se seleccionen los órganos...");
      await Future.delayed(Duration(milliseconds: 100));
    }
    return (organoSeleccionadoIndexJugador!, organoSeleccionadoIndexOponente!);
  }

  Future<Organo?> seleccionarOrganoParaRobo() async {
    while (organoSeleccionadoIndexOponente == null) {
      print("Esperando a que el oponente seleccione un órgano...");
      await Future.delayed(Duration(milliseconds: 100));
    }
    return cartasOponenteOrganos[organoSeleccionadoIndexOponente!];
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
            child: _construirCarta(carta, index, esOrgano, esJugador),
          );
        }),
      ),
    );
  }

  Widget _construirCarta(
      Carta carta, int index, bool esOrgano, bool esJugador) {
    bool esSeleccionada = esOrgano
        ? (esJugador
            ? organoSeleccionadoIndexJugador == index
            : organoSeleccionadoIndexOponente == index)
        : (esJugador
            ? cartaSeleccionadaIndexJugador == index
            : cartaSeleccionadaIndexOponente == index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (modoSeleccionAvanzada || esJugador) {
            if (esOrgano) {
              if (esJugador) {
                organoSeleccionadoIndexJugador =
                    organoSeleccionadoIndexJugador == index ? null : index;
              } else {
                organoSeleccionadoIndexOponente =
                    organoSeleccionadoIndexOponente == index ? null : index;
              }
            } else {
              if (esJugador) {
                cartaSeleccionadaIndexJugador =
                    cartaSeleccionadaIndexJugador == index ? null : index;
              } else {
                cartaSeleccionadaIndexOponente =
                    cartaSeleccionadaIndexOponente == index ? null : index;
              }
            }
          }
        });
      },
      onLongPressStart: (details) {
        _mostrarMenuEmergente(context, carta, details.globalPosition);
      },
      child: esOrgano
          ? Functions.disenoOrgano(carta as Organo, esSeleccionada)
          : Functions.disenoCarta(carta, esSeleccionada, !esJugador),
    );
  }

  Widget _construirCartaOponente(Carta carta, int index, bool esOrgano) {
    bool esSeleccionada = esOrgano
        ? organoSeleccionadoIndexOponente == index
        : cartaSeleccionadaIndexOponente == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (modoSeleccionAvanzada) {
            if (esOrgano) {
              organoSeleccionadoIndexOponente = esSeleccionada ? null : index;
            } else {
              cartaSeleccionadaIndexOponente = esSeleccionada ? null : index;
            }
          }
        });
      },
      onLongPressStart: (details) {
        _mostrarMenuEmergente(context, carta, details.globalPosition);
      },
      child: esOrgano
          ? Functions.disenoOrgano(carta as Organo, esSeleccionada)
          : Functions.disenoCarta(carta, esSeleccionada, true),
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
              if (cartaSeleccionadaIndexJugador != null) {
                Juego.moverCartaADescartes(
                    cartasJugador, descartes, cartaSeleccionadaIndexJugador!);
              }
            });
          },
        ),
        PopupMenuItem(
          value: 'usar_carta',
          child: Text('Usar carta'),
          onTap: () async {
            setState(() {
              if (Juego.esTurnoJugador1) {
                Juego.realizarAccion(
                  context,
                  cartaSeleccionadaIndexJugador,
                  cartaSeleccionadaIndexOponente,
                  organoSeleccionadoIndexJugador,
                  organoSeleccionadoIndexOponente,
                  setState,
                  seleccionarOrganoParaRobo,
                  seleccionarOrgano,
                  cartasJugador,
                  cartasJugadorOrganos,
                  cartasOponente,
                  cartasOponenteOrganos,
                  descartes,
                  baraja,
                );
              }
            });
          },
        ),
      ],
    );
  }
}
