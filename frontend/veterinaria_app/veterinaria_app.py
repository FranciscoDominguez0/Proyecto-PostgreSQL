import reflex as rx
import httpx
from typing import Any, TypedDict
import os

BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:8000")

# ── Paleta oscura profesional (Ocean / Slate) ─────────────────────────
BG    = "#0b0f14"
SURF  = "#111827"
CARD  = "#1f2937"
BORDER= "#374151"
ACCENT= "#06b6d4"        # cyan
ACCENT2="#0ea5e9"        # ocean blue
TEXT  = "#f9fafb"
MUTED = "#9ca3af"
DIM   = "#374151"
GREEN = "#10b981"
RED   = "#ef4444"
AMBER = "#f59e0b"
BLUE  = "#3b82f6"
PINK  = "#d946ef"
MONO  = "'JetBrains Mono', monospace"
SANS  = "'Inter', system-ui, sans-serif"
GRAD  = "linear-gradient(135deg, #06b6d4 0%, #3b82f6 100%)"
GRAD_USER = "linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)"


class Mensaje(TypedDict):
    pregunta: str
    respuesta_ia: str
    sql_ejecutado: str
    datos_db: list[dict[str, str]]
    error: str


class State(rx.State):
    pregunta: str = ""
    pregunta_mostrada: str = ""
    cargando: bool = False
    historial: list[Mensaje] = []
    total_propietarios: int = 0
    total_mascotas: int = 0
    total_vacunas: int = 0
    total_consultas: int = 0
    ingresos_total: float = 0.0
    stats_ok: bool = False
    activa: str = ""

    async def cargar_stats(self):
        try:
            async with httpx.AsyncClient(timeout=10) as c:
                r = await c.get(f"{BACKEND_URL}/stats")
                if r.status_code == 200:
                    d = r.json()
                    self.total_propietarios = d.get("propietarios", 0)
                    self.total_mascotas     = d.get("mascotas", 0)
                    self.total_vacunas      = d.get("vacunas", 0)
                    self.total_consultas    = d.get("consultas", 0)
                    self.ingresos_total     = d.get("ingresos_total", 0.0)
                    self.stats_ok = True
        except Exception: pass

    def set_pregunta(self, v: str): self.pregunta = v
    def set_sugerida(self, p: str): self.pregunta = p; self.activa = p
    def handle_enter(self, k: str):
        if k == "Enter": return State.enviar()

    def limpiar(self):
        self.historial = []
        self.pregunta = ""
        self.activa = ""

    async def enviar(self):
        if not self.pregunta.strip(): return
        texto = self.pregunta
        self.pregunta_mostrada = texto
        self.pregunta = ""
        self.activa = ""
        self.cargando = True
        yield rx.call_script("setTimeout(() => { var e = document.getElementById('chat-container'); if(e) e.scrollTop = e.scrollHeight; }, 100)")
        try:
            async with httpx.AsyncClient(timeout=60) as c:
                r = await c.post(f"{BACKEND_URL}/consulta",
                                 json={"pregunta": texto})
                d = r.json()
                msg = {
                    "pregunta": texto,
                    "respuesta_ia": d.get("respuesta_ia", ""),
                    "sql_ejecutado": d.get("sql_ejecutado", ""),
                    "datos_db": d.get("datos_db", []),
                    "error": d.get("error") or "",
                }
        except httpx.ConnectError:
            msg = {"pregunta": texto, "respuesta_ia": "",
                   "sql_ejecutado": "", "datos_db": [],
                   "error": "Sin conexión con el backend"}
        except Exception as e:
            msg = {"pregunta": texto, "respuesta_ia": "",
                   "sql_ejecutado": "", "datos_db": [],
                   "error": str(e)}
        self.historial.append(msg)
        self.cargando = False
        self.pregunta_mostrada = ""
        # Scroll to top of the new AI response
        yield rx.call_script("setTimeout(() => { var els = document.getElementsByClassName('ai-response'); if(els.length > 0) { els[els.length - 1].scrollIntoView({behavior: 'smooth', block: 'start'}); } }, 150)")


CHIPS = [
    "Cuantas mascotas hay",
    "Lista de propietarios",
    "Mascotas y sus duenos",
    "Vacunas aplicadas",
    "Consultas completadas",
    "Mascotas por especie",
]


