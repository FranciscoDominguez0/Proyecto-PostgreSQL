# =============================================
# FRONTEND - Reflex  |  ShopAI Chat Interface
# =============================================

import reflex as rx
import httpx
from typing import Any

BACKEND_URL = "http://localhost:8000"

# ─── Tokens de diseño ────────────────────────────────────────────────────────

BG       = "#08090f"
SURFACE  = "#0d1117"
CARD     = "#111820"
BORDER   = "#1a2535"
ACCENT   = "#06b6d4"
ACCENT2  = "#0ea5e9"
GRAD     = "linear-gradient(135deg, #06b6d4, #0ea5e9)"
TEXT     = "#e2e8f0"
MUTED    = "#64748b"
DIM      = "#1e2d3d"
GREEN    = "#10b981"
RED      = "#f87171"
CODE_CLR = "#7dd3fc"
MONO     = "'JetBrains Mono', monospace"
SANS     = "'Inter', system-ui, sans-serif"

# ─── Estado ───────────────────────────────────────────────────────────────────

class State(rx.State):
    pregunta: str = ""
    respuesta_ia: str = ""
    sql_ejecutado: str = ""
    datos_db: list[dict] = []
    error: str = ""
    cargando: bool = False

    total_clientes: int = 0
    total_productos: int = 0
    total_pedidos: int = 0
    total_ventas: float = 0.0
    stats_cargadas: bool = False
    pregunta_activa: str = ""
    pregunta_mostrada: str = ""

    async def cargar_stats(self):
        try:
            async with httpx.AsyncClient(timeout=10) as c:
                r = await c.get(f"{BACKEND_URL}/stats")
                if r.status_code == 200:
                    d = r.json()
                    self.total_clientes  = d.get("clientes", 0)
                    self.total_productos = d.get("productos", 0)
                    self.total_pedidos   = d.get("pedidos", 0)
                    self.total_ventas    = d.get("ventas_total", 0.0)
                    self.stats_cargadas  = True
        except Exception:
            pass

    def set_pregunta(self, v: str):
        self.pregunta = v

    def set_pregunta_sugerida(self, p: str):
        self.pregunta = p
        self.pregunta_activa = p

    def handle_enter(self, key: str):
        if key == "Enter":
            return State.enviar_consulta()

    def limpiar(self):
        self.pregunta = ""
        self.respuesta_ia = ""
        self.sql_ejecutado = ""
        self.datos_db = []
        self.error = ""
        self.pregunta_activa = ""
        self.pregunta_mostrada = ""

    async def enviar_consulta(self):
        if not self.pregunta.strip():
            return
        self.cargando = True
        self.pregunta_mostrada = self.pregunta
        self.respuesta_ia = ""
        self.sql_ejecutado = ""
        self.datos_db = []
        self.error = ""
        yield

        try:
            async with httpx.AsyncClient(timeout=60) as c:
                r = await c.post(f"{BACKEND_URL}/consulta",
                                 json={"pregunta": self.pregunta})
                if r.status_code == 200:
                    d = r.json()
                    self.respuesta_ia  = d.get("respuesta_ia", "")
                    self.sql_ejecutado = d.get("sql_ejecutado", "")
                    self.datos_db      = d.get("datos_db", [])
                    self.error         = d.get("error") or ""
                else:
                    self.error = f"Error {r.status_code}"
        except httpx.ConnectError:
            self.error = "Sin conexion con el backend — localhost:8000"
        except Exception as e:
            self.error = str(e)
        finally:
            self.cargando = False

# ─── Sugerencias ──────────────────────────────────────────────────────────────

SUGERENCIAS = [
    "Cuantos clientes hay",
    "Producto mas vendido",
    "Pedidos pendientes",
    "Top 5 clientes por gasto",
    "Categoria con mas ingresos",
    "Stock bajo 15 unidades",
    "Pedido de mayor valor",
    "Resumen por estado",
]

# ─── Componentes ──────────────────────────────────────────────────────────────

def stat_item(label: str, valor: Any, color: str) -> rx.Component:
    return rx.hstack(
        rx.text(label, color=MUTED, font_size="0.72rem", font_family=MONO, flex="1"),
        rx.cond(
            State.stats_cargadas,
            rx.text(valor, color=color, font_size="0.8rem",
                    font_weight="600", font_family=MONO),
            rx.text("--", color=DIM, font_size="0.8rem", font_family=MONO),
        ),
        width="100%", align="center", padding_y="0.3rem",
    )


