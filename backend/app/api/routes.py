# app/api/routes.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.services.fit_engine import get_full_fit_report
from app.services.styling_engine import get_styling_suggestions
from app.services.catalog_service import get_garment_by_id

router = APIRouter()

class FitCheckRequest(BaseModel):
    garment_id: str
    size: str
    user_measurements: dict

class StyleRequest(BaseModel):
    occasion: str
    budget: float

@router.post("/fit-check")
def fit_check(payload: FitCheckRequest):
    garment = get_garment_by_id(payload.garment_id)
    if not garment:
        raise HTTPException(status_code=404, detail="Garment not found")
    size_chart = garment["sizeChart"].get(payload.size)
    if not size_chart:
        raise HTTPException(status_code=404, detail="Size not found for this garment")
    report = get_full_fit_report(payload.user_measurements, size_chart)
    return {"garment_id": payload.garment_id, "size": payload.size, "fit_report": report}

@router.post("/style-suggestions")
def style_suggestions(payload: StyleRequest):
    return get_styling_suggestions(payload.occasion, payload.budget)