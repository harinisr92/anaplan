#!/usr/bin/env python3
"""
deploy_all.py — deploys the full anaplan_dev PG package in dependency order.

Usage:
    python3 deploy_all.py --host HOST --port 5432 --dbname DBNAME --user USER
    (password: set PGPASSWORD env var, or you'll be prompted securely)

    # Or via a full connection string:
    python3 deploy_all.py --dsn "postgresql://user:pass@host:5432/dbname"

Requires: psycopg2 (pip install psycopg2-binary --break-system-packages)

What this does NOT create: mvxjdta.* and bousr.* — those are the external
M3/BI source schemas this package reads FROM. They must already exist and
be populated before running this script; nothing here creates them.

Stops immediately on the first error (equivalent to psql's ON_ERROR_STOP=1)
rather than continuing and leaving you to guess what broke.
"""

import argparse
import getpass
import os
import sys
from pathlib import Path

try:
    import psycopg2
except ImportError:
    print("psycopg2 is required. Install it with:")
    print("    pip install psycopg2-binary --break-system-packages")
    sys.exit(1)


SCHEMA_SQL = """
CREATE SCHEMA IF NOT EXISTS anaplan_dev;
CREATE SCHEMA IF NOT EXISTS ref_dev;
CREATE SCHEMA IF NOT EXISTS lbm3prd1_anaplan;
CREATE SCHEMA IF NOT EXISTS m3sky_anaplan;
"""

# (step label, relative dir, whether to actually execute the files in it)
STEPS = [
    ("1. Functions (anaplan_dev.to_number_spec etc — views depend on these)", "functions", True),
    ("2. ref_dev lookup tables (required before tables; ad_chargemodel depends on charge_model_excise_ids)", "ref_dev", True),
    ("3. Tables (anaplan_dev physical tables)", "tables", True),
    ("4a. External compat schema tables (lbm3prd1_anaplan)", "tables_external/lbm3prd1_anaplan", True),
    ("4b. External compat schema tables (m3sky_anaplan)", "tables_external/m3sky_anaplan", True),
    ("5. Views (order-independent — zero anaplan_dev.*_v self-references)", "views", True),
    ("6. Procedures (depend on views/tables above)", "procedures", True),
    ("7. Jobs (scheduling — review manually, NOT auto-run)", "jobs", False),
]

# Objects that are OUT OF SCOPE for this migration per Requirement 4 of the
# original migration brief: "Some legacy processes are completely obsolete
# now [...] their functionality will be handled entirely via ECS/ECR
# container tasks in AWS in a different method altogether."
#
# These files are kept in source control for traceability (so the original
# Oracle logic remains visible if ever needed for reference), but are NEVER
# deployed by this script, regardless of what folder they sit in. This is
# an explicit filename check, not a file-renaming convention (.skip
# extensions, etc.) — those have proven fragile in this project (an earlier
# pass only renamed authenticate.sql and missed the other 8 obsolete files
# in the same category; this list is the single source of truth instead).
#
# Two categories:
#   1. The HTTP/API push-pull family itself — explicitly named as obsolete
#      (SEND_DATA, GET_FILE, AUTHENTICATE) in the original migration brief.
#   2. Utility functions confirmed to have ZERO callers outside that family
#      — checked against every view and every retained procedure in this
#      package; nothing else references them.
DEFAULT_SKIP_FILES = {
    # Category 1: HTTP/API push-pull family (ECS/ECR replaces these)
    "authenticate.sql",
    "get_file.sql",
    "get_file2.sql",
    "get_metadata.sql",
    "pro_anaplan_01.sql",
    "pro_write_clob_to_file.sql",
    "send_data.sql",
    "send_data_file.sql",
    "send_data_no_chunks.sql",
    # Category 2: utility functions with zero callers outside category 1
    "create_dynamic_list.sql",
    "rectify_non_ascii.sql",
    "reencode.sql",
    "split_clob.sql",
}


