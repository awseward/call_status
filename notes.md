# Homebrew Auto-PR Notes

## Inputs

- Tap location (assume GitHub for now)
- Formula location within tap
- Auth token
- File url
- File checksum
- Misc PR details (assignee, reviewers, title/body templating?)

## General approach

1. Clone repo @master
2. Update formula file
   - Maybe check that version is actually different and abort if so?
   - More checks like this, but will probably stop there for now.
3. Commit
4. Push
5. Open PR
