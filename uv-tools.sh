#!/usr/bin/env bash
set -euo pipefail

# User-wide Python tools managed by uv. Keep one install command per tool,
# including its Python version, extras and additional dependencies.
# Run ./uv-tools.sh to install; ./uv-tools.sh --upgrade to update.
# Additional arguments are passed to every `uv tool install` command.

# LangGraph: graph library, CLI (`langgraph`) and local development server.
# https://github.com/langchain-ai/langgraph
uv tool install --python 3.13 --with langgraph 'langgraph-cli[inmem]' "$@"
