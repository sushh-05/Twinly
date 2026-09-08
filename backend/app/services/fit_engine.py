"""Explainable, chart-based size guidance for the curated Twinly catalog."""

from typing import Any

REGIONS = (("bust", "bustCm", "chestCm"), ("waist", "waistCm", None), ("hip", "hipCm", None))


def get_fit_verdict(user_measurement: float, garment_measurement: float, tolerance: float = 3.0) -> str:
    """Legacy verdict used by /fit-check; positive delta means tight."""
    delta = user_measurement - garment_measurement
    if delta > tolerance:
        return "tight"
    if delta < -tolerance:
        return "loose"
    return "good"


def get_full_fit_report(user_measurements: dict, garment_size_chart: dict) -> dict:
    return {region: "insufficient data" if (value := garment_size_chart.get(region)) is None else get_fit_verdict(user_value, value) for region, user_value in user_measurements.items()}


def _label_for_ease(ease: float) -> str:
    if ease < 0:
        return "tight"
    if ease <= 2:
        return "slightly_snug"
    if ease <= 6:
        return "good"
    return "loose"


def _preferred_distance(ease: float, preferred_fit: str) -> float:
    """Distance from the requested positive-ease range.

    Negative ease is deliberately much more expensive than ordinary distance:
    a size that is tight in any region should not win merely because another
    region happens to be close to the requested fit.
    """
    lower, upper = {"fitted": (0, 2), "regular": (2, 4), "relaxed": (4, 6)}[preferred_fit]
    if ease < 0:
        return 50 + abs(ease) * 10
    if ease < lower:
        return lower - ease
    if ease > upper:
        return ease - upper
    return 0


def build_fit_report(garment: dict[str, Any], measurements: dict[str, float], preferred_fit: str) -> dict[str, Any] | None:
    """Rank every available chart size; None means no usable detailed chart."""
    charts = garment.get("sizeChart")
    if garment.get("sizeChartVerified") is False or not isinstance(charts, dict) or not charts:
        return None
    candidates = []
    for size, chart in charts.items():
        if not isinstance(chart, dict):
            continue
        regions, score, complete, positive_eases = {}, 0.0, True, []
        for output_name, primary_key, alternate_key in REGIONS:
            chart_value = chart.get(primary_key, chart.get(alternate_key) if alternate_key else None)
            if not isinstance(chart_value, (int, float)):
                complete, score = False, score + 100
                regions[output_name] = {"label": "unknown", "easeCm": None}
                continue
            ease = round(float(chart_value) - measurements[output_name], 1)
            regions[output_name] = {"label": _label_for_ease(ease), "easeCm": ease}
            score += _preferred_distance(ease, preferred_fit)
            positive_eases.append(ease)
        average_ease = sum(positive_eases) / len(positive_eases) if positive_eases else 0
        candidates.append((score, str(size), regions, complete, average_ease))
    if not candidates:
        return None
    # When distances tie, preferences resolve the otherwise indistinguishable
    # available sizes. In particular, relaxed intentionally favours more room.
    if preferred_fit == "fitted":
        ranking_key = lambda item: (item[0], item[4])
    elif preferred_fit == "relaxed":
        ranking_key = lambda item: (item[0], -item[4])
    else:
        ranking_key = lambda item: (item[0], abs(item[4] - 3))
    score, recommended_size, regions, complete, _ = min(candidates, key=ranking_key)
    labels = [region["label"] for region in regions.values()]
    # High means every region lands in the requested target range. A total
    # distance of six or less is one small two-centimetre miss per region and
    # remains a useful, but medium-confidence, nearest-size recommendation.
    confidence = "low"
    if complete and "tight" not in labels:
        confidence = "high" if score == 0 else "medium" if score <= 6 else "low"
    return {"recommendedSize": recommended_size, "confidence": confidence, "regions": regions, "explanation": f"{recommended_size} is the closest available size to your {preferred_fit} fit preference based on the verified demo size chart."}
