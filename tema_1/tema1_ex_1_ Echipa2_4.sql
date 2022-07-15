-- Task 4

-- Incercati sa cititi continutul tabelului general_schema.test_table
select * from general_schema.test_table;
-- Rezultat 213

-- Incercati sa inserati un rand nou in tabela general_schema.test_table
INSERT INTO general_schema.test_table(test_table_id) values (214);
-- Rezultat SQL Error [42501]: ERROR: permission denied for table test_table

-- Urmariti si ce s-a intamplat in folderele de pe HDD-ul vostru acolo unde ati definit tablespace-urile. 
-- Rezultat: A fost creat un folder cu denumirea 'PG_14_202107181' pentru baza de date.
-- 			 A fost creat un folder cu denumirea '16406' pentru schema.
-- 			 In folderul schemei bazei de date se regasesc datafile-urile.