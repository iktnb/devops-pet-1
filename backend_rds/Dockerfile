# Используем базовый образ Python
FROM python:python:3.9

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

# Выводим содержимое директории /app в консоль для отладки
RUN ls -la /app

# Добавляем права на выполнение для manage.py
RUN chmod +x /app/manage.py

# Открываем порт для приложения
EXPOSE 8000

# Команда по умолчанию
CMD ["python", "/app/manage.py", "runserver", "0.0.0.0:8000"]
