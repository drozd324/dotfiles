---
name: auto-open-browser
description: Use when user asks to show, open, display, view, or point to an internet page, URL, website, link, documentation, article, or web resource.
---

# Auto Open Browser

Automatically open URLs in the user's default web browser whenever you are asked to show or point to internet pages.

## When to trigger

Trigger this skill when the user says:
- "point me to a page"
- "show me a website / internet page / link / URL"
- "open this in browser / firefox / chrome"
- "where can I read about X online"
- Any request that results in you returning one or more `http://` or `https://` URLs for the user to read.

Do NOT trigger for internal file reads or when you are just using `webfetch`/`websearch` for your own research without being asked to show the user a page.

## Behavior

1. **Always provide the URL in text** as normal (so the user can see/click it in chat) AND open it in the browser.

2. **Open with default browser** using bash. Prefer `xdg-open` (respects Linux default browser), fallback to `firefox` if needed:
   ```bash
   xdg-open "https://example.com" & disown; echo opened
   ```
   For multiple URLs, open each one:
   ```bash
   xdg-open "https://example.com/a" & xdg-open "https://example.com/b" & disown; echo opened
   ```
   On this system `firefox "URL" & disown` also works. Use `xdg-open` first.

3. **Run in parallel/background** - add `& disown` so opencode doesn't block. Do not wait for browser to close.

4. **Do not ask for permission** - if the user asked to see a page, opening it IS the expected action. Just do it and then confirm: "Opened in browser: <url>"

5. **Quote URLs** with double quotes to handle `&`, `?`, etc.

6. **Limit to reasonable number** - if you return >5 URLs from a search, only auto-open the top 2-3 most relevant unless user explicitly said "open all".

## Example

User: "point me to some page about nuclear notation"
Assistant: finds https://en.wikipedia.org/wiki/Isotope via websearch, then:
- calls `bash` with `xdg-open "https://en.wikipedia.org/wiki/Isotope" & disown`
- replies with link and confirmation "Opened https://en.wikipedia.org/wiki/Isotope in your default browser."

## Notes

- This skill requires `bash` permission. If permission is denied, tell user to allow `bash` with `xdg-open *` / `firefox *`.
- Never open URLs that were not requested to be shown. Background research fetches via `webfetch` do not need a browser open.
