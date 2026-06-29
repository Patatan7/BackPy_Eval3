# ================================
# Stage 1: Builder
# ================================
FROM python:3.11-alpine AS builder

WORKDIR /app

# Dependencias del sistema necesarias para compilar paquetes Python con C extensions
RUN apk add --no-cache gcc musl-dev mariadb-connector-c-dev

COPY requirements.txt .

RUN pip install --no-cache-dir --user -r requirements.txt

# ================================
# Stage 2: Production
# ================================
FROM python:3.11-alpine AS production

# Librería de runtime de MySQL (sin las herramientas de compilación)
RUN apk add --no-cache mariadb-connector-c

# Usuario no root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copiar dependencias instaladas desde el stage builder
COPY --from=builder /root/.local /home/appuser/.local

# Copiar código fuente
COPY . .

# Asignar permisos al usuario no root
RUN chown -R appuser:appgroup /app

USER appuser

ENV PATH=/home/appuser/.local/bin:$PATH

EXPOSE 8082

CMD ["python", "app.py"]
