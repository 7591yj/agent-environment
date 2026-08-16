# Agent Environment

A shared coding-agent environment managed with Nix and Home Manager.

## Setup

Add this repository's Home Manager module to your configuration, then enable it:

```nix
programs.agent-environment.enable = true;
```

## Customize

- Pi configuration: [`pi/agent`](./pi/agent)
- Home Manager module: [`modules/home-manager.nix`](./modules/home-manager.nix)
- Local skills: [`skills`](./skills)

## Notes

- This flake includes Cursor Agent, Claude Code, Codex, OpenCode, T3 Code (CLI and desktop), and Pi (with extensions, themes, and skills).
- Pi is provided by [`numtide/llm-agents.nix`](https://github.com/numtide/llm-agents.nix). A weekly GitHub Actions workflow advances this flake's locked revision after `nix flake check` passes.

## Licenses

This flake is based on [my-pi-setup](https://github.com/davis7dotsh/my-pi-setup).

Skills included from external sources remain subject to the licenses of their respective creators. Refer to each skill's source for its license terms.
