# Example Projects

This directory contains minimal starter projects that demonstrate how to adopt EasyDeploy. At the moment the repository ships a single Node.js example while additional templates are in progress.

## Available Examples

| Path | Description |
|------|-------------|
| `examples/nodejs` | Opinionated React/Node project showing commit-based deployments |

## Trying the Node.js Example

```bash
cd examples/nodejs

# Read the example-specific README for instructions
cat README.md

# Install dependencies and run locally (if desired)
npm install
npm run dev

# Simulate an EasyDeploy setup
../../scripts/init/install.sh --dir . --type nodejs
```

The example project mirrors the layout produced by the installer. Use it as a reference when adapting EasyDeploy to your own codebase.

## Copying to Your Project

```bash
cp -R examples/nodejs/* /path/to/your/project/
```

Then follow the main [Installation Guide](../docs/INSTALLATION.md) to apply EasyDeploy to the copied project.

---

Looking for language-specific templates? Contributions are welcome—add your example under `examples/<language>` and open a pull request.
