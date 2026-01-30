#!/usr/bin/env bash

OAUTH_TOKEN=$(cat ~/.config/github-copilot/apps.json | jq '.[keys[0]]["oauth_token"]' | sed 's/"//g')

CACHED_FILE="$HOME/.cache/gh_copilot_quota.response_cache.json"
CACHE_TTL_SECONDS=${CACHE_TTL_SECONDS:-3600} # Default to 60 minutes
QUIET=${QUIET:-false}

FORMAT=${1}

fetch_newest_data() {
    curl --silent --request GET \
    --url "https://api.github.com/copilot_internal/user" \
    --header "Authorization: Bearer ${OAUTH_TOKEN}" \
    --header "X-GitHub-Api-Version: 2022-11-28" > ${CACHED_FILE}
}

file_reached_ttl() {
    UPDATED_SINCE_SECONDS=$(( $(date +%s) - $(stat -c %Y ${CACHED_FILE}) ))
    say "Cache age: ${UPDATED_SINCE_SECONDS}s"
    say "Cache TTL: ${CACHE_TTL_SECONDS}s"

    if [ ! -f ${CACHED_FILE} ] || [ ${UPDATED_SINCE_SECONDS} -gt ${CACHE_TTL_SECONDS} ]; then
        return 0
    fi
    return 1
}

file_is_empty() {
    if [ ! -s ${CACHED_FILE} ]; then
        return 0
    fi
    return 1
}

say() {
    if [ "$QUIET" = false ]; then
        echo "$1"
    fi
}

if file_reached_ttl || file_is_empty; then
    say "Fetching newest GitHub Copilot quota data..."
    fetch_newest_data
fi

if [ -z "$FORMAT" ]; then
    jq '.quota_snapshots' ${CACHED_FILE}
    exit 0
fi


LC_NUMERIC=C  # For rounding with dot as decimal separator

INTERACTIONS_TOTAL=$(jq '.quota_snapshots.premium_interactions.entitlement' ${CACHED_FILE})
INTERACTIONS_REMAINING=$(jq '.quota_snapshots.premium_interactions.remaining' ${CACHED_FILE})
INTERACTIONS_REMAINING_PERCENTAGE=$(jq '.quota_snapshots.premium_interactions.percent_remaining' ${CACHED_FILE})

declare -A FORMAT_TOKENS=(
    ["%it"]=$INTERACTIONS_TOTAL
    ["%irp"]=$(printf "%.1f" "$INTERACTIONS_REMAINING_PERCENTAGE")
    ["%ir"]=$INTERACTIONS_REMAINING
    ["%icon_gh"]=" "
)

OUTPUT=${FORMAT}
for KEY in $(printf "%s\n" "${!FORMAT_TOKENS[@]}" | awk '{ print length, $0 }' | sort -nr | cut -d" " -f2-); do
    OUTPUT=${OUTPUT//$KEY/${FORMAT_TOKENS[$KEY]}}
done

echo "$OUTPUT"
