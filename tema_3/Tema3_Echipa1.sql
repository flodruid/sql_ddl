--1 -- FROM clause
--Scrieti un query care sa extraga toate datele din tabela t_trades
select * from t_trades tt;
--2 -- WHERE clause
--Scrieti un query care sa extraga toate coloanele din tabela t_trades pentru inregistrarile care au trade_date ziua de 15-iulie-2022

select * from t_trades tt 
where tt.trade_date = '2022-07-15';

--3 -- WHERE clause
--Scrieti un query care sa extraga toate coloanele din tabela t_trades pentru inregistrarile care indeplinesc urmatoarele conditiiL
-- fie trade_date este 14-iulie-2022 si trade_time e dupa ora 18 iar trade_stock e NVRO, fie trade_date este dupa ziua de 16-iulie-2022,
-- trade_time este intre ora 13:00 si 18:00 si traded_market nu e goala sau NASDAQ 

select * from t_trades tt 
where (tt.trade_date = '2022-07-14' and extract(hour from tt.trade_time) >18 and tt.traded_stock ='NVRO')
		or (tt.trade_date > '2022-07-16' and ( extract(hour from tt.trade_time) >= 13 and extract(hour from tt.trade_time) <=18)  
		and (tt.traded_market != 'NASDAQ' and tt.traded_market is not null ));

--4 -- WHERE clause
--Scrieti un query care sa extraga toate coloanele din tabela t_trades pentru inregistrarile care indeplinesc urmatoarele conditiiL
-- fie trade_date este 14-iulie-2022 si trade_time e dupa ora 18 iar trade_stock nu e PRIM (rezultatul trebuie sa includa si randurile pentru traded_stock e null )

select * from t_trades tt
where tt.trade_date ='2022-07-14' and extract(hour from tt.trade_time) >18 and (tt.traded_stock !='PRIM' or tt.traded_stock isnull );

--5 -- FROM + SELECT clause
--Creati un view numit trades_2022_07_16 care sa cuprinda toate coloanele din tabela t_trades cu exceptia trade_date si trade_time
--adaugati o coloana noua de tip timestamp in view: trade_tmstmp care sa concateneze trade_date si trade_time.
--Scrieti 2 query-uri pe baza acestui view:
-- primul va extrage toate coloanele doar pentru inregistrarile care au traded_stock CTSO
-- cel de-al doilea va extrage toate coloanele care au seller participant PART_017

create view trades_2022_07_16 as
select tt.trade_id , tt.seller_participant , tt.buyer_participant ,tt.trade_amount_usd , tt.trade_currency , tt.traded_stock ,
tt.traded_market, tt.instrument_score , tt.trader_comment, concat(tt.trade_date,' ', tt.trade_time) as date_and_time
from t_trades tt;

select *
from trades_2022_07_16 tv
where tv.traded_stock ='CTSO';

select *
from trades_2022_07_16 tv
where tv.seller_participant ='PART_017';

--6 -- SELECT + WHERE + timestamp function
-- scrieti o interogare care sa returneze urmatoarele coloane: trade_timestamp_utc (trade_date concatenat cu trade_time). 
--trade_timestamp_ro (trade_date concatenat cu trade_time) convertit la Europe/Bucharest timezone, trade_id, buyer_participant si trade_amount_usd
-- se presupune ca trade_date si trade_time in tabelul initial sunt stocate in UTC timezone
-- filtrati doar inregistrarile care au trade_Date 15-iulie-2022 si pentru care trade_date + trade_time convertit la Europe/Bucharest
-- la care se adauga 3 zile este mai mare decat timpul actual al sistemului

select 
concat(trade_date,' ', trade_time)::timestamp as trade_timestamp_utc, 
concat(trade_date,' ', trade_time)::timestamp at time zone 'UTC' at time zone 'Europe/Bucharest'as tstamp_ro, 
tt.trade_id,
tt.buyer_participant ,
tt.trade_amount_usd
from t_trades tt
where tt.trade_date ='2022-07-15'
and (concat(trade_date,' ', trade_time)::timestamptz at time zone 'UTC' at time zone 'Europe/Bucharest' + interval '3 days') > current_timestamp;

--7 -- order by
--selectati toate trade-urile efectuate in ziua de 16-iulie-2022. Prezentati rezultatele ordonate descrescator dupa buyer_participant si crescator dupa trade_amount_usd

select * from t_trades tt
where tt.trade_date = '2022-07-16'
order by buyer_participant desc, trade_amount_usd asc;

