import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../config.dart';
import '../models/producto.dart';
import '../services/cloudinary_service.dart';
import '../services/firestore_service.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;
  const ProductoFormScreen({super.key, this.producto});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  static const Color oliveGreen = Color(0xFF556B2F);

  final _nombreCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _costoCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _saborCtrl = TextEditingController();
  final _presentacionCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _proveedorNombreCtrl = TextEditingController();
  final _proveedorWhatsappCtrl = TextEditingController();

  String _categoria = AppConfig.categorias.first;
  bool _enStock = true;
  bool _guardando = false;
  List<String> _fotosExistentes = [];
  List<File> _fotosNuevas = [];

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    if (p != null) {
      _nombreCtrl.text = p.nombre;
      _codigoCtrl.text = p.codigo;
      _costoCtrl.text = p.costoProveedor.toString();
      _precioCtrl.text = p.precioVenta.toString();
      _saborCtrl.text = p.sabor;
      _presentacionCtrl.text = p.presentacion;
      _descripcionCtrl.text = p.descripcion;
      _proveedorNombreCtrl.text = p.proveedorNombre;
      _proveedorWhatsappCtrl.text = p.proveedorWhatsapp;
      _categoria = p.categoria;
      _enStock = p.enStock;
      _fotosExistentes = List.from(p.fotos);
    }
  }

  Future<void> _elegirFotos() async {
    final picker = ImagePicker();
    final archivos = await picker.pickMultiImage();
    if (archivos.isNotEmpty) {
      setState(() {
        _fotosNuevas.addAll(archivos.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _guardar() async {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el nombre del producto')),
      );
      return;
    }

    setState(() => _guardando = true);

    List<String> fotosSubidas = [];
    if (_fotosNuevas.isNotEmpty) {
      fotosSubidas = await CloudinaryService.subirVariasFotos(_fotosNuevas);
    }

    final todasLasFotos = [..._fotosExistentes, ...fotosSubidas];

    final producto = Producto(
      id: widget.producto?.id ?? const Uuid().v4(),
      nombre: _nombreCtrl.text.trim(),
      codigo: _codigoCtrl.text.trim(),
      categoria: _categoria,
      sabor: _saborCtrl.text.trim(),
      presentacion: _presentacionCtrl.text.trim(),
      costoProveedor: double.tryParse(_costoCtrl.text) ?? 0,
      precioVenta: double.tryParse(_precioCtrl.text) ?? 0,
      enStock: _enStock,
      fotos: todasLasFotos,
      proveedorNombre: _proveedorNombreCtrl.text.trim(),
      proveedorWhatsapp: _proveedorWhatsappCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      fechaCreacion: widget.producto?.fechaCreacion,
    );

    await FirestoreService.guardarProducto(producto);

    setState(() => _guardando = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _eliminar() async {
    if (widget.producto == null) return;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: const Text('Esta seguro de eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await FirestoreService.eliminarProducto(widget.producto!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.producto == null ? 'Nuevo producto' : 'Editar producto'),
        backgroundColor: oliveGreen,
        foregroundColor: Colors.white,
        actions: [
          if (widget.producto != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _eliminar,
            ),
        ],
      ),
      body: _guardando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fotos', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._fotosExistentes.map((url) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                          )),
                      ..._fotosNuevas.map((file) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
                          )),
                      InkWell(
                        onTap: _elegirFotos,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_a_photo),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre del producto', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codigoCtrl,
                    decoration: const InputDecoration(labelText: 'Codigo (opcional)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _categoria,
                    decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
                    items: AppConfig.categorias
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _categoria = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _saborCtrl,
                    decoration: const InputDecoration(labelText: 'Sabor', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _presentacionCtrl,
                    decoration: const InputDecoration(labelText: 'Presentacion (ej. 500ml)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descripcionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Descripcion', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _costoCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Costo proveedor', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _precioCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Precio de venta', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    activeColor: oliveGreen,
                    title: const Text('En stock'),
                    value: _enStock,
                    onChanged: (v) => setState(() => _enStock = v),
                  ),
                  const Divider(height: 32),
                  const Text('Proveedor', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _proveedorNombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre del proveedor', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _proveedorWhatsappCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'WhatsApp del proveedor', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: oliveGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Guardar producto', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
