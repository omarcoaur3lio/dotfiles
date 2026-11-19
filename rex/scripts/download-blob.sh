#!/bin/bash
set -e

file_name="${1:-}"
video_url="${2:-}"

if [ -z "$file_name" ]; then
    read -er -p "Nome do arquivo (sem .mp4): " file_name || exit 1
fi
[ -n "$file_name" ] || exit 1

if [ -z "$video_url" ]; then
    read -er -p "URL base do vídeo: " video_url || exit 1
fi
[ -n "$video_url" ] || exit 1

exec yt-dlp -o "${file_name}.mp4" "${video_url}_Ott_Hls_Ts_Avc_Aac_1080p_4Mbps_qvbr.m3u8" \
    --referer "https://privacy.com.br/" \
    --add-header "Origin: https://privacy.com.br" \
    --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:156.0) Gecko/20100101 Firefox/156.0"
