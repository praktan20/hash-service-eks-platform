FROM python:3.11-slim

# Install curl
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Install your FastAPI app requirements
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . /app
WORKDIR /app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
