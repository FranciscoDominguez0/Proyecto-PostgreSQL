import reflex as rx
import httpx
from typing import TypedDict
import os

BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:8000")

# Paleta
BG="#121417"; SURF="#171A1E"; CARD="#20242A"; CARD2="#1A1D21"; BORDER="#2C3138"
TEXT="#F2F3F5"; SUB="#A7ADB7"; DIM="#6F7682"; ACCENT="#8EBB67"; ACLT="#6F9E4A"
BTN="#5E7F45"; ERR="#D96C6C"; WARN="#D8A43A"; USER_BG="#2E3D30"
MONO="'JetBrains Mono',monospace"; SANS="'Inter',system-ui,sans-serif"
GRAD="linear-gradient(135deg,#121417 0%,#161A1F 45%,#101214 100%)"

# Estilos reutilizables
_card  = {"background": CARD,  "border": f"1px solid {BORDER}", "border_radius": "10px"}
_row   = {"position": "relative", "width": "100%", "height": "34px"}
_abs_l = lambda l: {"position":"absolute","left":l,"top":"50%","transform":"translateY(-50%)"}
_abs_r = {"position":"absolute","right":"0.75rem","top":"50%","transform":"translateY(-50%)"}

MODULOS = [
    ("paw-print","Cuantas mascotas hay"), ("user","Lista de propietarios"),
    ("link-2","Mascotas y sus duenos"),   ("syringe","Vacunas aplicadas"),
    ("clipboard-list","Consultas completadas"), ("bar-chart-2","Mascotas por especie"),
]
STATS = [
    ("user","Propietarios",lambda: State.total_propietarios,"#22d3ee"),
    ("paw-print","Mascotas",lambda: State.total_mascotas, ACCENT),
    ("syringe","Vacunas",lambda: State.total_vacunas, WARN),
    ("clipboard-list","Consultas",lambda: State.total_consultas,"#60a5fa"),
    ("dollar-sign","Ingresos",lambda: "$"+State.ingresos_total.to_string(),"#c084fc"),
]


class Mensaje(TypedDict):
    pregunta:str; respuesta_ia:str; sql_ejecutado:str
    datos_db:list[dict[str,str]]; error:str


class State(rx.State):
    pregunta:str=""; pregunta_mostrada:str=""; cargando:bool=False
    historial:list[Mensaje]=[]; activa:str=""
    total_propietarios:int=0; total_mascotas:int=0
    total_vacunas:int=0; total_consultas:int=0
    ingresos_total:float=0.0; stats_ok:bool=False

    async def cargar_stats(self):
        try:
            async with httpx.AsyncClient(timeout=10) as c:
                r = await c.get(f"{BACKEND_URL}/stats")
                if r.status_code == 200:
                    d = r.json()
                    self.total_propietarios=d.get("propietarios",0)
                    self.total_mascotas=d.get("mascotas",0)
                    self.total_vacunas=d.get("vacunas",0)
                    self.total_consultas=d.get("consultas",0)
                    self.ingresos_total=d.get("ingresos_total",0.0)
                    self.stats_ok=True
        except Exception: pass

    def set_pregunta(self,v): self.pregunta=v
    def set_sugerida(self,p): self.pregunta=p; self.activa=p
    def handle_enter(self,k):
        if k=="Enter": return State.enviar()
    def limpiar(self): self.historial=[]; self.pregunta=""; self.activa=""

    async def enviar(self):
        if not self.pregunta.strip(): return
        texto=self.pregunta; self.pregunta_mostrada=texto
        self.pregunta=""; self.activa=""; self.cargando=True
        yield rx.call_script("setTimeout(()=>{var e=document.getElementById('chat');if(e)e.scrollTop=e.scrollHeight;},80)")
        try:
            async with httpx.AsyncClient(timeout=60) as c:
                r=await c.post(f"{BACKEND_URL}/consulta",json={"pregunta":texto})
                d=r.json()
                msg={"pregunta":texto,"respuesta_ia":d.get("respuesta_ia",""),
                     "sql_ejecutado":d.get("sql_ejecutado",""),
                     "datos_db":d.get("datos_db",[]),"error":d.get("error") or ""}
        except httpx.ConnectError:
            msg={"pregunta":texto,"respuesta_ia":"","sql_ejecutado":"","datos_db":[],"error":"Sin conexion con el backend"}
        except Exception as e:
            msg={"pregunta":texto,"respuesta_ia":"","sql_ejecutado":"","datos_db":[],"error":str(e)}
        self.historial.append(msg); self.cargando=False; self.pregunta_mostrada=""
        yield rx.call_script("setTimeout(()=>{var el=document.querySelector('.ai-block:last-of-type');if(el)el.scrollIntoView({behavior:'smooth',block:'start'});},120)")


