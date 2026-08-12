-- =============================================================================
-- TABLE: anaplan_dev.http_blob_test
-- Source: Oracle ANAPLAN.HTTP_BLOB_TEST
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.HTTP_BLOB_TEST (
    ID   NUMERIC(10,0) PRIMARY KEY,
    URL  VARCHAR(255),
    DATA TEXT
);

COMMENT ON TABLE ANAPLAN.HTTP_BLOB_TEST IS
    'Test table for HTTP BLOB responses (Oracle UTL_HTTP tests). CLOB → TEXT.';