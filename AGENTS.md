# Instructions for AI Agents

**This file must be named `AGENTS.md` (uppercase, markdown format) so AI tools can easily discover and read it.**

## Core Rule: Everything is .org

**All content in this repository must be `.org` files. Never create `.md`, `.html`, or other format files.**

### What This Means

- ✅ **DO**: Create and edit `.org` files
- ❌ **DON'T**: Create `.md`, `.html`, `.txt`, or any other format for content
- ❌ **DON'T**: Edit generated HTML files in `_site/`
- ❌ **DON'T**: Convert org files to other formats

## Transformation Pipeline

```
.org files → jekyll-org plugin → HTML → GitHub Pages
```

**The transformation must stay simple and straightforward.**

## How to Work Here

### Adding Content
1. Create a new `.org` file in the appropriate directory
2. Use Org-mode syntax
3. Push to `main` - GitHub Actions handles the rest

### Editing Content
1. Edit the `.org` file directly
2. Push changes
3. Site rebuilds automatically

### Linking Between Files
Use org link syntax: `[[./other-file.org][Link Text]]`

The jekyll-org plugin converts these to HTML automatically.

## Key Constraints

- **Ruby 2.7.x required** (for jekyll-org compatibility)
- **UTF-8 encoding only** (no invalid bytes)
- **No custom HTML generation** (keep it simple)
- **No build complexity** (org → HTML via jekyll-org, that's it)

## When You Want to Help

Ask yourself: "Does this keep the org-to-HTML transformation simple and straightforward?"

- If yes → proceed
- If no → don't do it

## Summary

**Everything is `.org`. Transformation to HTML is automatic, simple, and straightforward via Jekyll + jekyll-org plugin. Never deviate from this.**
