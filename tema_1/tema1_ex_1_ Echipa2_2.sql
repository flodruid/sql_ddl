-- Task 2

-- Creati schema general_schema
create schema general_schema;

-- Creati un tabel nou in general_schema 
CREATE TABLE general_schema.test_table (
    test_table_id numeric
);

-- Acordati drepturi de SELECT, INSERT,UPDATE, DELETE userului internship1_user 
grant usage on schema general_schema to Internship1_user;
grant select on general_schema.test_table to Internship1_user;
grant insert on general_schema.test_table to Internship1_user;
grant update on general_schema.test_table to Internship1_user;
grant delete on general_schema.test_table to Internship1_user;

-- Acordati dreptul de SELECT userului  internship1_read 
grant usage on schema general_schema to Internship1_read;
grant select on general_schema.test_table to Internship1_read;




