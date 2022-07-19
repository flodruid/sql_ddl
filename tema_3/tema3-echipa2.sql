--1 -- FROM clause
--Scrieti un query care sa extraga toate datele din tabela t_trades

select * from t_trades;

--2 -- WHERE clause
--Scrieti un query care sa extraga toate coloanele din tabela t_trades pentru inregistrarile care au trade_date ziua de 15-iulie-2022

select * from t_trades 
where trade_date='2022-07-15'::date;

--3 -- WHERE clause
--Scrieti un query care sa extraga toate coloanele din tabela t_trades pentru inregistrarile care indeplinesc urmatoarele conditiiL
-- fie trade_date este 14-iulie-2022 si trade_time e dupa ora 18 iar trade_stock e NVRO, fie trade_date este dupa ziua de 16-iulie-2022, trade_time este intre ora 13:00 si 18:00 si traded_market nu e goala sau NASDAQ 

select * from t_trades 
where (trade_date='2022-07-14'::date and extract(hour from trade_time) >= 18 and traded_stock='NVRO') 
or (trade_date > '2022-07-16'::date and (extract(hour from trade_time) between 13 and 17) and (traded_market is not null and traded_market <> 'NASDAQ'));

--4 -- WHERE clause
--Scrieti un query care sa extraga toate coloanele din tabela t_trades pentru inregistrarile care indeplinesc urmatoarele conditiiL
-- fie trade_date este 14-iulie-2022 si trade_time e dupa ora 18 iar trade_stock nu e PRIM (rezultatul trebuie sa includa si randurile pentru traded_stock e null )

select * from t_trades 
where (trade_date='2022-07-14'::date and extract(hour from trade_time) >= 18 and (traded_stock <> 'PRIM' or traded_stock is NULL));

--5 -- FROM + SELECT clause
--Creati un view numit trades_2022_07_16 care sa cuprinda toate coloanele din tabela t_trades cu exceptia trade_date si trade_time
--adaugati o coloana noua de tip timestamp in view: trade_tmstmp care sa concateneze trade_date si trade_time.
--Scrieti 2 query-uri pe baza acestui view:
-- primul va extrage toate coloanele doar pentru inregistrarile care au traded_stock CTSO
-- cel de-al doilea va extrage toate coloanele care au seller participant PART_017

create view trades_2022_07_16 as 
	select trade_id, seller_participant, buyer_participant, trade_amount_usd, trade_currency, 
	traded_stock, traded_market, instrument_score, trader_comment, (trade_date::varchar || ' ' ||trade_time::varchar) as trade_tmstpm from t_trades;

select * from trades_2022_07_16 
where traded_stock='CTSO';

select * from trades_2022_07_16 
where seller_participant = 'PART_017';
	

--6 -- SELECT + WHERE + timestamp function
-- scrieti o interogare care sa returneze urmatoarele coloane: trade_timestamp_utc (trade_date concatenat cu trade_time). trade_timestamp_ro (trade_date concatenat cu trade_time) convertit la Europe/Bucharest timezone, trade_id, buyer_participant si trade_amount_usd
-- se presupune ca trade_date si trade_time in tabelul initial sunt stocate in UTC timezone
-- filtrati doar inregistrarile care au trade_Date 15-iulie-2022 si pentru care trade_date + trade_time convertit la Europe/Bucharest la care se adauga 3 zile este mai mare decat timpul actual al sistemului

select (trade_date::varchar || ' ' ||trade_time::varchar) as trade_timestamp_utc, 
		 (trade_date::varchar || ' ' ||trade_time::varchar)::timestamp AT TIME ZONE 'Europe/Bucharest' as trade_timestamp_ro,
		trade_id, buyer_participant, trade_amount_usd
		from t_trades
where trade_date='2022-07-15' and (trade_date::varchar || ' ' ||trade_time::varchar)::timestamp AT TIME ZONE 'Europe/Bucharest' + interval '3' day > CURRENT_TIMESTAMP;


--7 -- order by
--selectati toate trade-urile efectuate in ziua de 16-iulie-2022. Prezentati rezultatele ordonate descrescator dupa buyer_participant si crescator dupa trade_amount_usd

select * from t_trades
where trade_date='2022-07-16'
order by buyer_participant desc, trade_amount_usd asc;


--8 -- order by, limit si offset
--selectati toate trade-urile efectuate in ziua de 15-iulie-2022. Prezentati rezultatele ordonate descrescator dupa trade_amount_usd si afisati doar randurile 5-12 din outputul initial

select * from t_trades
where trade_date='2022-07-15'
order by trade_amount_usd asc
offset 4 limit 8;


--9 -- FROM + TABLE GENERATORS + SUBQUERY + functions
--porning de la stringul: '0:Group0;1:Group1;2:Group2;3:Group3' scrieti o interogare care sa returneze un tabel cu 4 randuri cate una pentru fiecare substring separat de ;
--Rezultatul va avea 2 coloane: group_code si va cuprinde numarul de dinainte de : si group_name - textul de dupa :
/*
group_code	group_name
         0	Group0
         1	Group1
         2 	Group2
         3	Group3
*/

/*
 * -- string_to_table: string_to_table 
 * --position
 * --substring
 */

create view stt_view as (select * from string_to_table('0:Group0;1:Group1;2:Group2;3:Group3',';'));
select * from stt_view;
select split_part(stt_view.string_to_table,':',1) as group_code, split_part(stt_view.string_to_table,':',2) as group_name
from stt_view;


