# Используем базовый образ Python
FROM python:3.10

# Устанавливаем рабочую директорию


# Устанавливаем dos2unix для преобразования формата файлов
RUN apt-get update && apt-get install -y dos2unix

# Копируем зависимости и устанавливаем их


# Копируем весь код проекта
COPY . ./app

WORKDIR /app

RUN pip install -r requirements.txt
# Преобразуем manage.py в Unix-совместимый формат
RUN dos2unix /app/manage.py

# Открываем порт для приложения
EXPOSE 8001

# Команда по умолчанию
CMD ["python", "manage.py", "runserver", "0.0.0.0:8001"]
