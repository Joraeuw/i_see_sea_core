# I See Sea

I See Sea is a comprehensive marine observation and reporting platform built with Elixir and Phoenix. The platform allows users to report and track various marine-related observations including jellyfish sightings, meteorological conditions, pollution incidents, and other atypical activities.

## Documentation

For detailed information about specific features and functionality, please refer to our documentation:

- [Reports System](docs/reports/README.md) - Detailed information about the reporting system and its capabilities
- [Deployment Guide](docs/deployment/README.md) - Comprehensive deployment and infrastructure documentation
- [API Documentation](docs/api/README.md) - Complete API reference and usage guidelines

## Features

### Report Types
- **Jellyfish Reports**: Track jellyfish species and quantities
- **Meteorological Reports**: Monitor weather conditions including:
  - Fog conditions (very thick to no fog)
  - Wind conditions (hurricane to no wind)
  - Sea swell conditions (strong to no waves)
  - Storm types (thunderstorm, rain, hailstorm)
- **Pollution Reports**: Document various types of marine pollution
- **Atypical Activity Reports**: Record unusual marine activities
- **Other Reports**: General marine observations

### Technical Capabilities
- RESTful API with OpenAPI/Swagger documentation
- Real-time data processing
- Image upload and management
- Advanced filtering and search capabilities
- Pagination support
- Authentication and authorization
- Database backup and maintenance
- Docker containerization
- Nginx reverse proxy with SSL support
- Automated SSL certificate renewal

## Tech Stack

- **Backend**: Elixir/Phoenix
- **Database**: PostgreSQL
- **Frontend**: Phoenix LiveView with Tailwind CSS
- **Authentication**: Guardian
- **Background Jobs**: Oban
- **API Documentation**: OpenAPI/Swagger
- **Monitoring**: Prometheus metrics
- **Containerization**: Docker
- **Web Server**: Nginx
- **SSL**: Certbot

## Prerequisites

- Elixir 1.16+
- Erlang/OTP
- PostgreSQL 15+
- Docker and Docker Compose
- Node.js (for asset compilation)

## Setup

1. Clone the repository:
```bash
git clone [repository-url]
cd i_see_sea
```

2. Install dependencies:
```bash
mix deps.get
```

3. Setup the database:
```bash
mix ecto.setup
```

4. Install and build assets:
```bash
mix assets.setup
mix assets.build
```

5. Start the Phoenix server:
```bash
mix phx.server
```

## Docker Deployment

The project includes Docker configuration for easy deployment:

1. Build and start the containers:
```bash
docker-compose up -d
```

2. The application will be available at:
- HTTP: http://localhost
- HTTPS: https://localhost (if SSL is configured)

## API Documentation

The API documentation is available at `/api/docs` when running the server. The API supports:

- Report creation and management
- Image upload and retrieval
- Advanced filtering and search
- Pagination
- Authentication

## Database Management

The project includes scripts for database management:

- `db_backup.sh`: Database backup script
- `docker_db_backup.sh`: Docker-specific backup script
- `setup_backup_cron.sh`: Setup automated backups

## Development

- Run tests: `mix test`
- Check code style: `mix credo`
- Generate API spec: `mix spec`

## License

Copyright (c) 2024 I See Sea

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, subject to the following conditions:

1. The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

2. The Software may not be used for commercial purposes, including but not limited to:
   - Selling the Software or its derivatives
   - Using the Software to generate revenue
   - Including the Software in any commercial product or service
   - Using the Software for any profit-making activities

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
