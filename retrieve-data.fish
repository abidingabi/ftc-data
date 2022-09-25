#!/usr/bin/env fish

set BASE_API_URL "https://ftc-api.firstinspires.org/v2.0"
set YEAR "2022"

mkdir -p raw-data
mkdir -p data

function query_api
    curl -H 'Accept:application/json' -H "Authorization: Basic $FTC_EVENTS_KEY" "$BASE_API_URL/$YEAR/$argv"
end

query_api 'events' > 'raw-data/events.json'


set played_events (jq -r '.events | .[] | select(.published) | .code' raw-data/events.json)

for event in $played_events
    query_api "matches/$event"
end > raw-data/matches.json

for event in $played_events
    query_api "scores/$event/qual"
end > raw-data/quals.json

for event in $played_events
    query_api "scores/$event/playoff"
end > raw-data/playoffs.json

for page in (seq (query_api "teams" | jq '.pageTotal'))
    query_api "teams?page=$page"
end > raw-data/teams.json

# Create cleaned up data
jq '.events | .[]' raw-data/events.json | jq --slurp --compact-output > data/events.json
jq '.matches | .[]' raw-data/matches.json | jq --slurp --compact-output > data/matches.json
jq '.MatchScores | .[]' raw-data/quals.json | jq --slurp --compact-output > data/quals.json
jq '.MatchScores | .[]' raw-data/playoffs.json | jq --slurp --compact-output > data/playoffs.json
jq '.teams | .[]' raw-data/teams.json | jq --slurp --compact-output > data/teams.json
