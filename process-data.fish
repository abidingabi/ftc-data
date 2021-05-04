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

set process_scores '.[] | .[] |
if .alliances == null then .alliances = [{}, {}] else . end
| .alliances = (.alliances
| map(.alliance as $allianceColor | del(.alliance) | with_entries(.key = .key + $allianceColor)))
| .alliance0 = .alliances[0] | .alliance1 = .alliances[1] | del(.alliances)
| with_entries(if .key=="scores" or .key=="alliance0" or .key=="alliance1" then .value|to_entries[] else . end)'
# Set alliances to empty objects if it doesn't exist to keep everything after it from breaking.
# Saving the alliance, remove its key. Then, append it to every key for the alliance objects.
# Then, elevate the individual alliance objects, then remove the .alliances array
# Finally, elevate the key/value pairs in scores, alliance0, alliance1, thereby removing them.

jq $process_scores quals.json  | jq -s '.' | json_to_csv > quals.csv
jq $process_scores playoffs.json  | jq -s '.' | json_to_csv > playoffs.csv

jq '.teams | .[]' teams.json | jq -s '.' | json_to_csv > teams.csv

rm 'ftcdata.db'
sqlite3 'ftcdata.db' -cmd '.mode csv' '.import events.csv events'
sqlite3 'ftcdata.db' -cmd '.mode csv' '.import matches.csv matches'
sqlite3 'ftcdata.db' -cmd '.mode csv' '.import quals.csv quals'
sqlite3 'ftcdata.db' -cmd '.mode csv' '.import playoffs.csv playoffs'
sqlite3 'ftcdata.db' -cmd '.mode csv' '.import teams.csv teams'
