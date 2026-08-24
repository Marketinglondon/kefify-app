class Producto {
  String id;
  String nombre;
  String nombreEs;
  String codigo;
  String categoria;
  String sabor;
  String saborEs;
  String presentacion;
  String descripcion;
  String descripcionEs;
  String ingredientes;
  String ingredientesEs;
  String nutriEnergiaKJ;
  String nutriEnergiaKcal;
  String nutriGrasa;
  String nutriGrasaSat;
  String nutriCarbo;
  String nutriAzucar;
  String nutriFibra;
  String nutriProteina;
  String nutriSal;
  double costoProveedor;
  double precioVenta;
  double precioVentaCOP;
  bool enStock;
  List<String> fotos;
  String proveedorNombre;
  String proveedorWhatsapp;
  DateTime fechaCreacion;

  Producto({
    required this.id,
    required this.nombre,
    this.nombreEs = '',
    this.codigo = '',
    required this.categoria,
    this.sabor = '',
    this.saborEs = '',
    this.presentacion = '',
    this.descripcion = '',
    this.descripcionEs = '',
    this.ingredientes = '',
    this.ingredientesEs = '',
    this.nutriEnergiaKJ = '',
    this.nutriEnergiaKcal = '',
    this.nutriGrasa = '',
    this.nutriGrasaSat = '',
    this.nutriCarbo = '',
    this.nutriAzucar = '',
    this.nutriFibra = '',
    this.nutriProteina = '',
    this.nutriSal = '',
    this.costoProveedor = 0,
    this.precioVenta = 0,
    this.precioVentaCOP = 0,
    this.enStock = true,
    this.fotos = const [],
    this.proveedorNombre = '',
    this.proveedorWhatsapp = '',
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'nombreEs': nombreEs,
      'codigo': codigo,
      'categoria': categoria,
      'sabor': sabor,
      'saborEs': saborEs,
      'presentacion': presentacion,
      'descripcion': descripcion,
      'descripcionEs': descripcionEs,
      'ingredientes': ingredientes,
      'ingredientesEs': ingredientesEs,
      'nutriEnergiaKJ': nutriEnergiaKJ,
      'nutriEnergiaKcal': nutriEnergiaKcal,
      'nutriGrasa': nutriGrasa,
      'nutriGrasaSat': nutriGrasaSat,
      'nutriCarbo': nutriCarbo,
      'nutriAzucar': nutriAzucar,
      'nutriFibra': nutriFibra,
      'nutriProteina': nutriProteina,
      'nutriSal': nutriSal,
      'costoProveedor': costoProveedor,
      'precioVenta': precioVenta,
      'precioVentaCOP': precioVentaCOP,
      'enStock': enStock,
      'fotos': fotos,
      'proveedorNombre': proveedorNombre,
      'proveedorWhatsapp': proveedorWhatsapp,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Producto.fromMap(String id, Map<String, dynamic> map) {
    return Producto(
      id: id,
      nombre: map['nombre'] ?? '',
      nombreEs: map['nombreEs'] ?? '',
      codigo: map['codigo'] ?? '',
      categoria: map['categoria'] ?? '',
      sabor: map['sabor'] ?? '',
      saborEs: map['saborEs'] ?? '',
      presentacion: map['presentacion'] ?? '',
      descripcion: map['descripcion'] ?? '',
      descripcionEs: map['descripcionEs'] ?? '',
      ingredientes: map['ingredientes'] ?? '',
      ingredientesEs: map['ingredientesEs'] ?? '',
      nutriEnergiaKJ: map['nutriEnergiaKJ'] ?? '',
      nutriEnergiaKcal: map['nutriEnergiaKcal'] ?? '',
      nutriGrasa: map['nutriGrasa'] ?? '',
      nutriGrasaSat: map['nutriGrasaSat'] ?? '',
      nutriCarbo: map['nutriCarbo'] ?? '',
      nutriAzucar: map['nutriAzucar'] ?? '',
      nutriFibra: map['nutriFibra'] ?? '',
      nutriProteina: map['nutriProteina'] ?? '',
      nutriSal: map['nutriSal'] ?? '',
      costoProveedor: (map['costoProveedor'] ?? 0).toDouble(),
      precioVenta: (map['precioVenta'] ?? 0).toDouble(),
      precioVentaCOP: (map['precioVentaCOP'] ?? 0).toDouble(),
      enStock: map['enStock'] ?? true,
      fotos: List<String>.from(map['fotos'] ?? []),
      proveedorNombre: map['proveedorNombre'] ?? '',
      proveedorWhatsapp: map['proveedorWhatsapp'] ?? '',
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.parse(map['fechaCreacion'])
          : DateTime.now(),
    );
  }
}
