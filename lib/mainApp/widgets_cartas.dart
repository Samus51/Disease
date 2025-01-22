import 'package:flutter/material.dart';

import '../models/carta.dart';
import '../models/carta_especial.dart';

class CartasWidget extends StatefulWidget {
  const CartasWidget({super.key});

  @override
  State<CartasWidget> createState() => _CartasWidgetState();
}

class _CartasWidgetState extends State<CartasWidget> {
  // Lista de cartas del jugador
    String? cartaSeleccionada;

  List<Carta> cartasJugador = [
    Carta(tipo: TipoCarta.curacion, organo: "corazón", descripcion: "Curación para el corazón"),
    Carta(tipo: TipoCarta.virus, organo: "cerebro", descripcion: "Virus para el cerebro"),
    CartaEspecial(tipoEspecial: TipoEspecial.contagio, descripcion: "Intercambia una carta con el oponente"),
  ];

  List<Carta> cartasJugadorOrganos = [
    Carta(tipo: TipoCarta.organo, organo: "corazón", descripcion: "Curación para el corazón"),
    Carta(tipo: TipoCarta.organo, organo: "hueso", descripcion: "Curación para el hueso"),
    Carta(tipo: TipoCarta.organo, organo: "hueso", descripcion: "Organo hueso"),
    Carta(tipo: TipoCarta.organo, organo: "estomago", descripcion: "Organo hueso"),

  ];

  List<Carta> cartasOponenteOrganos = [
    Carta(tipo: TipoCarta.organo, organo: "corazón", descripcion: "Curación para el corazón"),
    Carta(tipo: TipoCarta.organo, organo: "cerebro", descripcion: "Organo hueso"),
    Carta(tipo: TipoCarta.organo, organo: "hueso", descripcion: "Organo hueso"),
    Carta(tipo: TipoCarta.organo, organo: "estomago", descripcion: "Organo hueso"),

  ];

  // Lista de cartas del oponente
  List<Carta> cartasOponente = [
    Carta(tipo: TipoCarta.curacion, organo: "estómago", descripcion: "Curación para el estómago"),
    Carta(tipo: TipoCarta.virus, organo: "estomago", descripcion: "Virus para el estomago"),
    CartaEspecial(tipoEspecial: TipoEspecial.errorMedico, descripcion: "Intercambia una carta con el oponente"),
  ];

  double cartaSize = 70;

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Fila con el mazo de cartas alineado a la izquierda y las cartas del oponente centradas
        Row(
          mainAxisAlignment: MainAxisAlignment.start, // Alineación a la izquierda para el mazo
          children: [
            _mazoDeCartas(), // Mazo de cartas (alineado a la izquierda)
            SizedBox(width: 20), // Espacio entre el mazo y las cartas del oponente
          ],
        ),
        _construirFilaCartas(cartasOponente, false), // Cartas del oponente (centradas)
        _construirFilaCartas(cartasOponenteOrganos, false), // Cartas del oponente (centradas)

        // Cartas del jugador en la parte inferior
        SizedBox(height: 200), // Espaciado entre las cartas del oponente y las del jugador
        _construirFilaCartas(cartasJugadorOrganos, true), // Organos del jugador
        _construirFilaCartas(cartasJugador, true), // Cartas del jugador
      ],
    );
  }

  // Método para construir las filas de cartas
  Widget _construirFilaCartas(List<Carta> cartas, bool esJugador) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Alineación centrada horizontalmente
        children: List.generate(cartas.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Draggable<String>(
              data: index.toString(),
              feedback: _construirCarta(cartas[index], index, esJugador),
              childWhenDragging: Opacity(
                opacity: 0.5,
                child: _construirCarta(cartas[index], index, esJugador),
              ),
              child: DragTarget<String>(
                onAcceptWithDetails: (details) {
                  setState(() {
                    final draggedIndex = int.parse(details.data);
                    final temp = cartas[index];
                    cartas[index] = cartas[draggedIndex];
                    cartas[draggedIndex] = temp;
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return _construirCarta(cartas[index], index, esJugador);
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  int? cartaSeleccionadaIndex;

Widget _construirCarta(Carta carta, int index, bool esJugador) {
  bool esSeleccionada = cartaSeleccionadaIndex == index;

  return GestureDetector(
    onTap: () {
      setState(() {
        cartaSeleccionada = carta.descripcionCompleta;
        cartaSeleccionadaIndex = esSeleccionada ? null : index;
        cartaSize = esSeleccionada ? 70 : 150;
      });
    },
    onLongPressStart: (details) {
      // Mostrar el menú emergente al hacer un toque largo
      _mostrarMenuEmergente(context, carta, details.globalPosition);
    },
    child: Draggable<String>(
      data: index.toString(),
      feedback: _disenoCarta(carta),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _disenoCarta(carta),
      ),
      child: DragTarget<String>(
        onAcceptWithDetails: (details) {
          setState(() {
            final draggedIndex = int.parse(details.data);
            final temp = cartasJugador[index];
            cartasJugador[index] = cartasJugador[draggedIndex];
            cartasJugador[draggedIndex] = temp;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return _disenoCarta(carta);
        },
      ),
    ),
  );
}

Widget _disenoCarta(Carta carta) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: cartaSize,
    height: cartaSize * 1.4,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: carta.obtenerImagen(),
        fit: BoxFit.cover,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

void _mostrarMenuEmergente(BuildContext context, Carta carta, Offset position) async {
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

  await showMenu(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      overlay.size.width - position.dx,
      overlay.size.height - position.dy,
    ),
    color: Colors.transparent,
    items: [
      PopupMenuItem<int>(
        value: 1,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 2,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(Icons.remove, color: Colors.white),
          ),
        ),
      ),
    ],
  ).then((value) {
    if (value == 1) {
      print('Acción 1 seleccionada para la carta ${carta.descripcionCompleta}');
    } else if (value == 2) {
      print('Acción 2 seleccionada para la carta ${carta.descripcionCompleta}');
    }
  });
}


  // Modificación de _mazoDeCartas para alinearlo horizontalmente a la izquierda
  _mazoDeCartas() {
    return SizedBox(
      width: 80, // Ancho del SizedBox para limitar el tamaño de la pila
      height: 100, // Alto del SizedBox para limitar el tamaño de la pila
      child: Stack(
        alignment: Alignment.centerLeft, // Alinea las cartas a la izquierda
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
    );
  }
}