# ── Helpers ────────────────────────────────────────────────────────────

def stat(label: str, val: Any, color: str) -> rx.Component:
    return rx.hstack(
        rx.text(label, color=MUTED, font_size="0.7rem",
                font_family=MONO, flex="1"),
        rx.cond(State.stats_ok,
                rx.text(val, color=color, font_size="0.78rem",
                        font_weight="700", font_family=MONO),
                rx.text("—", color=DIM, font_family=MONO)),
        width="100%", align="center", padding_y="0.28rem",
        border_bottom=f"1px solid {BORDER}",
    )


def chip(t: str) -> rx.Component:
    return rx.button(
        t, on_click=State.set_sugerida(t),
        font_size="0.69rem", font_family=SANS,
        padding="0.3rem 0.7rem", border_radius="6px",
        background=rx.cond(State.activa == t, ACCENT2, "transparent"),
        color=rx.cond(State.activa == t, "#fff", MUTED),
        border=rx.cond(State.activa == t,
                       f"1px solid {ACCENT}", f"1px solid {BORDER}"),
        cursor="pointer", transition="all 0.15s",
        width="100%", text_align="left",
        _hover={"background": DIM, "color": TEXT,
                "border_color": ACCENT},
    )


def sidebar() -> rx.Component:
    return rx.box(
        # Logo
        rx.vstack(
            rx.text("VetAI", font_size="1.2rem", font_weight="800",
                    color=TEXT, font_family=MONO,
                    background=GRAD, background_clip="text",
                    webkit_background_clip="text",
                    color_="transparent"),
            rx.text("sistema veterinario", font_size="0.58rem",
                    color=MUTED, font_family=MONO),
            spacing="0", align_items="flex-start",
            margin_bottom="1.2rem",
        ),

        rx.box(height="1px", background=BORDER, margin_bottom="1.1rem"),

        # Stats
        rx.text("RESUMEN", font_size="0.52rem", color=MUTED,
                letter_spacing="0.14em", font_family=MONO,
                font_weight="700", margin_bottom="0.4rem"),
        rx.box(
            stat("propietarios", State.total_propietarios, ACCENT),
            stat("mascotas",     State.total_mascotas,     GREEN),
            stat("vacunas",      State.total_vacunas,      AMBER),
            stat("consultas",    State.total_consultas,    BLUE),
            rx.hstack(
                rx.text("ingresos", color=MUTED, font_size="0.7rem",
                        font_family=MONO, flex="1"),
                rx.cond(State.stats_ok,
                        rx.text("$" + State.ingresos_total.to_string(),
                                color=PINK, font_size="0.78rem",
                                font_weight="700", font_family=MONO),
                        rx.text("—", color=DIM, font_family=MONO)),
                width="100%", align="center", padding_y="0.28rem",
            ),
            background=CARD, border=f"1px solid {BORDER}",
            border_radius="10px", padding="0.5rem 0.8rem",
            margin_bottom="1.1rem",
        ),

        # Chips
        rx.text("EJEMPLOS", font_size="0.52rem", color=MUTED,
                letter_spacing="0.14em", font_family=MONO,
                font_weight="700", margin_bottom="0.4rem"),
        rx.vstack(*[chip(s) for s in CHIPS], spacing="1",
                  align_items="stretch", width="100%"),

        rx.spacer(),
        rx.box(height="1px", background=BORDER, margin_bottom="0.8rem"),
        rx.text("FastAPI · Reflex · DeepSeek",
                font_size="0.52rem", color=DIM, font_family=MONO),

        width="205px", min_width="205px", height="100vh",
        background=SURF, border_right=f"1px solid {BORDER}",
        padding="1.4rem 1rem",
        display="flex", flex_direction="column", overflow_y="auto",
        css={"&::-webkit-scrollbar": {"width": "3px"},
             "&::-webkit-scrollbar-thumb": {"background": BORDER}},
    )


