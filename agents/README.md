# Agents

Agent skills, written once and used from any MCP client on that client's own model and login:
Claude Code with the Claude subscription, Codex with the ChatGPT login, or any other client. No
API keys, no background services.

```
agents/
  README.md                 this file
  haskell-coder/SKILL.md    production Haskell: modules, GHC errors, tests, cabal and Nix
  dotfiles-expert/SKILL.md  maintains this repository: Nix, nix-darwin, Homebrew, updates
```

A skill is a folder with a `SKILL.md`: frontmatter with a `name` and a `description` (which
also says when to use it), then the instructions. This is the open Agent Skills format.

## How it works

[Skillz](https://pypi.org/project/skillz/) is a small MCP server that reads this folder and serves
each skill as a tool. When a client calls the tool, it receives the skill's instructions and
carries out the task itself, with its own model, tools and sandbox.

```
Claude Code / Codex / any MCP client ──MCP (stdio)──> skillz ──reads──> ~/code/dotfiles/agents/*/SKILL.md
          └── does the work with its own model
```

The client starts Skillz on demand through `uvx` (`uv` comes from `modules/home.nix`), so there is
nothing to install and nothing left running.

## Setup

The skills reach every client through Skillz only. Don't also link them into a client's own skill
folder (`~/.claude/skills`, `~/.codex/skills`): the client would then load each skill twice.

Once per machine and per client. Every skill in this folder comes with the one registration; a
skill added later needs no new setup, only a client restart.

### Claude Code

1. Register the server for your user, so it is available in every project:

   ```sh
   claude mcp add --scope user skills -- uvx skillz@latest ~/code/dotfiles/agents
   ```

2. Restart Claude Code.
3. Check it: `claude mcp list` should show `skills` as connected, and `/mcp` inside a session
   lists its tools: one per skill, plus `fetch_resource` for files a skill ships with.

To remove it: `claude mcp remove skills -s user`.

### Codex

1. Register the server:

   ```sh
   codex mcp add skills -- uvx skillz@latest ~/code/dotfiles/agents
   ```

   This writes the entry to `~/.codex/config.toml`. Written by hand, it is:

   ```toml
   [mcp_servers.skills]
   command = "uvx"
   args = ["skillz@latest", "/Users/v0d1ch/code/dotfiles/agents"]
   ```

   Use the full path there; the config file does not expand `~`.

2. Restart Codex.
3. Check it: `codex mcp list` should show `skills`, and `/mcp` inside a session lists the same tools.

To remove it: `codex mcp remove skills`.

### Any other MCP client

Add a stdio server named `skills` with the command `uvx` and the arguments
`skillz@latest /Users/v0d1ch/code/dotfiles/agents`.

## Using a skill

Ask for the task and name the skill, so the client calls it rather than working without it:

```
use dotfiles-expert to install Raycast
use haskell-coder to fix the GHC errors in ~/code/hydra
```

## Adding a skill

Create `agents/<name>/SKILL.md`. Skillz picks it up the next time a client starts it, so restart
the client. Check that it parses with:

```sh
uvx skillz@latest ~/code/dotfiles/agents --list-skills
```

Skillz reads the frontmatter as strict YAML and silently skips a skill it cannot parse. A
`description` containing `: ` (a colon and a space) breaks it, so write the description as a
folded block:

```yaml
description: >-
  What the skill does and when to use it, over as many indented lines as needed.
``` Write the `description` so it says what the skill does and when to use it: that is
what the client reads when deciding to call it.

## Optional: delegating to another model

Not needed for the setup above. To hand a whole task to a different model than the one you are
talking to (a local model, or a long loop kept out of your session), the same skills can be served
by [fast-agent](https://fast-agent.ai) as agents running on Hermes (`modules/hermes.nix`).
Findings from trying it on 2026-10-08:

- `uvx fast-agent-mcp serve --agent-cards <dir> --transport http --port 8810` serves one MCP tool
  per agent card at `http://127.0.0.1:8810/mcp`; a card is a Markdown file with `name`,
  `description` and run settings in its frontmatter, and its body is the agent's instructions.
- fast-agent reaches Hermes through its `generic` provider (`base_url:
  http://127.0.0.1:8642/v1`, key in `GENERIC_API_KEY`). Hermes honours the requested model only with
  `direct_model_requests = true` (set in `modules/hermes.nix`), and reads it as
  `<provider>:<model>`, split at the first colon, e.g. `generic.custom:gpt-oss:20b` for local Ollama.
- On this 24 GB MacBook, `gpt-oss:20b` (13 GB) is the largest local model that leaves room to work.
- Hermes reaches Anthropic through an OAuth login. A Claude subscription is not for third-party
  tools, so route only API-key, cloud, Copilot or local credentials through it.
