FROM python:3.13-slim AS build
WORKDIR /build
COPY requirements-app.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements-app.txt

FROM python:3.13-slim
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 10001 appuser \
    && pip uninstall -y pip
WORKDIR /app
COPY --from=build /install /usr/local
COPY app ./app
USER 10001
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
