#!/bin/bash
set -e

hosts=(
    "synter-prod"
    "synter-staging"
    "crabki-prod"
    "crabki-staging"
)

target="${1:-}"

if [ -z "$target" ]; then
    echo "Selecione a instância EC2:"
    echo ""
    for i in "${!hosts[@]}"; do
        h="${hosts[$i]}"
        ip="$(ssh -G "$h" 2>/dev/null | awk '$1 == "hostname" { print $2; exit }')"
        printf "  %d) %-16s (%s)\n" "$((i + 1))" "$h" "${ip:-?}"
    done
    echo ""
    read -er -p "Opção [1-${#hosts[@]}]: " choice || exit 1
    [[ "$choice" =~ ^[0-9]+$ ]] || { echo "Opção inválida." >&2; exit 1; }
    idx=$((choice - 1))
    if [ "$idx" -lt 0 ] || [ "$idx" -ge "${#hosts[@]}" ]; then
        echo "Opção inválida." >&2
        exit 1
    fi
    target="${hosts[$idx]}"
fi

exec ssh "$target"
