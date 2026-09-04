# tests/test_styling_engine.py
import sys, os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.services.styling_engine import get_styling_suggestions

def test_matches_occasion_and_budget():
    result = get_styling_suggestions("dinner", 20.0)
    assert result["hairstyle"] is not None
    assert isinstance(result["accessories"], list)

def test_no_match_returns_empty():
    result = get_styling_suggestions("nonexistent_occasion", 5.0)
    assert result["accessories"] == []