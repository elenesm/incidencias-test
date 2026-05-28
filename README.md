# 🛠 Sistema de Gestión de Incidencias

Monorepo con **API Node.js (Express + PostgreSQL)** y **App Flutter Mobile**.

## 👥 Usuarios de prueba (seeders)

| Rol        | Email                  | Contraseña     |
|------------|------------------------|----------------|
| SUPERVISOR | supervisor@test.com    | Admin123!      |
| TÉCNICO    | tecnico1@test.com      | Tecnico123!    |
| TÉCNICO    | tecnico2@test.com      | Tecnico123!    |
| USUARIO    | usuario1@test.com      | Usuario123!    |
| USUARIO    | usuario2@test.com      | Usuario123!    |

---

## 🐳 Levantar con Docker (recomendado)

### Requisitos
- Docker Desktop instalado y corriendo

### Pasos

```bash
# 1. Clonar / abrir el proyecto
cd incidencias-test

# 2. Crear archivo de entorno (opcional, ya tiene defaults)
cp backend/.env.example backend/.env

# 3. Levantar todo (DB + API + migraciones + seeders)
docker-compose up --build
```

La API estará disponible en: **http://localhost:3000**

Para detener:
```bash
docker-compose down
```

Para limpiar la base de datos:
```bash
docker-compose down -v
```

---

## 💻 Levantar sin Docker (modo local)

### Requisitos
- Node.js 18+ (LTS)
- PostgreSQL 14+ corriendo localmente
- Flutter SDK estable

### Back-end

```bash
cd backend

# 1. Instalar dependencias
npm install

# 2. Crear y configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales de PostgreSQL

# 3. Crear la base de datos en PostgreSQL (TablePlus, psql, etc.)
# CREATE DATABASE incidencias_db;

# 4. Ejecutar migraciones
npx sequelize-cli db:migrate

# 5. Ejecutar seeders (datos iniciales)
npx sequelize-cli db:seed:all

# 6. Levantar servidor de desarrollo
npm run dev
```

API disponible en: **http://localhost:3000**

Para deshacer migraciones:
```bash
npx sequelize-cli db:migrate:undo:all
```

### Front-end (Flutter)

```bash
cd frontend

# 1. Instalar dependencias
flutter pub get

# 2. (Opcional) Verificar dispositivos disponibles
flutter devices

# 3. Ejecutar en emulador o dispositivo
flutter run
```

> Asegúrate de que la API esté corriendo antes de lanzar Flutter.

---

## 🔒 Guards de rutas: Producción vs Smoke Tests

El archivo de configuración se encuentra en:
```
frontend/lib/config/app_config.dart
```

```dart
// true  = Modo Producción (requiere JWT válido)
// false = Modo Smoke Tests (navegación libre sin autenticación)
const bool ENABLE_ROUTE_GUARDS = true;
```

### Activar modo Smoke Tests
Cambia el valor a `false`:
```dart
const bool ENABLE_ROUTE_GUARDS = false;
```

Esto permite navegar todas las pantallas sin autenticación para revisar layouts y flujos visuales.

### Volver a Producción
Cambia el valor a `true` (valor por defecto y recomendado en producción).

---

## 📡 Endpoints de la API

### Auth
| Método | Ruta               | Descripción                    |
|--------|--------------------|--------------------------------|
| POST   | /api/auth/login    | Login y obtención de JWT       |

### Usuario
| Método | Ruta                                        | Descripción                        |
|--------|---------------------------------------------|------------------------------------|
| POST   | /api/usuario/incidencias                    | Crear incidencia                   |
| GET    | /api/usuario/incidencias                    | Listar mis incidencias             |
| GET    | /api/usuario/incidencias/:id               | Detalle + bitácora                 |
| POST   | /api/usuario/incidencias/:id/comentarios   | Agregar comentario                 |

### Técnico
| Método | Ruta                                        | Descripción                        |
|--------|---------------------------------------------|------------------------------------|
| GET    | /api/tecnico/incidencias                    | Listar asignadas                   |
| GET    | /api/tecnico/incidencias/:id               | Detalle + bitácora                 |
| PATCH  | /api/tecnico/incidencias/:id               | Actualizar estatus/comentario      |
| POST   | /api/tecnico/incidencias/:id/comentarios   | Agregar comentario técnico         |

### Supervisor
| Método | Ruta                                        | Descripción                        |
|--------|---------------------------------------------|------------------------------------|
| GET    | /api/admin/incidencias                      | Tablero global con filtros         |
| POST   | /api/admin/incidencias/:id/asignar          | Asignar técnico                    |
| PATCH  | /api/admin/incidencias/:id                  | Actualizar campos                  |
| DELETE | /api/admin/incidencias/:id                  | Inactivar (soft delete)            |
| GET    | /api/admin/reportes                         | Reportes métricos                  |

---

## 🗄 Conexión a PostgreSQL (TablePlus)

| Campo    | Valor              |
|----------|--------------------|
| Host     | localhost          |
| Puerto   | 5432               |
| Base de datos | incidencias_db |
| Usuario  | postgres           |
| Contraseña | postgres123      |

---

## 🏗 Estructura del proyecto

```
incidencias-test/
├── backend/
│   ├── src/
│   │   ├── config/        # Sequelize + variables de entorno
│   │   ├── models/        # Entidades (Usuario, Incidencia, Log, Asignacion)
│   │   ├── controllers/   # Lógica de negocio por módulo
│   │   ├── routes/        # Endpoints + validaciones
│   │   ├── middlewares/   # Auth JWT, roles, validación, errores
│   │   ├── migrations/    # Migraciones Sequelize
│   │   └── seeders/       # Datos iniciales
│   ├── Dockerfile
│   └── package.json
├── frontend/
│   └── lib/
│       ├── config/        # Rutas y configuración global (guards)
│       ├── models/        # Modelos Dart
│       ├── services/      # AuthService, ApiService, IncidenciaService
│       ├── screens/       # Pantallas por rol (auth/usuario/tecnico/admin)
│       ├── widgets/       # Componentes reutilizables
│       └── utils/         # Colores, guards
├── docker-compose.yml
└── README.md
```
