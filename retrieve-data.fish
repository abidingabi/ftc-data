#!/usr/bin/env fish

set BASE_API_URL "https://ftc-api.firstinspires.org/v2.0"
set YEAR "2020"

mkdir -p output

function query_api
    curl -H 'Accept:application/json' -H "Authorization: Basic $FTC_EVENTS_KEY" "$BASE_API_URL/$YEAR/$argv"
end

query_api 'events' > 'output/events.json'

set played_events (jq -r '.events | .[] | select(.published) | .code' output/events.json)

for event in $played_events
    query_api "matches/$event"
end > output/matches.json

for event in $played_events
    query_api "scores/$event/qual"
end > output/quals.json

for event in $played_events
    query_api "scores/$event/playoff"
end > output/playoffs.json

for page in (seq (query_api "teams" | jq '.pageTotal'))
    query_api "teams?page=$page"
end > output/teams.json
