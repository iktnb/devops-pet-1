# Используем базовый образ Python
FROM python:3.10

# Устанавливаем рабочую директорию
WORKDIR /app

# Устанавливаем dos2unix для преобразования формата файлов
RUN apt-get update && apt-get install -y dos2unix

# Копируем зависимости и устанавливаем их
COPY requirements.txt .
RUN pip install -r requirements.txt

# Копируем весь код проекта
COPY . .

# Преобразуем manage.py в Unix-совместимый формат
RUN dos2unix /app/manage.py

# Открываем порт для приложения
EXPOSE 8001

# Команда по умолчанию
CMD ["python", "manage.py", "runserver", "0.0.0.0:8001"]
