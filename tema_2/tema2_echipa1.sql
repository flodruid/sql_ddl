create table general_schema."2022_sales"(
id_sales_point varchar(20) primary key not null,
sales_point_descr varchar(200),
sales_tmstmp timestamp default current_timestamp,
ska varchar (32),
prod_desc varchar(200),
sale_amd numeric(10,2) default 0,
utc_revceip_tmtsmp timestamptz,
sales_person_name varchar(200),
client_revies text);