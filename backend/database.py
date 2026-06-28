# database.py — Conexión y consultas a PostgreSQL (Sistema Veterinario)

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
            dbname=os.getenv("DB_NAME", "veterinaria_db"),
            user=os.getenv("DB_USER", "postgres"),
            password=os.getenv("DB_PASSWORD", ""),
        )
        return conn
    except psycopg2.Error as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error de conexión a la base de datos: {str(e)}"
        )


def ejecutar_query(sql: str) -> list:
    """Ejecuta una consulta SQL y retorna los resultados como lista de dicts."""
    conn = get_db_connection()
    try:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql)
            return [dict(row) for row in cur.fetchall()]
    except psycopg2.Error as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error ejecutando SQL: {str(e)}"
        )
    finally:
        conn.close()