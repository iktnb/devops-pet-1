# Используем базовый образ Python
FROM python:3.10

# Устанавливаем dos2unix для преобразования формата файлов

WORKDIR /app
COPY . .


RUN pip install -r requirements.txt

# Преобразуем manage.py в Unix-совместимый формат и добавляем права на выполнение
RUN chmod +x manage.py

# Открываем порт для приложения
EXPOSE 8000

# Команда по умолчанию
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
