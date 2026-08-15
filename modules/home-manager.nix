{ self, inputs }:
{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.agent-environment;
in
{
  imports = [ inputs.agent-skills-nix.homeManagerModules.default ];

  options.programs.agent-environment = {
    enable = lib.mkEnableOption "shared coding-agent environment";
    piConfigPath = lib.mkOption {
      type = lib.types.path;
      default = self + /pi/agent;
      description = "Source directory for the Pi configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.agent-skills = {
      enable = true;
      sources.local.path = "${self}/skills";
      sources.nix-best-practices = {
        path = inputs.nix-best-practices;
        subdir = ".claude/skills";
        filter.nameRegex = "^nix-best-practices$";
      };
      sources.stop-slop = {
        path = inputs.stop-slop;
        filter.nameRegex = "^$";
      };
      sources.anthropics-pdf = {
        path = inputs.anthropics-skills;
        subdir = "skills";
        filter.nameRegex = "^pdf$";
      };
      sources.impeccable = {
        path = inputs.impeccable;
        subdir = ".pi/skills";
        filter.nameRegex = "^impeccable$";
      };
      sources.cloudflare = {
        path = inputs.cloudflare-skills;
        subdir = "skills";
      };

      skills = {
        enableAll = false;
        enable = [
          "background-terminals"
          "nix-best-practices"
          "pdf"
          "stop-slop"
          "impeccable"
          "linear-local-first-architecture"
          "subagents"
          "agents-sdk"
          "cloudflare"
          "cloudflare-email-service"
          "cloudflare-one"
          "cloudflare-one-migrations"
          "durable-objects"
          "sandbox-migrate-to-next"
          "sandbox-next"
          "sandbox-stable"
          "turnstile-spin"
          "web-perf"
          "workers-best-practices"
          "wrangler"
        ];
      };

      targets = {
        agents.enable = true;
        claude.enable = true;
        codex.enable = true;
        pi = {
          enable = true;
          dest = ".pi/agent/skills";
        };
      };
    };

    home.file = {
      ".pi/agent/AGENTS.md" = {
        source = "${cfg.piConfigPath}/AGENTS.md";
        force = true;
      };
      ".pi/agent/settings.json" = {
        source = "${cfg.piConfigPath}/settings.json";
        force = true;
      };
      ".pi/agent/extensions" = {
        source = "${cfg.piConfigPath}/extensions";
        force = true;
      };
      ".pi/agent/themes" = {
        source = "${cfg.piConfigPath}/themes";
        force = true;
      };
    };

    home.sessionVariables.WRANGLER_NO_SKILLS_UPDATE_PROMPTS = "true";
  };
}
