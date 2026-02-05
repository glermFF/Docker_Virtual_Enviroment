#!/bin/bash

# ClamAV + Binwalk

INPUT="$1"
BASE_OUT="/analysis/resultados"

if [ -z "$INPUT" ]; then
    echo "[!] Uso: $0 <arquivo_ou_diretorio>"
    exit 1
fi

if [ ! -e "$INPUT" ]; then
    echo "[!] Caminho não encontrado: $INPUT"
    exit 1
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUT_DIR="$BASE_OUT/analise_$TIMESTAMP"

mkdir -p "$OUT_DIR"/{clamav,binwalk}

echo "[+] Iniciando análise"
echo "[+] Entrada: $INPUT"
echo "-------------------------------------"

# =====================================
# ClamAV
# =====================================
echo "[+] Rodando ClamAV..."

clamscan -r "$INPUT" > "$OUT_DIR/clamav/resultado.txt"

if grep -q "FOUND" "$OUT_DIR/clamav/resultado.txt"; then
    echo "[!] ClamAV: possóvel ameaça detectada"
else
    echo "[+] ClamAV: nenhuma assinatura conhecida"
fi

# =====================================
# Binwalk
# =====================================
echo "[+] Rodando Binwalk..."

if [ -d "$INPUT" ]; then
    find "$INPUT" -type f | while read -r file; do
        fname=$(basename "$file")
        fdir="$OUT_DIR/binwalk/$fname"
        mkdir -p "$fdir"

        binwalk "$file" > "$fdir/scan.txt"
        binwalk -e --directory "$fdir/extracted" "$file" >/dev/null 2>&1
    done
else
    binwalk "$INPUT" > "$OUT_DIR/binwalk/scan.txt"
    binwalk -e --directory "$OUT_DIR/binwalk/extracted" "$INPUT" >/dev/null 2>&1
fi

# =====================================
# Resumo
# =====================================
echo "[+] Gerando resumo..."

{
    echo "Relatório de Análise Estática"
    echo "Data: $(date)"
    echo "Entrada: $INPUT"
    echo
    echo "===== ClamAV ====="
    grep "FOUND" "$OUT_DIR/clamav/resultado.txt" || echo "Nenhuma ameaça detectada"
    echo
    echo "===== Binwalk ====="
    find "$OUT_DIR/binwalk" -name "scan.txt" -exec cat {} \;
} > "$OUT_DIR/resumo.txt"

echo "-------------------------------------"
echo "[✓] Análise concluída"
echo "[✓] Resultados disponíveis em $OUT_DIR"

