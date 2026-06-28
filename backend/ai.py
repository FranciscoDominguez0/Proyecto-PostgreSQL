# ai.py — Integración con DeepSeek AI (Sistema Veterinario)

import os
import json
from openai import OpenAI
from fastapi import HTTPException

SCHEMA_INFO = """
Base de datos: veterinaria_db (Sistema Veterinario)

TABLA: propietarios
  - id (SERIAL PK)
  - nombre (VARCHAR)
  - email (VARCHAR, unico)
  - telefono (VARCHAR)
  - ciudad (VARCHAR)
  - direccion (VARCHAR)
  - fecha_registro (DATE)
  - activo (BOOLEAN)

TABLA: mascotas
  - id (SERIAL PK)
  - nombre (VARCHAR)
  - especie (VARCHAR): 'Perro','Gato','Ave','Conejo','Reptil','Otro'
  - raza (VARCHAR)
  - fecha_nacimiento (DATE)
  - sexo (CHAR): 'M' (macho) o 'H' (hembra)
  - propietario_id (FK -> propietarios.id)
  - activo (BOOLEAN)

TABLA: vacunas
  - id (SERIAL PK)
  - mascota_id (FK -> mascotas.id)
  - nombre_vacuna (VARCHAR)
  - fecha_aplicacion (DATE)
  - fecha_proxima (DATE)
  - veterinario (VARCHAR)
  - lote (VARCHAR)
  - observaciones (TEXT)

TABLA: consultas
  - id (SERIAL PK)
  - mascota_id (FK -> mascotas.id)
  - fecha_consulta (TIMESTAMP)
  - motivo (VARCHAR)
  - diagnostico (TEXT)
  - tratamiento (TEXT)
  - costo (NUMERIC)
  - veterinario (VARCHAR)
  - estado (VARCHAR): 'pendiente','en_curso','completada','cancelada'
"""

_client = None


def get_deepseek_client() -> OpenAI:
    global _client
    if _client is None:
        api_key = os.getenv("DEEPSEEK_API_KEY")
        if not api_key:
            raise HTTPException(status_code=500, detail="DEEPSEEK_API_KEY no configurada en .env")
        _client = OpenAI(
            api_key=api_key,
            base_url=os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com"),
        )
    return _client


def validar_pregunta(pregunta: str) -> bool:
    """Verifica si la pregunta está relacionada con el sistema veterinario."""
    client = get_deepseek_client()
    prompt = f"""Eres un guardián de consultas para un sistema veterinario.
Determina si esta pregunta está relacionada con: mascotas, propietarios, vacunas, consultas veterinarias o datos de la clínica.

Pregunta: "{pregunta}"

Responde ÚNICAMENTE con una palabra: SI o NO.
"""
    response = client.chat.completions.create(
        model="deepseek-chat",
        messages=[{"role": "user", "content": prompt}],
        temperature=0,
        max_tokens=5,
    )
    resultado = response.choices[0].message.content.strip().upper()
    return "SI" in resultado


def generar_sql(pregunta: str) -> str:
    """Convierte una pregunta en lenguaje natural a SQL usando DeepSeek."""
    client = get_deepseek_client()
    prompt = f"""Eres un experto en SQL para PostgreSQL. Dado el siguiente schema de un sistema veterinario:

{SCHEMA_INFO}

Genera UNA SOLA consulta SQL valida para PostgreSQL que responda:
"{pregunta}"

REGLAS:
- Responde UNICAMENTE con el SQL, sin explicaciones ni bloques de codigo.
- Usa JOINs cuando sea necesario.
- Si la pregunta pide UNO (el mas caro, el mayor, el que mas...), NO uses LIMIT, usa ORDER BY + LIMIT 1.
- Si pide una cantidad especifica (los 4 mas viejos, los 3 primeros), usa exactamente ese LIMIT.
- Solo usa LIMIT 20 si la pregunta pide una lista general sin cantidad especifica (ej: "lista de mascotas").
- No uses columnas fuera del schema.
- Para edad de mascotas usa: DATE_PART('year', AGE(fecha_nacimiento))
"""
    response = client.chat.completions.create(
        model="deepseek-chat",
        messages=[{"role": "user", "content": prompt}],
        temperature=0,
        max_tokens=300,
    )
    sql = response.choices[0].message.content.strip()
    return sql.replace("```sql", "").replace("```", "").strip()


def generar_respuesta_natural(pregunta: str, datos: list) -> str:
    """Genera una respuesta en lenguaje natural a partir de los datos de PostgreSQL."""
    client = get_deepseek_client()
    datos_str = json.dumps(datos, ensure_ascii=False, default=str, indent=2)
    prompt = f"""Eres el sistema analitico VetAI. Resume los datos obtenidos de forma directa y profesional.

Pregunta original: "{pregunta}"
Datos obtenidos:
{datos_str}

REGLAS:
1. Ve DIRECTAMENTE a la respuesta. Sin saludos ni despedidas.
2. NUNCA ofrezcas hacer consultas adicionales.
3. Si los datos son una lista, da un resumen de 1-2 lineas (el usuario ya ve la tabla).
4. Tono analitico y conciso (maximo 2-3 lineas).
"""
    response = client.chat.completions.create(
        model="deepseek-chat",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.7,
        max_tokens=400,
    )
    return response.choices[0].message.content.strip()