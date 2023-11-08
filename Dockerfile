FROM python:3.10.12-alpine3.18

LABEL contacto="jcandodevops@gmail.com" \
      descripcion="Aplicación Python que imprime hola mundo"

WORKDIR /app

COPY main.py .

CMD ["python", "main.py"]
