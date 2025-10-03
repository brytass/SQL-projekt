1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
	
SELECT
	trm.rok,
	trm.nazev_odvetvi,
	trm.prumerna_mzda_odvetvi,
	CASE
		WHEN lag(trm.prumerna_mzda_odvetvi) OVER (PARTITION BY trm.nazev_odvetvi ORDER BY rok) > trm.prumerna_mzda_odvetvi THEN 'pokles'
		WHEN lag(trm.prumerna_mzda_odvetvi) OVER (PARTITION BY trm.nazev_odvetvi ORDER BY rok) = trm.prumerna_mzda_odvetvi THEN 'stagnace'
		WHEN lag(trm.prumerna_mzda_odvetvi) OVER (PARTITION BY trm.nazev_odvetvi ORDER BY rok) < trm.prumerna_mzda_odvetvi THEN 'rust'
		ELSE 'prvni_rok'
	END AS zmena_mzdy
FROM
	t_radek_marval_project_sql_primary_final trm
GROUP BY
	trm.rok,
	trm.nazev_odvetvi,
	trm.prumerna_mzda_odvetvi
ORDER BY
	trm.nazev_odvetvi,
	trm.rok;

-----------------------------------------------------------------
FILTR ODVĚTVÍ, KDE BYL V CELÉM SLEDOVANÉM OBDOBÍ POUZE RŮST MEZD
-----------------------------------------------------------------

WITH prehled AS (				
SELECT
	trm.rok,
	trm.nazev_odvetvi,
	trm.prumerna_mzda_odvetvi,
	CASE
		WHEN lag(trm.prumerna_mzda_odvetvi) OVER (PARTITION BY trm.nazev_odvetvi ORDER BY rok) > trm.prumerna_mzda_odvetvi THEN 'pokles'
		WHEN lag(trm.prumerna_mzda_odvetvi) OVER (PARTITION BY trm.nazev_odvetvi ORDER BY rok) = trm.prumerna_mzda_odvetvi THEN 'stagnace'
		WHEN lag(trm.prumerna_mzda_odvetvi) OVER (PARTITION BY trm.nazev_odvetvi ORDER BY rok) < trm.prumerna_mzda_odvetvi THEN 'rust'
		ELSE 'prvni_rok'
	END AS zmena_mzdy
FROM
	t_radek_marval_project_sql_primary_final trm
GROUP BY
	trm.rok,
	trm.nazev_odvetvi,
	trm.prumerna_mzda_odvetvi),
jen_rust AS (
SELECT
	nazev_odvetvi,
	count(1) AS pocet_let_rustu
FROM
	prehled
WHERE
	zmena_mzdy = 'rust'
GROUP BY
	nazev_odvetvi),
pocet_let_se_zmenou AS (
SELECT DISTINCT
	count(1)
FROM
		prehled
WHERE
		zmena_mzdy != 'prvni_rok'
GROUP BY
		nazev_odvetvi)	
SELECT
	*
FROM
	jen_rust
WHERE
	pocet_let_rustu = (SELECT * FROM pocet_let_se_zmenou);

-----------------------------------------------------------
FILTR ROK+ODVĚTVÍ, KDE BYL ZA SLEDOVANÉ OBDOBÍ POKLES MZDY
-----------------------------------------------------------

WITH prehled as (
SELECT
	trm.rok,
	trm.nazev_odvetvi,
	trm.prumerna_mzda_odvetvi,
	CASE
		WHEN lag(trm.prumerna_mzda_odvetvi) OVER (PARTITION BY trm.nazev_odvetvi ORDER BY rok) > trm.prumerna_mzda_odvetvi THEN 'pokles'
		WHEN lag(trm.prumerna_mzda_odvetvi) OVER (PARTITION BY trm.nazev_odvetvi ORDER BY rok) = trm.prumerna_mzda_odvetvi THEN 'stagnace'
		WHEN lag(trm.prumerna_mzda_odvetvi) OVER (PARTITION BY trm.nazev_odvetvi ORDER BY rok) < trm.prumerna_mzda_odvetvi THEN 'rust'
		ELSE 'prvni_rok'
	END AS zmena_mzdy
FROM
	t_radek_marval_project_sql_primary_final trm
GROUP BY
	trm.rok,
	trm.nazev_odvetvi,
	trm.prumerna_mzda_odvetvi)
SELECT rok, nazev_odvetvi
FROM prehled
WHERE zmena_mzdy = 'pokles'
ORDER BY
	rok,
	nazev_odvetvi
