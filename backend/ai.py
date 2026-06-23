# ai.py — Integración con DeepSeek AI (Sistema Veterinario)

import os
import json
from openai import OpenAI
from fastapi import HTTPException


# Schema de la base de datos para el prompt de generación SQL
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


def get_deepseek_client() -> OpenAI:
    """Crea y retorna el cliente de DeepSeek (compatible con OpenAI SDK)."""
    api_key = os.getenv("DEEPSEEK_API_KEY")
    if not api_key:
        raise HTTPException(
            status_code=500,
            detail="DEEPSEEK_API_KEY no configurada en .env"
        )
    return OpenAI(
        api_key=api_key,
        base_url=os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com"),
    )


def generar_sql(pregunta: str) -> str:
    """Convierte una pregunta en lenguaje natural a SQL usando DeepSeek."""
    client = get_deepseek_client()

    prompt = f"""Eres un experto en SQL para PostgreSQL. Dado el siguiente schema de un sistema veterinario:

{SCHEMA_INFO}

Genera UNA SOLA consulta SQL valida para PostgreSQL que responda:
"{pregunta}"

REGLAS:
- Responde UNICAMENTE con el SQL, sin explicaciones ni bloques de codigo.
- Usa JOINs cuando sea necesario (mascotas JOIN propietarios, etc.).
- Limita listas a LIMIT 20.
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
    sql = sql.replace("```sql", "").replace("```", "").strip()
    return sql


def generar_respuesta_natural(pregunta: str, datos: list, sql: str) -> str:
    """Genera una respuesta en lenguaje natural a partir de los datos de PostgreSQL."""
    client = get_deepseek_client()

    datos_str = json.dumps(datos, ensure_ascii=False, default=str, indent=2)

    prompt = f"""Eres el sistema analitico VetAI. Tu objetivo es resumir los datos obtenidos para el usuario de forma directa y profesional.

Pregunta original: "{pregunta}"
Datos obtenidos de la base de datos:
{datos_str}

REGLAS DE RESPUESTA:
1. Ve DIRECTAMENTE a la respuesta. Cero saludos o despedidas.
2. NUNCA ofrezcas hacer consultas adicionales ni digas "Si necesitas mas informacion...".
3. NO agregues recomendaciones ni sugerencias fuera de lo estrictamente preguntado.
4. Si los datos son una lista, simplemente da un resumen de 1-2 lineas (ej: "Se encontraron X mascotas que cumplen el criterio") ya que el usuario vera la tabla de datos completa en su pantalla.
5. Usa un tono analitico, serio y conciso (maximo 2-3 lineas de texto).
"""

    response = client.chat.completions.create(
        model="deepseek-chat",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.7,
        max_tokens=400,
    )

    return response.choices[0].message.content.strip()
