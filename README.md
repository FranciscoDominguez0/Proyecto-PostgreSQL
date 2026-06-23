# 🐾 VetAI — Sistema Veterinario Inteligente

Sistema de gestión veterinaria con consultas en **lenguaje natural** usando **DeepSeek AI + PostgreSQL**.

---

## 🏗️ Arquitectura

```
Frontend (Reflex)  →  Backend (FastAPI)  →  IA (DeepSeek)
                            ↓
                    PostgreSQL (veterinaria_db)
```

## 🗂️ Tablas de la Base de Datos

| Tabla | Descripción |
|-------|-------------|
| `propietarios` | Dueños de mascotas (nombre, email, ciudad…) |
| `mascotas` | Animales registrados (especie, raza, sexo, propietario…) |
| `vacunas` | Historial de vacunación de cada mascota |
| `consultas` | Citas veterinarias (motivo, diagnóstico, tratamiento, costo…) |

Cada tabla incluye **50 registros de ejemplo** en `database/veterinaria_setup.sql`.

---

## 🚀 Puesta en Marcha

### 1. Configurar variables de entorno

```bash
cp .env.example backend/.env
# Editar backend/.env con tus credenciales
```

### 2. Levantar con Docker Compose

```bash
docker-compose up -d
```

### 3. Cargar el SQL veterinario

```bash
# Conectar al contenedor de PostgreSQL
docker exec -i vetai_db psql -U fran2003 -d veterinaria_db < database/veterinaria_setup.sql
```

### 4. Acceder

| Servicio | URL |
|----------|-----|
| Frontend | http://localhost:9092 |
| API Backend | http://localhost:9090 |
| Docs API | http://localhost:9090/docs |

---

## 🐶 Consultas de Ejemplo

- _"¿Cuántas mascotas hay registradas?"_
- _"¿Qué mascotas no tienen vacunas?"_
- _"¿Cuáles son las consultas más costosas?"_
- _"¿Qué veterinario atendió más consultas?"_
- _"¿Qué mascotas tienen vacuna próxima a vencer?"_
- _"Top 5 propietarios con más mascotas"_

---

## 🛠️ Stack Tecnológico

- **Frontend**: Reflex (Python) + JetBrains Mono + Inter
- **Backend**: FastAPI + Pydantic
- **IA**: DeepSeek Chat (OpenAI-compatible)
- **Base de datos**: PostgreSQL 15
- **Deploy**: Docker Compose

---

## 📁 Estructura del Proyecto

```
ShopAI/
├── backend/
│   ├── main.py          # API FastAPI (endpoints /consulta, /stats, /health)
│   ├── ai.py            # Integración DeepSeek (SQL + respuesta natural)
│   ├── database.py      # Conexión PostgreSQL
│   └── models.py        # Modelos Pydantic
├── frontend/
│   ├── rxconfig.py      # Config Reflex (veterinaria_app)
│   └── veterinaria_app/
│       └── veterinaria_app.py  # UI completa del sistema
├── database/
│   └── veterinaria_setup.sql   # Schema + 50 registros por tabla
└── docker-compose.yml
```
