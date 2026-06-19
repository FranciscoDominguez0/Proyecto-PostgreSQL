# FRONTEND — ShopAI
import reflex as rx
import httpx
from typing import Any

BACKEND_URL = "http://localhost:8000"

BG, SURF, CARD = "#0b0d14", "#111420", "#161929"
BORDER         = "#1f2440"
ACCENT         = "#38bdf8"
TEXT, MUTED    = "#e1e6f0", "#4a5580"
DIM            = "#1a1f35"
GREEN, RED     = "#34d399", "#f87171"
MONO           = "'JetBrains Mono', monospace"
SANS           = "'Inter', system-ui, sans-serif"
GRAD           = "linear-gradient(135deg, #38bdf8, #818cf8)"


class State(rx.State):
    pregunta: str = ""
    pregunta_mostrada: str = ""
    respuesta_ia: str = ""
    sql_ejecutado: str = ""
    datos_db: list[dict] = []
    error: str = ""
    cargando: bool = False
    total_clientes: int = 0
    total_productos: int = 0
    total_pedidos: int = 0
    stats_ok: bool = False
    activa: str = ""

    async def cargar_stats(self):
        try:
            async with httpx.AsyncClient(timeout=10) as c:
                r = await c.get(f"{BACKEND_URL}/stats")
                if r.status_code == 200:
                    d = r.json()
                    self.total_clientes  = d.get("clientes", 0)
                    self.total_productos = d.get("productos", 0)
                    self.total_pedidos   = d.get("pedidos", 0)
                    self.stats_ok = True
        except Exception: pass

    def set_pregunta(self, v: str): self.pregunta = v
    def set_sugerida(self, p: str): self.pregunta = p; self.activa = p
    def handle_enter(self, k: str):
        if k == "Enter": return State.enviar()

    def limpiar(self):
        self.pregunta = self.pregunta_mostrada = self.respuesta_ia = ""
        self.sql_ejecutado = ""; self.datos_db = []; self.error = ""; self.activa = ""

    async def enviar(self):
        if not self.pregunta.strip(): return
        self.cargando = True
        self.pregunta_mostrada = self.pregunta
        self.respuesta_ia = self.sql_ejecutado = self.error = ""
        self.datos_db = []
        yield
        try:
            async with httpx.AsyncClient(timeout=60) as c:
                r = await c.post(f"{BACKEND_URL}/consulta", json={"pregunta": self.pregunta})
                d = r.json()
                self.respuesta_ia  = d.get("respuesta_ia", "")
                self.sql_ejecutado = d.get("sql_ejecutado", "")
                self.datos_db      = d.get("datos_db", [])
                self.error         = d.get("error") or ""
        except httpx.ConnectError: self.error = "Sin conexion con el backend"
        except Exception as e: self.error = str(e)
        finally: self.cargando = False


CHIPS = ["Cuantos clientes hay", "Producto mas vendido", "Pedidos pendientes",
         "Top 5 clientes por gasto", "Categoria con mas ingresos", "Stock bajo 15"]


def stat(label: str, val: Any, color: str) -> rx.Component:
    return rx.hstack(
        rx.text(label, color=MUTED, font_size="0.7rem", font_family=MONO, flex="1"),
        rx.cond(State.stats_ok,
                rx.text(val, color=color, font_size="0.78rem", font_weight="600", font_family=MONO),
                rx.text("—", color=DIM, font_size="0.78rem", font_family=MONO)),
        width="100%", align="center", padding_y="0.25rem",
    )


def chip(t: str) -> rx.Component:
    return rx.button(
        t, on_click=State.set_sugerida(t),
        font_size="0.67rem", font_family=MONO,
        padding="0.2rem 0.55rem", border_radius="999px",
        background=rx.cond(State.activa == t, ACCENT, DIM),
        color=rx.cond(State.activa == t, BG, MUTED),
        border="none", cursor="pointer",
        transition="all 0.15s",
        _hover={"background": ACCENT, "color": BG},
    )


