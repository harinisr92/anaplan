CREATE TABLE ref.NATUREBASED_COGS_SOURCE (
    MATCH_TYPE    TEXT,
    KEY_VALUE     TEXT,
    IS_LINE_LABEL TEXT,
    SORT_ORDER    INT
);

INSERT INTO ref.NATUREBASED_COGS_SOURCE VALUES
('LIKE','2.1%','Other production costs',1),
('LIKE','5%','Other production costs',2),
('LIKE','0%','Balancing',3),
('LIKE','9%','Change of inventory of WIP and fin prod',4);