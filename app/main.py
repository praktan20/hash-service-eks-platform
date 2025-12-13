from fastapi import FastAPI, HTTPException
import hashlib
import os
import asyncpg # Async DB driver
import logging
from asyncpg.pool import Pool

# Configure basic logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

# Placeholder for the async database connection pool
# We'll initialize this in the startup event
db_pool: Pool = None 

# --- FastAPI Lifecycle Events for Connection Management ---

@app.on_event("startup")
async def startup_event():
    """Establish the database connection pool on application start."""
    global db_pool
    try:
        # asyncpg handles connection pooling internally
        db_pool = await asyncpg.create_pool(dsn=os.environ["DATABASE_URL"])
        logger.info("Database connection pool established successfully.")
    except Exception as e:
        logger.error(f"Failed to connect to the database at startup: {e}")
        # In a real app, you might want to stop the app from starting here

@app.on_event("shutdown")
async def shutdown_event():
    """Close the database connection pool on application shutdown."""
    if db_pool:
        await db_pool.close()
        logger.info("Database connection pool closed.")

# --- Endpoints (now async) ---

@app.post("/store")
async def store(value: str):
    h = hashlib.sha256(value.encode()).hexdigest()
    
    # Use the connection pool via 'acquire' in a context manager
    async with db_pool.acquire() as connection:
        # Use connection methods for transactions or simple execution
        try:
            await connection.execute(
                "INSERT INTO strings (hash, value) VALUES ($1, $2) ON CONFLICT DO NOTHING",
                h, value
            )
        except asyncpg.exceptions.PostgresError as e:
            logger.error(f"Database error during /store: {e}")
            raise HTTPException(status_code=500, detail="Database operation failed")

    return {"hash": h}

@app.get("/lookup/{hash}")
async def lookup(hash: str):
    async with db_pool.acquire() as connection:
        try:
            row = await connection.fetchrow(
                "SELECT value FROM strings WHERE hash=$1", 
                hash
            )
        except asyncpg.exceptions.PostgresError as e:
            logger.error(f"Database error during /lookup: {e}")
            raise HTTPException(status_code=500, detail="Database operation failed")
            
        if not row:
            raise HTTPException(status_code=404, detail="Not found")
            
        # Access the value using column name or index
        return {"value": row['value']}

