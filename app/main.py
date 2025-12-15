from fastapi import FastAPI, HTTPException
import hashlib
import os
import asyncpg
import logging
from asyncpg.pool import Pool

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Hash Service", version="1.0")

# Async DB connection pool
db_pool: Pool = None

# --- FastAPI Startup / Shutdown Events ---

@app.on_event("startup")
async def startup_event():
    """Initialize DB pool"""
    global db_pool
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        logger.error("DATABASE_URL environment variable not set")
        raise RuntimeError("DATABASE_URL must be set")
    try:
        db_pool = await asyncpg.create_pool(dsn=database_url)
        logger.info("Database pool initialized")
        # Ensure table exists
        async with db_pool.acquire() as conn:
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS strings (
                    hash TEXT PRIMARY KEY,
                    value TEXT NOT NULL
                )
            """)
    except Exception as e:
        logger.error(f"Failed to connect to DB: {e}")
        raise

@app.on_event("shutdown")
async def shutdown_event():
    """Close DB pool"""
    if db_pool:
        await db_pool.close()
        logger.info("Database pool closed")

# --- Endpoints ---

@app.post("/store")
async def store_string(value: str):
    """Store a string and return its SHA256 hash"""
    h = hashlib.sha256(value.encode()).hexdigest()
    async with db_pool.acquire() as conn:
        try:
            await conn.execute(
                "INSERT INTO strings (hash, value) VALUES ($1, $2) ON CONFLICT DO NOTHING",
                h, value
            )
        except asyncpg.PostgresError as e:
            logger.error(f"DB error: {e}")
            raise HTTPException(status_code=500, detail="DB operation failed")
    return {"hash": h}

@app.get("/lookup/{hash}")
async def lookup_hash(hash: str):
    """Lookup a SHA256 hash and return the original string if found"""
    async with db_pool.acquire() as conn:
        row = await conn.fetchrow("SELECT value FROM strings WHERE hash=$1", hash)
        if not row:
            raise HTTPException(status_code=404, detail="Not found")
        return {"value": row["value"]}