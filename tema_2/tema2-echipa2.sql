create table general_schema."#2022_sales" (
	id_sales_point VARCHAR(20) primary key,
	sales_point_descr VARCHAR(200),
	sale_tmstmp  timestamp with time zone,
	sku VARCHAR(32),
	prod_desc VARCHAR(200),
	sale_amt decimal(10,2),
	utc_receipt_tmstmp timestamp,
	sales_person_name VARCHAR(100),
	client_review text,
	input_file VARCHAR(100),
	CONSTRAINT CK_sku CHECK (sku ~ '$[a-zA-Z0-9]*^')
);