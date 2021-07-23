#!/usr/bin/env fish

set BASE_API_URL "https://ftc-api.firstinspires.org/v2.0"
set YEAR "2020"

mkdir -p data

function query_api
    curl -H 'Accept:application/json' -H "Authorization: Basic $FTC_EVENTS_KEY" "$BASE_API_URL/$YEAR/$argv"
end

query_api 'events' > 'data/events.json'

set played_events (jq -r '.events | .[] | select(.published) | .code' data/events.json)

for event in $played_events
    query_api "matches/$event"
end > data/matches.json

for event in $played_events
    query_api "scores/$event/qual"
end > data/quals.json

for event in $played_events
    query_api "scores/$event/playoff"
end > data/playoffs.json

for page in (seq (query_api "teams" | jq '.pageTotal'))
    query_api "teams?page=$page"
end > data/teams.json
