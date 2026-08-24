import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  final _nombreEsCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _costoCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _precioCOPCtrl = TextEditingController();
  final _saborCtrl = TextEditingController();
  final _saborEsCtrl = TextEditingController();
  final _presentacionCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _descripcionEsCtrl = TextEditingController();
  final _ingredientesCtrl = TextEditingController();
  final _ingredientesEsCtrl = TextEditingController();
  final _proveedorNombreCtrl = TextEditingController();
  final _proveedorWhatsappCtrl = TextEditingController();

  final _nutriEnergiaKJCtrl = TextEditingController();
  final _nutriEnergiaKcalCtrl = TextEditingController();
  final _nutriGrasaCtrl = TextEditingController();
  final _nutriGrasaSatCtrl = TextEditingController();
  final _nutriCarboCtrl = TextEditingController();
  final _nutriAzucarCtrl = TextEditingController();
  final _nutriFibraCtrl = TextEditingController();
  final _nutriProteinaCtrl = TextEditingController();
  final _nutriSalCtrl = TextEditingController();

  final _nombreFocus = FocusNode();
  final _descripcionFocus = FocusNode();
  final _ingredientesFocus = FocusNode();
  final _saborFocus = FocusNode();

  String _categoria = AppConfig.categorias.first;
  bool _enStock = true;
  bool _guardando = false;
  bool _traduciendoNombre = false;
  bool _traduciendoDesc = false;
  bool _traduciendoIngr = false;
  bool _traduciendoSabor = false;
  List<String> _fotosExistentes = [];
  List<File> _fotosNuevas = [];

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    if (p != null) {
      _nombreCtrl.text = p.nombre;
      _nombreEsCtrl.text = p.nombreEs;
      _codigoCtrl.text = p.codigo;
      _costoCtrl.text = p.costoProveedor.toString();
      _precioCtrl.text = p.precioVenta.toString();
      _precioCOPCtrl.text = p.precioVentaCOP.toString();
      _saborCtrl.text = p.sabor;
      _saborEsCtrl.text = p.saborEs;
      _presentacionCtrl.text = p.presentacion;
      _descripcionCtrl.text = p.descripcion;
      _descripcionEsCtrl.text = p.descripcionEs;
      _ingredientesCtrl.text = p.ingredientes;
      _ingredientesEsCtrl.text = p.ingredientesEs;
      _nutriEnergiaKJCtrl.text = p.nutriEnergiaKJ;
      _nutriEnergiaKcalCtrl.text = p.nutriEnergiaKcal;
      _nutriGrasaCtrl.text = p.nutriGrasa;
      _nutriGrasaSatCtrl.text = p.nutriGrasaSat;
      _nutriCarboCtrl.text = p.nutriCarbo;
      _nutriAzucarCtrl.text = p.nutriAzucar;
      _nutriFibraCtrl.text = p.nutriFibra;
      _nutriProteinaCtrl.text = p.nutriProteina;
      _nutriSalCtrl.text = p.nutriSal;
      _proveedorNombreCtrl.text = p.proveedorNombre;
      _proveedorWhatsappCtrl.text = p.proveedorWhatsapp;
      _categoria = p.categoria;
      _enStock = p.enStock;
      _fotosExistentes = List.from(p.fotos);
    }

    _nombreFocus.addListener(() {
      if (!_nombreFocus.hasFocus) {
        _autoTraducir(_nombreCtrl, _nombreEsCtrl, (v) => setState(() => _traduciendoNombre = v));
      }
    });
    _descripcionFocus.addListener(() {
      if (!_descripcionFocus.hasFocus) {
        _autoTraducir(_descripcionCtrl, _descripcionEsCtrl, (v) => setState(() => _traduciendoDesc = v));
      }
    });
    _ingredientesFocus.addListener(() {
      if (!_ingredientesFocus.hasFocus) {
        _autoTraducir(_ingredientesCtrl, _ingredientesEsCtrl, (v) => setState(() => _traduciendoIngr = v));
      }
    });
    _saborFocus.addListener(() {
      if (!_saborFocus.hasFocus) {
        _autoTraducir(_saborCtrl, _saborEsCtrl, (v) => setState(() => _traduciendoSabor = v));
      }
    });
  }

  Future<void> _autoTraducir(TextEditingController origen, TextEditingController destino,
      void Function(bool) setLoading) async {
    final texto = origen.text.trim();
    if (texto.isEmpty || destino.text.trim().isNotEmpty) return;
    setLoading(true);
    try {
      final url = Uri.parse(
          'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(texto)}&langpair=en|es');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final traducido = data['responseData']?['translatedText'];
        if (traducido != null && mounted) destino.text = traducido;
      }
    } catch (e) {}
    setLoading(false);
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
      nombreEs: _nombreEsCtrl.text.trim(),
      codigo: _codigoCtrl.text.trim(),
      categoria: _categoria,
      sabor: _saborCtrl.text.trim(),
      saborEs: _saborEsCtrl.text.trim(),
      presentacion: _presentacionCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      descripcionEs: _descripcionEsCtrl.text.trim(),
      ingredientes: _ingredientesCtrl.text.trim(),
      ingredientesEs: _ingredientesEsCtrl.text.trim(),
      nutriEnergiaKJ: _nutriEnergiaKJCtrl.text.trim(),
      nutriEnergiaKcal: _nutriEnergiaKcalCtrl.text.trim(),
      nutriGrasa: _nutriGrasaCtrl.text.trim(),
      nutriGrasaSat: _nutriGrasaSatCtrl.text.trim(),
      nutriCarbo: _nutriCarboCtrl.text.trim(),
      nutriAzucar: _nutriAzucarCtrl.text.trim(),
      nutriFibra: _nutriFibraCtrl.text.trim(),
      nutriProteina: _nutriProteinaCtrl.text.trim(),
      nutriSal: _nutriSalCtrl.text.trim(),
      costoProveedor: double.tryParse(_costoCtrl.text) ?? 0,
      precioVenta: double.tryParse(_precioCtrl.text) ?? 0,
      precioVentaCOP: double.tryParse(_precioCOPCtrl.text) ?? 0,
      enStock: _enStock,
      fotos: todasLasFotos,
      proveedorNombre: _proveedorNombreCtrl.text.trim(),
      proveedorWhatsapp: _proveedorWhatsappCtrl.text.trim(),
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

  Widget _campoNutri(String label, TextEditingController ctrl, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
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
                    focusNode: _nombreFocus,
                    decoration: const InputDecoration(labelText: 'Nombre (Inglés)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nombreEsCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nombre (Español)',
                      border: const OutlineInputBorder(),
                      suffixIcon: _traduciendoNombre
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                          : null,
                    ),
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
                    focusNode: _saborFocus,
                    decoration: const InputDecoration(labelText: 'Sabor (Inglés)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _saborEsCtrl,
                    decoration: InputDecoration(
                      labelText: 'Sabor (Español)',
                      border: const OutlineInputBorder(),
                      suffixIcon: _traduciendoSabor
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _presentacionCtrl,
                    decoration: const InputDecoration(labelText: 'Presentacion (ej. 500ml)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),

                  const Divider(),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descripcionCtrl,
                    focusNode: _descripcionFocus,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Descripcion (Inglés)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descripcionEsCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descripcion (Español)',
                      border: const OutlineInputBorder(),
                      suffixIcon: _traduciendoDesc
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                          : null,
                    ),
                  ),

                  const Divider(height: 32),
                  const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ingredientesCtrl,
                    focusNode: _ingredientesFocus,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Ingredientes (Inglés)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ingredientesEsCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Ingredientes (Español)',
                      border: const OutlineInputBorder(),
                      suffixIcon: _traduciendoIngr
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                          : null,
                    ),
                  ),

                  const Divider(height: 32),
                  const Text('Nutrition (per 100g)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _campoNutri('Energy kJ', _nutriEnergiaKJCtrl, hint: 'ej. 242'),
                  _campoNutri('Energy kcal', _nutriEnergiaKcalCtrl, hint: 'ej. 58'),
                  _campoNutri('Fat', _nutriGrasaCtrl, hint: 'ej. 3.0g'),
                  _campoNutri('of which saturates', _nutriGrasaSatCtrl, hint: 'ej. 1.9g'),
                  _campoNutri('Carbohydrates', _nutriCarboCtrl, hint: 'ej. 4.4g'),
                  _campoNutri('of which sugars', _nutriAzucarCtrl, hint: 'ej. 3.7g'),
                  _campoNutri('Fibre', _nutriFibraCtrl, hint: 'ej. <0.5g'),
                  _campoNutri('Protein', _nutriProteinaCtrl, hint: 'ej. 3.3g'),
                  _campoNutri('Salt', _nutriSalCtrl, hint: 'ej. 0.10g'),

                  const Divider(height: 32),
                  TextField(
                    controller: _costoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Costo proveedor (£)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _precioCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Precio de venta - UK (£)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _precioCOPCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Precio de venta - Colombia (\$ COP)', border: OutlineInputBorder()),
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
