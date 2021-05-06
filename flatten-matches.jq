def null_to_empty_object:
  if . == null then {} else . end;

def flatten($keys):
  with_entries(
      if .key as $key | . | any($keys[]; . == $key) # Check if .key is in $keys
      then .value|to_entries[]
      else . end
  );

.matches
| .[]
| .teams as $teams
| .teams =(.teams
   | map(. as $team
        | $teams
        | map(.teamNumber == $team.teamNumber) | index(true) as $index
        | $team
        | to_entries
        | map(.key = .key + ($index | tostring) | .)
        )
  )
| .teams = (.teams | map(from_entries))
| .team0 = (.teams[0] | null_to_empty_object)
| .team1 = (.teams[1] | null_to_empty_object)
| .team2 = (.teams[2] | null_to_empty_object)
| .team3 = (.teams[3] | null_to_empty_object)
| .team4 = (.teams[4] | null_to_empty_object)
| .team5 = (.teams[5] | null_to_empty_object)
| del(.teams)
| flatten(["team0", "team1", "team2", "team3", "team4", "team5"])
