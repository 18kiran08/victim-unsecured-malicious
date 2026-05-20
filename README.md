# victim-unsecured

Deliberately vulnerable demo repo for the **Citadel** runtime-security project.

## What's wrong with this repo

The workflow at `.github/workflows/build.yml` combines **three** common mistakes
that, together, make any fork PR a remote code execution + secret-exfiltration:

1. **`pull_request_target` trigger** — fires on fork PRs **with secrets access**.
   (Compare to `pull_request`, which runs sandboxed without secrets.)
2. **`actions/checkout` of `pull_request.head.sha`** — executes attacker code,
   not your main branch.
3. **`env: SECRET_TOKEN: ${{ secrets.SECRET_TOKEN }}`** — hands the secret
   to that attacker-controlled code.

An attacker forks this repo, modifies `build.sh` to exfiltrate `$SECRET_TOKEN`,
opens a PR, and watches it run with secrets. **No approval required.**

## Companion repo

See [`kiran-sec/victim-secured`](https://github.com/kiran-sec/victim-secured)
for the same workflow + the [Citadel](https://github.com/kiran-sec/citadel-action)
defense in `block` mode. Same attacker payload, completely different outcome.

## ⚠️ Do not deploy

No real production code lives here. `SECRET_TOKEN` is a demo string. Don't copy
this workflow into a real repo.
