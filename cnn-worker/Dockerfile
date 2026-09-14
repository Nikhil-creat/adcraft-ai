# AdCraft AI — Hyper-Engine v2.0
# CNN Inference Service — brand/logo visual analysis (MobileNet/ResNet backbone)
# Designed & Developed by Nikhil Chary Sriramoju
#
# The browser prototype runs a real MobileNet CNN client-side via TensorFlow.js
# for demos. This service is the server-side equivalent for production: batch
# logo analysis, style classification, and feature extraction at scale.

FROM python:3.12-slim
WORKDIR /cnn

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 libglib2.0-0 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
# torch, torchvision, fastapi, pillow, uvicorn
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 8500
CMD ["uvicorn", "cnn_service:app", "--host", "0.0.0.0", "--port", "8500"]
