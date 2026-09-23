"""
Unit tests for Room Access API — DevSecOps Experiment 7
Run locally:  pytest api/tests/ -v
"""
import sys
import os
import pytest

# Ensure api/ is on sys.path when tests run from repo root
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from app import app  # noqa: E402


@pytest.fixture
def client():
    """Create a Flask test client."""
    app.testing = True
    with app.test_client() as c:
        yield c


# ─── Home page ────────────────────────────────────────────────────────────────
class TestHomePage:
    def test_index_returns_200(self, client):
        """GET / must return HTTP 200."""
        assert client.get("/").status_code == 200

    def test_index_contains_app_name(self, client):
        """GET / must mention the application name."""
        response = client.get("/")
        assert b"Room Access" in response.data


# ─── Health endpoint ──────────────────────────────────────────────────────────
class TestHealth:
    def test_health_returns_200(self, client):
        """GET /health must return HTTP 200."""
        assert client.get("/health").status_code == 200

    def test_health_returns_json(self, client):
        """GET /health must return application/json."""
        response = client.get("/health")
        assert "application/json" in response.content_type

    def test_health_status_ok(self, client):
        """GET /health body must contain status=ok."""
        data = client.get("/health").get_json()
        assert data["status"] == "ok"

    def test_health_includes_service(self, client):
        """GET /health body must include a service field."""
        data = client.get("/health").get_json()
        assert "service" in data


# ─── Search endpoint ──────────────────────────────────────────────────────────
class TestSearch:
    def test_search_returns_200(self, client):
        """GET /search?q=term must return HTTP 200."""
        assert client.get("/search?q=lab101").status_code == 200

    def test_search_reflects_term(self, client):
        """GET /search?q=Library must contain 'Library' in the response."""
        response = client.get("/search?q=Library")
        assert b"Library" in response.data

    def test_search_empty_query_returns_200(self, client):
        """GET /search without ?q must still return HTTP 200."""
        assert client.get("/search").status_code == 200


# ─── Security headers (present in both FAIL and PASS states) ─────────────────
class TestSecurityHeaders:
    def test_x_frame_options(self, client):
        """X-Frame-Options header must be present."""
        assert "X-Frame-Options" in client.get("/").headers

    def test_x_content_type_options(self, client):
        """X-Content-Type-Options header must be present."""
        assert "X-Content-Type-Options" in client.get("/").headers

    def test_content_security_policy(self, client):
        """Content-Security-Policy header must be present."""
        assert "Content-Security-Policy" in client.get("/").headers
