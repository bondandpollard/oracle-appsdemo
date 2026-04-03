-- Add KEY_VALUE column to CSV import tables

ALTER TABLE importcsv
ADD KEY_VALUE VARCHAR2(30);

ALTER TABLE importerror
ADD KEY_VALUE VARCHAR2(30);

