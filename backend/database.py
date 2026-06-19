# database.py — Conexión y consultas a PostgreSQL

import os
import psycopg2
import psycopg2.extras
from fastapi import HTTPException


def get_db_connection():
    """Crea y retorna una conexión a PostgreSQL."""
    try:
        conn = psycopg2.connect(
            host=os.getenv("DB_HOST", "localhost"),
            port=os.getenv("DB_PORT", "5432"),
            dbname=os.getenv("DB_NAME", "ecommerce_db"),
            user=os.getenv("DB_USER", "postgres"),
            password=os.getenv("DB_PASSWORD", ""),
        )
        # LATIN1 es compatible con WIN1252 (encoding por defecto en PostgreSQL Windows)
        conn.set_client_encoding("LATIN1")
        return conn
    except psycopg2.Error as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error de conexión a la base de datos: {str(e)}"
        )


def sanitize_value(v):
    """Convierte bytes a str con latin-1 para evitar errores de encoding."""
    if isinstance(v, bytes):
        return v.decode("latin-1", errors="replace")
    return v


def ejecutar_query(sql: str) -> list:
    """Ejecuta una consulta SQL y retorna los resultados como lista de dicts."""
    conn = get_db_connection()
    try:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql)
            rows = []
            for row in cur.fetchall():
                rows.append({k: sanitize_value(v) for k, v in dict(row).items()})
            return rows
    except psycopg2.Error as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error ejecutando SQL: {str(e)}"
        )
    finally:
        conn.close()
