#!/bin/bash
echo "👁️  Слежу за изменениями в /root/rtgbot..."
echo "🔄 При изменении .py/.yaml файлов — авто-синхронизация"

inotifywait -m -r -e modify,create,delete,move \
    --exclude '(__pycache__|\.pyc|\.env|logs|\.git|rtgbot_sync)' \
    --format '%w%f %e' \
    /root/rtgbot | while read file event; do
    
    # Фильтруем только нужные расширения
    if [[ "$file" == *.py || "$file" == *.yaml || "$file" == *.yml || "$file" == *.toml ]]; then
        echo "📝 Изменение: $file ($event) → запускаю синхронизацию..."
        /root/rtgbot/sync_for_qwen.sh
    fi
done
