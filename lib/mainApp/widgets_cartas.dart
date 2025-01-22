import 'package:flutter/material.dart';

import '../models/carta.dart';
import '../models/carta_especial.dart';

class CartasWidget extends StatefulWidget {
  const CartasWidget({super.key});

  @override
  State<CartasWidget> createState() => _CartasWidgetState();
}

class _CartasWidgetState extends State<CartasWidget> {
  // Declaramos cartaSeleccionada para almacenar la carta seleccionada
  String? cartaSeleccionada;

  // Lista de cartas del jugador
  List<Carta> cartasJugador = [
    Carta(
        tipo: TipoCarta.curacion,
        organo: "corazón",
        descripcion: "Curación para el corazón"),
    Carta(
        tipo: TipoCarta.virus,
        organo: "cerebro",
        descripcion: "Virus para el cerebro"),
    CartaEspecial(
        tipoEspecial: TipoEspecial.contagio,
        descripcion: "Intercambia una carta con el oponente"),
  ];

  // Lista de cartas del oponente
  List<Carta> cartasOponente = [
    Carta(
        tipo: TipoCarta.curacion,
        organo: "estómago",
        descripcion: "Curación para el estómago"),
    Carta(
        tipo: TipoCarta.virus,
        organo: "estomago",
        descripcion: "Virus para el estomago"),
  ];

  double cartaSize = 70;

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCartasFila(cartasOponente, false),
        _buildCartasFila(cartasJugador, true),
      ],
    );
  }

  // Método para construir las filas de cartas
// Método para construir las filas de cartas
  Widget _buildCartasFila(List<Carta> cartas, bool esJugador) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(cartas.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Draggable<String>(
              data: index.toString(),
              feedback: _buildCard(
                  cartas[index], index, esJugador), // Pasamos index aquí
              childWhenDragging: Opacity(
                opacity: 0.5,
                child: _buildCard(cartas[index], index,
                    esJugador), // Pasamos index aquí también
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
                  return _buildCard(cartas[index], index,
                      esJugador); // Pasamos index aquí también
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  int? cartaSeleccionadaIndex; // Indice de la carta seleccionada

  Widget _buildCard(Carta carta, int index, bool esJugador) {
    bool esSeleccionada = cartaSeleccionadaIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          cartaSeleccionada = carta.descripcionCompleta;
          cartaSeleccionadaIndex = esSeleccionada
              ? null
              : index; // Solo cambia la carta seleccionada
          cartaSize = esSeleccionada ? 70 : 150; // Cambia solo la seleccionada
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cartaSize,
        height: cartaSize * 1.4,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: carta.obtenerImagen(), // Obtener la imagen de la carta
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
        ),
      ),
    );
  }
}
