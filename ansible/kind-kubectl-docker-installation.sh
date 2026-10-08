#!/bin/bash

set -e
set -o pipefail

echo "🚀 Starting installation of Docker, Kind, and kubectl..."

# ----------------------------
# 1. Install Docker
# ----------------------------

if ! command -v docker &>/dev/null; then

  echo "📦 Installing Docker..."

  apt-get update -y
  apt-get install -y docker.io curl

  systemctl enable --now docker

  echo "✅ Docker installed successfully."

else

  echo "✅ Docker is already installed."

fi


# ----------------------------
# 2. Install Kind
# ----------------------------

if ! command -v kind &>/dev/null; then

  echo "📦 Installing Kind..."

  ARCH=$(uname -m)

  if [ "$ARCH" = "x86_64" ]; then

    curl -Lo /tmp/kind \
      https://kind.sigs.k8s.io/dl/v0.32.0/kind-linux-amd64

  elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then

    curl -Lo /tmp/kind \
      https://kind.sigs.k8s.io/dl/v0.32.0/kind-linux-arm64

  else

    echo "❌ Unsupported architecture: $ARCH"
    exit 1

  fi

  chmod +x /tmp/kind
  mv /tmp/kind /usr/local/bin/kind

  echo "✅ Kind installed successfully."

else

  echo "✅ Kind is already installed."

fi


# ----------------------------
# 3. Install kubectl
# ----------------------------

if ! command -v kubectl &>/dev/null; then

  echo "📦 Installing kubectl..."

  ARCH=$(uname -m)

  VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)

  if [ "$ARCH" = "x86_64" ]; then

    curl -Lo /tmp/kubectl \
      "https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl"

  elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then

    curl -Lo /tmp/kubectl \
      "https://dl.k8s.io/release/${VERSION}/bin/linux/arm64/kubectl"

  else

    echo "❌ Unsupported architecture: $ARCH"
    exit 1

  fi

  chmod +x /tmp/kubectl
  mv /tmp/kubectl /usr/local/bin/kubectl

  echo "✅ kubectl installed successfully."

else

  echo "✅ kubectl is already installed."

fi


# ----------------------------
# 4. Verify Docker Service
# ----------------------------

echo
echo "🔍 Checking Docker service..."

systemctl is-active --quiet docker

echo "✅ Docker service is running."


# ----------------------------
# 5. Verify Versions
# ----------------------------

echo
echo "🔍 Installed Versions:"

docker --version
kind --version
kubectl version --client


echo
echo "🎉 Docker, Kind, and kubectl installation complete!"
echo "ℹ️ Docker group configuration will be handled by Ansible."
