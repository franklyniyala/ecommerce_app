# E-commerce App

Full-stack e-commerce sample application with:
- React + Vite frontend
- Python FastAPI backend
- MongoDB datastore

## Structure

- `frontend/` — React + Vite app
- `backend/` — FastAPI app connecting to MongoDB

## Run locally

### Backend

1. Create a Python virtual environment:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```
2. Install dependencies using the project venv:
   ```bash
   npm run backend:install
   ```
3. Start MongoDB locally and configure `MONGODB_URI` if needed.
4. Run the backend from the repo root:
   ```bash
   npm run backend:dev
   ```

If you have not created the venv yet, you can also run:
```bash
npm run backend:setup
```

### Frontend

1. Install dependencies:
   ```bash
   npm run frontend:install
   ```
2. Run the dev server from the repo root:
   ```bash
   npm run dev
   ```

The frontend runs on `http://localhost:5173` and proxies `/api` to the backend on `http://localhost:8000` during development.

### Notes

If you want to call the backend directly outside of Vite, use `http://localhost:8000/api`.
See `.dockerignore` for files excluded from Docker builds.
