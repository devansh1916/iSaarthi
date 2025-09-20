# Use a specific, stable Python version
FROM python:3.13.7-slim

# Set the working directory inside the container
WORKDIR /app

# Install system tools needed for compiling packages
RUN apt-get update && apt-get install -y build-essential && rm -rf /var/lib/apt/lists/*

# Copy and install Python requirements
COPY Python/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy all your project files from the "Python" folder into the container
COPY Python/ .

# Tell Render what port the app will run on
EXPOSE 10000

# The command to start the Gunicorn server
CMD ["gunicorn", "--bind", "0.0.0.0:10000", "ml_server:app"]