# Componentes sidebar
def _stat(ic,lb,val,col):
    return rx.box(
        rx.icon(ic,size=13,color=col,**_abs_l("0.75rem")),
        rx.text(lb,color=SUB,font_size="0.72rem",font_family=SANS,**_abs_l("2rem"),white_space="nowrap"),
        rx.cond(State.stats_ok,
            rx.text(val(),color=col,font_size="0.75rem",font_weight="700",font_family=MONO,**_abs_r),
            rx.box(width="22px",height="7px",background=BORDER,border_radius="3px",**_abs_r),
        ),
        **_row, border_bottom=f"1px solid {BORDER}",
    )

def _modulo(ic,lb):
    actv=State.activa==lb
    return rx.box(
        rx.icon(ic,size=14,color=rx.cond(actv,ACCENT,DIM),**_abs_l("0.7rem")),
        rx.text(lb,font_size="0.72rem",font_family=SANS,
                color=rx.cond(actv,TEXT,SUB),**_abs_l("2.1rem"),white_space="nowrap"),
        on_click=State.set_sugerida(lb),**_row,
        background=rx.cond(actv,f"{ACCENT}15","transparent"),
        border_radius="8px",
        border_left=rx.cond(actv,f"2px solid {ACCENT}","2px solid transparent"),
        cursor="pointer",transition="all 0.12s",
        _hover={"background":f"{ACCENT}10","border_left_color":ACLT},
    )

def sidebar():
    return rx.box(
        rx.hstack(
            rx.box(rx.text("V",color="#fff",font_size="0.82rem",font_weight="800"),
                   background=BTN,border_radius="8px",width="28px",height="28px",min_width="28px",
                   display="flex",align_items="center",justify_content="center"),
            rx.vstack(rx.text("VetAI",font_size="0.92rem",font_weight="800",color=TEXT,letter_spacing="-0.02em"),
                      rx.text("sistema veterinario",font_size="0.52rem",color=DIM,font_family=MONO),
                      spacing="0",align_items="flex-start"),
            spacing="2",align="center",margin_bottom="1.4rem",
        ),
        rx.text("RESUMEN",font_size="0.48rem",color=DIM,letter_spacing="0.18em",font_family=MONO,font_weight="700",margin_bottom="0.35rem"),
        rx.box(*[_stat(ic,lb,val,col) for ic,lb,val,col in STATS],
               **_card, padding_y="0.15rem", padding_x="0", overflow="hidden", margin_bottom="1.3rem"),
        rx.text("MÓDULOS",font_size="0.48rem",color=DIM,letter_spacing="0.18em",font_family=MONO,font_weight="700",margin_bottom="0.4rem"),
        rx.vstack(*[_modulo(ic,lb) for ic,lb in MODULOS],spacing="1",align_items="stretch",width="100%"),
        rx.spacer(),
        rx.box(height="1px",background=BORDER,margin_bottom="0.65rem"),
        rx.text("FastAPI · Reflex · DeepSeek",font_size="0.48rem",color=DIM,font_family=MONO),
        width="215px",min_width="215px",height="100vh",background=SURF,
        border_right=f"1px solid {BORDER}",padding="1.3rem 0.85rem",
        display="flex",flex_direction="column",overflow="hidden",
    )


# Componentes chat
def _avatar():
    return rx.box(rx.icon("paw-print",size=13,color=ACCENT),
                  width="30px",height="30px",min_width="30px",
                  background=CARD2,border=f"1px solid {BORDER}",border_radius="50%",
                  display="flex",align_items="center",justify_content="center",margin_top="1px")

