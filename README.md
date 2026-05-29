# Sistema de Gestión de Incidencias

Monorepo con **API REST (Node.js + Express + PostgreSQL)** y **App Flutter Mobile/Web**.

---

## Usuarios de prueba

| Rol        | Email               | Contraseña    |
|------------|---------------------|---------------|
| SUPERVISOR | supervisor@test.com | Admin123!     |
| TÉCNICO    | tecnico1@test.com   | Tecnico123!   |
| TÉCNICO    | tecnico2@test.com   | Tecnico123!   |
| USUARIO    | usuario1@test.com   | Usuario123!   |
| USUARIO    | usuario2@test.com   | Usuario123!   |

---

## Levantar con Docker (recomendado)

### Requisitos
- Docker Desktop instalado y corriendo

### Pasos

```bash
# 1. Clonar el proyecto
git clone https://github.com/elenesm/incidencias-test.git
cd incidencias-test

# 2. Crear el archivo de entorno en la raíz (requerido por docker-compose)
cp backend/.env.example .env
# Editar .env con tus valores
```

El archivo `.env` en la **raíz** del proyecto debe tener:

```env
DB_USER=postgres
DB_PASSWORD=tu_password_seguro
DB_NAME=incidencias_db
JWT_SECRET=genera_un_string_largo_aleatorio
JWT_EXPIRES_IN=24h
```

> Para generar un JWT_SECRET seguro: `openssl rand -base64 64`

```bash
# 3. Levantar todo (DB + API + migraciones + seeders)
docker-compose up --build
```

La API estará disponible en: **http://localhost:3000**

```bash
# Detener los contenedores
docker-compose down

# Limpiar la base de datos (volumen)
docker-compose down -v
```

> Los seeders se ejecutan automáticamente al levantar. Gracias al `seederStorage: sequelize`,
> no se re-ejecutan si los datos ya existen — puedes reiniciar el contenedor sin errores.

---

## Levantar sin Docker (modo local)

### Requisitos
- Node.js 18+ (LTS)
- PostgreSQL 14+ corriendo localmente
- Flutter SDK estable (3.x)

### Back-end

```bash
cd backend

# 1. Instalar dependencias
npm install

# 2. Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales de PostgreSQL
```

El archivo `backend/.env` debe tener:

```env
NODE_ENV=development
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_USER=tu_usuario_db
DB_PASSWORD=tu_password_seguro
DB_NAME=incidencias_db
JWT_SECRET=genera_un_string_largo_aleatorio
JWT_EXPIRES_IN=24h
```

```bash
# 3. Crear la base de datos (TablePlus, psql, etc.)
# CREATE DATABASE incidencias_db;

# 4. Ejecutar migraciones
npx sequelize-cli db:migrate

# 5. Ejecutar seeders
npx sequelize-cli db:seed:all

# 6. Levantar servidor de desarrollo
npm run dev
```

API disponible en: **http://localhost:3000**

Scripts disponibles:

```bash
npm run dev          # Desarrollo con hot-reload (nodemon)
npm start            # Producción
npm run lint         # ESLint
npm run format       # Prettier
npm test             # Jest
npm run migrate:undo # Deshacer todas las migraciones
```

### Front-end (Flutter)

```bash
cd frontend

# 1. Instalar dependencias
flutter pub get

# 2. Verificar dispositivos disponibles
flutter devices

# 3a. Ejecutar en emulador/dispositivo físico
flutter run

# 3b. Ejecutar en el navegador (modo web)
flutter run -d chrome --web-port 7300

# 3c. Ejecutar apuntando a una API en otro servidor
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:3000/api
```

> Por defecto la app apunta a `http://localhost:3000/api`.
> Usa `--dart-define=API_BASE_URL=<url>` para cambiar el servidor sin tocar el código.

---

## Guards de rutas: Producción vs Smoke Tests

Archivo de configuración: `frontend/lib/config/app_config.dart`