def sidebar() -> rx.Component:
    return rx.box(
        rx.text("ShopAI", font_size="1rem", font_weight="700", color=TEXT, font_family=MONO),
        rx.text("commerce · intelligence", font_size="0.58rem", color=MUTED,
                font_family=MONO, margin_bottom="1.5rem"),
        rx.divider(color_scheme="gray", margin_y="0.1rem"),

        rx.vstack(
            rx.text("DATABASE", font_size="0.56rem", color=MUTED,
                    letter_spacing="0.13em", font_family=MONO, font_weight="600",
                    margin_top="1.25rem"),
            stat("clientes",  State.total_clientes,  ACCENT),
            stat("productos", State.total_productos, GREEN),
            stat("pedidos",   State.total_pedidos,   "#a5b4fc"),
            spacing="0", align_items="stretch", width="100%",
        ),

        rx.divider(color_scheme="gray", margin_y="1.25rem"),
        rx.text("QUERIES", font_size="0.56rem", color=MUTED,
                letter_spacing="0.13em", font_family=MONO, font_weight="600",
                margin_bottom="0.5rem"),
        rx.flex(*[chip(s) for s in CHIPS], flex_wrap="wrap", gap="0.28rem"),

        rx.spacer(),
        rx.text("FastAPI · Reflex · DeepSeek",
                font_size="0.57rem", color=DIM, font_family=MONO),

        width="210px", min_width="210px", height="100vh",
        background=SURF, border_right=f"1px solid {BORDER}",
        padding="1.4rem 1.1rem",
        display="flex", flex_direction="column", overflow_y="auto",
    )


def resultado() -> rx.Component:
    return rx.cond(
        State.respuesta_ia != "",
        rx.vstack(
            # Respuesta con markdown
            rx.box(
                rx.markdown(State.respuesta_ia, component_map={
                    "p": lambda t: rx.text(t, font_size="0.86rem", color=TEXT,
                                           line_height="1.75", margin_bottom="0.4rem"),
                    "strong": lambda t: rx.text(t, font_weight="700", color=ACCENT, display="inline"),
                    "li": lambda t: rx.text("· ", t, font_size="0.86rem", color=TEXT, line_height="1.6"),
                    "code": lambda t: rx.code(t, font_size="0.76rem", color="#94a3b8",
                                              font_family=MONO, background=BG,
                                              padding="0.1rem 0.35rem", border_radius="4px"),
                }),
                background=CARD, border=f"1px solid {BORDER}",
                border_radius="4px 16px 16px 16px",
                padding="0.95rem 1.2rem", max_width="85%",
            ),

            # SQL block
            rx.cond(
                State.sql_ejecutado != "",
                rx.box(
                    rx.text("sql", font_size="0.58rem", color=MUTED,
                            font_family=MONO, letter_spacing="0.12em", margin_bottom="0.4rem"),
                    rx.text(State.sql_ejecutado, font_size="0.74rem", color="#64748b",
                            font_family=MONO, white_space="pre-wrap", line_height="1.55"),
                    background="#08090f", border=f"1px solid {BORDER}",
                    border_radius="8px", padding="0.75rem 1rem", width="100%",
                ),
                rx.box(),
            ),

            # Tabla
            rx.cond(
                State.datos_db.length() > 0,
                rx.box(
                    rx.text("datos", font_size="0.58rem", color=MUTED,
                            font_family=MONO, letter_spacing="0.12em", margin_bottom="0.4rem"),
                    rx.box(
                        rx.table.root(
                            rx.table.header(rx.table.row(
                                rx.foreach(State.datos_db[0],
                                    lambda kv: rx.table.column_header_cell(
                                        kv[0], font_size="0.6rem", text_transform="uppercase",
                                        color=ACCENT, padding="0.4rem 0.85rem",
                                        background=DIM, font_family=MONO, white_space="nowrap")),
                            )),
                            rx.table.body(rx.foreach(State.datos_db,
                                lambda row: rx.table.row(
                                    rx.foreach(row, lambda kv: rx.table.cell(
                                        rx.text(kv[1], font_size="0.77rem", color=MUTED, font_family=MONO),
                                        padding="0.38rem 0.85rem",
                                        border_bottom=f"1px solid {BORDER}",
                                        white_space="nowrap")),
                                    _hover={"background": DIM}))),
                            width="100%",
                        ),
                        overflow_x="auto", border=f"1px solid {BORDER}",
                        border_radius="8px", background=CARD,
                    ),
                    width="100%",
                ),
                rx.box(),
            ),

            align_items="flex-start", spacing="3", width="100%", margin_bottom="1rem",
        ),
        rx.box(),
    )


