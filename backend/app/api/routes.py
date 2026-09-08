from typing import Literal

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

from app.services.catalog_service import get_garment_by_id, list_garments
from app.services.fit_engine import build_fit_report, get_full_fit_report
from app.services.styling_engine import get_styling_suggestions

router = APIRouter()
DISCLAIMER = "Twinly provides a size-guidance estimate based on the available size chart and your entered measurements. It does not guarantee fit."
INSUFFICIENT_EXPLANATION = "A detailed size recommendation is unavailable because Twinly does not yet have a verified brand size chart for this garment."

class FitCheckRequest(BaseModel):
    garment_id: str
    size: str
    user_measurements: dict

class StyleRequest(BaseModel):
    occasion: str
    budget: float

class FitReportRequest(BaseModel):
    garment_id: str = Field(alias="garmentId", min_length=1)
    bust_cm: float = Field(alias="bustCm", gt=0)
    waist_cm: float = Field(alias="waistCm", gt=0)
    hip_cm: float = Field(alias="hipCm", gt=0)
    preferred_fit: Literal["fitted", "regular", "relaxed"] = Field(alias="preferredFit")


class FitRegionResponse(BaseModel):
    label: Literal["tight", "slightly_snug", "good", "loose", "unknown"]
    easeCm: float | None


class FitReportResponse(BaseModel):
    status: Literal["ok", "insufficient_data"]
    garmentId: str
    recommendedSize: str | None
    confidence: Literal["low", "medium", "high"] | None
    regions: dict[str, FitRegionResponse]
    explanation: str
    disclaimer: str

@router.get("/api/health")
def api_health():
    return {"status": "ok", "service": "twinly-backend"}

@router.get("/api/garments")
def api_garments():
    return list_garments()

@router.get("/api/garments/{garment_id}")
def api_garment(garment_id: str):
    result = get_garment_by_id(garment_id)
    if not result:
        raise HTTPException(status_code=404, detail="Garment not found")
    return result

@router.post("/api/fit-report", response_model=FitReportResponse)
def api_fit_report(payload: FitReportRequest):
    garment = get_garment_by_id(payload.garment_id)
    if not garment:
        raise HTTPException(status_code=404, detail="Garment not found")
    report = build_fit_report(garment, {"bust": payload.bust_cm, "waist": payload.waist_cm, "hip": payload.hip_cm}, payload.preferred_fit)
    if report is None:
        return {"status": "insufficient_data", "garmentId": payload.garment_id, "recommendedSize": None, "confidence": None, "regions": {}, "explanation": INSUFFICIENT_EXPLANATION, "disclaimer": DISCLAIMER}
    return {"status": "ok", "garmentId": payload.garment_id, **report, "disclaimer": DISCLAIMER}

# Legacy endpoints remain available for older clients and existing tests.
@router.post("/fit-check")
def fit_check(payload: FitCheckRequest):
    garment = get_garment_by_id(payload.garment_id)
    if not garment:
        raise HTTPException(status_code=404, detail="Garment not found")
    size_chart = garment["sizeChart"].get(payload.size)
    if not size_chart:
        raise HTTPException(status_code=404, detail="Size not found for this garment")
    return {"garment_id": payload.garment_id, "size": payload.size, "fit_report": get_full_fit_report(payload.user_measurements, size_chart)}

@router.post("/style-suggestions")
def style_suggestions(payload: StyleRequest):
    return get_styling_suggestions(payload.occasion, payload.budget)
