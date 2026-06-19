# models.py — Modelos Pydantic de la API

from pydantic import BaseModel


class ConsultaRequest(BaseModel):
    pregunta: str


class ConsultaResponse(BaseModel):
    pregunta: str
    sql_ejecutado: str
    datos_db: list
    respuesta_ia: str
    error: str | None = None
