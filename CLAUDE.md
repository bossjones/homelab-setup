# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A homelab automation toolkit (Ansible, OpenTofu/Terraform for Proxmox, macOS VMs via tart/packer/UTM) plus validation tooling for agentic infrastructure management. The Python package at `src/homelab_setup/` is currently a stub — `main()` is empty (see `src/homelab_setup/homelab_setup.py`). Most of the substance today lives in scaffolding, CI, and the `.claude/` ecosystem; the infra tooling (ansible, tofu, packer recipes in `justfile`) is stubbed with TODOs.

Scaffolded from [simple-modern-uv](https://github.com/jlevy/simple-modern-uv) via uvtemplate — see `.copier-answers.yml`. When updating template-managed files, expect Copier to want to overwrite them.

## Commands

Use `just` (the justfile is the canonical task runner; GitHub Actions calls `uv` directly).

```shell
just                  # default: install + lint + test
just install          # uv sync --all-extras
just lint             # auto-fix mode (codespell, ruff fix, ruff format, basedpyright)
just lint-check       # check-only mode — matches CI, fails on issues, does not modify files
just test             # uv run pytest
just upgrade          # uv sync --upgrade --all-extras --dev
just build            # uv build (produces wheel/sdist)
just clean            # remove dist/, caches, .venv/
just check            # lint-check + test (CI-equivalent locally)
```

Run a single test:

```shell
uv run pytest tests/test_placeholder.py
uv run pytest -s tests/test_placeholder.py::test_name   # show stdout
uv run pytest -k "substring"
```

Linting is orchestrated by `devtools/lint.py`, not by calling ruff/basedpyright directly. It runs against `src/`, `tests/`, `devtools/` (`SRC_PATHS` in that file) and `README.md`. If you add a top-level source dir, update `SRC_PATHS` there.

Homelab tooling recipes in the justfile (`ansible-lint`, `tofu-fmt`, `tofu-validate`, `packer-validate`) are placeholder echoes — wire them up when the corresponding tools land in the repo.

## Architecture notes

- **Dynamic versioning**: version comes from git tags via `uv-dynamic-versioning` (configured under `[tool.uv-dynamic-versioning]`). There is no version string in `pyproject.toml` — `version` is declared `dynamic`. CI uses `fetch-depth: 0` so tags are available; preserve that if editing workflows.
- **Releases publish to PyPI on git tag push** via `.github/workflows/publish.yml` using PyPI trusted publishing. Tag format is `vX.Y.Z`. See `docs/publishing.md` for the full release flow.
- **CI matrix** (`ci.yml`) tests Python 3.11–3.14 on ubuntu-latest. It pins `astral-sh/setup-uv` to a full version tag (setup-uv v8+ no longer publishes floating tags) and pins a specific `uv` version — bump both together when upgrading.
- **Supply-chain cool-off**: this repo intentionally does NOT set `UV_EXCLUDE_NEWER` in CI (the simple-modern-uv template ships it; it was removed because dev pins are recent). If you re-introduce it, set a date — uv expects a date, not a duration. See `docs/development.md#supply-chain-hardening`.
- **Type checking**: basedpyright (not mypy), configured under `[tool.basedpyright]` in `pyproject.toml`. Set to include `src/`, `tests/`, `devtools/`.

## Project rules (`.claude/rules/`)

These are checked into the repo and apply to all Claude sessions:

- **`audit-protocol.md`** — when invoking an audit agent (skill-auditor, command-audit, pr-review, etc.), pass ONLY the file path. No context, no "we just fixed X", no hint at what to look for. Tainted context skews audit results.
- **`python-scripts.md`** — standalone scripts use PEP 723 inline metadata (`#!/usr/bin/env -S uv run` with `# /// script` block). Prefer `pathlib.Path` over `os.path`; use `rich` for CLI output.
- **`documentation.md`** — markdown is linted with `rumdl` (config in `.rumdl.toml` once present). ATX headers, fenced code blocks with language, files end with a single newline. Docs live under `docs/{architecture,checklists,developer,ideas,notes,plans,research,reviews,templates}/` — date-prefix time-sensitive files (`YYYY-MM-DD-name.md`).
- **`skill-development.md`**, **`plugin-structure.md`** — present for Claude Code plugin/skill authoring conventions.

## Conventions worth knowing before editing

- Ruff line length is 100, not the default 88. Many pedantic rules are off (see `[tool.ruff.lint.ignore]` in `pyproject.toml`).
- Tests live in both `tests/` and inline within `src/` — `[tool.pytest.ini_options].testpaths = ["src", "tests"]`, and `python_files = ["*.py"]` means pytest will collect from any `.py` file.
- Public package symbols are re-exported via `from .homelab_setup import *` in `src/homelab_setup/__init__.py`. Add new public symbols to `__all__` there.