def parse_args():
    p = argparse.ArgumentParser(description="Deploy the anaplan_dev PG package in dependency order.")
    p.add_argument("--dsn", help="Full connection string, e.g. postgresql://user:pass@host:5432/dbname")
    p.add_argument("--host", default=os.environ.get("PGHOST"))
    p.add_argument("--port", default=os.environ.get("PGPORT", "5432"))
    p.add_argument("--dbname", default=os.environ.get("PGDATABASE"))
    p.add_argument("--user", default=os.environ.get("PGUSER"))
    p.add_argument("--password", default=os.environ.get("PGPASSWORD"))
    p.add_argument("--package-dir", default=".", help="Root of the unzipped package (default: current dir)")
    p.add_argument("--run-jobs", action="store_true", help="Also execute jobs/*.sql (off by default — review these first)")
    p.add_argument("--dry-run", action="store_true", help="Print what would run without executing anything")
    return p.parse_args()


def connect(args):
    if args.dsn:
        conn = psycopg2.connect(args.dsn)
        conn.set_client_encoding("UTF8")
        return conn
    if not args.password:
        args.password = getpass.getpass(f"Password for {args.user}@{args.host}: ")
    conn = psycopg2.connect(
        host=args.host, port=args.port, dbname=args.dbname,
        user=args.user, password=args.password,
    )
    conn.set_client_encoding("UTF8")
    return conn


def run_sql_file(cur, path: Path, dry_run: bool):
    sql_text = path.read_text(encoding="utf-8")
    print(f"  -> {path}")
    if dry_run:
        return
    cur.execute(sql_text)


def run_dir(cur, base: Path, rel_dir: str, dry_run: bool):
    dir_path = base / rel_dir
    if not dir_path.is_dir():
        print(f"  (skip — {dir_path} not found)")
        return
    files = sorted(dir_path.glob("*.sql"))
    if not files:
        print(f"  (no .sql files in {dir_path})")
        return
    for f in files:
        if f.name in DEFAULT_SKIP_FILES:
            print(f"  (skipped — out of scope, ECS/ECR replaces this: {f})")
            continue
        run_sql_file(cur, f, dry_run)


def main():
    args = parse_args()
    base = Path(args.package_dir).resolve()

    if not base.is_dir():
        print(f"ERROR: package dir not found: {base}")
        sys.exit(1)

    if args.dry_run:
        print(f"[DRY RUN] Would deploy package from {base}\n")
        conn = None
        cur = None
    else:
        try:
            conn = connect(args)
        except Exception as e:
            print(f"ERROR: could not connect: {e}")
            sys.exit(1)
        conn.autocommit = False
        cur = conn.cursor()

    try:
        print("== 0. Schemas ==")
        if not args.dry_run:
            cur.execute(SCHEMA_SQL)
            conn.commit()
        else:
            print(SCHEMA_SQL)

        for label, rel_dir, default_run in STEPS:
            print(f"\n== {label} ==")
            do_run = default_run or args.run_jobs
            if not do_run:
                # jobs step, not requested — just list files for review
                dir_path = base / rel_dir
                if dir_path.is_dir():
                    for f in sorted(dir_path.glob("*.sql")):
                        print(f"  (not run — review manually) {f}")
                continue
            run_dir(cur, base, rel_dir, args.dry_run)
            if not args.dry_run:
                conn.commit()

        print("\nDeployment complete. Recommended next step: re-run your dependency/self-reference")
        print("verification query against anaplan_dev to confirm everything landed as expected.")

    except Exception as e:
        print(f"\nERROR during deployment: {e}")
        if conn is not None:
            print("Rolling back current transaction and stopping (ON_ERROR_STOP-style halt).")
            conn.rollback()
        sys.exit(1)
    finally:
        if cur is not None:
            cur.close()
        if conn is not None:
            conn.close()


if __name__ == "__main__":
    main()
