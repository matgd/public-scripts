#!/usr/bin/env bash
set -euo pipefail

function help() {
    echo "Usage: $0 <from_currency> <to_currency> [format]"
    echo
    echo "Arguments:"
    echo "  from_currency   The currency code to convert from (e.g., USD)"
    echo "  to_currency     The currency code to convert to (e.g., EUR)"
    echo "  format          Optional format string with tokens:"
    echo "                    {rate} - The exchange rate"
    echo "                    {rate:2f} - The exchange rate formatted to 2 decimal places"
    echo "                    {from} - The source currency code"
    echo "                    {to} - The target currency code"
    echo "                    {date} - The date of the exchange rate"
    echo "                    {emoji_usd} - Emoji for USD"
    echo "                    {emoji_eur} - Emoji for EUR"
    echo "                    {emoji_gbp} - Emoji for GBP"
    echo "                    {emoji_jpy} - Emoji for JPY"
}

if [ "$#" -lt 2 ]; then
    help
    exit 1
fi

FROM_CURRENCY="${1}"
TO_CURRENCY="${2}"
FORMAT="${3:-}"

XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHED_FILE="${CACHED_FILE:-$XDG_CACHE_HOME/exchange_rate.$FROM_CURRENCY.$TO_CURRENCY.json}"
CACHE_TTL_SECONDS="${CACHE_TTL_SECONDS:-18000}"  # 5 hours
QUIET_CURL="${QUIET_CURL:-true}"

URL="https://api.frankfurter.app/latest?from=${FROM_CURRENCY}&to=${TO_CURRENCY}"

QUIET=$QUIET_CURL cached_curl \
  "$URL" \
  "$CACHE_TTL_SECONDS" \
  "$CACHED_FILE" \
  --silent > /dev/null

if [ -z "$FORMAT" ]; then
  jq . "$CACHED_FILE"
  exit 0
fi

LC_NUMERIC=C

RATE=$(jq -r ".rates[\"$TO_CURRENCY\"]" "$CACHED_FILE")
declare -A FORMAT_TOKENS=(
  ["{rate}"]="$RATE"
  ["{rate:2f}"]="$(printf "%.2f" "$RATE")"
  ["{from}"]="$FROM_CURRENCY"
  ["{to}"]="$TO_CURRENCY"
  ["{date}"]="$(jq -r .date "$CACHED_FILE")"
  ["{emoji_usd}"]="💵"
  ["{emoji_eur}"]="💶"
  ["{emoji_gbp}"]="💷"
  ["{emoji_jpy}"]="💴"
)

OUTPUT="$FORMAT"

for KEY in $(printf "%s\n" "${!FORMAT_TOKENS[@]}" | awk '{ print length, $0 }' | sort -nr | cut -d" " -f2-); do
  OUTPUT=${OUTPUT//$KEY/${FORMAT_TOKENS[$KEY]}}
done

echo "$OUTPUT"

