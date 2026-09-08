import os
import sys

from fastapi.testclient import TestClient

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from app.main import app

client = TestClient(app)


def payload(**overrides):
    result = {"garmentId": "dress_001", "bustCm": 88, "waistCm": 70, "hipCm": 96, "preferredFit": "regular"}
    result.update(overrides)
    return result


def test_api_health():
    assert client.get("/api/health").json() == {"status": "ok", "service": "twinly-backend"}


def test_api_garments():
    response = client.get("/api/garments")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
    assert response.json()[0]["id"] == "dress_001"


def test_fit_report():
    response = client.post("/api/fit-report", json=payload())
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "ok"
    assert body["recommendedSize"] is not None
    assert set(body["regions"]) == {"bust", "waist", "hip"}


def test_fit_report_unknown_garment():
    assert client.post("/api/fit-report", json=payload(garmentId="missing")).status_code == 404


def test_fit_report_rejects_non_positive_measurement():
    assert client.post("/api/fit-report", json=payload(bustCm=0)).status_code == 422


def test_fit_report_insufficient_data(monkeypatch):
    monkeypatch.setattr("app.api.routes.get_garment_by_id", lambda _: {"id": "partial", "sizeChart": {}})
    response = client.post("/api/fit-report", json=payload(garmentId="partial"))
    assert response.status_code == 200
    assert response.json()["status"] == "insufficient_data"


def test_unverified_shirt_returns_the_exact_disclaimer():
    response = client.post("/api/fit-report", json=payload(garmentId="shirt_001"))
    body = response.json()
    assert response.status_code == 200
    assert body["status"] == "insufficient_data"
    assert body["disclaimer"] == (
        "Twinly provides a size-guidance estimate based on the available size chart "
        "and your entered measurements. It does not guarantee fit."
    )


def test_fit_preference_changes_the_available_recommendation():
    measurements = {"bustCm": 84, "waistCm": 68, "hipCm": 92}
    fitted = client.post("/api/fit-report", json=payload(**measurements, preferredFit="fitted")).json()
    regular = client.post("/api/fit-report", json=payload(**measurements, preferredFit="regular")).json()
    relaxed = client.post("/api/fit-report", json=payload(**measurements, preferredFit="relaxed")).json()

    assert (fitted["recommendedSize"], fitted["confidence"]) == ("S", "high")
    # S is exactly at the regular target's lower bound in all regions.
    assert (regular["recommendedSize"], regular["confidence"]) == ("S", "high")
    # S and M are equally distant from relaxed; the relaxed tie-break prefers M's room.
    assert (relaxed["recommendedSize"], relaxed["confidence"]) == ("M", "medium")


def test_fit_report_disclaimer_is_exact():
    response = client.post("/api/fit-report", json=payload())
    assert response.json()["disclaimer"] == (
        "Twinly provides a size-guidance estimate based on the available size chart "
        "and your entered measurements. It does not guarantee fit."
    )