```dart
// true  = Modo Producción (requiere JWT válido)
// false = Modo Smoke Tests (navegación libre sin autenticación)
const bool ENABLE_ROUTE_GUARDS = true;
```

| Modo | Comportamiento |
|---|---|
| `true` (producción) | Sin token → redirige a Login. Rol incorrecto → pantalla de acceso denegado. |
| `false` (smoke tests) | Navegación libre, las llamadas a la API pueden devolver 401 y es aceptable. |

---

## Endpoints de la API

Todas las rutas bajo `/api`. Las rutas protegidas requieren header:
```
Authorization: Bearer <token>
```

### Auth

| Método | Ruta             | Auth | Descripción          |
|--------|------------------|------|----------------------|
| POST   | /api/auth/login  | No   | Login — devuelve JWT |
| POST   | /api/auth/logout | Sí   | Cerrar sesión        |

### Usuario (`rol: USUARIO`)

| Método | Ruta                                     | Descripción                          |
|--------|------------------------------------------|--------------------------------------|
| POST   | /api/usuario/incidencias                 | Crear incidencia                     |
| GET    | /api/usuario/incidencias                 | Listar mis incidencias (`?estatus=`) |
| GET    | /api/usuario/incidencias/:id             | Detalle + conversación completa      |
| POST   | /api/usuario/incidencias/:id/comentarios | Agregar mensaje al chat              |

### Técnico (`rol: TECNICO`)

| Método | Ruta                                     | Descripción                                         |
|--------|------------------------------------------|-----------------------------------------------------|
| GET    | /api/tecnico/incidencias                 | Listar incidencias asignadas                        |
| GET    | /api/tecnico/incidencias/:id             | Detalle + conversación                              |
| PATCH  | /api/tecnico/incidencias/:id             | Actualizar estatus (`EN_PROCESO` `EN_REVISION` `EN_DESARROLLO` `EN_ESPERA` `RESUELTA`) y/o comentario |
| POST   | /api/tecnico/incidencias/:id/comentarios | Agregar nota técnica al chat                        |

### Supervisor (`rol: SUPERVISOR`)

| Método | Ruta                                      | Descripción                                                              |
|--------|-------------------------------------------|--------------------------------------------------------------------------|
| GET    | /api/admin/incidencias                    | Tablero global (`?estatus` `?prioridad` `?tecnico_id` `?desde` `?hasta`) |
| POST   | /api/admin/incidencias                    | Crear incidencia y asignar técnico en un paso                            |
| POST   | /api/admin/incidencias/:id/asignar        | Reasignar técnico a incidencia existente                                 |
| PATCH  | /api/admin/incidencias/:id                | Actualizar campos (prioridad, estatus, categoría, etc.)                  |
| DELETE | /api/admin/incidencias/:id                | Inactivar incidencia (soft delete — dato preservado en DB)               |
| POST   | /api/admin/incidencias/:id/comentarios    | Agregar nota supervisora al chat                                         |
| GET    | /api/admin/reportes                       | Métricas por estatus, prioridad y técnico (`?desde` `?hasta`)            |
| GET    | /api/admin/tecnicos                       | Listar usuarios con rol TECNICO                                          |
| GET    | /api/admin/usuarios                       | Listar usuarios con rol USUARIO                                          |

### Utilitario

| Método | Ruta        | Descripción      |
|--------|-------------|------------------|
| GET    | /api/health | Estado de la API |

---

## Estatus de incidencias

| Estatus          | Color    | Quién puede asignarlo              |
|------------------|----------|------------------------------------|
| `ABIERTA`        | Azul     | Se asigna al crear                 |
| `EN_PROCESO`     | Naranja  | Técnico / Supervisor               |
| `EN_REVISION`    | Índigo   | Técnico                            |
| `EN_DESARROLLO`  | Teal     | Técnico                            |
| `EN_ESPERA`      | Morado   | Técnico / Supervisor               |
| `RESUELTA`       | Verde    | Técnico (registra `fecha_cierre`)  |
| `CERRADA`        | Gris     | Supervisor                         |

