# tests/test_fit_engine.py
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.services.catalog_service import get_garment_by_id
from app.services.fit_engine import build_fit_report, get_fit_verdict, get_full_fit_report


def test_tight():
    assert get_fit_verdict(82, 76) == "tight"


def test_good():
    assert get_fit_verdict(76, 76) == "good"


def test_loose():
    assert get_fit_verdict(70, 76) == "loose"


def test_boundary_good():
    assert get_fit_verdict(73, 76) == "good"  # exactly at -3 tolerance


def test_missing_data():
    report = get_full_fit_report(
        {"bustCm": 92, "shoulderCm": 40},
        {"bustCm": 92, "waistCm": 76}
    )
    assert report["shoulderCm"] == "insufficient data"
    assert report["bustCm"] == "good"


def test_negative_ease_is_tight():
    garment = get_garment_by_id("dress_001")
    report = build_fit_report(
        garment,
        {"bust": 110, "waist": 70, "hip": 96},
        "regular",
    )
    assert report["regions"]["bust"]["label"] == "tight"
    assert report["confidence"] == "low"
