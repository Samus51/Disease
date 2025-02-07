// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:disease/models/bot.dart';
import 'package:disease/models/musica_juego.dart';
import 'package:disease/screens/home.dart';
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
  String nombreOponente = "Cargando...";
  int? cartaSeleccionadaIndexJugador;
  int? cartaSeleccionadaIndexOponente;
  int? organoSeleccionadoIndexJugador;
  int? organoSeleccionadoIndexOponente;
  bool jugadorGana = false;
  bool modoSeleccionAvanzada = true;
  bool oponenteGana = false;
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
    MusicaJuego.iniciarMusica();
  }

  void _mostrarDialogoResultado(bool jugadorEsGanador) {
    // Mostrar el diálogo de victoria/derrota
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(jugadorEsGanador ? "¡Ganador!" : "¡Derrota!"),
          content: Text(jugadorEsGanador
              ? "¡El Jugador ha ganado la partida!"
              : "¡El Oponente ha ganado la partida!"),
          actions: [
            TextButton(
              onPressed: () {
                // Cerrar el diálogo
                Navigator.of(context).pop();

                // Luego de cerrar el diálogo, hacer la navegación
                _reiniciarPartida();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => const HomeScreen()));
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> mandarMensajeFin(BuildContext context) async {
    // Verifica si TODOS los órganos del jugador están en buen estado
    if (cartasJugadorOrganos.length == 4) {
      jugadorGana = cartasJugadorOrganos.every(
        (organo) =>
            organo.estado != EstadoOrgano.infectado &&
            organo.estado != EstadoOrgano.muerto,
      );
    }
    if (cartasOponenteOrganos.length == 4) {
      // Verifica si TODOS los órganos del oponente están en buen estado
      oponenteGana = cartasOponenteOrganos.every(
        (organo) =>
            organo.estado != EstadoOrgano.infectado &&
            organo.estado != EstadoOrgano.muerto,
      );
    }
    // Mostrar el contenido de las cartas del jugador para depuración
    print("Cartas del Jugador:");
    cartasJugadorOrganos.forEach((organo) {
      print("Organo: ${organo.descripcionCompleta}, Estado: ${organo.estado}");
    });

    // Mostrar el contenido de las cartas del oponente para depuración
    print("Cartas del Oponente:");
    cartasOponenteOrganos.forEach((organo) {
      print("Organo: ${organo.descripcionCompleta}, Estado: ${organo.estado}");
    });

    // Si el jugador tiene todos los órganos en buen estado o el oponente,
    // entonces se determina el ganador
    if (jugadorGana || oponenteGana) {
      bool jugadorEsGanador = jugadorGana;

      // Actualizar estadísticas
      Juego.actualizarEstadisticas(jugadorEsGanador);

      // Detener música y reproducir la correspondiente
      MusicaJuego.detenerMusica();

      if (jugadorEsGanador) {
        // Si el jugador gana
        print("El Jugador ha ganado la partida.");
        MusicaJuego.iniciarMusicaWin();
      } else {
        // Si el oponente gana
        print("El Oponente ha ganado la partida.");
        MusicaJuego.iniciarMusicaDerrota();
      }

      // Mostrar el diálogo de victoria o derrota
      _mostrarDialogoResultado(jugadorEsGanador);
    }
  }

  Future<void> _obtenerNombreOponente() async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final nombre = data['results'][0]['name']['first'];
      setState(() {
        nombreOponente = nombre;
      });
    } else {
      setState(() {
        nombreOponente = "Desconocido";
      });
    }
  }

  void _reiniciarPartida() {
    setState(() {
      cartasJugador = baraja.robarVariasCartas(3);
      cartasOponente = baraja.robarVariasCartas(3);
      cartasJugadorOrganos.clear();
      cartasOponenteOrganos.clear();
      cartaSeleccionadaIndexJugador = null;
      cartaSeleccionadaIndexOponente = null;
      organoSeleccionadoIndexJugador = null;
      organoSeleccionadoIndexOponente = null;
      nombreOponente = "Cargando...";
      Juego.contAccion = 0;
      Juego.contDescartes = 0;
      Juego.esTurnoJugador1 = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!Juego.esTurnoJugador1) {
      Juego.contAccion = 0;
      Juego.contDescartes = 0;
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
                            mazoDeCartas(cartasJugador, baraja, descartes),
                            SizedBox(width: 250),
                            FloatingActionButton(
                              onPressed: _mostrarDialogoSalida,
                              backgroundColor: Colors.purple,
                              child:
                                  Icon(Icons.exit_to_app, color: Colors.black),
                            ),
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
                            nombreOponente,
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

  Widget mazoDeCartas(
      List<Carta> cartasJugador, Baraja baraja, List<Carta> descartes) {
    return SizedBox(
      width: 80,
      height: 100,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (cartasJugador.length < 3) {
              if (baraja.cartas.isEmpty) {
                baraja.reponerCartas(descartes);
                baraja.cartas.shuffle();
                descartes.clear();
              }

              Carta cartaRobada = baraja.cartas.removeAt(0);
              cartasJugador.add(cartaRobada);
              print("Carta añadida: ${cartaRobada.descripcion}");
            } else {
              print("Ya tienes 3 cartas en mano. No puedes robar más.");
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

  void _mostrarDialogoSalida() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("¿Salir de la partida?"),
          content: Text("Si sales, contarás como una derrota."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Juego.actualizarEstadisticas(false);

                _reiniciarPartida();
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => const HomeScreen()));
              },
              child: Text("Salir", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

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
    mandarMensajeFin(context);
  }

  Future<(int?, int?)> seleccionarOrgano() async {
    while (organoSeleccionadoIndexJugador == null &&
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
            : esJugador
                ? Functions.disenoCarta(carta, esSeleccionada, !esJugador)
                : _construirCartaOponente(carta, index, esOrgano));
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
                mandarMensajeFin(context); // Verifica si alguien ganó
              }
            });
          },
        ),
      ],
    );
  }
}
