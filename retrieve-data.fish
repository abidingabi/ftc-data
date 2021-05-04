#!/usr/bin/env fish

set BASE_API_URL "https://ftc-api.firstinspires.org/v2.0"
set YEAR "2020"

function query_api
    curl -H 'Accept:application/json' -H "Authorization: Basic $FTC_EVENTS_KEY" "$BASE_API_URL/$YEAR/$argv"
end

query_api 'events' > 'events.json'

set played_events (jq -r '.events | .[] | select(.published) | .code' events.json)

for event in $played_events
    query_api "matches/$event"
end > matches.json

for event in $played_events
    query_api "scores/$event/qual"
end > quals.json

for event in $played_events
    query_api "scores/$event/playoff"
end > playoffs.json
