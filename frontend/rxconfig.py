import reflex as rx
import os

config = rx.Config(
    app_name="veterinaria_app",
    show_built_with_reflex=False,
    api_url=os.getenv("API_URL", "http://localhost:8000"),
)
