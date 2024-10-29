# Используем базовый образ Python
FROM python:3.10

WORKDIR /app


COPY requirements.txt .
RUN pip install -r requirements.txt


COPY . .


EXPOSE 8001

CMD ["python", "manage.py", "runserver", "0.0.0.0:8001"]