---

## Chat / Conversación (bitácora)

Cada incidencia tiene una **conversación** visible en el detalle para los 3 roles. Las burbujas se colorean según quién escribió:

| Rol        | Color de burbuja | Alineación |
|------------|------------------|------------|
| USUARIO    | Azul claro       | Izquierda  |
| TECNICO    | Verde claro      | Derecha    |
| SUPERVISOR | Naranja claro    | Izquierda  |
| Sistema    | Gris centrado    | Centro     |

Cada burbuja incluye nombre del autor, timestamp y — si aplica — el chip del cambio de estatus.

---

## Seguridad

- Los archivos `.env` están en `.gitignore` y **nunca se suben al repositorio**.
- Usar `backend/.env.example` como plantilla; contiene solo placeholders, sin credenciales reales.
- El `docker-compose.yml` no tiene valores hardcodeados — requiere el `.env` en la raíz.
- JWT validado en cada request a rutas protegidas mediante middleware.
- Control de roles: cada módulo (`/usuario`, `/tecnico`, `/admin`) valida el rol del token.
- Respuestas `401` en Flutter disparan logout automático y redirigen a Login.
- Soft delete: `DELETE` solo marca `activo = false`, los datos y logs se preservan en la DB.

### Conexión a PostgreSQL (TablePlus u otro cliente)

| Campo         | Valor                        |
|---------------|------------------------------|
| Host          | localhost                    |
| Puerto        | **5433** (Docker) / 5432 (local sin Docker) |
| Base de datos | valor de `DB_NAME`           |
| Usuario       | valor de `DB_USER`           |
| Contraseña    | valor de `DB_PASSWORD`       |

---

## Arquitectura

```
incidencias-test/
├── backend/
│   ├── src/
│   │   ├── config/        # database.js (Sequelize + seederStorage)
│   │   ├── models/        # Usuario, Incidencia, IncidenciaLog, Asignacion
│   │   ├── controllers/   # Lógica de negocio separada por rol
│   │   ├── routes/        # Endpoints + validaciones (express-validator)
│   │   ├── middlewares/   # auth (JWT), role (RBAC), validate, error
│   │   ├── migrations/    # 5 migraciones (esquema + ENUM de estatus)
│   │   └── seeders/       # 1 supervisor, 2 técnicos, 2 usuarios, 5 incidencias, logs
│   ├── .eslintrc.json
│   ├── .prettierrc
│   ├── Dockerfile
│   └── package.json
├── frontend/
│   └── lib/
│       ├── config/        # app_config.dart (ENABLE_ROUTE_GUARDS, BASE_URL), routes.dart
│       ├── models/        # IncidenciaModel, UsuarioModel, LogModel, UsuarioRef
│       ├── services/      # AuthService, ApiService (interceptor 401), IncidenciaService
│       ├── screens/
│       │   ├── auth/      # LoginScreen
│       │   ├── usuario/   # Home, NuevaIncidencia, Detalle
│       │   ├── tecnico/   # Home, Detalle
│       │   └── admin/     # Home, Detalle, Crear, Reportes
│       ├── widgets/       # EstatusChip, PrioridadChip, LoadingButton, ChatBubble
│       └── main.dart      # onGenerateRoute, guards, navigatorKey global
├── docker-compose.yml
├── postman_collection.json
└── README.md
```

### Stack

| Capa       | Tecnología                              |
|------------|-----------------------------------------|
| Runtime    | Node.js 18 LTS                          |
| Framework  | Express 4                               |
| Base datos | PostgreSQL 15                           |
| ORM        | Sequelize 6 (migraciones + seeders)     |
| Auth       | JWT (jsonwebtoken) + bcryptjs           |
| Seguridad  | helmet, cors, express-validator         |
| Mobile/Web | Flutter 3.44 + Dart 3                   |
| HTTP       | package:http                            |
| Sesión     | shared_preferences (JWT local)          |
| DevOps     | Docker + Docker Compose                 |
