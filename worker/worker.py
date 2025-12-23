import os
import time
import json
import redis
import psycopg2

def get_redis():
    redis_host = os.getenv('REDIS_HOST', 'redis')
    return redis.Redis(host=redis_host, port=6379, socket_timeout=5)

def get_postgres():
    while True:
        try:
            conn = psycopg2.connect(
                host=os.getenv('POSTGRES_HOST', 'db'),
                port=5432,
                database=os.getenv('POSTGRES_DB', 'postgres'),
                user=os.getenv('POSTGRES_USER', 'postgres'),
                password=os.getenv('POSTGRES_PASSWORD', 'postgres')
            )
            return conn
        except psycopg2.OperationalError:
            print("Waiting for PostgreSQL...")
            time.sleep(1)

def main():
    print("Worker starting...")
    r = get_redis()
    db = get_postgres()
    cur = db.cursor()
    
    # Create table if not exists
    cur.execute("""
        CREATE TABLE IF NOT EXISTS votes (
            id VARCHAR(255) PRIMARY KEY,
            vote VARCHAR(255) NOT NULL
        )
    """)
    db.commit()
    
    print("Processing votes...")
    while True:
        try:
            vote_data = r.blpop('votes', timeout=1)
            if vote_data:
                vote = json.loads(vote_data[1])
                voter_id = vote['voter_id']
                vote_choice = vote['vote']
                
                cur.execute("""
                    INSERT INTO votes (id, vote) 
                    VALUES (%s, %s)
                    ON CONFLICT (id) DO UPDATE SET vote = %s
                """, (voter_id, vote_choice, vote_choice))
                db.commit()
                
                print(f"Processed vote: {voter_id} -> {vote_choice}")
        except Exception as e:
            print(f"Error: {e}")
            time.sleep(1)

if __name__ == '__main__':
    main()
