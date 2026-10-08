# Hermes Agent (github.com/NousResearch/hermes-agent): the brain behind the agent fleet in
# github.com/Devnull-org/plenum. Installed and configured declaratively with Hermes' own
# home-manager module; nothing runs at login (plenum's `fleet up` starts `hermes gateway run`
# on demand). Secrets stay out of the repo: ~/.hermes/.env holds API_SERVER_KEY (the same value
# as plenum's .env) and any provider keys; the Anthropic OAuth login lives in ~/.hermes/auth.json.
# Hermes is in "managed" mode, so `hermes config set` and `hermes update` refuse; change this file
# and rebuild instead.
{ inputs, ... }:
{
  flake.modules.homeManager.hermes = { ... }: {
    imports = [ inputs.hermes-agent.homeManagerModules.default ];

    programs.hermes-agent.enable = true;   # `hermes` on PATH, HERMES_HOME=~/.hermes

    services.hermes-agent = {
      enable = true;                        # owns ~/.hermes/config.yaml (Nix keys override, the rest is kept)
      gateway.enable = false;               # no launchd agent: the fleet runs the gateway when needed
      backend.mode = "none";

      settings = {
        _config_version = 49;

        # Fallback model when a request carries no provider/model override. The haskell-coder agent
        # sends MODEL=<provider>/<model> as a per-request override, so this is rarely used.
        model = {
          provider = "custom:ollama";
          default = "qwen3-coder";
        };
        # Named OpenAI-compatible endpoints, referenced as provider "custom:<name>".
        providers.ollama = {
          base_url = "http://localhost:11434/v1";
          api_key = "ollama";
        };

        # Commands run right here, as the user, with the login shell's environment (nix on PATH).
        terminal = {
          backend = "local";
          cwd = "/Users/v0d1ch/code";          # where the projects are; a task names the subdirectory
          timeout = 3600;                      # seconds per command; a cold `nix develop` is slow
        };

        agent = {
          max_turns = 150;
          gateway_timeout = 3600;
          # Everything a sandboxed-by-convention coder does not need. `clarify` is off because nothing
          # answers questions on the API server.
          disabled_toolsets = [
            "web" "browser" "vision" "video" "video_gen" "image_gen" "tts" "cronjob" "delegation"
            "clarify" "x_search" "computer_use" "desktop_ui" "kanban" "connections" "discord"
            "discord_admin" "spotify" "feishu_doc" "feishu_drive" "setup"
          ];
        };

        # No sandbox: the agent runs as the user on this Mac. Approvals are off (nobody answers
        # prompts on the API server), so these globs are the guard rail; they block even in yolo mode.
        approvals = {
          mode = "off";
          deny = [
            "rm -rf /workspace*" "rm -rf /*" "rm -rf ~*" "rm -rf /Users*"
            "git push --force*" "git push -f*" "git reset --hard*" "git clean*" "git checkout -- *"
            "sudo *" "*nix-collect-garbage*" "*nix store gc*"
          ];
        };

        memory.memory_enabled = true;

        # The OpenAI-compatible API the fleet talks to, loopback only. The key comes from
        # API_SERVER_KEY in ~/.hermes/.env (16+ characters).
        gateway.platforms.api_server = {
          enabled = true;
          host = "127.0.0.1";
          port = 8642;
          # Honour a bare `model` without `provider`: fast-agent's OpenAI-compatible provider sends only
          # `model`, so this is what lets each fast-agent card pick its model. plenum always sends both.
          direct_model_requests = true;
          tool_progress_events = true;     # hermes.tool.progress SSE events -> A2A status updates
          max_concurrent_runs = 4;
        };
      };
    };
  };
}