def chip(texto: str) -> rx.Component:
    return rx.button(
        texto,
        on_click=State.set_pregunta_sugerida(texto),
        background=rx.cond(State.pregunta_activa == texto, ACCENT, DIM),
        color=rx.cond(State.pregunta_activa == texto, "white", MUTED),
        font_size="0.68rem", font_family=MONO,
        padding="0.25rem 0.6rem",
        border_radius="999px",
        border="none", cursor="pointer",
        transition="all 0.2s",
        _hover={"background": ACCENT, "color": "white"},
        white_space="normal", text_align="left",
    )


def sidebar() -> rx.Component:
    return rx.box(
        # Logo
        rx.vstack(
            rx.hstack(
                rx.box(
                    width="8px", height="8px",
                    border_radius="50%",
                    background=GRAD,
                    box_shadow=f"0 0 8px {ACCENT}",
                ),
                rx.text("ShopAI", font_size="0.95rem", font_weight="700",
                        color=TEXT, font_family=MONO),
                align="center", spacing="2",
            ),
            rx.text("commerce intelligence", font_size="0.62rem",
                    color=MUTED, font_family=MONO),
            align_items="flex-start", spacing="1",
            margin_bottom="1.75rem",
            padding_bottom="1.25rem",
            border_bottom=f"1px solid {BORDER}",
        ),

        # Stats
        rx.vstack(
            rx.text("DATABASE", font_size="0.58rem", color=DIM,
                    letter_spacing="0.14em", font_family=MONO,
                    font_weight="700", margin_bottom="0.5rem"),
            stat_item("clientes",  State.total_clientes,  ACCENT2),
            stat_item("productos", State.total_productos, GREEN),
            stat_item("pedidos",   State.total_pedidos,   "#a78bfa"),
            stat_item("ventas $",  State.total_ventas,    MUTED),
            align_items="stretch", spacing="0",
            margin_bottom="1.75rem",
        ),

        # Chips
        rx.vstack(
            rx.text("QUERIES", font_size="0.58rem", color=DIM,
                    letter_spacing="0.14em", font_family=MONO,
                    font_weight="700", margin_bottom="0.5rem"),
            rx.flex(*[chip(s) for s in SUGERENCIAS],
                    flex_wrap="wrap", gap="0.35rem"),
            align_items="flex-start", spacing="0",
        ),

        # Footer
        rx.box(
            rx.text("FastAPI · Reflex · DeepSeek",
                    font_size="0.6rem", color=DIM, font_family=MONO),
            margin_top="auto",
            padding_top="1.5rem",
        ),

        width="230px", min_width="230px",
        height="100vh",
        background=SURFACE,
        border_right=f"1px solid {BORDER}",
        padding="1.5rem 1.1rem",
        display="flex",
        flex_direction="column",
        overflow_y="auto",
    )


def burbuja_usuario() -> rx.Component:
    return rx.cond(
        State.pregunta_mostrada != "",
        rx.box(
            rx.box(
                rx.text(State.pregunta_mostrada,
                        font_size="0.88rem", color="white",
                        line_height="1.6"),
                background=GRAD,
                padding="0.75rem 1.1rem",
                border_radius="18px 18px 4px 18px",
                max_width="75%",
                box_shadow=f"0 4px 20px {ACCENT}33",
            ),
            display="flex",
            justify_content="flex-end",
            margin_bottom="1rem",
        ),
        rx.box(),
    )


