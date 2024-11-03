# Используем базовый образ Python
FROM python:3.10

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем зависимости и устанавливаем их
COPY requirements.txt .
RUN pip install -r requirements.txt

# Копируем весь код проекта
COPY . .

# Выводим содержимое директории /app в консоль для отладки
RUN ls -la /app

# Добавляем права на выполнение для manage.py
RUN chmod +x /app/manage.py

# Открываем порт для приложения
EXPOSE 8000

# Команда по умолчанию
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
