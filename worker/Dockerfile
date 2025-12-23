FROM python:3.9-slim
WORKDIR /app
COPY . /app
RUN pip install redis psycopg2-binary
CMD ["python", "worker.py"]
