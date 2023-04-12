FROM python:3.9

# Install system dependencies
RUN apt-get update
RUN apt install -y lsb-release wget software-properties-common gnupg

# Install LLVM
ENV LLVM_VERSION=9
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN apt-get install -y \
    clang-${LLVM_VERSION} \
    lldb-${LLVM_VERSION} \
    lld-${LLVM_VERSION}
# llvm-${LLVM_VERSION}

# LLVM
RUN apt-get install -y \
    libllvm-${LLVM_VERSION}-ocaml-dev \
    libllvm${LLVM_VERSION} \
    llvm-${LLVM_VERSION} \
    llvm-${LLVM_VERSION}-dev \
    llvm-${LLVM_VERSION}-doc \
    llvm-${LLVM_VERSION}-examples \
    llvm-${LLVM_VERSION}-runtime
# Clang and co
RUN apt-get install -y \
    clang-tools-${LLVM_VERSION} \
    clang-${LLVM_VERSION}-doc \
    libclang-common-${LLVM_VERSION}-dev \
    libclang-${LLVM_VERSION}-dev \
    libclang1-${LLVM_VERSION} \
    clang-format-${LLVM_VERSION} \
    python3-clang-${LLVM_VERSION} \
    clangd-${LLVM_VERSION} \
    clang-tidy-${LLVM_VERSION} 
# libc++
RUN apt-get install -y \
    libc++-${LLVM_VERSION}-dev \
    libc++abi-${LLVM_VERSION}-dev

# For llvmlite
ENV LLVM_CONFIG=/usr/bin/llvm-config-${LLVM_VERSION}

# Configure Poetry
ENV POETRY_VERSION=1.4.1
ENV POETRY_HOME=/opt/poetry
ENV POETRY_VENV=/opt/poetry-venv
ENV POETRY_CACHE_DIR=/opt/.cache

# Install poetry separated from system interpreter
RUN python3 -m venv $POETRY_VENV \
    && $POETRY_VENV/bin/pip install -U pip setuptools \
    && $POETRY_VENV/bin/pip install poetry==${POETRY_VERSION}

# Add `poetry` to PATH
ENV PATH="${PATH}:${POETRY_VENV}/bin"

WORKDIR /app

## Install dependencies
# COPY poetry.lock pyproject.toml ./

# RUN poetry install
