# Используем базовый образ Python
FROM python:3.10

# Устанавливаем dos2unix для преобразования формата файлов
RUN apt-get update && apt-get install -y dos2unix

# Копируем весь код проекта
COPY . /app

# Устанавливаем рабочую директорию
WORKDIR /app

# Устанавливаем зависимости
RUN pip install -r requirements.txt

# Преобразуем manage.py в Unix-совместимый формат и добавляем права на выполнение
RUN dos2unix /app/manage.py && chmod +x /app/manage.py

# Открываем порт для приложения
EXPOSE 8000

# Команда по умолчанию
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