def card_ia() -> rx.Component:
    return rx.cond(
        State.respuesta_ia != "",
        rx.vstack(
            # Respuesta
            rx.box(
                rx.markdown(
                    State.respuesta_ia,
                    component_map={
                        "p": lambda text: rx.text(text, font_size="0.88rem",
                                                  color=TEXT, line_height="1.75",
                                                  margin_bottom="0.5rem"),
                        "strong": lambda text: rx.text(text, font_weight="700",
                                                       color=ACCENT2, display="inline"),
                        "code": lambda text: rx.code(text, font_size="0.78rem",
                                                     color=CODE_CLR, font_family=MONO,
                                                     background=BG, padding="0.1rem 0.35rem",
                                                     border_radius="4px"),
                    },
                ),
                background=CARD,
                border=f"1px solid {BORDER}",
                border_radius="4px 18px 18px 18px",
                padding="1rem 1.25rem",
                max_width="85%",
            ),

            # SQL
            rx.cond(
                State.sql_ejecutado != "",
                rx.box(
                    rx.text("SQL", font_size="0.6rem", color=MUTED,
                            font_family=MONO, letter_spacing="0.1em",
                            margin_bottom="0.4rem"),
                    rx.code(State.sql_ejecutado,
                            font_size="0.75rem", color=CODE_CLR,
                            font_family=MONO, display="block",
                            white_space="pre-wrap"),
                    background=BG,
                    border=f"1px solid {BORDER}",
                    border_left=f"3px solid {ACCENT}",
                    border_radius="8px",
                    padding="0.75rem 1rem",
                    width="100%",
                ),
                rx.box(),
            ),

            # Tabla
            rx.cond(
                State.datos_db.length() > 0,
                rx.box(
                    rx.text("DATOS", font_size="0.6rem", color=MUTED,
                            font_family=MONO, letter_spacing="0.1em",
                            margin_bottom="0.4rem"),
                    rx.box(
                        rx.table.root(
                            rx.table.header(
                                rx.table.row(
                                    rx.foreach(
                                        State.datos_db[0],
                                        lambda kv: rx.table.column_header_cell(
                                            kv[0],
                                            font_size="0.62rem",
                                            text_transform="uppercase",
                                            letter_spacing="0.07em",
                                            color="#a78bfa",
                                            padding="0.45rem 0.9rem",
                                            background=DIM,
                                            font_family=MONO,
                                            white_space="nowrap",
                                        ),
                                    ),
                                ),
                            ),
                            rx.table.body(
                                rx.foreach(
                                    State.datos_db,
                                    lambda row: rx.table.row(
                                        rx.foreach(
                                            row,
                                            lambda kv: rx.table.cell(
                                                rx.text(kv[1],
                                                        font_size="0.78rem",
                                                        color=MUTED,
                                                        font_family=MONO),
                                                padding="0.4rem 0.9rem",
                                                border_bottom=f"1px solid {BORDER}",
                                                white_space="nowrap",
                                            ),
                                        ),
                                        _hover={"background": DIM},
                                    ),
                                ),
                            ),
                            width="100%",
                        ),
                        overflow_x="auto",
                        border=f"1px solid {BORDER}",
                        border_radius="8px",
                        background=CARD,
                    ),
                    width="100%",
                ),
                rx.box(),
            ),

            align_items="flex-start",
            spacing="3",
            width="100%",
            margin_bottom="1rem",
        ),
        rx.box(),
    )


def card_error() -> rx.Component:
    return rx.cond(
        State.error != "",
        rx.box(
            rx.text(State.error, font_size="0.8rem", color=RED,
                    font_family=MONO, white_space="pre-wrap"),
            background=CARD,
            border=f"1px solid {BORDER}",
            border_left=f"3px solid {RED}",
            border_radius="8px",
            padding="0.85rem 1rem",
            margin_bottom="1rem",
            width="100%",
        ),
        rx.box(),
    )


def estado_vacio() -> rx.Component:
    return rx.cond(
        (State.pregunta_mostrada == "") & ~State.cargando,
        rx.box(
            rx.vstack(
                rx.box(
                    width="40px", height="40px",
                    border_radius="50%",
                    background=GRAD,
                    box_shadow=f"0 0 20px {ACCENT}44",
                    margin_bottom="0.75rem",
                ),
                rx.text("Haz una pregunta",
                        font_size="0.95rem", font_weight="600", color=TEXT),
                rx.text("selecciona una sugerencia o escribe tu consulta",
                        font_size="0.78rem", color=MUTED),
                align="center", spacing="1",
            ),
            display="flex",
            align_items="center",
            justify_content="center",
            flex="1",
        ),
        rx.box(),
    )


# ─── Página principal ─────────────────────────────────────────────────────────