def chat_panel() -> rx.Component:
    return rx.box(
        # Header
        rx.hstack(
            rx.box(
                rx.text("Consultor IA", font_size="0.9rem", font_weight="600", color=TEXT),
                rx.text("lenguaje natural → sql → ia", font_size="0.61rem", color=MUTED, font_family=MONO),
            ),
            rx.spacer(),
            rx.button("limpiar", on_click=State.limpiar,
                      background="transparent", color=MUTED, border=f"1px solid {BORDER}",
                      border_radius="8px", font_size="0.7rem", font_family=MONO,
                      padding="0.28rem 0.7rem", cursor="pointer",
                      _hover={"color": TEXT, "border_color": ACCENT}, transition="all 0.15s"),
            align="center", width="100%",
            padding="0.85rem 1.4rem", border_bottom=f"1px solid {BORDER}", background=SURF,
        ),

        # Área de chat
        rx.box(
            rx.cond(
                (State.pregunta_mostrada == "") & ~State.cargando,
                rx.box(
                    rx.text("Escribe una pregunta o selecciona un query",
                            font_size="0.82rem", color=MUTED),
                    position="absolute", top="50%", left="50%",
                    transform="translate(-50%, -50%)", text_align="center",
                ),
                rx.box(),
            ),

            rx.cond(
                State.pregunta_mostrada != "",
                rx.box(
                    rx.box(rx.text(State.pregunta_mostrada, font_size="0.86rem",
                                   color="white", line_height="1.6"),
                           background=GRAD, padding="0.7rem 1rem",
                           border_radius="16px 16px 4px 16px", max_width="72%",
                           box_shadow="0 2px 16px rgba(56,189,248,.15)"),
                    display="flex", justify_content="flex-end", margin_bottom="1rem",
                ),
                rx.box(),
            ),

            rx.cond(State.cargando,
                    rx.hstack(rx.spinner(color=ACCENT, size="2"),
                              rx.text("procesando...", font_size="0.76rem",
                                      color=MUTED, font_family=MONO),
                              spacing="2", margin_bottom="1rem"),
                    rx.box()),

            rx.cond(State.error != "",
                    rx.box(rx.text(State.error, font_size="0.78rem", color=RED,
                                   font_family=MONO, white_space="pre-wrap"),
                           background=CARD, border=f"1px solid {BORDER}",
                           border_left=f"2px solid {RED}", border_radius="8px",
                           padding="0.75rem 1rem", margin_bottom="1rem"),
                    rx.box()),

            resultado(),

            padding="1.2rem 1.4rem", flex="1",
            overflow_y="auto", position="relative",
        ),

        # Input
        rx.box(
            rx.hstack(
                rx.input(
                    placeholder="escribe tu pregunta...",
                    value=State.pregunta,
                    on_change=State.set_pregunta,
                    on_key_down=State.handle_enter,
                    font_size="0.85rem", font_family=SANS,
                    background=CARD, color=TEXT,
                    border=f"1px solid {BORDER}", border_radius="10px",
                    padding="0.7rem 1rem", height="44px", flex="1",
                    _placeholder={"color": MUTED},
                    _focus={"border_color": ACCENT, "box_shadow": "0 0 0 2px rgba(56,189,248,.15)", "outline": "none"},
                    transition="all 0.2s",
                ),
                rx.button(
                    rx.cond(State.cargando, "...", "enviar"),
                    on_click=State.enviar, disabled=State.cargando,
                    background=GRAD, color=BG, font_family=MONO,
                    font_size="0.78rem", font_weight="700",
                    border="none", border_radius="10px",
                    padding="0 1.1rem", height="44px", cursor="pointer",
                    _hover={"opacity": "0.85"},
                    _disabled={"opacity": "0.4", "cursor": "not-allowed"},
                    transition="all 0.15s",
                ),
                spacing="2",
            ),
            padding="0.9rem 1.4rem", border_top=f"1px solid {BORDER}", background=SURF,
        ),

        flex="1", display="flex", flex_direction="column",
        height="100vh", background=BG, overflow="hidden",
    )


def index() -> rx.Component:
    return rx.box(
        sidebar(), chat_panel(),
        display="flex", width="100vw", height="100vh",
        font_family=SANS, background=BG, color=TEXT,
        on_mount=State.cargar_stats,
    )


app = rx.App(
    stylesheets=[
        "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap",
        "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500&display=swap",
    ],
    style={"margin": "0", "padding": "0"},
)
app.add_page(index, route="/", title="ShopAI")
