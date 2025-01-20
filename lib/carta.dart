// Definimos el enum para los tipos de carta
enum TipoCarta { curacion, virus, especial }

// Definimos el enum para los tipos especiales de carta
enum TipoEspecial {
  contagio,
  guanteLatex,
  errorMedico,
  transplante,
  ladronDeOrganos
}

class Carta {
  // Campos privados
  TipoCarta _tipo;
  String? _organo;
  String _descripcion;
  TipoEspecial? _tipoEspecial;

  // Constructor
  Carta({
    required TipoCarta tipo,
    String? organo,
    TipoEspecial? tipoEspecial,
    required String descripcion,
  })  : _tipo = tipo,
        _organo = organo,
        _descripcion = descripcion,
        _tipoEspecial = tipoEspecial;

  // Getter para 'tipo'
  TipoCarta get tipo => _tipo;

  // Getter para 'tipoEspecial'
  TipoEspecial? get tipoEspecial => _tipoEspecial;

  // Setter para 'tipo' con validación
  set tipo(TipoCarta value) {
    _tipo = value;
  }

  // Getter para 'organo' (puede ser nulo)
  String? get organo => _organo;

  // Setter para 'organo' (opcional)
  set organo(String? value) {
    if (_tipo != TipoCarta.especial && value == null) {
      throw ArgumentError(
          "El órgano no puede ser nulo si el tipo no es 'especial'.");
    }
    _organo = value;
  }

  // Getter para 'descripcion'
  String get descripcion => _descripcion;

  // Setter para 'descripcion'
  set descripcion(String value) {
    if (value.isEmpty) {
      throw ArgumentError("La descripción no puede estar vacía.");
    }
    _descripcion = value;
  }

  // Getter calculado: descripción completa de la carta
  String get descripcionCompleta {
    if (_organo != null) {
      return "$_tipo: $_descripcion (Órgano: $_organo)";
    } else {
      return "$_tipo: $_descripcion";
    }
  }
}
