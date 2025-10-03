--------------------------------------------------
1. VIEW - meziroční změny cen (včetně poklesů cen)    
--------------------------------------------------

CREATE VIEW v_radek_marval_mezirocni_zmeny_cen AS (                    	
WITH zmeny_cen AS (
SELECT
	rok,
	nazev_produktu,
	cena_produktu,
	(((cena_produktu - LAG(cena_produktu) OVER (PARTITION BY nazev_produktu ORDER BY rok)) / LAG(cena_produktu) OVER (PARTITION BY nazev_produktu ORDER BY rok))* 100) AS mezirocni_zmena_ceny
FROM
	t_radek_marval_project_sql_primary_final trm
GROUP BY
	rok,
	nazev_produktu,
	cena_produktu
ORDER BY
	nazev_produktu,
	rok)
SELECT
		zmeny_cen.*,
		RANK() OVER (PARTITION BY rok
ORDER BY
		mezirocni_zmena_ceny) AS poradi
FROM
		zmeny_cen
WHERE
		mezirocni_zmena_ceny IS NOT NULL
ORDER BY
		rok,
		mezirocni_zmena_ceny);

--------------------------------------------------------------------------
2. VIEW - meziroční změny cen u produktů, u nichž došlo POUZE KE ZDRAŽENÍ
--------------------------------------------------------------------------
	
CREATE VIEW v_radek_marval_mezirocni_zmeny_cen_pouze_ZDRAZENI AS (WITH zmeny_cen AS (						
SELECT
	rok,
	nazev_produktu,
	cena_produktu,
	(((cena_produktu - LAG(cena_produktu) OVER (PARTITION BY nazev_produktu ORDER BY rok)) / LAG(cena_produktu) OVER (PARTITION BY nazev_produktu ORDER BY rok))* 100) AS mezirocni_zmena_ceny
FROM
	t_radek_marval_project_sql_primary_final trm
GROUP BY
	rok,
	nazev_produktu,
	cena_produktu
ORDER BY
	nazev_produktu,
	rok)
SELECT
		zmeny_cen.*,
		RANK() OVER (PARTITION BY rok
ORDER BY
		mezirocni_zmena_ceny) AS poradi
FROM
		zmeny_cen
WHERE
		mezirocni_zmena_ceny IS NOT NULL
	AND mezirocni_zmena_ceny > 0 									    -- NULL hodnoty jsou pro rok 2006, kdy není s čím porovnat (data za rok 2005 v datasetu nejsou); chceme jen zdražení, proto větší než 0
ORDER BY
		rok,
		mezirocni_zmena_ceny)

-------------------------------
3. VIEW - meziroční změny mezd
-------------------------------

CREATE VIEW v_radek_marval_mezirocni_zmeny_mzdy_cr AS (				
SELECT
	trm.rok,
	trm.prumerna_mzda_cr,
	((trm.prumerna_mzda_cr  - LAG(trm.prumerna_mzda_cr) OVER (ORDER BY rok)) / LAG(trm.prumerna_mzda_cr) OVER (ORDER BY rok)) * 100 AS mezirocni_zmena_mzdy_cr
FROM
	t_radek_marval_project_sql_primary_final trm
GROUP BY
	trm.rok,
	trm.prumerna_mzda_cr
ORDER BY
	rok);



