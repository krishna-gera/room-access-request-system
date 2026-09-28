# Room Access Request System

Flutter app for managing container-room access requests with role-based flows:
- Student: create request, view approvals, show QR pass.
- Admin: review and approve requests.
- Guard: scan QR and validate time-window access.
- Tech Admin: placeholder dashboard.

## Setup

1. Install Flutter SDK.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure environment variables in `.env`:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```
4. Run app:
   ```bash
   flutter run
   ```

A sample file is included at `.env.example`.


## Supabase setup (required)

Run these SQL files in Supabase SQL Editor:

1. `supabase/schema.sql` (creates all required tables)
2. `supabase/seed.sql` (adds sample role/profile/member data after Auth users are created)

Then create Auth users (email/password) from Supabase Dashboard or Admin API for:
- student1, student2
- admin1, admin2
- guard
- techadmin

Important role values for `public.profiles.role`:
- `student`
- `admin`
- `guard`
- `tech_admin` (must include underscore)

Quick fix if Tech Admin role insert/update fails:
```sql
update public.profiles
set role = 'tech_admin'
where email = 'techadmin@example.com';
```

---

# Experiment 7 — Security Testing and Automation

## Aim
Demonstrate an end-to-end DevSecOps CI/CD pipeline that automatically detects and **blocks deployment** of a vulnerable application using OWASP ZAP DAST, and allows deployment once the vulnerability is fixed.

## Objective
1. Build and test the application automatically on every push.
2. Run static code analysis (SonarQube) after the build.
3. Run dynamic application security testing (OWASP ZAP) against the live Docker container.
4. Block deployment when a security vulnerability is detected.
5. Allow deployment only when all security gates pass.

## Tools Used
| Tool | Purpose |
|---|---|
| GitHub | Source control & pipeline trigger |
| GitHub Actions | CI/CD orchestration |
| Python Flask | Lab API application (DAST target) |
| pytest | Unit testing |
| Docker | Containerisation |
| SonarQube / SonarCloud | SAST — static code analysis |
| OWASP ZAP | DAST — dynamic security testing |

## Architecture
```
GitHub (push to branch)
         ↓
 1. Build & Unit Tests  (pytest)
         ↓
 2. Docker Build        (python:3.12-slim)
         ↓
 3. SonarQube           (SAST — static analysis)
         ↓
 4. Docker Run          (container on localhost:5000)
         ↓
 5. OWASP ZAP DAST      (full scan + active scan)
         ↓
 6. Security Gate       (exit 0 = pass | exit 2 = fail)
         ↓
 7. Deployment          (only if ALL gates pass)
```

## Project Structure
```
room-access-request-system/
├── api/                          ← Python Flask API (DAST target)
│   ├── app.py                    ← Application source (FAIL/PASS state)
│   ├── requirements.txt
│   ├── Dockerfile
│   └── tests/
│       └── test_app.py           ← pytest unit tests
├── .github/
│   └── workflows/
│       ├── security-pipeline.yml ← Experiment 7 pipeline  ← NEW
│       └── docker-security.yml   ← Experiment 6 Trivy pipeline (unchanged)
├── sonar-project.properties      ← SonarQube / SonarCloud config  ← NEW
├── lib/                          ← Flutter app (completely unchanged)
└── README.md
```

## Setup Requirements

### GitHub Secrets Required
| Secret | Value | Where to get it |
|---|---|---|
| `SONAR_TOKEN` | SonarCloud personal token | https://sonarcloud.io/account/security |

> SonarQube step is skipped gracefully if `SONAR_TOKEN` is not set — the pipeline still runs ZAP.

### SonarCloud Setup
1. Log in at https://sonarcloud.io using your GitHub account.
2. Import this repository as a new project.
3. Copy the **Project Key** and **Organization slug** into `sonar-project.properties`.
4. Add `SONAR_TOKEN` → GitHub → Settings → Secrets → Actions.

## Local Execution

```bash
# Install Python dependencies
pip install -r api/requirements.txt

# Run unit tests
pytest api/tests/ -v

# Start application
python api/app.py
# Endpoints:
#   http://localhost:5000/
#   http://localhost:5000/health
#   http://localhost:5000/search?q=test
```

## Docker Execution

```bash
# Build
docker build -t room-access-api:latest -f api/Dockerfile api/

# Run
docker run -d --name api -p 5000:5000 room-access-api:latest

# Verify
curl http://localhost:5000/health
curl "http://localhost:5000/search?q=room101"

