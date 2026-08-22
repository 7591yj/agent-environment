{
  description = "Agent Environment Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };
    agent-skills-nix = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-best-practices = {
      url = "github:0xbigboss/claude-code";
      flake = false;
    };
    impeccable = {
      url = "github:pbakaus/impeccable";
      flake = false;
    };
    cloudflare-skills = {
      url = "github:cloudflare/skills";
      flake = false;
    };
    anthropics-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };
    unslop = {
      url = "github:cursor/plugins";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      agent-skills-nix,
      nix-best-practices,
      impeccable,
      cloudflare-skills,
      anthropics-skills,
      unslop,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      homeManagerModules.default = import ./modules/home-manager.nix { inherit self inputs; };

      checks = nixpkgs.lib.genAttrs supportedSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          home-manager =
            (home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                self.homeManagerModules.default
                {
                  home.username = "agent-environment-check";
                  home.homeDirectory = "/tmp/agent-environment-check";
                  home.stateVersion = "25.05";
                  programs.agent-environment.enable = true;
                }
              ];
            }).activationPackage;
        }
      );

      sources = {
        inherit
          nix-best-practices
          impeccable
          cloudflare-skills
          anthropics-skills
          unslop
          ;
      };
    };
}
