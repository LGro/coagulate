FROM python:3.9-slim-bullseye

RUN pip install poetry

WORKDIR /app

COPY ./ /app/

RUN poetry install

EXPOSE 80

CMD ["poetry", "run", "uvicorn", "coagulate_server.main:app", "--host", "0.0.0.0", "--port", "80"]
