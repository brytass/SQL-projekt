5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

WITH mezirocni_zmena_HDP_CR AS (
SELECT
	*,
	(((hdp - LAG(hdp) OVER (ORDER BY rok)) / LAG(hdp) OVER (ORDER BY rok)) * 100) AS mezirocni_zmena_HDP
FROM
	t_radek_marval_project_sql_secondary_final trmpssf
WHERE
	lower(zeme) LIKE '%czech%'),
prumerna_mezirocni_zmena_cen_potravin AS (
SELECT
	rok,
	avg(mezirocni_zmena_ceny) AS prumerna_mezirocni_zmena_ceny
FROM
	v_radek_marval_mezirocni_zmeny_cen vrmmzc                    -- zohledněny i potraviny, u kterych bylo zlevnění 
GROUP BY
	rok),
celkove_prumerne_zmeny AS (
SELECT
	avg(mzhdp.mezirocni_zmena_HDP) celkovy_prumer_zmen_HDP,
	avg(pmzc.prumerna_mezirocni_zmena_ceny) celkovy_prumer_zmen_cen,
	avg(vrmm.mezirocni_zmena_mzdy_cr) celkovy_prumer_zmen_mezd
FROM
	mezirocni_zmena_HDP_CR mzhdp
LEFT JOIN prumerna_mezirocni_zmena_cen_potravin pmzc
		USING (rok)
LEFT JOIN v_radek_marval_mezirocni_zmeny_mzdy_cr vrmm
		USING (rok)
),
komentare_zmen_roky AS (
SELECT
	pmzcp.rok,
	round(pmzcp.prumerna_mezirocni_zmena_ceny::numeric, 2) AS zaok_prumerna_mezirocni_zmena_ceny,
	round(vrmm.mezirocni_zmena_mzdy_cr::numeric, 2) AS zaok_mezirocni_zmena_mzdy_cr,
	round(mzhdp.mezirocni_zmena_hdp::numeric, 2) AS zaok_mezirocni_zmena_hdp,
	CASE
		WHEN mezirocni_zmena_HDP > (
		SELECT
			celkovy_prumer_zmen_HDP
		FROM
			celkove_prumerne_zmeny) THEN 'vyrazny rust HDP'
		WHEN mezirocni_zmena_HDP < 0 THEN 'pokles HDP'
		ELSE 'NEvyrazny rust HDP'
	END komentar_HDP,
	CASE
		WHEN pmzcp.prumerna_mezirocni_zmena_ceny > (
		SELECT
			celkovy_prumer_zmen_cen
		FROM
			celkove_prumerne_zmeny) THEN 'vyrazny rust cen'
		WHEN pmzcp.prumerna_mezirocni_zmena_ceny < 0 THEN 'pokles cen'
		ELSE 'NEvyrazny rust cen'
	END komentar_ceny,
	CASE
		WHEN vrmm.mezirocni_zmena_mzdy_cr > (
		SELECT
			celkovy_prumer_zmen_mezd
		FROM
			celkove_prumerne_zmeny) THEN 'vyrazny rust mezd'
		WHEN vrmm.mezirocni_zmena_mzdy_cr < 0 THEN 'pokles mezd'
		ELSE 'NEvyrazny rust mezd'
	END komentar_mzdy
FROM
	prumerna_mezirocni_zmena_cen_potravin pmzcp
LEFT JOIN v_radek_marval_mezirocni_zmeny_mzdy_cr vrmm
		USING (rok)
LEFT JOIN mezirocni_zmena_HDP_CR mzhdp
		USING (rok)),
vyhodnoceni_vsechny_roky AS (
SELECT
	rok,
	zaok_prumerna_mezirocni_zmena_ceny,
	zaok_mezirocni_zmena_mzdy_cr,
	zaok_mezirocni_zmena_hdp,
	komentar_hdp,
	komentar_ceny,   
	LEAD(komentar_ceny) OVER (ORDER BY rok) AS komentar_ceny_nasledujici_rok,
	komentar_mzdy,
	LEAD(komentar_mzdy) OVER (ORDER BY rok) AS komentar_mzdy_nasledujici_rok
FROM
	komentare_zmen_roky)
SELECT
	*,
	CASE
		WHEN komentar_ceny = 'vyrazny rust cen' OR komentar_ceny_nasledujici_rok = 'vyrazny rust cen' THEN TRUE
		ELSE FALSE
	END AS ceny_vyrazne_tento_nebo_pristi,
	CASE
		WHEN komentar_mzdy = 'vyrazny rust mezd' OR komentar_mzdy_nasledujici_rok = 'vyrazny rust mezd' THEN TRUE
		ELSE FALSE
	END AS mzdy_vyrazne_tento_nebo_pristi
FROM
	vyhodnoceni_vsechny_roky
WHERE
	komentar_hdp = 'vyrazny rust HDP';			      -- vyfiltruje jen roky, kde byl vyrazny rust HDP	
