import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static final _productos = _db.collection('productos');

  static Stream<List<Producto>> obtenerProductos() {
    return _productos
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Producto.fromMap(doc.id, doc.data()))
            .toList());
  }

  static Future<void> guardarProducto(Producto producto) async {
    if (producto.id.isEmpty) {
      await _productos.add(producto.toMap());
    } else {
      await _productos.doc(producto.id).set(producto.toMap());
    }
  }

  static Future<void> actualizarProducto(String id, Map<String, dynamic> datos) async {
    await _productos.doc(id).update(datos);
  }

  static Future<void> eliminarProducto(String id) async {
    await _productos.doc(id).delete();
  }

  static Future<List<String>> obtenerProveedoresSugeridos() async {
    final snapshot = await _productos.get();
    final nombres = <String>{};
    for (var doc in snapshot.docs) {
      final nombre = doc.data()['proveedorNombre'] as String?;
      if (nombre != null && nombre.isNotEmpty) {
        nombres.add(nombre);
      }
    }
    return nombres.toList();
  }

  static Future<String?> obtenerWhatsappProveedor(String nombreProveedor) async {
    final snapshot = await _productos
        .where('proveedorNombre', isEqualTo: nombreProveedor)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data()['proveedorWhatsapp'] as String?;
    }
    return null;
  }
}
