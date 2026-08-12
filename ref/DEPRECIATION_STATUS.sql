CREATE TABLE ref.DEPRECIATION_STATUS (
    MATCH_TYPE TEXT,
    KEY_VALUE  TEXT,
    LABEL      TEXT,
    SORT_ORDER INT
);

INSERT INTO ref.DEPRECIATION_STATUS VALUES
('EXACT','1','Normal',1),
('EXACT','5','Preliminary',2),
('EXACT','8','Fully depreciated',3),
('EXACT','9','Sold_Disposed',4);