def index() -> rx.Component:
    return rx.box(
        sidebar(),

        # Panel de chat
        rx.box(
            # Header
            rx.hstack(
                rx.vstack(
                    rx.text("Consultor", font_size="0.95rem",
                            font_weight="600", color=TEXT),
                    rx.text("lenguaje natural  →  sql  →  ia",
                            font_size="0.65rem", color=MUTED,
                            font_family=MONO),
                    align_items="flex-start", spacing="0",
                ),
                rx.spacer(),
                rx.button(
                    "limpiar",
                    on_click=State.limpiar,
                    background="transparent",
                    color=MUTED, font_family=MONO,
                    font_size="0.72rem",
                    border=f"1px solid {BORDER}",
                    border_radius="8px",
                    padding="0.3rem 0.75rem",
                    cursor="pointer",
                    _hover={"color": TEXT, "border_color": MUTED},
                    transition="all 0.15s",
                ),
                width="100%", align="center",
                padding="0.9rem 1.5rem",
                border_bottom=f"1px solid {BORDER}",
                background=SURFACE,
            ),

            # Area de mensajes
            rx.box(
                estado_vacio(),
                burbuja_usuario(),

                rx.cond(
                    State.cargando,
                    rx.box(
                        rx.hstack(
                            rx.box(width="6px", height="6px", border_radius="50%",
                                   background=ACCENT, animation="pulse 1.2s infinite"),
                            rx.box(width="6px", height="6px", border_radius="50%",
                                   background=ACCENT, animation="pulse 1.2s infinite 0.2s"),
                            rx.box(width="6px", height="6px", border_radius="50%",
                                   background=ACCENT, animation="pulse 1.2s infinite 0.4s"),
                            spacing="2",
                        ),
                        padding="0.75rem 1rem",
                        background=CARD,
                        border_radius="8px 18px 18px 18px",
                        display="inline-block",
                        margin_bottom="1rem",
                    ),
                    rx.box(),
                ),

                card_error(),
                card_ia(),

                padding="1.25rem 1.5rem",
                flex="1",
                overflow_y="auto",
                display="flex",
                flex_direction="column",
            ),

            # Barra de input
            rx.box(
                rx.hstack(
                    rx.input(
                        placeholder="escribe tu pregunta...",
                        value=State.pregunta,
                        on_change=State.set_pregunta,
                        on_key_down=State.handle_enter,
                        font_size="0.88rem",
                        font_family=SANS,
                        background=CARD,
                        color=TEXT,
                        border=f"1px solid {BORDER}",
                        border_radius="12px",
                        padding="0.75rem 1.1rem",
                        height="46px",
                        flex="1",
                        _placeholder={"color": MUTED},
                        _focus={
                            "border_color": ACCENT,
                            "box_shadow": f"0 0 0 3px {ACCENT}22",
                            "outline": "none",
                        },
                        transition="all 0.2s",
                    ),
                    rx.button(
                        rx.cond(State.cargando, "...", "enviar"),
                        on_click=State.enviar_consulta,
                        disabled=State.cargando,
                        background=GRAD,
                        color="white",
                        font_family=MONO,
                        font_size="0.8rem",
                        font_weight="600",
                        border="none",
                        border_radius="12px",
                        padding="0 1.25rem",
                        height="46px",
                        cursor="pointer",
                        box_shadow=f"0 4px 16px {ACCENT}44",
                        _hover={"opacity": "0.88"},
                        _disabled={"opacity": "0.4", "cursor": "not-allowed"},
                        transition="all 0.2s",
                    ),
                    spacing="3",
                ),
                padding="1rem 1.5rem",
                border_top=f"1px solid {BORDER}",
                background=SURFACE,
            ),

            flex="1",
            display="flex",
            flex_direction="column",
            height="100vh",
            background=BG,
            overflow="hidden",
        ),

        display="flex",
        width="100vw",
        height="100vh",
        font_family=SANS,
        background=BG,
        color=TEXT,
        on_mount=State.cargar_stats,
    )


# ─── App ──────────────────────────────────────────────────────────────────────

app = rx.App(
    stylesheets=[
        "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap",
        "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500&display=swap",
    ],
    style={"margin": "0", "padding": "0", "box_sizing": "border-box"},
)
app.add_page(index, route="/", title="ShopAI")
