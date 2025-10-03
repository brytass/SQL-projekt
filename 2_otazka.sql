2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

--------------------------
POUZE ZA ČESKOU REPUBLIKU
--------------------------

WITH odvetvi_plus_cr as (SELECT
	*,
	(prumerna_mzda_odvetvi / cena_produktu)::NUMERIC(10, 2) AS moznost_porizeni_odvetvi,
	jednotka AS jednotka2,
	(prumerna_mzda_cr / cena_produktu)::NUMERIC(10,2) AS moznost_porizeni_cela_CR,
	jednotka AS jednotka3
FROM
	t_radek_marval_project_sql_primary_final trm
WHERE
	trm.rok IN (
		SELECT min(rok) FROM t_radek_marval_project_sql_primary_final trmpspf
		UNION
		SELECT max(rok) FROM t_radek_marval_project_sql_primary_final trmpspf)
	AND (lower(trm.nazev_produktu) LIKE '%mléko%' OR lower(trm.nazev_produktu) LIKE '%chléb%')
ORDER BY
	rok,
	nazev_produktu)
SELECT
	rok,
	nazev_produktu,
	round(cena_produktu, 2),
	pocet_jednotek,
	jednotka,
	prumerna_mzda_cr,
	moznost_porizeni_cela_cr,
	jednotka
FROM odvetvi_plus_cr opcr
GROUP BY rok, nazev_produktu, cena_produktu, pocet_jednotek, jednotka, prumerna_mzda_cr, moznost_porizeni_cela_cr;

------------------------------
DLE ODVĚTVÍ + ČESKÁ REPUBLIKA
------------------------------

SELECT
	*,
	(prumerna_mzda_odvetvi / cena_produktu)::NUMERIC(10, 2) AS moznost_porizeni_odvetvi,
	jednotka,
	(prumerna_mzda_cr / cena_produktu)::NUMERIC(10,2) AS moznost_porizeni_cela_CR,
	jednotka
FROM
	t_radek_marval_project_sql_primary_final trm
WHERE
	trm.rok IN (
		SELECT min(rok) FROM t_radek_marval_project_sql_primary_final trmpspf
		UNION
		SELECT max(rok) FROM t_radek_marval_project_sql_primary_final trmpspf)
	AND (lower(trm.nazev_produktu) LIKE '%mléko%' OR lower(trm.nazev_produktu) LIKE '%chléb%')
ORDER BY
	rok,
	nazev_produktu;
