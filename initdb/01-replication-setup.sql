-- Create replication user and physical slot (runs once on first init)
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'repl') THEN
    CREATE ROLE repl WITH REPLICATION LOGIN PASSWORD 'change-me-dev-repl';
  END IF;
END
$$;

SELECT pg_create_physical_replication_slot('replica_slot');
