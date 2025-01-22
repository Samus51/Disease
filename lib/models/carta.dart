// ignore_for_file: unnecessary_getters_setters

import 'package:flutter/material.dart';

enum TipoCarta { curacion, virus, especial }

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
      case TipoCarta.curacion:
        return _obtenerImagenCuracion();
      case TipoCarta.virus:
        return _obtenerImagenVirus();
      case TipoCarta.especial:
        return _obtenerImagenEspecial();
      // Imagen por defecto
    }
  }

  // Cargar imagen de curación
  AssetImage _obtenerImagenCuracion() {
    switch (_organo.toLowerCase()) {
      case 'cerebro':
        return AssetImage('assets/images/cura_cerebro.png');
      case 'corazón':
        return AssetImage('assets/images/cura_corazon.png');
      case 'estómago':
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
      case 'corazón':
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
}
