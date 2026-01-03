---
description: Commit and push changes to GitHub
---

# Git Commit and Push Workflow

Use this workflow to commit and push changes to GitHub.

## When to Commit

Commit changes after:
- ✅ Completing a feature or significant improvement
- ✅ Fixing a bug
- ✅ Making localization updates
- ✅ Refactoring code
- ✅ Before ending a work session

**Don't commit:**
- ❌ Broken/incomplete code
- ❌ Debug statements or temporary changes
- ❌ Code that doesn't build

## Steps

### 1. Check Status
```bash
git status
```

Review changed files to ensure they're all intentional.

### 2. Add Files
```bash
# Add all changes
git add .

# Or add specific files
git add lib/widgets/player_name_field.dart
```

### 3. Commit with Descriptive Message

**Format:** 
```
<type>: <short description>

<optional detailed description>
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `refactor:` Code restructuring without functional changes
- `style:` UI/styling changes
- `docs:` Documentation updates
- `chore:` Maintenance tasks

**Examples:**
```bash
git commit -m "feat: add player validation and prepopulation

- Fix PlayerNameField to update when initialValue changes
- Add hasValidPlayers getter for button validation
- Update button to show START GAME when players are valid
- Rename Spielregeln to Voreinstellungen in German"
```

```bash
git commit -m "fix: resolve break foul score calculation bug"
```

### 4. Push to GitHub
```bash
git push
```

If this is a new branch:
```bash
git push -u origin <branch-name>
```

## Quick Command (All-in-One)
```bash
git add . && git commit -m "feat: your message here" && git push
```

## After Restart

If you restarted the conversation and have uncommitted changes:

1. Check what changed:
```bash
git status
git diff
```

2. Review recent session logs:
- Check `task.md` for completed work
- Check `walkthrough.md` for implementation details

3. Create a commit message based on the work done

4. Commit and push as usual
