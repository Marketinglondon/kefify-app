class AppConfig {
  // Datos de Cloudinary (para subir fotos)
  static const String cloudinaryCloudName = 'iggcl810';
  static const String cloudinaryUploadPreset = 'kefify_preset';
  static String get cloudinaryUploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload';

  // WhatsApp del negocio
  static const String whatsappNumber = '447446830987';

  // Categorias de producto
  static const List<String> categorias = [
    'Artisanal Dairy',
    'Ice Cream',
    'Yogurt',
    'Desserts',
    'Drinks',
  ];

  // Nombre de la app
  static const String appName = 'Kefify';
}
