select * from def_area da 
select "Ano/Estados", "AMZ LEGAL" from def_area 
select * from public.el_nino_la_nina

select "start year", "end year" from el_nino_la_nina enln where phenomenon like 'El Nino';
select *, 
case
	when severity like 'Weak' then '1'
	when severity like 'Moderate' then '2'
	when severity like 'Strong' then '3'
	else '4'
end as severity_number
from el_nino_la_nina enln where phenomenon like 'El Nino' order by "start year";

select *,
case
when severity like 'Weak' then '1'
when severity like 'Moderate' then '2'
when severity like 'Strong' then '3'
else '4'
end as severity_number
from el_nino_la_nina where phenomenon like 'La Nina' order by "start year";

--Suma roczna pożarów występująca na całym terenie.
select "year", sum(firespots) as suma_pożarów
from inpe_brazilian_amazon_fires
group by "year" 
order by 1;

--Suma roczna pożarów w poszczególnych stanach.
select "year",state, sum(firespots) as suma_pożarów
from inpe_brazilian_amazon_fires ibaf 
group by "year",state
order by 2;

--Ile stanów jest w tabeli?
select distinct state from inpe_brazilian_amazon_fires ibaf 

--MARANHAO, TOCANTINS, AMAZONA, MARANHAO, MATO GROSSO, PARA, RONDONIA, RORAIMA, AMAPA
select "year", sum(firespots) as suma_pożarów_AMAZONAS
from inpe_brazilian_amazon_fires ibaf 
where state = 'AMAZONAS'
group by "year"
order by 1;

--Połączyć tabelę def area i fires
create view deforestacja_pożart as 
select d."Ano/Estados", d."AMZ LEGAL", i."year", sum(firespots) as suma_pożarów 
from def_area as d
left join inpe_brazilian_amazon_fires as i
on d."Ano/Estados" = i."year" 
group by "year", "Ano/Estados", "AMZ LEGAL"
order by 1;

--połączyć pożary i deforestecje w poszczególnych stanach
create view deforestacja_pożar_Acre as 
select d."Ano/Estados", d.am, i."year", sum(firespots) as suma_pożarów_Acre
from def_area as d
left join inpe_brazilian_amazon_fires as i
on d."Ano/Estados" = i."year" 
where state = 'ACRE'
group by "year", "Ano/Estados", am
order by 1;
--korelacja
select corr(am,suma_pożarów_amazonas)
from public.deforestacja_pożar_amazonas

select * from deforestacja_pożart dp 
--Korelacja pomiędzy obszarem deforestacji a pożarami
select corr("AMZ LEGAL", suma_pożarów)
from deforestacja_pożart dp2 

create table public.el_nino_severity (
year_event int4 not null,
severity_number int2 not null);
insert into public.el_nino_severity (year_event, severity_number) 
values (2002, 2), (2003, 2), (2004, 1), (2005, 1), (2006, 1), (2007, 1), (2008, 0), 
(2009, 2), (2010, 2), (2011, 0), (2012, 0), (2013, 0), (2014, 1), (2015, 4),(2016, 4),
(2017, 0), (2018, 1),(2019, 1);
select * from public.el_nino_severity

--Tabela ilość pożarów i el nino severity
create view pożary_el_nino_severity_RORAIMA as
select el.year_event, el.severity_number, i."year", sum(firespots) as suma_pożarów_RORAIMA
from public.el_nino_severity as el
left join inpe_brazilian_amazon_fires as i
on el.year_event = i."year" 
where state = 'RORAIMA'
group by year_event, severity_number, "year"
order by 1;
select * from public.pożary_el_nino_severity_tocantis
select * from pożary_el_nino_severity pens 
--Korelacja miedzy el nino a ilością pożarów
select corr(severity_number, suma_pożarów_TOCANTIS)
from public.pożary__la_nina_severity_tocantis

--Tabela ilość pożarów i la nina severity
create view pożary__la_nina_severity_ACRE  as
select la.year_event, la.severity_number, i."year", sum(firespots) as suma_pożarów_ACRE
from public.la_nina_severity as la
left join inpe_brazilian_amazon_fires as i
on la.year_event = i."year" 
where state = 'ACRE'
group by year_event, severity_number, "year"
order by 1;

select * from public.pożary__la_nina_severity_para
 
--Korelacja miedzy la nina a ilością pożarów
select corr(severity_number, suma_pożarów_ACRE)
from public.pożary__la_nina_severity_acre

select * 
--Tabela la nina
create table public.la_nina_severity (
year_event int4 not null,
severity_number int2 not null);
insert into public.la_nina_severity (year_event, severity_number) 
values (1999, 3), (2000, 1), (2001, 0), (2002, 0), (2003, 0), (2004, 0), (2005, 1), (2006, 1), (2007, 3), (2008, 1), 
(2009, 1), (2010, 3), (2011, 2), (2012, 2), (2013, 0), (2014, 0), (2015, 0),(2016, 1),
(2017, 1), (2018, 1);
select * from public.la_nina_severity

create view pożary_la_nina_severity as
select la.year_event, la.severity_number, i."year", sum(firespots) as suma_pożarów
from public.la_nina_severity as la
left join inpe_brazilian_amazon_fires as i
on la.year_event = i."year" 
group by year_event, severity_number, "year"
order by 1;

--Korelacja miedzy la nina a ilością pożarów
select corr(severity_number, suma_pożarów)
from public.pożary_la_nina_severity

select * from public.pożary_la_nina_severity