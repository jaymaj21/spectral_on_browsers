# 📘 Spectral Web — Multi-Cursor Visual Text Editor in the Browser

**Spectral Web** is a fully browser-based, richly featured editor for text and code with support for **multi-cursor editing**, **regex-based highlighting**, **inline notes**, **styling**, **custom shortcuts**, and **S3 integration** — all without requiring any installation or backend server.

> 🧠 Originally crafted for advanced editing workflows, educational demos, and deep code/text markup, Spectral Web is now open-source and freely extensible.
> Here is a (slightly dated) video demo: https://youtu.be/b4CBOInIUts

## 🚀 Features

### 🖋️ Text & Code Editing
- Multi-line contentEditable editor with visual formatting
- Smart line wrapping and brace-aware indentation
- Configurable font, color, and size options
- Inline formatting: bold, italic, underline, remove formatting
- Indentation/Unindentation via Tab/Shift+Tab

### ⚡ Multi-Cursor Support
- Add multiple cursors to start or end of selected lines
- Insert, delete, and backspace work across all cursors
- Keyboard-friendly navigation (`←`, `→`, `Enter`, `Tab`)
- Visual blinking cursors to aid tracking

### 🔍 Regex Highlighting & Search
- 7 independent color-coded highlighters with regex support
- Optional case-insensitive matching
- Pop-up results panel with clickable anchors
- Contextual text shown before/after each match
- Toggle search results display with `Alt+1`...`Alt+7`

### 🔊 Accessibility
- Text-to-speech support for selected text (`🗣 Speak`)
- Readable font options like OpenDyslexic

### 🔗 Inline Notes and Anchors
- Insert custom note buttons with encoded Base64 payloads
- Inline anchor targets for internal linking or navigation

### 📥 File & Cloud I/O
- Upload `.txt` files via file picker
- Save/load HTML content to/from AWS S3 buckets
- Configurable S3 keys and regions via popup

### ✨ Extras
- Matching parentheses/brackets highlighting (`Ctrl+Alt+M`)
- Inline camel/snake/kebab-case transformation (`camel()`, etc.)
- Code-style reflow (`reflow(n)`), smart Enter key, word count
- Clipboard-friendly: `yy(n)` to yank/copy `n` lines, `dd(n)` to cut them, `p()` to paste

## 🧪 Try It Now

Just open [`spectral.html`](./spectral.html) in any modern browser. No install needed. Works offline.

## 🛠️ Installation

```bash
git clone https://github.com/jaymaj21/spectral_on_browser.git
cd spectral_on_browser
open spectral.html
```

> No build steps required. This is pure HTML + JavaScript.

## ⌨️ Key Bindings

| Shortcut                | Action                            |
|------------------------|-----------------------------------|
| `Ctrl+M`               | Add note                          |
| `Ctrl+L`               | Start recording (if supported)    |
| `Ctrl+Alt+M`           | Match brackets                    |
| `Ctrl+Alt+S`           | Save (to S3 or internal)          |
| `Ctrl+Alt+Z` / `Y`     | Undo / Redo                       |
| `Ctrl+Alt+C`           | Clear highlights                  |
| `Alt+1`...`Alt+7`      | Toggle search results for highlighters |
| `Enter` (no cursor)    | Smart newline insertion           |
| `Esc`                  | Open JavaScript Eval console      |

## 🧑‍💻 Developer Hooks

### JS Commands
- Extend `yy(n)`, `dd(n)`, '2yy', '2dd' etc in the JS console for vi-style edits
- Evaluate snippets directly in the console or via the Eval popup

## 🧾 License

Spectral Web is distributed under the **Spectral Web Open License (SWOL)**.

You are free to use, modify, distribute, and incorporate this software in any project — commercial or personal — provided that:

- You **acknowledge** this repository as the origin of your derived work:  
  https://github.com/jaymaj21/spectral_on_browsers
- You accept that the software is provided **as-is**, with **no warranties** or **indemnities**.

See [`LICENSE.md`](./LICENSE.md) for full details.

## 🙏 Acknowledgments

Created and maintained by **Jayanta Majumder** with help from friends, students, and the ChatGPT project.
