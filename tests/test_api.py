from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_returns_ok():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_chunk_endpoint_splits_text():
    text = " ".join(f"word{n}" for n in range(300))
    response = client.post("/chunk", json={"text": text, "size": 200, "overlap": 50})
    assert response.status_code == 200
    assert response.json()["count"] == 2
