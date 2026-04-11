# How to install

## Nix

In your `flake.nix`, add:

```nix
  inputs.aifiles.url = "github:vorburger/aifiles";
  inputs.aifiles.flake = false;

... devShells ...

  # Symlink AI skills from https://github.com/vorburger/aifiles to the standard https://agentskills.io location
  mkdir -p .agents/
  rmdir .agents/skills 2>/dev/null || true
  ln -sfn "${inputs.aifiles}/skills" .agents/
```

## vercel-labs/skills

Using [`vercel-labs/skills`](https://github.com/vercel-labs/skills), run:

    npx skills add vorburger/aifiles
