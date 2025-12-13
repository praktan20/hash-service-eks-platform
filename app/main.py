from fastapi import FastAPI, HTTPException
import hashlib
import psycopg2
import os

app = FastAPI()

conn = psycopg2.connect(os.environ["DATABASE_URL"])

@app.post("/store")
def store(value: str):
    h = hashlib.sha256(value.encode()).hexdigest()
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO strings (hash, value) VALUES (%s, %s) ON CONFLICT DO NOTHING",
            (h, value)
        )
        conn.commit()
    return {"hash": h}

@app.get("/lookup/{hash}")
def lookup(hash: str):
    with conn.cursor() as cur:
        cur.execute("SELECT value FROM strings WHERE hash=%s", (hash,))
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Not found")
        return {"value": row[0]}
