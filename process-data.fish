#!/usr/bin/env fish

function json_to_csv
    jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv'
end

jq '.events' 'events.json'| json_to_csv > 'events.csv'

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

rm 'ftcdata.db'
sqlite3 'ftcdata.db' -cmd '.mode csv' '.import events.csv events'
sqlite3 'ftcdata.db' -cmd '.mode csv' '.import matches.csv matches'
