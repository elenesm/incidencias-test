// Bandera global para activar/desactivar guards de rutas
// true  = Modo Producción (requiere JWT)
// false = Modo Smoke Tests (navegación libre)
const bool ENABLE_ROUTE_GUARDS = true;

// URL base de la API — inyectada en build time con --dart-define=API_BASE_URL=...
// Ejemplo local:  flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
// Ejemplo prod:   flutter build apk --dart-define=API_BASE_URL=https://api.tudominio.com/api
const String BASE_URL = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000/api',
);
