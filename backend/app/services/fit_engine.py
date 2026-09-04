# fit_engine.py

def get_fit_verdict(user_measurement: float, garment_measurement: float, tolerance: float = 3.0) -> str:
    delta = user_measurement - garment_measurement
    if delta < -tolerance:
        return "tight"
    elif delta > tolerance:
        return "loose"
    return "good"


def get_full_fit_report(user_measurements: dict, garment_size_chart: dict) -> dict:
    report = {}
    for region, user_value in user_measurements.items():
        garment_value = garment_size_chart.get(region)
        if garment_value is None:
            report[region] = "insufficient data"
        else:
            report[region] = get_fit_verdict(user_value, garment_value)
    return report