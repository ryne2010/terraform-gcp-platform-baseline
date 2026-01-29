# Contributing

PRs are welcome.

## Dev
- Run `make fmt` before committing.
- Ensure examples validate: `make validate`.

## Guidelines
- Keep modules composable and minimal.
- Prefer secure-by-default behavior (public access should be opt-in).
- Avoid storing secret values in Terraform state.
