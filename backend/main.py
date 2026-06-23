# main.py — Entry point del backend FastAPI (Sistema Veterinario)

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import traceback

from models import ConsultaRequest, ConsultaResponse
from database import ejecutar_query, get_db_connection
from ai import generar_sql, generar_respuesta_natural

load_dotenv(encoding="latin-1")

app = FastAPI(
    title="VetAI API",
    description="Backend para consultas inteligentes de Sistema Veterinario con DeepSeek + PostgreSQL",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {"mensaje": "VetAI API activa", "version": "1.0.0"}


@app.get("/health")
def health():
    """Verifica la conexion a la base de datos."""
    try:
        conn = get_db_connection()
        conn.close()
        return {"status": "ok", "db": "conectada"}
    except Exception as e:
        return {"status": "error", "db": str(e)}


@app.post("/consulta", response_model=ConsultaResponse)
def consulta(request: ConsultaRequest):
    """
    Recibe una pregunta en lenguaje natural,
    genera SQL con DeepSeek, ejecuta en PostgreSQL y devuelve la respuesta.
    """
    pregunta = request.pregunta.strip()
    if not pregunta:
        raise HTTPException(status_code=400, detail="La pregunta no puede estar vacia.")

    try:
        sql      = generar_sql(pregunta)
        datos    = ejecutar_query(sql)
        respuesta = generar_respuesta_natural(pregunta, datos, sql)

        return ConsultaResponse(
            pregunta=pregunta,
            sql_ejecutado=sql,
            datos_db=datos,
            respuesta_ia=respuesta,
        )

    except HTTPException:
        raise
    except Exception as e:
        tb = traceback.format_exc()
        return ConsultaResponse(
            pregunta=pregunta,
            sql_ejecutado="",
            datos_db=[],
            respuesta_ia="",
            error=f"Error inesperado ({type(e).__name__}): {str(e)}\n\nTraceback:\n{tb}",
        )


@app.get("/stats")
def stats():
    """Estadisticas rapidas del sistema veterinario."""
    try:
        propietarios = ejecutar_query("SELECT COUNT(*) as total FROM propietarios")
        mascotas     = ejecutar_query("SELECT COUNT(*) as total FROM mascotas")
        vacunas      = ejecutar_query("SELECT COUNT(*) as total FROM vacunas")
        consultas    = ejecutar_query("SELECT COUNT(*) as total FROM consultas")
        ingresos     = ejecutar_query(
            "SELECT COALESCE(SUM(costo), 0) as total FROM consultas WHERE estado='completada'"
        )
        return {
            "propietarios":   propietarios[0]["total"],
            "mascotas":       mascotas[0]["total"],
            "vacunas":        vacunas[0]["total"],
            "consultas":      consultas[0]["total"],
            "ingresos_total": float(ingresos[0]["total"]),
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
