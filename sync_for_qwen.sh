#!/bin/bash
SRC="/root/rtgbot"
DST="/root/rtgbot_sync"

# Очищаем старое
rm -rf "$DST"/*
mkdir -p "$DST/app" "$DST/docker"

# Копируем только нужные расширения, исключая секреты и кэш
find "$SRC" -type f \( \
    -name "*.py" -o \
    -name "*.yaml" -o \
    -name "*.yml" -o \
    -name "*.toml" -o \
    -name "*.md" -o \
    -name "Dockerfile*" -o \
    -name "docker-compose*" \
\) | grep -v "__pycache__" | grep -v ".pyc" | grep -v ".env" | grep -v "logs/" | grep -v ".git" | while read file; do
    rel_path="${file#$SRC/}"
    mkdir -p "$DST/$(dirname "$rel_path")"
    cp "$file" "$DST/$rel_path"
done

echo "✅ Синхронизировано в $DST"
echo "📦 Файлов: $(find "$DST" -type f | wc -l)"
