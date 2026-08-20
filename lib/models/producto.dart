class Producto {
  String id;
  String nombre;
  String codigo;
  String categoria;
  String sabor;
  String presentacion;
  double costoProveedor;
  double precioVenta;
  bool enStock;
  List<String> fotos;
  String proveedorNombre;
  String proveedorWhatsapp;
  String descripcion;
  DateTime fechaCreacion;

  Producto({
    required this.id,
    required this.nombre,
    this.codigo = '',
    required this.categoria,
    this.sabor = '',
    this.presentacion = '',
    this.costoProveedor = 0,
    this.precioVenta = 0,
    this.enStock = true,
    this.fotos = const [],
    this.proveedorNombre = '',
    this.proveedorWhatsapp = '',
    this.descripcion = '',
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'codigo': codigo,
      'categoria': categoria,
      'sabor': sabor,
      'presentacion': presentacion,
      'costoProveedor': costoProveedor,
      'precioVenta': precioVenta,
      'enStock': enStock,
      'fotos': fotos,
      'proveedorNombre': proveedorNombre,
      'proveedorWhatsapp': proveedorWhatsapp,
      'descripcion': descripcion,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Producto.fromMap(String id, Map<String, dynamic> map) {
    return Producto(
      id: id,
      nombre: map['nombre'] ?? '',
      codigo: map['codigo'] ?? '',
      categoria: map['categoria'] ?? '',
      sabor: map['sabor'] ?? '',
      presentacion: map['presentacion'] ?? '',
      costoProveedor: (map['costoProveedor'] ?? 0).toDouble(),
      precioVenta: (map['precioVenta'] ?? 0).toDouble(),
      enStock: map['enStock'] ?? true,
      fotos: List<String>.from(map['fotos'] ?? []),
      proveedorNombre: map['proveedorNombre'] ?? '',
      proveedorWhatsapp: map['proveedorWhatsapp'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.parse(map['fechaCreacion'])
          : DateTime.now(),
    );
  }
}
