--Jakie są miasta, w których mieszka więcej niż 3 pracowników? 
select "City", count ("City") from employees e group by "City" having count (*) >3;

--Jaki jest średni wiek pracowników w momencie ich zatrudnienia (zakładamy, że każdy rok ma 365 dni?
SELECT AVG(date_part('year', "HireDate") - date_part('year',"BirthDate") )
AS Średni_wiek_pracownika
FROM Employees;

--Zakładając, że produkty, które kosztują (UnitPrice) mniej niż 10$ możemy uznać za tanie, 
--te między 10$ a 50$ za średnie, a te powyżej 50$ za drogie, ile produktów należy do poszczególnych przedziałów? 
select 
	case 
		when "UnitPrice" <10 then 'Tanie'
		when "UnitPrice" between 10 and 50 then 'Średnie'
		else 'Drogie'
	end as Kategorie_Cenowe,
	count (*) as Ilość_Produktów
from public.products
group by Kategorie_Cenowe;

--Ile kosztuje najtańszy, najdroższy i ile średnio kosztuje produkt od każdego z dostawców? 
--Ile różnych typów produktów dostarcza każdy z dostawców? 
	
select 
	p."SupplierID", s."CompanyName",
	round (min("UnitPrice")::numeric, 2) as cena_MIN,
	round (max("UnitPrice")::numeric, 2) as cena_MAX,
	round (avg("UnitPrice")::numeric, 2) as cena_ŚREDNIA,
	count(distinct "ProductID") as ilość_produktów
from products as p 
left join suppliers as s
on p."SupplierID" = s."SupplierID" 
group by p."SupplierID", s."CompanyName";

--Jak się nazywają i jakie mają numery kontaktowe wszyscy dostawcy i klienci (ContactName) z Londynu? 
--Jeśli nie ma numeru telefonu, wyświetl faks.
update customers 
SET "Phone" = NULLIF("Phone", '')
WHERE "Phone" = ''

select "CompanyName", "ContactName",
	case
		when "Phone" is not null then "Phone"
		else "Fax"
	end as numer_kontaktowy
from suppliers s 
where "City" = 'London'
union 
select "CompanyName", "ContactName",
	case
		when "Phone" is not null then "Phone"
		else "Fax"
	end as numer_kontaktowy
from customers c 
where "City" = 'London';

--Jakie produkty były na najdroższym zamówieniu (OrderID)? Uwzględnij zniżki i poziom zamówień (Discount) 

SELECT od."OrderID", 
sum(od."UnitPrice" * od."Quantity") as wartość_zamówienia,
sum(od."UnitPrice" * od."Quantity" * (1 - od."Discount")) AS wartość_po_zniżce
FROM public.order_details AS od
group by "OrderID" ORDER BY wartość_po_zniżce DESC;

select "OrderID", "ProductID" from public.order_details where "OrderID" = 10865;
	
select "ProductName" from public.products where "ProductID" in ('38', '39');

--Które miejsce cenowo (od najtańszego) zajmują w swojej kategorii (CategoryID) wszystkie produkty? 

select "ProductName", "CategoryID", "UnitPrice",
	dense_rank () over (partition by "CategoryID" order by "UnitPrice") as ranking
from products p 

--Przygotuj zestawienie produktów, których jest mniej w zapasie (UnitsInStock) niż średnio w swojej kategorii (CategoryID) 
create view zapas as
select "CategoryID", "ProductName", "UnitsInStock",
	avg("UnitsInStock") over (partition by "CategoryID") as średnia_kategorii
from products p 

select "CategoryID", "ProductName", "UnitsInStock", średnia_kategorii
	from zapas z2  
	where "UnitsInStock" < średnia_kategorii;