--8 -- order by, limit si offset
--selectati toate trade-urile efectuate in ziua de 15-iulie-2022. Prezentati rezultatele ordonate descrescator 
--dupa trade_amount_usd si afisati doar randurile 5-12 din outputul initial

select * from t_trades tt
where tt.trade_date = '2022-07-15'
order by trade_amount_usd desc
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

select substring (string_to_table('0:Group0;1:Group1;2:Group2;3:Group3', ';'), 1,1) as group_code, 
substring (string_to_table('0:Group0;1:Group1;2:Group2;3:Group3', ';'), 3) as group_name;
--OR
select substring (string_to_table('0:Group0;1:Group1;2:Group2;3:Group3', ';'), 1,position(':' in '0:Group0;1:Group1;2:Group2;3:Group3' )-1) as group_code, 
substring (string_to_table('0:Group0;1:Group1;2:Group2;3:Group3', ';'), position(':' in '0:Group0;1:Group1;2:Group2;3:Group3' )+1) as group_name;

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
    --extract(day from trade_date) as week_day, --in case we need the day as numeric value
    to_char(trade_date,'day') as week_day ,
    extract('doy' from trade_date) as year_day,
    substring(trim(seller_participant),6)::decimal as seller_code,
    substring(trim(buyer_participant),6)::decimal as buyer_code,
    trade_amount_usd::integer as  trade_amount_int,
    (case
        when trade_amount_usd::integer%17=13 then 'Category 1'
        when trade_amount_usd::integer%17<5 then 'Category 2'
        when trade_amount_usd::integer%2=0 then 'Category 3'
        else 'Other' end) as category
from t_trades where trade_date='2022-07-15' or trade_date='2022-07-13';

--11--
select t.trade_date,t.trade_time, t.buyer_participant, t.trade_amount_usd, trades_summary.total from t_trades t
	join
(select t1.tr_date,t1.buyer_participant, sum(trade_amount_usd) as total  from 
	(select trade_date-1 as  tr_date, buyer_participant, trade_amount_usd from t_trades 
 		where trade_date in ('2022-07-14','2022-07-12')
      		      and buyer_participant in('PART_013', 'PART_009', 'PART_008')
	) t1 
 	group by t1.buyer_participant,t1.tr_date) trades_summary
on t.trade_date=trades_summary.tr_date and t.buyer_participant=trades_summary.buyer_participant;

--12--
select * from t_trades t2
    where 
    t2.trade_date>'2022-07-14'::date
    and
    (select t3.trade_amount_usd from t_trades t3 where 
     t3.trade_date=t2.trade_date+1
    and t3.seller_participant=t2.seller_participant
    and t3.buyer_participant=t2.buyer_participant
    and t3.traded_stock=t2.traded_stock 
    )>t2.trade_amount_usd;

--13 -- aggregation function
-- generati un raport global pentru ziua de 13-iulie-2022. El va trebui sa cuprinda urmatoarele coloane:
-- o coloana numita descriere  care sa afiseze textul: "Date tranzactii tranzactii 13-iulie-2022"
-- numarul de tranzactii total
-- suma valorilor tranzactiilor(trade_amount_usd)
-- media valorilor tranzactiilor  (trade_amount_usd)
-- minim valoare tranzactie  (trade_amount_usd)
-- maxim valoare tranzactie  (trade_amount_usd)

select 'Date tranzactii 13-iulie-2022' as descriere, 
        count(trade_id) as numarul_de_tranzactii, 
        sum(trade_amount_usd) as suma_val_tranz,
        trunc(avg(trade_amount_usd),2) as media_val_tranz, 
        min(trade_amount_usd) as minim_val_tranz, 
        max(trade_amount_usd) as maxim_val_tranz 
from t_trades tt 
where trade_date ='2022-07-13';

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

select tt.trade_date, tt.buyer_participant, 
        count(*) as nr_of_trans, 
        sum(tt.trade_amount_usd) as total_trade_amount_usd, 
        trunc(avg(tt.trade_amount_usd),2) as avg_trade_amount_usd, 
        min(tt.trade_amount_usd) as min_trade_amount_usd,
        max(tt.trade_amount_usd) as max_trade_amount_usd
from t_trades tt
where tt.trade_date between '2022-07-13' and '2022-07-17'
group  by tt.trade_date , tt.buyer_participant 
having sum(tt.trade_amount_usd) > 15000000
order by tt.trade_date, tt.buyer_participant;


