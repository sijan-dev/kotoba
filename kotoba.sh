#!/usr/bin/env bash

if ! response="$(curl --fail --silent --show-error --max-time 10 \
  "https://api.animechan.io/v1/quotes/random")"; then
  printf 'Error: could not fetch an anime quote.\n' >&2
  exit 1
fi

fields=()
while IFS= read -r -d '' field; do
  fields+=("$field")
done < <(
  RESPONSE="$response" python3 -c '
import json
import os
import sys

try:
    data = json.loads(os.environ["RESPONSE"])["data"]
    quote = data["content"].strip()
    full_stop = quote.find(".")
    if full_stop != -1:
        quote = quote[:full_stop + 1]
    values = (
        quote,
        data["character"]["name"],
        data["anime"]["name"],
    )
    sys.stdout.buffer.write("\0".join(values).encode())
    sys.stdout.buffer.write(b"\0")
except (KeyError, TypeError, json.JSONDecodeError) as error:
    print("Error: unexpected Animechan response: {}".format(error), file=sys.stderr)
    sys.exit(1)
'
)

if [[ "${#fields[@]}" -ne 3 ]]; then
  printf 'Error: unexpected Animechan response.\n' >&2
  exit 1
fi

quote="${fields[0]}"
author="${fields[1]}"
anime="${fields[2]}"

if ! translation_response="$(curl --fail --silent --show-error --max-time 10 \
  --get "https://api.mymemory.translated.net/get" \
  --data-urlencode "q=$quote" \
  --data-urlencode "langpair=en|ja")"; then
  printf 'Error: could not translate the quote into Japanese.\n' >&2
  exit 1
fi

if ! japanese_translation="$(
  RESPONSE="$translation_response" python3 -c '
import json
import os
import sys

try:
    translated = json.loads(os.environ["RESPONSE"])["responseData"]["translatedText"]
    if not translated:
        raise ValueError("empty translation")
    print(translated)
except (KeyError, TypeError, ValueError, json.JSONDecodeError) as error:
    print("Error: unexpected translation response: {}".format(error), file=sys.stderr)
    sys.exit(1)
'
)"; then
  exit 1
fi

printf '%s\n' "$quote"
printf '%s\n' "$japanese_translation"
printf -- '— %s(%s)\n' "$author " "$anime"