def _caja(**kw): return {**_card,"border_left":f"3px solid {ACCENT}","border_radius":"2px 12px 12px 12px","padding":"0.8rem 1rem","width":"100%",**kw}

def bubble_ia(msg):
    return rx.hstack(
        _avatar(),
        rx.vstack(
            rx.text("VetAI",font_size="0.7rem",font_weight="600",color=SUB,margin_bottom="0.25rem"),
            rx.box(
                rx.cond(msg["error"]!="",
                    rx.hstack(rx.icon("circle-x",size=13,color=ERR),
                              rx.text(msg["error"],font_size="0.8rem",color=ERR,font_family=MONO),
                              spacing="2",align="center"),
                    rx.markdown(msg["respuesta_ia"],font_size="0.84rem",line_height="1.65"),
                ),
                **_caja(class_name="ai-block"),
            ),
            rx.cond(msg["sql_ejecutado"]!="",
                rx.box(
                    rx.hstack(rx.icon("code-2",size=11,color=DIM),
                              rx.text("SQL ejecutado",font_size="0.5rem",color=DIM,font_family=MONO,letter_spacing="0.1em"),
                              spacing="1",align="center",margin_bottom="0.28rem"),
                    rx.code_block(msg["sql_ejecutado"],language="sql",font_size="0.71rem",border_radius="6px",border=f"1px solid {BORDER}"),
                    **_card,padding="0.7rem 1rem",width="100%",
                ),rx.box()),
            rx.cond(msg["datos_db"].length()>0,
                rx.box(
                    rx.hstack(rx.icon("table-2",size=11,color=DIM),
                              rx.text("Resultado",font_size="0.5rem",color=DIM,font_family=MONO,letter_spacing="0.1em"),
                              spacing="1",align="center",margin_bottom="0.28rem"),
                    rx.box(
                        rx.table.root(
                            rx.table.header(rx.table.row(rx.foreach(msg["datos_db"][0],
                                lambda kv: rx.table.column_header_cell(kv[0],font_size="0.56rem",text_transform="uppercase",
                                    color=ACCENT,font_family=MONO,padding="0.4rem 0.9rem",
                                    border_bottom=f"1px solid {BORDER}",white_space="nowrap")),),background=CARD2),
                            rx.table.body(rx.foreach(msg["datos_db"],
                                lambda row: rx.table.row(rx.foreach(row,
                                    lambda kv: rx.table.cell(rx.text(kv[1],font_size="0.75rem",color=TEXT,font_family=SANS),
                                        padding="0.38rem 0.9rem",border_bottom=f"1px solid {BORDER}",white_space="nowrap")),
                                    _hover={"background":CARD2}))),
                            width="100%"),
                        overflow_x="auto",border=f"1px solid {BORDER}",border_radius="6px",background=CARD),
                    **_card,padding="0.7rem 1rem",width="100%",
                ),rx.box()),
            align_items="flex-start",spacing="2",flex="1",
        ),
        align_items="flex-start",spacing="3",width="100%",
    )

def _burbuja_user(txt):
    return rx.box(rx.text(txt,font_size="0.84rem",color="#fff",line_height="1.55"),
                  background=USER_BG,border=f"1px solid {BORDER}",
                  border_radius="12px 12px 2px 12px",padding="0.65rem 1rem",max_width="65%")

def mensaje(msg):
    return rx.vstack(
        rx.box(_burbuja_user(msg["pregunta"]),width="100%",display="flex",justify_content="flex-end"),
        bubble_ia(msg),
        align_items="flex-start",spacing="3",width="100%",margin_bottom="1.5rem",
    )

