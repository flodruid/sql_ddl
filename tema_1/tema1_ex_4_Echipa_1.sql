select * from general_schema.test_table;
-- utilizatorul are drepturi de citire

insert into general_schema.test_table(test_table_id) values (214);
--SQL Error [42501]: ERROR: permission denied for table test_table
-- userul nu are drept de editare

--in folderul 'C:\Work\Database_files\PostgreS\tbs1\PG_14_202107181\16431', inserturile anterioare (de la subpunctul 3)
--au fost scrise in memorie (wal buffer), dar nu inseamna ca au fost scrise pe disk.
--insertul de mai sus (de pe userul internship1_read nu a efectuat schimbari)
