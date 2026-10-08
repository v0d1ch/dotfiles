# Agents

Agent skills and the fast-agent cards that serve them. A skill is written once and used from any
client and any model: Claude Code and Codex load the skill folders directly, and fast-agent
serves them as MCP tools that run on whatever model Hermes is pointed at.

```
agents/
  README.md                 this file
  agents                    start/stop script: ./agents up | down | status
  fast-agent.yaml           fast-agent config: Hermes as the model endpoint, default model, skills
  haskell-coder/SKILL.md    a skill: frontmatter (name, description) plus the instructions
  dotfiles-expert/SKILL.md  a skill: maintains this repository (Nix, nix-darwin, Homebrew, updates)
  cards/haskell-coder.md    a fast-agent card: the agent fast-agent serves as an MCP tool
  cards/dotfiles-expert.md  the card for dotfiles-expert
```

## Quick start

```sh
~/code/dotfiles/agents/agents up
```

That links the skills for Hermes, Claude Code and Codex; starts Ollama when the default model is a
local one (and pulls it the first time); starts Hermes and fast-agent; and registers fast-agent with
Claude Code and Codex. Restart the client, then prompt it, naming the agent. `./agents status`
shows what is running and `./agents down` stops what `up` started; anything already running before
`up` is left alone. Logs are in `~/.local/state/agents`. The sections below are the same steps by
hand.

- **Skills hold the expertise.** One folder per skill, in the open Agent Skills format. No model
  is named in a skill.
- **Cards turn skills into callable agents.** A card gives the tool its name and description, the
  model, and run settings. Its body is two lines: an instruction to load the skill, and the
  `{{agentSkills}}` placeholder, where fast-agent lists the available skills. Do not copy skill
  text into a card.

How a call flows:

```
MCP client ──MCP──> fast-agent (:8810) ──OpenAI wire──> Hermes (:8642) ──> model vendor
 (Claude Code, Codex)   cards + skills                    tool loop, credentials   └─> ~/code/<project>
```

## 1. Start Hermes

Hermes is installed and configured by `modules/hermes.nix`. It runs in managed mode, so
`hermes config set` refuses; change that module and rebuild instead:

```sh
cd ~/code/dotfiles && sudo darwin-rebuild switch --flake .#macbook
```

Nothing starts at login. Start the gateway in its own terminal and leave it running:

```sh
hermes gateway run
```

It serves an OpenAI-compatible API on `127.0.0.1:8642`. Requests need `API_SERVER_KEY` from
`~/.hermes/.env` as a bearer token. Check it is up:

```sh
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8642/v1/models   # 401 = up, wants the key
```

Restart Hermes after every rebuild or Hermes upgrade. A gateway started before an upgrade keeps
running from the old install and fails every model call with `ModuleNotFoundError`.

### Credentials and models

Hermes holds every provider credential; fast-agent holds none. Provider logins and keys live in
`~/.hermes/.env` and `~/.hermes/auth.json`, never in this repository.

`direct_model_requests = true` in `modules/hermes.nix` makes Hermes honour the model a caller
names. The model string is `<provider>:<model>`, split at the first colon (tested 2026-10-08):

| model string sent to Hermes | provider used | model name passed on |
|---|---|---|
| `custom:qwen3-coder` | `custom` (the Ollama endpoint in `modules/hermes.nix`) | `qwen3-coder` |
| `anthropic:<model>` | `anthropic` | `<model>` |

Only route traffic through a credential that allows it. A Claude subscription login is not for
third-party tools; use an Anthropic API key, a cloud route (Bedrock, Vertex), Copilot, or a local
model.

For a local model, run Ollama and pull it once:

```sh
ollama serve &
ollama pull gpt-oss:20b
```

## 2. Configure fast-agent

fast-agent needs no install: `uvx fast-agent-mcp` downloads and runs it (`uv` comes from
`modules/home.nix`). Its config is `agents/fast-agent.yaml`:

```yaml
# fast-agent talks to Hermes's OpenAI-compatible API. The key is GENERIC_API_KEY (= API_SERVER_KEY).
generic:
  base_url: "http://127.0.0.1:8642/v1"

# Used by every card without its own `model:` line. "generic." selects the provider above; the rest
# is the Hermes model string from the table in section 1.
default_model: "generic.custom:gpt-oss:20b"

skills:
  directories:
    - "~/code/dotfiles/agents"
```

Choosing the model:

- **One model for everything:** `default_model` above, and no `model:` line in the cards.
- **One model per agent:** a `model:` line in that card, in the same `generic.<provider>:<model>`
  form. The card wins over the default.
- **One model for a single run:** `--model` on the command line.

`cards/haskell-coder.md` has no `model:` line, so it runs on the default. A plain name such as
`model: sonnet` would bypass Hermes and call Anthropic directly, which needs `ANTHROPIC_API_KEY`.

## 3. Load the skills

The same skill folders feed three places:

- **fast-agent** reads `~/code/dotfiles/agents` through `skills.directories` above, or
  `--skills <dir>` on the command line.
- **Hermes** has its own skills directory. Link a skill there too, so Hermes's own skill tools can
  load it when the card says "load the haskell-coder skill":

  ```sh
  ln -sfn ~/code/dotfiles/agents/haskell-coder ~/.hermes/skills/haskell-coder
  ```

- **Claude Code and Codex**, to use a skill directly with no fast-agent in between:

  ```sh
  mkdir -p ~/.claude/skills ~/.codex/skills
  ln -sfn ~/code/dotfiles/agents/haskell-coder ~/.claude/skills/haskell-coder
  ln -sfn ~/code/dotfiles/agents/haskell-coder ~/.codex/skills/haskell-coder
  ```

To add a skill, create `agents/<name>/SKILL.md` and link it the same way. To give it its own
tool, add `cards/<name>.md` modelled on `cards/haskell-coder.md`.

## 4. Run fast-agent

From `~/code/dotfiles/agents`, with the Hermes key exported for fast-agent:

```sh
cd ~/code/dotfiles/agents
export GENERIC_API_KEY=$(grep '^API_SERVER_KEY=' ~/.hermes/.env | cut -d= -f2-)
```

Try an agent interactively first:

```sh
uvx fast-agent-mcp go -c fast-agent.yaml --agent-cards cards --agent haskell-coder
```

Serve every card as an MCP tool over HTTP:

```sh
uvx fast-agent-mcp serve -c fast-agent.yaml --agent-cards cards --transport http --port 8810
```

Leave out `--shell`: with Hermes as the model, Hermes already runs the terminal and file tools on
this machine.

Register the server once with each client:

```sh
claude mcp add --scope user --transport http fast-agent http://localhost:8810/mcp
codex mcp add fast-agent --url http://localhost:8810/mcp
```

Each card appears as one tool, named after the card. Restart the client to pick up a new card.

## Stopping

Ctrl-C in the fast-agent and Hermes terminals. Nothing else is left running.

## Not yet verified

Verified 2026-10-08 with fast-agent 0.10.43: `serve` starts the server at
`http://127.0.0.1:8810/mcp`, and each card is one tool named after the card, taking a single
`message` string. There is no separate project argument, so name the project in the message.
fast-agent serves no MCP prompts.

Not yet verified:

- **Skill loading through Hermes.** Whether the agent loads the skill via Hermes's own skill tools
  when the card tells it to. If it does not, put the skill text back into the card body.
