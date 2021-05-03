#!/usr/bin/env fish
set BASE_API_URL "https://ftc-api.firstinspires.org/v2.0"
set YEAR "2020"

function json_to_csv
    jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv'
end

function query_api
    curl -H 'Accept:application/json' -H "Authorization: Basic $FTC_EVENTS_KEY" "$BASE_API_URL/$YEAR/$argv"
end

query_api 'events' > 'events.json'
jq '.events' 'events.json'| json_to_csv > 'events.csv'

set played_events (jq -r '.events | .[] | select(.published) | .code' events.json)

for event in $played_events
    query_api "matches/$event"
end > matches.json

jq '.matches | .[] | {"actualStartTime": .actualStartTime,
"description": .description,
"tournamentLevel": .tournamentLevel,
"series": .series,
"matchNumber": .matchNumber,
"scoreRedFinal": .scoreRedFinal,
"scoreRedFoul": .scoreRedFoul,
"scoreRedAuto": .scoreRedAuto,
"scoreBlueFinal": .scoreBlueFinal,
"scoreBlueFoul": .scoreBlueFoal,
"scoreBlueAuto": .scoreBlueAuto,
"postResultTime": .postResultTime,
"teamNumber0": .teams[0].teamNumber,
"station0": .teams[0].station,
"dq0": .teams[0].dq,
"onField0": .teams[0].onField,
"teamNumber1": .teams[1].teamNumber,
"station1": .teams[1].station,
"dq1": .teams[1].dq,
"onField1": .teams[1].onField,
"teamNumber2": .teams[2].teamNumber,
"station2": .teams[2].station,
"dq2": .teams[2].dq,
"onField2": .teams[2].onField,
"teamNumber3": .teams[3].teamNumber,
"station3": .teams[3].station,
"dq3": .teams[3].dq,
"onField3": .teams[3].onField,
"teamNumber4": .teams[4].teamNumber,
"station4": .teams[4].station,
"dq4": .teams[4].dq,
"onField4": .teams[4].onField,
"teamNumber5": .teams[5].teamNumber,
"station5": .teams[5].station,
"dq5": .teams[5].dq,
"onField5": .teams[5].onField,
"modifiedOn": .modifiedOn
}' 'matches.json' | jq -s '.' | json_to_csv > 'matches.csv'

for event in $played_events
    query_api "scores/$event/qual"
end > quals.json

for event in $played_events
    query_api "scores/$event/playoff"
end > playoffs.json

rm 'ftcdata.db'
sqlite3 'ftcdata.db' -cmd '.mode csv' '.import events.csv events'
sqlite3 'ftcdata.db' -cmd '.mode csv' '.import matches.csv matches'
