"""
Room Access Request System — Security API
Flask backend for DevSecOps Experiment 7

Pipeline:
  GitHub → Build → Unit Test → Docker → SonarQube → OWASP ZAP → Deploy
"""

from flask import Flask, request, jsonify

app = Flask(__name__)


# ─── Security response headers ───────────────────────────────────────────────
@app.after_request
def add_security_headers(response):
    """Attach standard HTTP security headers to every response."""
    response.headers["X-Frame-Options"] = "SAMEORIGIN"
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Content-Security-Policy"] = "default-src 'self'"
    return response


# ─── GET / ────────────────────────────────────────────────────────────────────
@app.route("/")
def index():
    """Home page — lists available endpoints."""
    return (
        "<html>"
        "<head><title>Room Access API</title></head>"
        "<body>"
        "<h1>Room Access Request System</h1>"
        "<p>Security API for DevSecOps Experiment 7.</p>"
        "<ul>"
        '<li><a href="/health">/health</a> — health check</li>'
        '<li><a href="/search?q=lab101">/search?q=term</a> — room search</li>'
        "</ul>"
        "</body>"
        "</html>"
    )


# ─── GET /health ──────────────────────────────────────────────────────────────
@app.route("/health")
def health():
    """Health check — used by Docker and CI/CD pipeline readiness probes."""
    return jsonify(
        {
            "status": "ok",
            "service": "room-access-api",
            "version": "1.0.0",
        }
    )


# ════════════════════════════════════════════════════════════════════════════
#  INTENTIONAL LAB VULNERABILITY — CWE-79: Reflected Cross-Site Scripting
#  ─────────────────────────────────────────────────────────────────────────
#  EXPERIMENT 7 FAIL SCENARIO — DO NOT USE IN PRODUCTION
#
#  The ?q= query parameter is reflected directly into the HTML response
#  without ANY sanitisation or escaping.
#
#  Attack example:
#    GET /search?q=<script>alert(document.cookie)</script>
#    → The script tag appears verbatim in the response HTML.
#    → A victim who clicks the crafted URL executes the attacker's script.
#
#  Detection method:
#    OWASP ZAP active scan injects standard XSS payloads (e.g.
#    <script>alert(1)</script>) into ?q=, receives them back unescaped,
#    and raises a HIGH-risk alert.
#
#  Why the pipeline fails:
#    ZAP exits with code 2 (FAIL-level / HIGH-risk alert found).
#    GitHub Actions treats exit ≠ 0 as step failure.
#    The deploy job depends on the ZAP job → deployment is BLOCKED.
#
#  How to fix (PASS branch):
#    from markupsafe import escape
#    safe_query = escape(query)          # ← replace `query` with `safe_query`
#    return f"... {safe_query} ..."
#
# ════════════════════════════════════════════════════════════════════════════
@app.route("/search")
def search():
    query = request.args.get("q", "")

    # VULNERABLE LINE — user input injected into HTML without escaping
    return (
        "<html>"
        "<head><title>Room Search</title></head>"
        "<body>"
        "<h1>Room Search</h1>"
        f"<p>Results for: {query}</p>"  # ← INTENTIONAL LAB VULNERABILITY
        "</body>"
        "</html>"
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
