VÝCHOZÍ TABULKY
---------------

-------------------
PRVNÍ TABULKA
-------------------

CREATE TABLE t_radek_marval_project_SQL_primary_final AS (
WITH ceny_roky AS (
SELECT
	date_part('year', cp.date_from)::INT AS rok,
	cp.category_code AS kod_produktu,
	cpc."name" AS nazev_produktu,
	avg(cp.value)::NUMERIC(12, 4) AS cena_produktu,
	cpc.price_value AS pocet_jednotek,
	cpc.price_unit AS jednotka
FROM
	czechia_price cp
JOIN czechia_price_category cpc ON cp.category_code = cpc.code
WHERE
	cp.region_code IS NOT NULL
GROUP BY
	rok,
	kod_produktu,
	nazev_produktu,
	pocet_jednotek,
	jednotka),
mzdy_roky AS (
SELECT
	cpay.payroll_year AS rok,
	cpib.code AS kod_odvetvi,
	cpib.name AS nazev_odvetvi,
	avg(cpay.value)::NUMERIC(10, 2) AS prumerna_mzda_odvetvi
FROM
	czechia_payroll cpay
JOIN czechia_payroll_industry_branch cpib ON cpay.industry_branch_code = cpib.code
WHERE
	cpay.value_type_code = 5958 AND cpay.calculation_code = 200 AND cpay.industry_branch_code IS NOT NULL
GROUP BY
	rok,
	kod_odvetvi,
	nazev_odvetvi), 
mzda_roky_CR AS (
SELECT
	cp.payroll_year AS rok,
	avg(value)::NUMERIC(10, 2) AS prumerna_mzda_CR
FROM
	czechia_payroll cp
WHERE
	cp.value_type_code = 5958 AND calculation_code = 200 AND industry_branch_code IS NULL
GROUP BY
	cp.payroll_year)	
SELECT
	*
FROM
	ceny_roky cr
JOIN mzdy_roky mr USING (rok)
JOIN mzda_roky_CR mrc USING (rok)
ORDER BY
	rok,
	kod_produktu,
	kod_odvetvi);

-------------------
DRUHÁ TABULKA
-------------------

CREATE TABLE t_radek_marval_project_SQL_secondary_final AS (
SELECT
	e."year" AS rok,
	e.country AS zeme,
	e.gdp AS HDP,
	e.gini,
	e.population AS populace
FROM
	economies e
JOIN countries c USING (country)
WHERE
	c.continent = 'Europe'
	AND e."year" IN (
	SELECT
		rok
	FROM
		t_radek_marval_project_sql_primary_final trmpspf)
	AND e.gdp IS NOT NULL 													              	-- chybí HDP za Gibraltar + Liechtenstein, Faroe Islands (u těchto 2 je ve sledovaném období HDP vyplněné pouze za rok 2010)
ORDER BY
	zeme,
	rok);
