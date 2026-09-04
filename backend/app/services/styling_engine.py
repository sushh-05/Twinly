# app/services/styling_engine.py
import json
import os

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "catalog"))

def load_json(filename):
    path = os.path.join(BASE_DIR, filename)
    with open(path, "r") as f:
        return json.load(f)

def get_styling_suggestions(occasion: str, budget: float) -> dict:
    accessories = load_json("accessories.json")
    hairstyles = load_json("hairstyles.json")

    matched_accessories = [
        a for a in accessories
        if occasion in a.get("occasion", []) and a["price"] <= budget
    ]
    matched_hairstyles = [
        h for h in hairstyles
        if occasion in h.get("occasion", [])
    ]

    return {
        "hairstyle": matched_hairstyles[0] if matched_hairstyles else None,
        "accessories": matched_accessories[:2],
        "reason": f"Matches {occasion} occasion within budget of {budget}"
    }