# Используем базовый образ Python
FROM python:3.10


WORKDIR /app

COPY . .

RUN pip install -r requirements.txt
RUN chmod +x manage.py

EXPOSE 8001

# Команда по умолчанию
CMD ["python", "manage.py", "runserver", "0.0.0.0:8001"]
