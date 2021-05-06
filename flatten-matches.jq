import "util" as util;

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
| .team0 = (.teams[0] | util::null_to_empty_object)
| .team1 = (.teams[1] | util::null_to_empty_object)
| .team2 = (.teams[2] | util::null_to_empty_object)
| .team3 = (.teams[3] | util::null_to_empty_object)
| .team4 = (.teams[4] | util::null_to_empty_object)
| .team5 = (.teams[5] | util::null_to_empty_object)
| del(.teams)
| util::flatten(["team0", "team1", "team2", "team3", "team4", "team5"])
