create tablespace tbs1 location 'C:\Work\Database_files\PostgreS\tbs1';
create tablespace tbs2 location 'C:\Work\Database_files\PostgreS\tbs2';

create database internship1_db template template0 tablespace tbs1;
create database internship2_db template template0 tablespace tbs2;

create user internship1_owner encrypted password 'internship1_owner';
create user internship1_user encrypted password 'internship1_user';
create user internship1_read encrypted password 'internship1_read';
create user internship2_owner encrypted password 'internship2_owner';
create user internship2_user encrypted password 'internship2_user';
create user internship2_read encrypted password 'internship2_read';

grant all privileges on tablespace tbs1 to internship1_owner;
grant all privileges on database internship1_db to internship1_owner;

grant all privileges on tablespace tbs2 to internship2_owner;
grant all privileges on database internship2_db to internship2_owner;

alter database internship1_db owner to internship1_owner;
alter database internship2_db owner to internship2_owner;
