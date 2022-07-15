create schema general_schema;

CREATE TABLE general_schema.test_table ( 

    test_table_id numeric 

); 

grant select, insert, update, delete on table general_schema.test_table to internship1_user;
grant usage on schema general_schema to internship1_user;

grant select on table general_schema.test_table to internship1_read;
grant usage on schema general_schema to internship1_read;

