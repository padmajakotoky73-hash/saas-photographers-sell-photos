```markdown
# Photographers SaaS

A SaaS platform enabling photographers to sell their photos online.

![Next.js](https://img.shields.io/badge/Next.js-13-blue?logo=next.js)
![FastAPI](https://img.shields.io/badge/FastAPI-0.95-green?logo=fastapi)
![License](https://img.shields.io/badge/License-MIT-red)

## Features

- Photographer profile management
- Photo upload & gallery
- Secure payment processing
- Digital download delivery
- Sales analytics dashboard

## Quick Start

1. Clone the repo:
```bash
git clone https://github.com/your-repo/saas-photographers-sell-photos.git
```

2. Install dependencies:
```bash
cd saas-photographers-sell-photos
npm install  # Frontend
pip install -r requirements.txt  # Backend
```

## Environment Setup

Create `.env` files:

**Frontend (Next.js):**
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

**Backend (FastAPI):**
```env
DATABASE_URL=postgresql://user:pass@localhost:5432/photosaas
SECRET_KEY=your-secret-key
STRIPE_API_KEY=your-stripe-key
```

## Deployment

1. Build frontend:
```bash
npm run build
```

2. Start backend:
```bash
uvicorn main:app --reload
```

3. Deploy with Docker:
```bash
docker-compose up -d
```

## License

MIT License - see [LICENSE](LICENSE) for details.
```