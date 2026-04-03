-- Add columns to CSV import tables

ALTER TABLE importcsv
ADD FILENAME VARCHAR2(255);

ALTER TABLE importerror
ADD ( ERROR_DATE   DATE,
      USER_NAME         VARCHAR2(128)
    );

