select * from general_schema.test_table;
--afisam toate coloanele din tabelul test_table  apartinand schemei 'general_schema'
insert into general_schema.test_table(test_table_id) values (213);
--inseram in tabelul creat mai sus valoarea '213' in singura coloana disponibila
--avand in vedere ca userul internship1_user are drepturi de executie a query-urilor de tip dml.
--toate operatiile de mai sus au fost executate cu succes
--acest user are drept de utilizare asupra obiectelor din baza de date