# Stop
docker stop api
```

## OWASP ZAP Configuration

```bash
# Run ZAP full scan locally (requires app container running first)
docker run --rm --network host \
  -v $(pwd)/zap-reports:/zap/wrk/:rw \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py \
    -t http://localhost:5000 \
    -r zap-report.html \
    -J zap-report.json \
    -I
```
- `-I` : only fail on HIGH-risk (FAIL-level) alerts
- Exit 0 = PASS | Exit 2 = FAIL

## FAIL Scenario — Vulnerable Code (`experiment7-fail` branch)

**Vulnerability:** Reflected XSS (CWE-79) in the `/search?q=` endpoint.

```python
# api/app.py — INTENTIONAL LAB VULNERABILITY
@app.route("/search")
def search():
    query = request.args.get("q", "")
    return f"<p>Results for: {query}</p>"   # ← unsanitised user input
```

**Expected pipeline result:**
```
1. Build & Unit Tests   ✅
2. Docker Build         ✅
3. SonarQube            ✅
4. OWASP ZAP DAST       ❌  Cross Site Scripting (Reflected) — HIGH risk
5. Security Gate        ❌  BLOCKED
6. Deployment           ⏭️  SKIPPED
```

### Git commands — FAIL branch
```bash
git checkout main
git checkout -b experiment7-fail
git add api/ sonar-project.properties .github/workflows/security-pipeline.yml README.md
git commit -m "feat(exp7): add security pipeline with intentional XSS [CWE-79]"
git push origin experiment7-fail
```

## PASS Scenario — Fixed Code (`experiment7-pass` branch)

**Fix:** Use `markupsafe.escape()` to sanitise user input.

Edit `api/app.py`:
```python
from markupsafe import escape   # add this import at the top

@app.route("/search")
def search():
    query = request.args.get("q", "")
    safe_query = escape(query)              # ← SANITISE before use
    return (
        "<html><head><title>Room Search</title></head>"
        "<body><h1>Room Search</h1>"
        f"<p>Results for: {safe_query}</p>"  # ← safe
        "</body></html>"
    )
```

**Expected pipeline result:**
```
1. Build & Unit Tests   ✅
2. Docker Build         ✅
3. SonarQube            ✅
4. OWASP ZAP DAST       ✅  No HIGH-risk alerts
5. Security Gate        ✅  PASSED
6. Deployment           ✅  DEPLOYED
```

### Git commands — PASS branch
```bash
git checkout experiment7-fail
git checkout -b experiment7-pass
# Edit api/app.py to apply the fix above
git add api/app.py
git commit -m "fix(exp7): sanitise /search input with markupsafe.escape() [CWE-79]"
git push origin experiment7-pass
```

## Security Gate Logic
```
Vulnerability found (HIGH risk)          No HIGH-risk vulnerability
          ↓                                         ↓
   ZAP exit code 2                          ZAP exit code 0
          ↓                                         ↓
   Job owasp-zap FAILS                      Job owasp-zap PASSES
          ↓                                         ↓
   Job deploy SKIPPED                       Job deploy RUNS
          ↓                                         ↓
   DEPLOYMENT BLOCKED                       DEPLOYMENT ALLOWED
```

## Screenshot Checklist

### FAIL build
| # | Screenshot |
|---|---|
| 1 | GitHub → Code tab → `experiment7-fail` branch |
| 2 | `api/app.py` with the vulnerable line highlighted |
| 3 | GitHub Actions workflow running |
| 4 | Job "1. Build & Unit Tests" — ✅ |
| 5 | Job "2. Docker Build" — ✅ |
| 6 | Job "3. SonarQube Analysis" — ✅ |
| 7 | Job "4. OWASP ZAP DAST Scan" — ❌ showing XSS alert |
| 8 | Full workflow — ❌ red |
| 9 | Job "5. Deployment" — ⏭️ skipped |

### PASS build
| # | Screenshot |
|---|---|
| 10 | `api/app.py` showing `escape(query)` fix |
| 11 | GitHub Actions new run in progress |
| 12 | Job "1. Build & Unit Tests" — ✅ |
| 13 | Job "2. Docker Build" — ✅ |
| 14 | Job "3. SonarQube Analysis" — ✅ |
| 15 | Job "4. OWASP ZAP DAST Scan" — ✅ |
| 16 | Full workflow — all green ✅ |
| 17 | Job "5. Deployment" — ✅ "Deployment completed successfully" |

---

# DevSecOps CI/CD Pipeline

A complete, production-grade automated DevSecOps CI/CD pipeline implemented in GitHub Actions for the Room Access Request System.

## Architecture

```
Developer
   ↓
