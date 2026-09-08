# app/services/catalog_service.py
import json
import os

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "catalog"))

def load_garments():
    path = os.path.join(BASE_DIR, "garments.json")
    with open(path, "r") as f:
        garments = json.load(f)
    # The demo app ships eight local dress photos. Keep the legacy source
    # record (dress_001) authoritative and derive the remaining curated demo
    # entries from its verified chart rather than duplicating chart data.
    base = next((garment for garment in garments if garment["id"] == "dress_001"), None)
    if base:
        variants = [
            ("dress_black_02", "Black Polka Dot Midi Dress", "black-dress-2.jpg", 2299),
            ("dress_blue_01", "Blue Floral Wrap Midi Dress", "blue-dress.jpg", 2499),
            ("dress_purple_01", "Plum Evening Midi Dress", "purple-dress.jpg", 2990),
            ("dress_red_01", "Red Flutter Sleeve Midi Dress", "red-dress-1.jpg", 2499),
            ("dress_red_02", "Crimson Ruffle Midi Dress", "red-dress-2.jpg", 3299),
            ("dress_white_01", "Ivory Summer Midi Dress", "white-dress-1.jpg", 1999),
            ("dress_white_02", "White Structured Tiered Dress", "white-dress-2.jpg", 2990),
        ]
        for garment_id, name, image, price in variants:
            if any(garment["id"] == garment_id for garment in garments):
                continue
            variant = dict(base)
            variant.update({
                "id": garment_id,
                "name": name,
                "price": price,
                "currency": "INR",
                "currencySymbol": "₹",
                "brand": "Twinly Edit",
                "assetImagePath": f"assets/dresses/{image}",
                "availableSizes": ["S", "M", "L", "XL"],
                "verifiedSizeChart": True,
            })
            garments.append(variant)
    return garments

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
