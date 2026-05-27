# justfile for homelab-setup
# See docs/development.md for details.
# Note: GitHub Actions call uv directly, not this justfile.

set shell := ["bash", "-uc"]

default: install lint test

# List available recipes.
help:
    @just --list

# Install or sync all dependencies (incl. dev/extras).
install:
    uv sync --all-extras

# Run linting + formatting (codespell, ruff fix, ruff format, basedpyright).
lint:
    uv run python devtools/lint.py

# Check-only lint, matching CI (does not modify files).
lint-check:
    uv run python devtools/lint.py --check

# Run pytest.
test:
    uv run pytest

# Upgrade all locked dependencies.
upgrade:
    uv sync --upgrade --all-extras --dev

# Build distributable artifacts.
build:
    uv build

# Remove build/test caches and the local virtualenv.
clean:
    -rm -rf dist/
    -rm -rf *.egg-info/
    -rm -rf .pytest_cache/
    -rm -rf .mypy_cache/
    -rm -rf .venv/
    -find . -type d -name "__pycache__" -exec rm -rf {} +

# ---- Homelab tooling (stubs — wire up once tools land in the repo) ----

# Lint Ansible playbooks/roles.
ansible-lint:
    @echo "TODO: ansible-lint <paths>"

# Format Terraform/OpenTofu config.
tofu-fmt:
    @echo "TODO: tofu fmt -recursive"

# Validate Terraform/OpenTofu config.
tofu-validate:
    @echo "TODO: tofu validate"

# Validate a Packer template.
packer-validate TEMPLATE:
    @echo "TODO: packer validate {{TEMPLATE}}"

# Convenience: lint + typecheck + test (CI-equivalent).
check: lint-check test