def bubble_ia(msg: dict) -> rx.Component:
    return rx.vstack(
        rx.box(
            rx.hstack(
                rx.icon("sparkles", size=12, color=ACCENT),
                rx.text("VetAI", font_size="0.68rem", font_family=MONO,
                        font_weight="700", color=ACCENT),
                align="center", spacing="1", margin_bottom="0.45rem",
            ),
            rx.cond(
                msg["error"] != "",
                rx.text(msg["error"], font_size="0.8rem", color=RED,
                        font_family=MONO, white_space="pre-wrap"),
                rx.markdown(msg["respuesta_ia"], font_size="0.87rem"),
            ),
            background=CARD, border=f"1px solid {BORDER}",
            border_left=f"3px solid {ACCENT}",
            border_radius="4px 14px 14px 14px",
            padding="0.9rem 1.2rem", max_width="85%",
            box_shadow="0 2px 16px rgba(6,182,212,0.07)",
            class_name="ai-response",
        ),
        rx.cond(
            msg["sql_ejecutado"] != "",
            rx.box(
                rx.text("SQL ejecutado", font_size="0.55rem", color=MUTED,
                        font_family=MONO, letter_spacing="0.1em",
                        margin_bottom="0.25rem"),
                rx.code_block(msg["sql_ejecutado"], language="sql",
                              font_size="0.73rem", border_radius="8px",
                              border=f"1px solid {BORDER}"),
                width="100%",
            ),
            rx.box(),
        ),
        rx.cond(
            msg["datos_db"].length() > 0,
            rx.box(
                rx.text("Datos", font_size="0.55rem", color=MUTED,
                        font_family=MONO, letter_spacing="0.1em",
                        margin_bottom="0.25rem"),
                rx.box(
                    rx.table.root(
                        rx.table.header(
                            rx.table.row(
                                rx.foreach(
                                    msg["datos_db"][0],
                                    lambda kv: rx.table.column_header_cell(
                                        kv[0], font_size="0.58rem",
                                        text_transform="uppercase",
                                        color=ACCENT, font_family=MONO,
                                        padding="0.5rem 0.9rem",
                                        border_bottom=f"1px solid {BORDER}",
                                        white_space="nowrap",
                                    ),
                                ),
                            ),
                            background=SURF,
                        ),
                        rx.table.body(
                            rx.foreach(
                                msg["datos_db"],
                                lambda row: rx.table.row(
                                    rx.foreach(
                                        row,
                                        lambda kv: rx.table.cell(
                                            rx.text(kv[1], font_size="0.76rem",
                                                    color=TEXT, font_family=SANS),
                                            padding="0.45rem 0.9rem",
                                            border_bottom=f"1px solid {BORDER}",
                                            white_space="nowrap",
                                        ),
                                    ),
                                    _hover={"background": DIM,
                                            "transition": "all 0.1s"},
                                ),
                            ),
                        ),
                        width="100%",
                    ),
                    overflow_x="auto", border=f"1px solid {BORDER}",
                    border_radius="8px", background=CARD,
                ),
                width="100%",
            ),
            rx.box(),
        ),
        align_items="flex-start", spacing="2", width="100%",
    )


def mensaje(msg: dict) -> rx.Component:
    return rx.vstack(
        # Burbuja usuario
        rx.box(
            rx.box(
                rx.text(msg["pregunta"], font_size="0.87rem",
                        color="#fff", line_height="1.5"),
                background=GRAD_USER,
                padding="0.65rem 1.05rem",
                border_radius="18px 18px 4px 18px",
                max_width="68%",
                box_shadow="0 2px 12px rgba(59,130,246,.15)",
            ),
            width="100%", display="flex", justify_content="flex-end",
        ),
        # Respuesta IA
        bubble_ia(msg),
        align_items="flex-start", spacing="2",
        width="100%", margin_bottom="1.2rem",
    )


