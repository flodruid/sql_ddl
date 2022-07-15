-- Task 1
-- Creati 2 tablespace-uri care sa pointeze intr-o locatie la alegere de pe HDD-ul vostru.
create tablespace tbs1 location 'C:\work\tbs1';
create tablespace tbs2 location 'C:\work\tbs2';

-- Creati 2 baze de date pe serverul vostru de date. 
-- Asignati  tbs1 bazei de date internship1_db si tbs2 la intership2_db
create database Internship1_db template template0 tablespace tbs1;
create database Internship2_db template template0 tablespace tbs2;

-- Creati sase utilizatori la nivel de server.
create user Internship1_owner encrypted password '123456';
create user Internship1_user encrypted password 'Internship1_user';
create user Internship1_read encrypted password 'Internship1_read';
create user Internship2_owner encrypted password 'Internship2_owner';
create user Internship2_user encrypted password 'Internship2_user';
create user Internship2_read encrypted password 'Internship2_read';

-- Acordati ALL PRIVILEGES 
-- Setati ca owner 
grant ALL PRIVILEGES ON tablespace tbs1 TO Internship1_owner;
alter database Internship1_db owner to Internship1_owner;

grant ALL PRIVILEGES ON tablespace tbs2 TO Internship2_owner;
alter database Internship2_db owner to Internship2_owner;



