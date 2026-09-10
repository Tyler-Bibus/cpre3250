# Agent Guidelines & Operational Notes

This document contains key workspace-specific operational constraints and best practices for AI agents working in this repository.

---

## 1. Jupyter Notebooks (`.ipynb`) Handling
- **Direct Editing Restriction**: The file editing tools (`replace_file_content`) prohibit editing `.ipynb` files directly to prevent corrupting notebook JSON structure and execution metadata.
- **Providing Code**: Prefer providing clean, copy-pasteable code blocks directly to the user to place into their active notebook cell.
- **Parsing Notebooks**: When inspecting notebooks, avoid fragile inline bash one-liners or complex f-strings. Use `grep_search` or clean `json.load()` scripts. If programmatic modification of a notebook is explicitly requested, always parse and re-serialize through standard JSON / `nbformat`.

---

## 2. Environment & Sandbox Boundaries
- **Virtual Environment (`.venv`)**:
  - The local virtual environment at `/home/tbibus/CprE325/.venv/` contains symlinks pointing to `/home/tbibus/.local/share/uv/python/...`.
  - In standard sandbox mode, files outside `/home/tbibus/CprE325` (such as `~/.local`) are not accessible. Calling `.venv/bin/python` directly will fail with `No such file or directory`.
  - When sandbox bypass is not enabled, avoid relying on the host `uv` python binary for scratch execution.
- **Filesystem Searches**:
  - **NEVER** run unconstrained `find` commands across `/home/tbibus/` or filesystem root. The directory tree is very large and will cause commands to hang or become long-running background tasks.
  - Limit file searches to the local workspace (`/home/tbibus/CprE325`) or use targeted search tools (`find_by_name`, `grep_search`).

---

## 3. Workflow Efficiency
- When asked for visualization, math, or model implementations, provide the solution directly without unnecessarily spending time searching for and booting up a full Python runtime environment unless execution or verification is explicitly necessary.

