"""
Room Access Request System — Security API
Flask backend for DevSecOps Experiment 7

Pipeline:
  GitHub → Build → Unit Test → Docker → SonarQube → OWASP ZAP → Deploy
"""

from flask import Flask, request, jsonify
from markupsafe import escape

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
#  DEVSECOPS DEMONSTRATION CONTROL:
#  -------------------------------------------------------------------------
#  PASS STATE (Default):
#    User query is safely escaped with markupsafe.escape(query).
#    All security tests, SAST, and OWASP ZAP DAST scans pass.
#
#  FAIL STATE (Classroom Demonstration):
#    To demonstrate a security gate failure in class, replace `safe_query`
#    with raw `query` below:
#      f"<p>Results for: {query}</p>"
#    This triggers CWE-79 (Reflected XSS), fails the security test,
#    causes the Risk Decision to FAIL, and BLOCKS deployment.
# ════════════════════════════════════════════════════════════════════════════
@app.route("/search")
def search():
    query = request.args.get("q", "")
    safe_query = escape(query)

    return (
        "<html>"
        "<head><title>Room Search</title></head>"
        "<body>"
        "<h1>Room Search</h1>"
        f"<p>Results for: {safe_query}</p>"
        "</body>"
        "</html>"
    )


if __name__ == "__main__":
    import os
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)  # nosec B104

