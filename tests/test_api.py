import pytest
from fastapi.testclient import TestClient

from app.main import MAX_TEXT_CHARS, app

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


@pytest.mark.parametrize(
    "payload",
    [
        {"text": "a b c", "size": 5, "overlap": 5},
        {"text": "a b c", "size": 5, "overlap": 9},
        {"text": "a b c", "size": 0, "overlap": 0},
        {"text": "a b c", "size": 5, "overlap": -3},
        {"text": "a b c", "size": 5000, "overlap": 1},
        {"text": "", "size": 5, "overlap": 1},
        {"size": 5, "overlap": 1},
    ],
    ids=[
        "overlap_equals_size",
        "overlap_larger_than_size",
        "size_zero",
        "negative_overlap",
        "size_above_limit",
        "empty_text",
        "missing_text",
    ],
)
def test_invalid_chunk_requests_return_422(payload):
    response = client.post("/chunk", json=payload)
    assert response.status_code == 422


def test_overlap_error_explains_the_rule():
    response = client.post("/chunk", json={"text": "a b c", "size": 5, "overlap": 5})
    assert "overlap must be smaller than size" in response.json()["detail"][0]["msg"]


def test_text_over_limit_is_rejected():
    response = client.post("/chunk", json={"text": "a" * (MAX_TEXT_CHARS + 1)})
    assert response.status_code == 422
