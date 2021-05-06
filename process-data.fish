#!/usr/bin/env fish

function json_to_csv
    jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv'
end

jq '.events' 'events.json'| json_to_csv > 'events.csv'

jq -f flatten-matches.jq 'matches.json' | jq -s '.' | json_to_csv > 'matches.csv'

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
