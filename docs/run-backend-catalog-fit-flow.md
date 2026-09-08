# Run the backend catalog and fit flow

From `backend/` in Windows PowerShell, start the API:

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

In another PowerShell window, check the service and catalog:

```powershell
Invoke-RestMethod http://127.0.0.1:8000/api/health
Invoke-RestMethod http://127.0.0.1:8000/api/garments
```

Send a sample fit request, replacing the garment ID with one returned by the API:

```powershell
$body = @{
    garmentId = "USE_AN_ID_RETURNED_BY_API"
    bustCm = 88
    waistCm = 70
    hipCm = 96
    preferredFit = "regular"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/fit-report" -Method POST -ContentType "application/json" -Body $body
```

From `mobile/`, run on an Android emulator:

```powershell
flutter run
```

For a physical phone on the same Wi-Fi, supply the computer LAN IP:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR_COMPUTER_LAN_IP:8000
```

`10.0.2.2` is the emulator default. The Android debug manifest permits cleartext HTTP only for local development; release networking remains unchanged.
