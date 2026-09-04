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