import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/producto.dart';
import '../services/firestore_service.dart';
import 'producto_form.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String _busqueda = '';
  String _categoriaFiltro = 'Todas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset('assets/icon/Logo.png', width: 32, height: 32),
            ),
            const SizedBox(width: 10),
            const Text('Kefify - Mis productos'),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por codigo o nombre',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _busqueda = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Producto>>(
              stream: FirestoreService.obtenerProductos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No hay productos todavia.\nToca + para agregar uno.',
                        textAlign: TextAlign.center),
                  );
                }
                var productos = snapshot.data!.where((p) {
                  final coincideBusqueda = _busqueda.isEmpty ||
                      p.nombre.toLowerCase().contains(_busqueda) ||
                      p.codigo.toLowerCase().contains(_busqueda);
                  final coincideCategoria = _categoriaFiltro == 'Todas' ||
                      p.categoria == _categoriaFiltro;
                  return coincideBusqueda && coincideCategoria;
                }).toList();

                if (productos.isEmpty) {
                  return const Center(child: Text('No se encontraron productos'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: producto.fotos.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  producto.fotos.first,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) =>
                                      const Icon(Icons.image_not_supported),
                                ),
                              )
                            : const Icon(Icons.image, size: 40),
                        title: Text(producto.nombre),
                        subtitle: Text(
                            '${producto.categoria} | \$${producto.precioVenta.toStringAsFixed(0)}\n'
                            '${producto.enStock ? "En stock" : "Agotado"}'),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.phone, color: Colors.green),
                          onPressed: producto.proveedorWhatsapp.isEmpty
                              ? null
                              : () => _contactarProveedor(producto.proveedorWhatsapp),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductoFormScreen(producto: producto),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductoFormScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _contactarProveedor(String numero) async {
    final numeroLimpio = numero.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://wa.me/$numeroLimpio');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
