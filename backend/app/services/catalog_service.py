# app/services/catalog_service.py
import json
import os

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "catalog"))

def load_garments():
    path = os.path.join(BASE_DIR, "garments.json")
    with open(path, "r") as f:
        return json.load(f)

def get_garment_by_id(garment_id: str):
    garments = load_garments()
    for g in garments:
        if g["id"] == garment_id:
            return g
    return None


def list_garments(category: str | None = None):
    """Return catalog entries, optionally restricted to a category."""
    garments = load_garments()
    if category is None:
        return garments
    return [garment for garment in garments if garment.get("category") == category]
