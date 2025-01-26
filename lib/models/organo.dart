import 'package:disease/models/carta.dart';

class Organo extends Carta {
  TipoOrgano tipoOrgano;
  EstadoOrgano estado;

  Organo({
    required this.tipoOrgano,
    this.estado = EstadoOrgano.sano,
    required super.descripcion,
    required super.tipo,
    required super.organo,
  });

  // Método para obtener el estado del órgano
  String get estadoOrgano => estado.toString().split('.').last;

  // Método para cambiar el estado del órgano
  void cambiarEstado(EstadoOrgano nuevoEstado) {
    estado = nuevoEstado;
  }
}
