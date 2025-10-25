# Legacy CI/CD Wrapper Scripts

These helper scripts are maintained for backwards compatibility. They forward every command to the newer tooling under `scripts/deploy/` so older documentation or automation keeps working.

- `trigger.sh` → `../deploy/auto-deploy.sh`
- `conflict_manager.sh` → `../deploy/troubleshoot.sh`
- `demo.sh` → `../deploy/status.sh`

## Recommended Usage

For all new work, call the scripts in `scripts/deploy/` directly:

```bash
./scripts/deploy/auto-deploy.sh commit-trigger
./scripts/deploy/status.sh status
./scripts/deploy/troubleshoot.sh detect
```

Refer to the updated documentation in `docs/` for feature descriptions and examples. These wrappers will remain minimal and are not intended to receive new capabilities.