--10-- SELECT + function + CASE expression
-- pentru toate randurile din data de 15-iulie-2022 si 13-iulie-2022 afisati urmatoarele coloane:
-- trade_date
-- ziua din saptamana a trade_date-ului
-- numarul zilei de la inceputul anului
-- codul seller_participant convertit la valoare numerica dupa eliminarea prefizului PART_ (position si substring functions) 
-- codul buyer_participant convertit la valoare numerica dupa eliminarea prefizului PART_ (position si substring functions)
-- trade_amount_usd ca numar intreg. In caz ca numarul are zecimale nu vor fi luate in considerare. Numele coloanei ca fi trade_amount_int
-- coloana numita "Tag" care va fi populata astfel:
  -- daca restul impartirii coloanei trade_amount_int la 17 este 13 atunci se va pune textul 'Category 1'
  -- altfel daca restul impartitii coloanei trade_amount_int la 17 este mai mic de 5 'Category 2'
  -- altfel daca trade_amount_int  este un numar par se va pune 'Category 3'
  -- pentru toate celelalte se va pune 'Other'

select trade_date, 
	extract(dow from trade_date) as week_day, 
	extract(doy from trade_date) as year_day, 
	substring(seller_participant, position('_' in seller_participant)+1)::numeric as numeric_seller_code,
	substring(buyer_participant, position('_' in buyer_participant)+1)::numeric as numeric_buyer_code,
	floor(trade_amount_usd) as trade_amount_int,
	case when (mod(floor(trade_amount_usd),17)=13) then 'Category 1'
		 when (mod(floor(trade_amount_usd),17)<5) then 'Category 2'
		 when (mod(floor(trade_amount_usd),2)=0) then 'Category 3'
		 else 'Other'
	end
from t_trades
where trade_date='2022-07-15' or trade_date='2022-07-13';

--11 -- WHERE clause + SELECT clause +correlated subquery
-- selectati din tabela t_trades toate tranzactiile efectuate in zilele de 14-iulie-2022 si 12-iulie-2022 a caror buyer_participant e  PART_013, PART_009 sau PART_008.
-- Afisati trade_date, trade_time, buyer_participant, trade_amount_usd precum si suma  valorilor din trade_amount_usd aferente acelui buyer_participant din ziua anterioara;

select tt.trade_date, tt.trade_time, tt.buyer_participant, tt.trade_amount_usd, stt.suma from t_trades tt join
    (select buyer_participant, trade_date, sum(trade_amount_usd) suma from t_trades
        where (trade_date='2022-07-13' or trade_date='2022-07-11')
        group by buyer_participant, trade_date
        having buyer_participant IN ('PART_013','PART_009','PART_008')) as stt
    on tt.buyer_participant = stt.buyer_participant  and tt.trade_date = stt.trade_date+ interval '1' day;

--12 -- where clause + correlated subquery
--selectati din tabela t_trades toate coloanele aferente randurilor care au trade_date > 14-iulie-2022. 
--Filtrati in rezultat doar randurile care au avut acelasi seller participant, buyer_participant, traded_stock
--si o valoare a trade_amount_usd mai mare decat cea curenta in ziua imediat urmatoare


select * from t_trades tt
join t_trades tt2 on 
	tt.seller_participant = tt2.seller_participant and 
	tt.buyer_participant = tt2.buyer_participant and 
	tt.traded_stock = tt2.traded_stock and 
	tt.trade_date = tt2.trade_date + 1
where tt.trade_date > '2022-07-14' and tt2.trade_amount_usd > tt.trade_amount_usd;

--13 -- aggregation function
-- generati un raport global pentru ziua de 13-iulie-2022. El va trebui sa cuprinda urmatoarele coloane:
-- o coloana numita descriere  care sa afiseze textul: "Date tranzactii tranzactii 13-iulie-2022"
-- numarul de tranzactii total
-- suma valorilor tranzactiilor(trade_amount_usd)
-- media valorilor tranzactiilor  (trade_amount_usd)
-- minim valoare tranzactie  (trade_amount_usd)
-- maxim valoare tranzactie  (trade_amount_usd)

select 
	'Date tranzactii tranzactii 13-iulie-2022' as descriere,
	count(trade_id) as tranzactii_totale,
	sum(trade_amount_usd) as suma_val,
	avg(trade_amount_usd) as media,
	min(trade_amount_usd) as min_val,
	max(trade_amount_usd) as max_val
from t_trades
where trade_date='2022-07-13';

--14 -- group by function
-- generati un raport la nivel de trade_Date si buyer_participant pentru toate zilele  din intervalul 13-iulie-2022 - 17-iulie-2022.El va trebui sa cuprinda urmatoarele coloane:
-- trade_date
-- buyer_participant
-- numarul de tranzactii total
-- suma valorilor tranzactiilor(trade_amount_usd)
-- media valorilor tranzactiilor  (trade_amount_usd)
-- minim valoare tranzactie  (trade_amount_usd)
-- maxim valoare tranzactie  (trade_amount_usd)
-- afisati doar acele linii pentru care suma valorilor este mai mare de 15 milioane USD

select trade_date, buyer_participant,
	count(trade_id) as tranzactii_totale,
	sum(trade_amount_usd) as suma_val,
	avg(trade_amount_usd) as media,
	min(trade_amount_usd) as min_val,
	max(trade_amount_usd) as max_val
from t_trades
where trade_date >= '2022-07-13'::date and trade_date <= '2022-07-17'::date
group by trade_date, buyer_participant
having sum(trade_amount_usd) > 15000000;

