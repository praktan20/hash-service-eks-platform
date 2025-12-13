import asyncpg
import os
import logging


logger = logging.getLogger(__name__)


class Database:
pool = None


async def init(self):
if not self.pool:
self.pool = await asyncpg.create_pool(
dsn=os.environ["DATABASE_URL"],
min_size=2,
max_size=10
)
logger.info("DB pool initialized")


get_db_pool = Database()
