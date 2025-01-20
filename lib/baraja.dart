import 'package:disease/carta.dart';

class Baraja {
  final List<Carta> _cartas;

  // Constructor
  Baraja({required List<Carta> cartas}) : _cartas = cartas;

  static List<Carta> generarMazo() {
    List<Carta> mazo = [];

    // Definir los órganos disponibles
    List<String> organos = ["Corazón", "Cerebro", "Huesos", "Estómago"];

    // Generar 5 cartas de virus y 5 de curación para cada órgano
    for (String organo in organos) {
      // 5 cartas de virus para cada órgano
      for (int i = 0; i < 4; i++) {
        mazo.add(Carta(
            tipo: TipoCarta.virus,
            organo: organo,
            descripcion: "Virus para el $organo"));
      }

      // 5 cartas de curación para cada órgano
      for (int i = 0; i < 4; i++) {
        mazo.add(Carta(
            tipo: TipoCarta.curacion,
            organo: organo,
            descripcion: "Curación para el $organo"));
      }

      // 5 cartas de órgano (como ejemplo puedes agregar cartas de órgano específicas)
      for (int i = 0; i < 5; i++) {
        mazo.add(Carta(
            tipo: TipoCarta.virus,
            organo: organo,
            descripcion: "Órgano de $organo"));
      }
    }

    // Generar cartas especiales
    // Tipo Contagio 2 cartas
    for (int i = 0; i < 2; i++) {
      mazo.add(Carta(
          tipo: TipoCarta.especial,
          tipoEspecial: TipoEspecial.contagio,
          descripcion:
              "Traslada tantos virus como puedas de tus órganos infectados a los órganos de los demás jugadores."));
    }

    // Tipo Guante de Látex y Error Médico con 1 carta cada uno
    mazo.add(Carta(
        tipo: TipoCarta.especial,
        tipoEspecial: TipoEspecial.guanteLatex,
        descripcion:
            'Todos los jugadores oponentes sueltan sus cartas y roban una nueva mano'));
    mazo.add(Carta(
        tipo: TipoCarta.especial,
        tipoEspecial: TipoEspecial.errorMedico,
        descripcion:
            'Cambia el cuerpo y mano por completo del jugador por el del oponente'));

    // Tipo Transplante y Ladrón de Órganos con 3 cartas cada uno
    for (int i = 0; i < 3; i++) {
      mazo.add(Carta(
          tipo: TipoCarta.especial,
          tipoEspecial: TipoEspecial.transplante,
          descripcion:
              "Carta especial que cambia un organo del jugador por otro del oponente"));
      mazo.add(Carta(
          tipo: TipoCarta.especial,
          tipoEspecial: TipoEspecial.ladronDeOrganos,
          descripcion: "Roba un órgano del Oponente"));
    }

    // Mezclar el mazo para que las cartas no estén ordenadas
    mazo.shuffle();

    return mazo;
  }

  // Getter para acceder a las cartas
  List<Carta> get cartas => List.unmodifiable(_cartas);

  // Método para contar las cartas por tipo
  void contarCartas() {
    int contadorVirus = 0;
    int contadorCuracion = 0;
    int contadorEspecial = 0;
    int contadorOrgano = 0;

    for (var carta in _cartas) {
      if (carta.tipo == TipoCarta.virus) {
        contadorVirus++;
      } else if (carta.tipo == TipoCarta.curacion) {
        contadorCuracion++;
      } else if (carta.tipo == TipoCarta.especial) {
        contadorEspecial++;
      }
      // En caso de que tenga órgano en su tipo
      if (carta.organo != null) {
        contadorOrgano++;
      }
    }

    print("Cartas de tipo 'Virus': $contadorVirus");
    print("Cartas de tipo 'Curación': $contadorCuracion");
    print("Cartas de tipo 'Especial': $contadorEspecial");
    print("Cartas de tipo 'Órgano': $contadorOrgano");
    print("Total de cartas: ${_cartas.length}");
  }
}

void main() {
  // Generar mazo
  List<Carta> mazo = Baraja.generarMazo();

  // Crear la baraja
  Baraja baraja = Baraja(cartas: mazo);

  // Contar cartas
  baraja.contarCartas();
}
