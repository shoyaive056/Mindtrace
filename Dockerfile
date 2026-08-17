# MindTrace — single-container deployment (backend serves the frontend too)
# Built for Hugging Face Spaces (Docker SDK), which expects the app to
# listen on port 7860. Works the same way on Render/Railway/any Docker host
# if you change the exposed port to whatever that platform requires.

FROM python:3.11-slim

WORKDIR /app

# System deps needed by torch/transformers wheels on slim images
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps first (better Docker layer caching)
COPY backend/requirements.txt /app/backend/requirements.txt
RUN pip install --no-cache-dir -r /app/backend/requirements.txt

# Copy the actual app code
COPY backend /app/backend
COPY frontend /app/frontend

# Hugging Face Spaces containers run as a non-root user by default and
# expect writable space — /app is writable here, which is where
# mindtrace.db (SQLite) will be created at runtime.
ENV PYTHONUNBUFFERED=1

WORKDIR /app/backend
EXPOSE 7860

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "7860"]
