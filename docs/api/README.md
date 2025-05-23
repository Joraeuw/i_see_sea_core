# API Documentation

The I See Sea API provides a set of public endpoints for accessing marine observation data.

## Public Endpoints

### Constants API
These endpoints provide reference data for the application:

- `GET /api/constants/picture_type` - Get supported image formats
- `GET /api/constants/jellyfish_quantity` - Get jellyfish quantity ranges
- `GET /api/constants/jellyfish_species` - Get jellyfish species list
- `GET /api/constants/pollution_type` - Get pollution types
- `GET /api/constants/report_type` - Get report types
- `GET /api/constants/fog_type` - Get fog condition types
- `GET /api/constants/sea_swell_type` - Get sea swell types
- `GET /api/constants/wind_type` - Get wind condition types
- `GET /api/constants/storm_type` - Get storm types

### Reports API
- `GET /api/reports/{report_type}` - List reports with filtering
  - Supported report types: jellyfish, meteorological, pollution, atypical_activity, other

### Pictures API
- `GET /api/pictures/{picture_id}` - Retrieve images

## Response Format

### Success Response
```json
{
  "data": [],
  "pagination": {
    "page": 1,
    "page_size": 10,
    "total_count": 100
  }
}
```

### Error Response
```json
{
  "message": "Error message",
  "reason": "Detailed error reason"
}
```

## Error Codes
- 400: Bad Request
- 404: Not Found
- 422: Unprocessable Entity
- 500: Internal Server Error

## API Documentation

- OpenAPI specification available at `/api/spec/openapi`
- Interactive documentation available at `/api/doc` 