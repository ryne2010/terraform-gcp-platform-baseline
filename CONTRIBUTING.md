# Contributing

PRs are welcome.

## Dev
- Run `make fmt` before committing.
- Ensure examples validate: `make validate`.

## Guidelines
- Keep modules composable and minimal.
- Prefer secure-by-default behavior (public access should be opt-in).
- Avoid storing secret values in Terraform state.

## Pre-commit (recommended)

If you use pre-commit locally, you'll catch formatting issues before CI:

```bash
brew install pre-commit
pre-commit install
pre-commit run -a
```

