import 'package:disease/carta.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CartasApp());
}

class CartasApp extends StatelessWidget {
  const CartasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prueba de Cartas',
      home: Scaffold(
        appBar: AppBar(title: const Text('Prueba de Cartas')),
        body: const Padding(
          padding: EdgeInsets.all(10.0),
          child: CartasWidget(),
        ),
      ),
    );
  }
}

class CartasWidget extends StatefulWidget {
  const CartasWidget({super.key});

  @override
  State<CartasWidget> createState() => _CartasWidgetState();
}

class _CartasWidgetState extends State<CartasWidget> {
  List<Carta> cartasJugador = [
    Carta(
        tipo: TipoCarta.curacion,
        organo: "corazón",
        descripcion: "Curación para el corazón"),
    Carta(
        tipo: TipoCarta.virus,
        organo: "pulmón",
        descripcion: "Virus para el pulmón"),
    Carta(
        tipo: TipoCarta.especial,
        descripcion: "Intercambia una carta con el oponente"),
  ];

  List<Carta> cartasOponente = [
    Carta(
        tipo: TipoCarta.curacion,
        organo: "estómago",
        descripcion: "Curación para el estómago"),
    Carta(
        tipo: TipoCarta.virus,
        organo: "hígado",
        descripcion: "Virus para el hígado"),
  ];
  String? cartaSeleccionada;
  double cartaSize = 60;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCartasFila(cartasOponente, false),

        Expanded(
          child: Center(
            child: Container(
              width: 250,
              height: 250,
              color: Colors.blueGrey,
              child: Center(
                child: Text(
                  'Espacio central',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
        ),

        // Fila inferior (Cartas del jugador)
        _buildCartasFila(cartasJugador, true),
      ],
    );
  }

  Widget _buildCartasFila(List<Carta> cartas, bool esJugador) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(cartas.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: esJugador
                ? Draggable<String>(
                    data: index.toString(),
                    feedback: _buildCard(cartas[index], esJugador),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: _buildCard(cartas[index], esJugador),
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
                        return _buildCard(cartas[index], esJugador);
                      },
                    ),
                  )
                : _buildCard(cartas[index], esJugador),
          );
        }),
      ),
    );
  }

  Widget _buildCard(Carta carta, bool esJugador) {
    return GestureDetector(
      onTap: () {
        setState(() {
          cartaSeleccionada = carta.descripcionCompleta;
          cartaSize = cartaSize == 80 ? 150 : 70;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cartaSize,
        height: cartaSize * 1.4,
        decoration: BoxDecoration(
          color: esJugador ? Colors.blueAccent : Colors.redAccent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              carta.descripcionCompleta, // Mostrar el getter
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
