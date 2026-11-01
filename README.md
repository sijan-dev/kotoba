# Kotoba

A small Bash script that fetches a random anime quote, translates it into
Japanese with character and anime title.

## Requirements

- Bash
- `curl`
- Python 3

## Usage

```bash
./kotoba.sh
```

Example output:

```text
English quote.
Japanese translation。
— Character (Anime)
```

## APIs

- [Animechan API](https://animechan.io/docs) — random anime quotes and attribution
- [MyMemory Translation API](https://mymemory.translated.net/doc/spec.php) — English-to-Japanese translation
