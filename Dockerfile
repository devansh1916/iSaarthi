FROM python:3.13.7-slim

WORKDIR /app

RUN apt-get update && apt-get install -y build-essential && rm -rf /var/lib/apt/lists/*

COPY code/Python/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY code/Python/ .

EXPOSE 10000

CMD ["python", "-m", "gunicorn", "--bind", "0.0.0.0:10000", "ml_server:app"]
