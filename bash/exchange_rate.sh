#!/usr/bin/env bash
set -euo pipefail

function help() {
    echo "Usage: $0 <from_currency> <to_currency> <provider> [format] [decimal_places]"
    echo
    echo "Arguments:"
    echo "  from_currency   The currency code to convert from (e.g., USD)"
    echo "  to_currency     The currency code to convert to (e.g., EUR)"
    echo "  provider        The exchange rate provider to use (e.g., frankfurter, er-api)"
    echo "  format          Optional format string with tokens:"
    echo "                    {rate} - The exchange rate"
    echo "                    {from} - The source currency code"
    echo "                    {to} - The target currency code"
    echo "                    {date} - The date of the exchange rate"
    echo "                    {emoji_usd} - Emoji for USD"
    echo "                    {emoji_eur} - Emoji for EUR"
    echo "                    {emoji_gbp} - Emoji for GBP"
    echo "                    {emoji_jpy} - Emoji for JPY"
    echo " decimal_places   Optional number of decimal places to format the exchange rate"
    echo
    echo "Environment Variables:"
    echo "  XDG_CACHE_HOME       Directory for cache files (default: \$HOME/. cache)"
    echo "  CACHED_FILE          Path to the cached exchange rate file (default: \$XDG_CACHE_HOME/exchange_rate.<provider>.<from_currency>.<to_currency>.json)"
    echo "  CACHE_TTL_SECONDS    Time-to-live for the cache in seconds (default: 43200, i.e., 12 hours)"
    echo "  QUIET                If set to true, suppresses output (default: true)"
}

if [ "$#" -lt 2 ]; then
    help
    exit 1
fi

FROM_CURRENCY="${1}"
TO_CURRENCY="${2}"
PROVIDER="${3:-}"
FORMAT="${4:-}"
DECIMAL_PLACES="${5:-4}"

if [ "$PROVIDER" = "frankfurter" ]; then
    URL="https://api.frankfurter.app/latest?from=${FROM_CURRENCY}&to=${TO_CURRENCY}"
elif [ "$PROVIDER" = "er-api" ]; then
    URL="https://open.er-api.com/v6/latest/${FROM_CURRENCY}"
else
    echo "Unsupported provider: $PROVIDER"
    help
    exit 1
fi

XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHED_FILE="${CACHED_FILE:-$XDG_CACHE_HOME/exchange_rate.$PROVIDER.$FROM_CURRENCY.$TO_CURRENCY.json}"
CACHE_TTL_SECONDS="${CACHE_TTL_SECONDS:-43200}"  # 12 hours
QUIET="${QUIET:-true}"


QUIET=$QUIET cached_curl \
  "$URL" \
  "$CACHE_TTL_SECONDS" \
  "$CACHED_FILE" \
  --silent > /dev/null

if [ -z "$FORMAT" ]; then
  jq . "$CACHED_FILE"
  exit 0
fi

if [ "$PROVIDER" = "frankfurter" ]; then
    EX_RATE=$(jq -r ".rates[\"$TO_CURRENCY\"]" "$CACHED_FILE")
    EX_DATE=$(jq -r .date "$CACHED_FILE")
elif [ "$PROVIDER" = "er-api" ]; then
    EX_RATE=$(jq -r ".rates[\"$TO_CURRENCY\"]" "$CACHED_FILE")  # same
    EX_UNIX_DATE=$(jq -r .time_last_update_unix "$CACHED_FILE")
    EX_DATE=$(date -d "@$EX_UNIX_DATE" +"%Y-%m-%d %H:%M:%S")
fi

LC_NUMERIC=C

declare -A FORMAT_TOKENS=(
  ["{rate}"]="$(printf "%.${DECIMAL_PLACES}f" "$EX_RATE")"
  ["{from}"]="$FROM_CURRENCY"
  ["{to}"]="$TO_CURRENCY"
  ["{date}"]="$EX_DATE"
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