GitHub
   ↓
CI Build
   ↓
Unit Tests
   ↓
Security Tests
   ↓
Static Security Scan
   ↓
Risk Decision
   ↓
Docker Build
   ↓
Deploy
```

## Tools Used

| Tool | Category | Purpose |
|---|---|---|
| **GitHub Actions** | CI/CD Orchestration | Workflow automation, stage dependencies, and artifact management |
| **Python 3.12 / pip** | Build Environment | Dependency resolution and bytecode compilation validation |
| **pytest / pytest-flask** | Unit Testing | Functional API and security regression tests |
| **pip-audit** | Software Supply Chain Security | Dependency vulnerability scanning against PyPA advisory database |
| **Trivy (FS & Image)** | Vulnerability Scanner | Filesystem secret scan and container image CVE detection |
| **OWASP ZAP Baseline** | DAST | Dynamic application security testing of running web service |
| **Bandit** | SAST | AST-based static code analysis for Python security vulnerabilities |
| **SonarQube / SonarCloud** | SAST & Quality Gate | Cloud-native static code analysis (optional via `SONAR_TOKEN`) |
| **Docker Buildx** | Containerisation | Minimal, non-root hardened production image building |

## Trigger Conditions

The DevSecOps pipeline (`.github/workflows/devsecops.yml`) triggers on:
- `push` to `main`
- `push` to `experiment7-*`
- `pull_request` targeting `main`
- `workflow_dispatch` (manual trigger from GitHub Actions tab)

## Pipeline Stages

### 1. Build Stage (`build`)
- Checks out the repository using `actions/checkout@v4`.
- Configures Python 3.12 with pip cache.
- Installs dependencies from `api/requirements.txt`.
- Validates syntax and executes bytecode compilation (`python -m compileall api/`).
- Verifies required packages (`flask`, `markupsafe`).
- Publishes build verification summary to GitHub Step Summary and saves build log artifact.

### 2. Unit Testing Stage (`unit-test`)
- Runs pytest suite (`api/tests/test_app.py`) covering endpoints, JSON response schema, HTTP security headers, and input escaping.
- Generates JUnit XML test report (`reports/junit-test-results.xml`).
- Stores test reports as workflow artifacts.
- Enforces strict gate: Any failing test immediately stops downstream execution.

### 3. Security Testing Stage (`security-test`)
- **Dependency Audit**: Executes `pip-audit -r api/requirements.txt` to detect vulnerable packages.
- **Secret Scanning**: Runs Trivy filesystem scanner across the repository to detect exposed API keys, credentials, or private configuration.
- **DAST (OWASP ZAP)**: Starts local Flask service on `http://localhost:5000`, waits for readiness via `/health`, and runs `zap-baseline.py` against the running service to verify headers, endpoints, and absence of Medium/High-risk vulnerabilities.
- Uploads `zap-report.html` and `pip-audit.json` artifacts.

### 4. Static Security Scanning Stage (`static-security-scan`)
- **Bandit SAST**: Scans Python source code (`bandit -r api/ -x api/tests -ll`) with exit-code enforcement on Medium/High security flaws.
- **SonarCloud SAST**: Integrates with SonarCloud using `sonar-project.properties`. If `SONAR_TOKEN` is present in GitHub Secrets, runs quality gate analysis; if omitted, gracefully logs information and proceeds.
- Uploads `bandit-report.json` as an artifact.

### 5. Risk Decision & Quality Gate Stage (`risk-decision`)
- Evaluates the health of all 4 prerequisite jobs (`build`, `unit-test`, `security-test`, `static-security-scan`).
- Formats console banner and GitHub Step Summary Markdown table:
  - If **ALL** stages succeed: Declares `Risk Decision: PASS` and `Deployment: ALLOWED`. Exits `0`.
  - If **ANY** stage fails: Declares `Risk Decision: FAIL` and `Deployment: BLOCKED`. Exits `1`.
- Because `docker-build` and `deploy` depend on `risk-decision`, any failure automatically prevents image building and deployment.

### 6. Docker Build & Container Scan Stage (`docker-build`)
- Executes **ONLY** after Risk Decision passes.
- Uses `api/Dockerfile` (unprivileged `python:3.12-slim` base, non-root user `appuser:1001`, built-in `HEALTHCHECK`).
- Builds and tags image as `room-access-api:${{ github.sha }}` and `room-access-api:latest`.
- Scans built container with **Trivy** (`vuln-type: os,library`, `severity: CRITICAL,HIGH`).
- Performs local container smoke test against `/health`.
- Exports and uploads compressed Docker image artifact.

