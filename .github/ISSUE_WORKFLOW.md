# Issue Tracking Workflow

## Overview
This project uses a file-based issue tracking system for managing bugs and features until we set up GitHub Issues.

## Directory Structure
```
.github/
├── ISSUES/                    # Active issues (tracked in git)
│   ├── bug_001_xxx.md
│   ├── feature_001_xxx.md
│   └── ...
└── ISSUE_TEMPLATE/            # Templates for creating new issues
    ├── bug_report.md
    └── feature_request.md
```

## Creating a New Issue

### Bug Report
1. Copy `.github/ISSUE_TEMPLATE/bug_report.md` to `.github/ISSUES/`
2. Rename to `bug_XXX_short_description.md` (e.g., `bug_001_double_sack_crash.md`)
3. Fill in all sections
4. Commit: `git add .github/ISSUES/bug_XXX_*.md && git commit -m "bug: Add issue #XXX - [title]"`

### Feature Request
1. Copy `.github/ISSUE_TEMPLATE/feature_request.md` to `.github/ISSUES/`
2. Rename to `feature_XXX_short_description.md` (e.g., `feature_001_enhanced_rerack_animation.md`)
3. Fill in all sections
4. Commit: `git add .github/ISSUES/feature_XXX_*.md && git commit -m "feat: Add feature request #XXX - [title]"`

## Issue States

Add status to the top of each issue file:

```markdown
**Status:** [Planned / In Progress / Testing / Done / Wont Fix]
```

## Closing Issues

When an issue is resolved:
1. Update status to `Done` in the issue file
2. Move to `.github/ISSUES/closed/` directory
3. Reference in commit: `git commit -m "fix: Resolve issue #001 - [title]"`

## Migration to GitHub Issues

When ready to use GitHub Issues:
1. Create issues on GitHub from the `.github/ISSUES/` files
2. Reference the file-based issue numbers in GitHub issue descriptions
3. Archive `.github/ISSUES/` to `.github/ISSUES_ARCHIVE/`

## Labels

Use these labels in issue files:

**Type:**
- `bug` - Something isn't working
- `enhancement` - New feature or improvement
- `documentation` - Documentation updates
- `refactor` - Code cleanup without functional changes

**Priority:**
- `critical` - Blocker, must fix immediately
- `high` - Important, schedule soon
- `medium` - Normal priority
- `low` - Nice to have

**Component:**
- `ui` - User interface
- `gameplay` - Game logic
- `animation` - Animations and transitions
- `performance` - Performance optimization
- `testing` - Test coverage

## Quick Commands

```bash
# List all open issues
ls .github/ISSUES/*.md

# List bugs only
ls .github/ISSUES/bug_*.md

# List features only
ls .github/ISSUES/feature_*.md

# Search issues
grep -r "animation" .github/ISSUES/

# Count open issues
ls .github/ISSUES/*.md | wc -l
```

## Example Workflow

1. **Report bug:** Create `bug_002_score_not_updating.md`
2. **Commit:** `git commit -m "bug: Add issue #002 - Score not updating after foul"`
3. **Fix bug:** Make code changes
4. **Commit fix:** `git commit -m "fix: Update score calculation (closes #002)"`
5. **Update issue:** Move to `closed/` with status `Done`
