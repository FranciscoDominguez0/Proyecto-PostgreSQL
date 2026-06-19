# ai.py — Integración con DeepSeek AI

import os
import json
from openai import OpenAI
from fastapi import HTTPException


# Schema de la base de datos para el prompt de generación SQL
SCHEMA_INFO = """
Base de datos: ecommerce_db (Sistema de Comercio Electronico)

TABLA: clientes
  - id (SERIAL PK)
  - nombre (VARCHAR)
  - email (VARCHAR, unico)
  - ciudad (VARCHAR)
  - pais (VARCHAR)
  - fecha_registro (DATE)
  - activo (BOOLEAN)

TABLA: productos
  - id (SERIAL PK)
  - nombre (VARCHAR)
  - categoria (VARCHAR): 'Electronica','Accesorios','Mobiliario','Almacenamiento','Wearables','Impresion','Redes'
  - precio (NUMERIC)
  - stock (INTEGER)
  - descripcion (TEXT)
  - activo (BOOLEAN)

TABLA: pedidos
  - id (SERIAL PK)
  - cliente_id (FK -> clientes.id)
  - producto_id (FK -> productos.id)
  - cantidad (INTEGER)
  - precio_unitario (NUMERIC)
  - total (NUMERIC, columna generada = cantidad * precio_unitario)
  - estado (VARCHAR): 'pendiente','procesando','enviado','entregado','cancelado'
  - fecha_pedido (TIMESTAMP)
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

    prompt = f"""Eres un experto en SQL para PostgreSQL. Dado el siguiente schema:

{SCHEMA_INFO}

Genera UNA SOLA consulta SQL valida para PostgreSQL que responda:
"{pregunta}"

REGLAS:
- Responde UNICAMENTE con el SQL, sin explicaciones ni bloques de codigo.
- Usa JOINs cuando sea necesario.
- Limita listas a LIMIT 20.
- No uses columnas fuera del schema.
- La columna 'total' en pedidos es generada, no la calcules manualmente.
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

    prompt = f"""Eres un asistente analitico de un sistema de comercio electronico.
Pregunta del usuario: "{pregunta}"
SQL ejecutado: {sql}
Datos obtenidos:
{datos_str}

Responde de forma clara y concisa en espanol.
- Interpreta los datos numericos.
- Si la lista esta vacia, indicalo.
- Maximo 150 palabras.
"""

    response = client.chat.completions.create(
        model="deepseek-chat",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.7,
        max_tokens=400,
    )

    return response.choices[0].message.content.strip()