### 7. Deployment Gate Stage (`deploy`)
- Executes **ONLY** after Docker build and container scan succeed.
- Confirms end-to-end security clearance across all stages.
- Executes controlled release simulation tagged with git SHA `${{ github.sha }}`.
- Publishes final deployment table to GitHub Step Summary.

---

## Fail → Fix → Pass Demonstration (Classroom Activity)

This repository includes two safe, reproducible options to demonstrate the DevSecOps quality gates in class:

### OPTION A: Controlled Unit Test Gate Demonstration (Fastest & Simplest)

1. **Trigger Failure (FAIL)**:
   In `api/tests/test_app.py`, change:
   ```python
   DEMO_GATE_STATUS = "PASS"
   ```
   to:
   ```python
   DEMO_GATE_STATUS = "FAIL"
   ```
   Commit and push:
   ```bash
   git commit -am "demo: trigger controlled unit test failure"
   git push origin main
   ```
   **Result in CI**:
   - `Unit Tests` job: **FAIL** ❌
   - `Risk Decision` job: **FAIL** ❌
   - Log output:
     ```
     ========================================
            DEVSECOPS RISK DECISION
     ========================================
     Build:              PASS
     Unit Tests:         FAIL
     Security Tests:     SKIPPED
     Static Scan:        SKIPPED
     Risk Decision:      FAIL
     Deployment:         BLOCKED
     ========================================
     ```
   - `Docker Build`: **SKIPPED** ⏭️
   - `Deployment`: **BLOCKED / SKIPPED** 🚫

2. **Fix the Failure (FIX → PASS)**:
   In `api/tests/test_app.py`, revert back:
   ```python
   DEMO_GATE_STATUS = "PASS"
   ```
   Commit and push:
   ```bash
   git commit -am "fix: restore quality gate to passing state"
   git push origin main
   ```
   **Result in CI**:
   - All jobs: **PASS** ✅
   - `Risk Decision`: **PASS** ✅
   - `Docker Build`: **PASS** ✅
   - `Deployment`: **ALLOWED** 🚀

---

### OPTION B: Controlled Security Gate Demonstration (CWE-79 XSS)

1. **Trigger Failure (FAIL)**:
   In `api/app.py`, change the search endpoint from safe escaped input:
   ```python
   safe_query = escape(query)
   return (
       ...
       f"<p>Results for: {safe_query}</p>"
   )
   ```
   to unescaped input:
   ```python
   return (
       ...
       f"<p>Results for: {query}</p>"  # unescaped user input
   )
   ```
   Commit and push to a demo branch:
   ```bash
   git checkout -b experiment7-fail
   git commit -am "demo: introduce unescaped reflection [CWE-79]"
   git push origin experiment7-fail
   ```
   **Result in CI**:
   - `Unit Tests` (XSS assertion) or `OWASP ZAP DAST`: **FAIL** ❌
   - `Risk Decision`: **FAIL** ❌ (`Deployment: BLOCKED`)
   - `Docker Build` & `Deployment`: **BLOCKED** 🚫

2. **Fix the Failure (FIX → PASS)**:
   Re-apply `safe_query = escape(query)` and return `safe_query`.
   Commit and push:
   ```bash
   git commit -am "fix: sanitize query input with markupsafe.escape()"
   git push origin main
   ```
   **Result in CI**:
   - All stages **PASS** ✅ and Deployment is **ALLOWED** 🚀.

---

## Required GitHub Secrets

| Secret Name | Required? | Purpose |
|---|---|---|
| `SONAR_TOKEN` | Optional | SonarCloud token for SAST analysis. If not provided, pipeline uses local Bandit scanner without failing. |
| `GITHUB_TOKEN` | Automatic | Provided automatically by GitHub Actions for repository access. |

> **Note**: No secrets or private keys are stored in this repository. All credentials must be configured under repository **Settings → Secrets and variables → Actions**.

---

## Local Validation Commands

```bash
# 1. Setup local environment
python3 -m venv .venv
source .venv/bin/activate
pip install -r api/requirements.txt pip-audit bandit

# 2. Run unit tests
pytest api/tests/ -v

# 3. Run dependency vulnerability scan
pip-audit -r api/requirements.txt

# 4. Run static security analysis (SAST)
bandit -r api/ -x api/tests -ll

# 5. Build and run API service
python api/app.py

# 6. Test endpoints
curl http://localhost:5000/health
curl "http://localhost:5000/search?q=Lab101"
```


