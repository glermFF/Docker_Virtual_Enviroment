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

# ClamAV

echo "[+] Executando ClamAV..."

clamscan -r -v "$INPUT" > "$OUT_DIR/clamav/scan.txt"

if grep -q "FOUND" "$OUT_DIR/clamav/scan.txt"; then
    echo "[!] ClamAV: possível ameaça detectada"
else
    echo "[+] ClamAV: nenhuma assinatura conhecida"
fi

# Binwalk

echo "[+] Executando Binwalk..."

BINFLAG=0

if [[ "$INPUT" == *.txt ]]; then
  echo "[!] Arquivo .txt não é preciso executar binwalk" 
  BINFLAG=1
fi

if [ -d "$INPUT" ]; then
    find "$INPUT" -type f | while read -r file; do
        fname=$(basename "$file")
        fdir="$OUT_DIR/binwalk/$fname"
        mkdir -p "$fdir"

        binwalk "$file" > "$fdir/scan.txt"
        binwalk -v --signature "$file" >> "$fdir/scan.txt"
        binwalk --opcodes "$file" >> "$fdir/scan.txt"
        binwalk -e --directory "$fdir/extracted" "$file" >/dev/null 2>&1
    done
else
    mkdir -p "$OUT_DIR/binwalk"

    binwalk "$INPUT" > "$OUT_DIR/binwalk/scan.txt"
    binwalk -v --signature "$INPUT" >> "$fdir/scan.txt"
    binwalk --opcodes "$INPUT" >> "$fdir/scan.txt"
    binwalk -e --directory "OUT_DIR/binwalk/extracted" >/dev/null 2>&1
fi

# Resumo

echo "[+] Gerando releatório..."

{
    echo "Relatório de Análise Estática"
    echo "Data: $(date)"
    echo "Entrada: $INPUT"
    echo
    echo "===== ClamAV ====="
    find "$OUT_DIR/clamav" -name "scan.txt" -exec cat {} \;
    echo
    if [[ $BINFLAG -eq 0 ]]; then
       echo "===== Binwalk ====="
       find "$OUT_DIR/binwalk" -name "scan.txt" -exec cat {} \;
    fi
} > "$OUT_DIR/resumo.txt"

echo "-------------------------------------"
echo "[✓] Análise concluída"
echo "[✓] Resultados disponíveis em: $OUT_DIR"