def chat_panel() -> rx.Component:
    return rx.box(
        # Header
        rx.hstack(
            rx.vstack(
                rx.text("Consultor Veterinario", font_size="0.95rem",
                        font_weight="700", color=TEXT),
                rx.text("lenguaje natural → sql → ia",
                        font_size="0.6rem", color=MUTED, font_family=MONO),
                spacing="0", align_items="flex-start",
            ),
            rx.spacer(),
            rx.button(
                "Nueva sesión", on_click=State.limpiar,
                background="transparent", color=MUTED,
                border=f"1px solid {BORDER}", border_radius="8px",
                font_size="0.68rem", font_family=SANS,
                padding="0.28rem 0.85rem", cursor="pointer",
                _hover={"color": TEXT, "border_color": ACCENT},
                transition="all 0.15s",
            ),
            align="center", width="100%",
            padding="0.9rem 1.6rem",
            border_bottom=f"1px solid {BORDER}", background=SURF,
        ),

        # Historial
        rx.box(
            rx.cond(
                State.historial.length() == 0,
                rx.box(
                    rx.vstack(
                        rx.icon("stethoscope", size=36,
                                color=MUTED, opacity="0.3"),
                        rx.text("¿En qué puedo ayudarte?",
                                font_size="0.9rem", color=MUTED,
                                font_weight="600"),
                        rx.text("Selecciona un ejemplo o escribe tu consulta",
                                font_size="0.72rem", color=DIM),
                        spacing="2", align="center",
                    ),
                    position="absolute", top="50%", left="50%",
                    transform="translate(-50%, -50%)",
                    text_align="center",
                ),
                rx.box(),
            ),

            rx.foreach(State.historial, mensaje),

            # Pregunta actual (cargando)
            rx.cond(
                State.pregunta_mostrada != "",
                rx.box(
                    rx.box(
                        rx.text(State.pregunta_mostrada, font_size="0.87rem",
                                color="#fff", line_height="1.5"),
                        background=GRAD_USER,
                        padding="0.65rem 1.05rem",
                        border_radius="18px 18px 4px 18px",
                        max_width="68%",
                        box_shadow="0 2px 12px rgba(59,130,246,.15)",
                    ),
                    width="100%", display="flex", justify_content="flex-end",
                    margin_bottom="1.2rem",
                ),
                rx.box(),
            ),

            rx.cond(
                State.cargando,
                rx.hstack(
                    rx.spinner(color=ACCENT, size="2"),
                    rx.text("Procesando...", font_size="0.76rem",
                            color=MUTED, font_family=MONO),
                    spacing="2", padding_y="0.5rem",
                ),
                rx.box(),
            ),

            padding="1.4rem 1.6rem",
            flex="1", overflow_y="auto", position="relative",
            id="chat-container",
            css={"&::-webkit-scrollbar": {"width": "4px"},
                 "&::-webkit-scrollbar-thumb": {
                     "background": BORDER, "border-radius": "4px"}},
        ),

        # Input
        rx.box(
            rx.hstack(
                rx.input(
                    placeholder="Escribe tu pregunta aquí...",
                    value=State.pregunta,
                    on_change=State.set_pregunta,
                    on_key_down=State.handle_enter,
                    font_size="0.86rem", font_family=SANS,
                    background=CARD, color=TEXT,
                    border=f"1px solid {BORDER}", border_radius="10px",
                    padding="0.75rem 1.1rem", height="46px", flex="1",
                    _placeholder={"color": MUTED},
                    _focus={"border_color": ACCENT,
                            "box_shadow": "0 0 0 3px rgba(129,140,248,.12)",
                            "outline": "none"},
                    transition="all 0.2s",
                ),
                rx.button(
                    rx.cond(State.cargando, "···", "Enviar"),
                    on_click=State.enviar, disabled=State.cargando,
                    background=GRAD, color="#fff",
                    font_family=SANS, font_size="0.82rem",
                    font_weight="600", border="none",
                    border_radius="10px", padding="0 1.4rem",
                    height="46px", cursor="pointer",
                    _hover={"opacity": "0.88"},
                    _disabled={"opacity": "0.35", "cursor": "not-allowed"},
                    transition="all 0.15s",
                ),
                spacing="2",
            ),
            padding="0.9rem 1.6rem 1.2rem",
            border_top=f"1px solid {BORDER}", background=SURF,
        ),

        flex="1", display="flex", flex_direction="column",
        height="100vh", background=BG, overflow="hidden",
    )


def index() -> rx.Component:
    return rx.box(
        sidebar(), chat_panel(),
        display="flex", width="100vw", height="100vh",
        font_family=SANS, background=BG, color=TEXT,
        overflow="hidden", on_mount=State.cargar_stats,
    )


app = rx.App(
    stylesheets=[
        "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap",
        "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500&display=swap",
    ],
    style={"margin": "0", "padding": "0", "box_sizing": "border-box",
           "body": {"margin": "0", "padding": "0", "overflow": "hidden"}},
)
app.add_page(index, route="/", title="VetAI")