def chat_panel():
    return rx.box(
        # Header
        rx.hstack(
            rx.vstack(rx.text("Consultor Veterinario",font_size="0.9rem",font_weight="700",color=TEXT,letter_spacing="-0.01em"),
                      rx.text("Lenguaje natural + SQL + IA",font_size="0.58rem",color=DIM,font_family=MONO),
                      spacing="0",align_items="flex-start"),
            rx.spacer(),
            rx.button(
                rx.hstack(rx.icon("plus",size=13,color=SUB),rx.text("Nueva sesion",font_size="0.7rem",color=SUB),spacing="1",align="center"),
                on_click=State.limpiar,background="transparent",border=f"1px solid {BORDER}",
                border_radius="8px",padding="0.3rem 0.85rem",cursor="pointer",
                transition="all 0.12s",_hover={"border_color":ACCENT,"color":TEXT},
            ),
            align="center",width="100%",padding="0.88rem 1.5rem",
            border_bottom=f"1px solid {BORDER}",background=SURF,
        ),
        # Historial
        rx.box(
            rx.cond(State.historial.length()==0,
                rx.box(rx.vstack(rx.icon("stethoscope",size=36,color=DIM,opacity="0.35"),
                                 rx.text("En que puedo ayudarte?",font_size="0.88rem",color=SUB,font_weight="600"),
                                 rx.text("Selecciona un modulo o escribe tu consulta",font_size="0.66rem",color=DIM),
                                 spacing="2",align="center"),
                       position="absolute",top="50%",left="50%",transform="translate(-50%,-50%)",text_align="center"),
                rx.box()),
            rx.foreach(State.historial,mensaje),
            rx.cond(State.pregunta_mostrada!="",
                rx.box(_burbuja_user(State.pregunta_mostrada),width="100%",display="flex",justify_content="flex-end",margin_bottom="1.5rem"),
                rx.box()),
            rx.cond(State.cargando,
                rx.hstack(_avatar(),
                    rx.hstack(rx.spinner(color=ACCENT,size="2"),
                              rx.text("Procesando consulta...",font_size="0.73rem",color=SUB,font_family=MONO),
                              spacing="2",align="center",**_caja()),
                    spacing="3",align="start"),
                rx.box()),
            padding="1.4rem 1.5rem",flex="1",overflow_y="auto",position="relative",id="chat",
            css={"&::-webkit-scrollbar":{"width":"3px"},"&::-webkit-scrollbar-thumb":{"background":BORDER,"border-radius":"3px"}},
        ),
        # Input
        rx.box(
            rx.hstack(
                rx.icon("paperclip",size=15,color=DIM,cursor="pointer"),
                rx.input(placeholder="Escribe tu pregunta aqui...",value=State.pregunta,
                         on_change=State.set_pregunta,on_key_down=State.handle_enter,
                         font_size="0.84rem",font_family=SANS,background="transparent",color=TEXT,
                         border="none",flex="1",_placeholder={"color":DIM},
                         _focus={"outline":"none","border":"none","box_shadow":"none"}),
                rx.button(
                    rx.cond(State.cargando,rx.spinner(color="#fff",size="2"),rx.icon("send-horizontal",size=15,color="#fff")),
                    on_click=State.enviar,disabled=State.cargando,background=BTN,border="none",
                    border_radius="8px",width="34px",height="34px",cursor="pointer",flex_shrink="0",
                    _hover={"background":ACLT},_disabled={"opacity":"0.35","cursor":"not-allowed"},transition="background 0.12s",
                ),
                spacing="3",align="center",background=CARD,border=f"1px solid {BORDER}",
                border_radius="12px",padding="0.48rem 0.65rem 0.48rem 1rem",
            ),
            padding="0.85rem 1.5rem 1.1rem",border_top=f"1px solid {BORDER}",background=SURF,
        ),
        flex="1",display="flex",flex_direction="column",height="100vh",background=GRAD,overflow="hidden",
    )


def index():
    return rx.box(sidebar(),chat_panel(),
                  display="flex",width="100vw",height="100vh",
                  font_family=SANS,background=BG,color=TEXT,
                  overflow="hidden",on_mount=State.cargar_stats)

app = rx.App(
    stylesheets=[
        "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap",
        "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500&display=swap",
    ],
    style={"margin":"0","padding":"0","box_sizing":"border-box","body":{"margin":"0","padding":"0","overflow":"hidden"}},
    head_components=[
        rx.el.link(rel="icon", type="image/x-icon", href="/favicon.ico"),
        rx.el.link(rel="shortcut icon", href="/favicon.ico"),
    ],
)
app.add_page(
    index,
    route="/",
    title="VetAI",
    meta=[
        {"name": "description", "content": "Sistema veterinario con IA"},
    ],
)