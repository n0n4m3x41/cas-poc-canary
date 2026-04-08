# Apereo CAS GitHub Actions Expression Injection (CWE-78)

**Severity:** High  
**Location:** `.github/workflows/release.yml`  
**Prerequisite:** Repository write access or compromised maintainer token  

---

## Summary

A command injection vulnerability exists in the release workflow due to unsafe interpolation of user-controlled input inside a shell execution block.

The GitHub Actions expression `${{ inputs.releaseVersion }}` is evaluated at **workflow template time**, not at runtime. As a result, shell quoting does **not** prevent injection.

An attacker can inject arbitrary commands, leading to **remote code execution (RCE)** in the CI environment and exposure of sensitive secrets.

---

## Vulnerable Code

```yaml
run: |
  RELEASE_VERSION="${{ inputs.releaseVersion }}"  # ← injection point
  ./ci/release.sh "$RELEASE_VERSION"
```

---

## Root Cause

- `${{ }}` expressions are evaluated before the shell executes
- User input is directly embedded into a shell context
- Double quotes (`"`) do not prevent injection

---

## Exploitation

An attacker can craft input that:

1. Closes the string
2. Injects commands
3. Reopens the string

### Example Payload

```bash
7.2.0" && <command> && echo "
```

---

## Secrets at Risk

| Secret            | Purpose                  |
|------------------|--------------------------|
| `PGP_PRIVATE_KEY` | Signs Maven artifacts    |
| `PGP_PASSPHRASE`  | Unlocks PGP key          |
| `REPOSITORY_USER` | Maven Central access     |
| `REPOSITORY_PWD`  | Maven Central access     |
| `GITHUB_TOKEN`    | Repository write access  |

---

## Proof of Concept

- PoC script: `./poc.sh`

- Successful exploitation:

  - Workflow run:  
    https://github.com/n0n4m3x41/cas/actions/runs/24108697996  

  - Injected file:  
    https://github.com/n0n4m3x41/cas/blob/master/pwned.txt  

---

## Impact

- Remote Code Execution (CI runner)
- Secret exfiltration
- Supply chain compromise (artifact signing)
- Repository takeover via `GITHUB_TOKEN`

---

## Remediation

### 1. Avoid direct interpolation in `run`

```yaml
env:
  RELEASE_VERSION: ${{ inputs.releaseVersion }}

run: |
  ./ci/release.sh "$RELEASE_VERSION"
```

---

### 2. Validate input

```bash
[[ "$RELEASE_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || exit 1
```

---

### 3. Treat inputs as untrusted

- Never embed `${{ }}` directly into shell commands
- Prefer environment variables or arguments
- Apply least privilege to secrets

---

## Detection

- Look for `${{ }}` inside `run:` blocks
- Flag unsanitized workflow inputs
- Use static analysis tools

