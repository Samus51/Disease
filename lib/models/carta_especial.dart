import 'package:disease/models/carta.dart';
import 'package:flutter/material.dart';

class CartaEspecial extends Carta {
  final TipoEspecial _tipoEspecial;

  CartaEspecial({
    required TipoEspecial tipoEspecial,
    required super.descripcion,
  })  : _tipoEspecial = tipoEspecial,
        super(
          tipo: TipoCarta.especial,
          organo: "", // No hay órgano en las cartas especiales
        );

  TipoEspecial get tipoEspecial => _tipoEspecial;

  @override
  String get descripcionCompleta =>
      "$tipo (Especial - $tipoEspecial): $descripcion";

  @override
  AssetImage obtenerImagen() {
    // Aquí puedes asignar las imágenes según el tipoEspecial
    switch (_tipoEspecial) {
      case TipoEspecial.contagio:
        return AssetImage('assets/images/especial_contagio.png');
      case TipoEspecial.errorMedico:
        return AssetImage('assets/images/especial_error_medico.png');
      case TipoEspecial.guanteLatex:
        return AssetImage('assets/images/especial_guante_latex.png');
      case TipoEspecial.ladronDeOrganos:
        return AssetImage('assets/images/especial_robo.png');
      case TipoEspecial.transplante:
        return AssetImage('assets/images/especial_cambio_organo.png');
      // Imagen por defecto
    }
  }
}
