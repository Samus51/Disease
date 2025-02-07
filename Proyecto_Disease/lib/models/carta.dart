// ignore_for_file: unnecessary_getters_setters

import 'package:flutter/material.dart';

enum TipoCarta { curacion, virus, especial, organo }

enum TipoOrgano { corazon, cerebro, hueso, estomago }

enum EstadoOrgano { muerto, infectado, sano, vacunado, inmune }

enum TipoEspecial {
  contagio,
  errorMedico,
  guanteLatex,
  ladronDeOrganos,
  transplante,
}

class Carta {
  TipoCarta _tipo;
  String _descripcion;
  String _organo;

  Carta({
    required TipoCarta tipo,
    required String descripcion,
    required String organo,
  })  : _tipo = tipo,
        _descripcion = descripcion,
        _organo = organo;

  TipoCarta get tipo => _tipo;

  set tipo(TipoCarta value) {
    _tipo = value;
  }

  String get descripcion => _descripcion;

  set descripcion(String value) {
    if (value.isEmpty) {
      throw ArgumentError("La descripción no puede estar vacía.");
    }
    _descripcion = value;
  }

  String get organo => _organo;

  set organo(String value) {
    if (value.isEmpty) {
      throw ArgumentError("El órgano no puede estar vacío.");
    }
    _organo = value;
  }

  // Método para obtener la imagen de la carta
  AssetImage obtenerImagen() {
    switch (_tipo) {
      case TipoCarta.organo:
        return _obtenerImagenOrgano();

      case TipoCarta.curacion:
        return _obtenerImagenCuracion();
      case TipoCarta.virus:
        return _obtenerImagenVirus();
      case TipoCarta.especial:
        return _obtenerImagenEspecial();
      // Imagen por defecto
    }
  }

  // // Método para aplicar curación
  // void cartaCuracion(Jugador jugador) {
  //   if (tipo == TipoCarta.curacion) {
  //     // Lógica para curar un órgano
  //     print('Usando carta de curación en $organo: $descripcion');

  //     // Seleccionar un órgano del jugador al que aplicar la curación
  //     String organoSeleccionado = jugador.seleccionarOrgano();

  //     // Verificar que el órgano seleccionado es del tipo adecuado
  //     if (organoSeleccionado.toLowerCase() == organo.toLowerCase()) {
  //       // Aplicar la curación al órgano del jugador
  //       jugador.aplicarCuracion(organoSeleccionado);
  //       print('Curación aplicada al órgano: $organoSeleccionado');
  //     } else {
  //       print(
  //           'No puedes curar el órgano $organoSeleccionado con esta carta. Debes seleccionar el órgano correspondiente.');
  //     }
  //   }
  // }

  // Método para cartas de tipo "virus"
  void cartaVirus() {
    if (tipo == TipoCarta.virus) {
      // Lógica para aplicar el virus
      print('Aplicando virus en $organo: $descripcion');
      // Aquí agregarías la lógica para aplicar el virus
    }
  }

  // Cargar imagen de curación

  AssetImage _obtenerImagenCuracion() {
    switch (_organo.toLowerCase()) {
      case 'cerebro':
        return AssetImage('assets/images/cura_cerebro.png');
      case 'corazon':
        return AssetImage('assets/images/cura_corazon.png');
      case 'estomago':
        return AssetImage('assets/images/cura_estomago.png');
      case 'hueso':
        return AssetImage('assets/images/cura_hueso.png');
      default:
        return AssetImage(
            'assets/images/carta_parte_trasera.png'); // Imagen por defecto
    }
  }

  // Cargar imagen de virus
  AssetImage _obtenerImagenVirus() {
    switch (_organo.toLowerCase()) {
      case 'cerebro':
        return AssetImage('assets/images/virus_cerebro.png');
      case 'corazon':
        return AssetImage('assets/images/virus_corazon.png');
      case 'estomago':
        return AssetImage('assets/images/virus_estomago.png');
      case 'hueso':
        return AssetImage('assets/images/virus_hueso.png');
      default:
        return AssetImage(
            'assets/images/carta_parte_trasera.png'); // Imagen por defecto
    }
  }

  // Cargar imagen de carta especial
  AssetImage _obtenerImagenEspecial() {
    // Aquí podemos añadir diferentes tipos de cartas especiales
    return AssetImage(
        'assets/images/especial_contagio.png'); // Imagen por defecto
  }

  String get descripcionCompleta => "$tipo: $descripcion (Órgano: $organo)";

  AssetImage _obtenerImagenOrgano() {
    switch (_organo.toLowerCase()) {
      case 'cerebro':
        return AssetImage('assets/images/organo_cerebro.png');
      case 'corazon':
        return AssetImage('assets/images/organo_corazon.png');
      case 'estomago':
        return AssetImage('assets/images/organo_estomago.png');
      case 'hueso':
        return AssetImage('assets/images/organo_hueso.png');
      default:
        return AssetImage(
            'assets/images/carta_parte_trasera.png'); // Imagen por defecto
    }
  }
}
