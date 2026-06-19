# 🛒 ShopAI — Sistema de Comercio Electrónico con IA

> FastAPI · PostgreSQL · Reflex · DeepSeek AI

---

## 📁 Estructura del proyecto (ya incluida en el ZIP)

```
shopai/
│
├── .env.example                         ← plantilla de credenciales
├── .gitignore
├── requirements.txt                     ← todas las dependencias juntas
├── README.md
│
├── database/
│   └── setup.sql                        ← crea tablas + 70 registros
│
├── backend/
│   └── main.py                          ← API FastAPI
│
└── frontend/
    ├── rxconfig.py                      ← configuración Reflex
    └── ecommerce_app/
        └── ecommerce_app.py             ← interfaz Reflex
```

---

## ✅ Pasos para ejecutar

### 1 — Descomprimir el ZIP

Extrae el ZIP donde quieras. Entra a la carpeta:

```bash
cd shopai
```

---

### 2 — Crear el archivo `.env`

Copia la plantilla y edítala con tus datos:

```bash
# Mac / Linux
cp .env.example .env

# Windows
copy .env.example .env
```

Abre `.env` y rellena tus credenciales:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ecommerce_db
DB_USER=postgres
DB_PASSWORD=TU_PASSWORD_POSTGRES    ← cambia esto

DEEPSEEK_API_KEY=sk-xxxxxxxxxxxx    ← cambia esto
DEEPSEEK_BASE_URL=https://api.deepseek.com

BACKEND_URL=http://localhost:8000
```

> Obtén tu API Key en: https://platform.deepseek.com/api_keys

---

### 3 — Crear y activar el ambiente virtual (uno solo para todo)

```bash
# Crear
python -m venv venv

# Activar en Mac/Linux
source venv/bin/activate

# Activar en Windows
venv\Scripts\activate
```

Instalar todas las dependencias:

```bash
pip install -r requirements.txt
```

---

### 4 — Cargar la base de datos

```bash
# Crear la base de datos
psql -U postgres -c "CREATE DATABASE ecommerce_db;"

# Cargar tablas y datos de prueba
psql -U postgres -d ecommerce_db -f database/setup.sql
```

> Si PostgreSQL pide contraseña agrega `-W` al final.  
> En Windows puede ser: `psql -U postgres -W`

Esto crea 3 tablas con 70 registros listos para consultar:
- `clientes` → 20 registros
- `productos` → 15 registros  
- `pedidos` → 35 registros

---

### 5 — Copiar el `.env` al backend

El backend necesita leer las variables de entorno:

```bash
# Mac / Linux
cp .env backend/.env

# Windows
copy .env backend\.env
```

---

### 6 — Iniciar el Backend (Terminal 1)

```bash
# Asegúrate de estar en shopai/ con el venv activado
cd backend
uvicorn main:app --reload --port 8000
```

Verifica que funciona en: **http://localhost:8000/docs**

---

### 7 — Iniciar el Frontend (Terminal 2)

Abre una **segunda terminal**, activa el mismo venv y ejecuta:

```bash
cd shopai          # vuelve a la raíz
source venv/bin/activate   # (Windows: venv\Scripts\activate)

cd frontend
reflex run
```

Abre el navegador en: **http://localhost:3000**

---

## 🖥️ Resumen rápido (una vez instalado)

| Terminal | Comando | URL |
|---|---|---|
| Terminal 1 | `cd backend && uvicorn main:app --reload --port 8000` | http://localhost:8000/docs |
| Terminal 2 | `cd frontend && reflex run` | http://localhost:3000 |

---

## 💬 Preguntas de ejemplo

```
¿Cuántos clientes están registrados?
¿Cuál es el producto más vendido?
¿Cuántos pedidos están pendientes?
¿Cuáles son los 5 clientes que más han gastado?
¿Qué categoría de productos genera más ingresos?
¿Qué productos tienen menos de 15 unidades en stock?
Resume el estado actual de los pedidos
¿Cuál es el pedido de mayor valor?
```

---

## 🛠️ Tecnologías

| Capa | Herramienta |
|---|---|
| Frontend | Reflex 0.6 |
| Backend | FastAPI + Uvicorn |
| Base de datos | PostgreSQL + psycopg2 |
| IA | DeepSeek API (SDK OpenAI) |
| HTTP interno | httpx |
| Configuración | python-dotenv |

---

## ⚠️ Problemas frecuentes

| Error | Solución |
|---|---|
| `connection refused` en DB | Verifica que PostgreSQL esté corriendo |
| `DEEPSEEK_API_KEY no configurada` | Revisa que `.env` esté en `backend/` |
| `reflex run` no abre el puerto | Espera ~30 segundos, Reflex tarda en compilar |
| `ModuleNotFoundError` | Asegúrate de que el venv esté activado |
