#!/bin/bash
set -e

file_name="${1:-}"
video_url="${2:-}"

if [ -z "$file_name" ]; then
    read -er -p "Nome do arquivo (sem .mp4): " file_name || exit 1
fi
[ -n "$file_name" ] || exit 1

if [ -z "$video_url" ]; then
    read -er -p "URL do vídeo: " video_url || exit 1
fi
[ -n "$video_url" ] || exit 1

exec yt-dlp -o "${file_name}.mp4" "$video_url"
