def null_to_empty_object:
  if . == null then {} else . end;

def flatten($keys):
  with_entries(
      if .key as $key | . | any($keys[]; . == $key) # Check if .key is in $keys
      then .value|to_entries[]
      else . end
  );
