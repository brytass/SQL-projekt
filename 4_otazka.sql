4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

SELECT
	vrmc.rok,
	round(avg(vrmc.mezirocni_zmena_ceny), 2) AS prumerny_mezirocni_rust_cen_potravin,
	round(vrmm.mezirocni_zmena_mzdy_cr,2) AS zaok_mezirocni_zmena_mzdy_cr,
	round(avg(vrmc.mezirocni_zmena_ceny) - vrmm.mezirocni_zmena_mzdy_cr, 2) AS rozdil,
	CASE
		WHEN avg(vrmc.mezirocni_zmena_ceny) - vrmm.mezirocni_zmena_mzdy_cr > 10 THEN 'výrazný nárůst cen potravin (> 10 %)'
		ELSE 'není výrazný nárůst cen potravin (< 10 %)'
	END AS komentar
FROM
	v_radek_marval_mezirocni_zmeny_cen vrmc
JOIN v_radek_marval_mezirocni_zmeny_mzdy_cr vrmm
		USING (rok)
WHERE vrmm.mezirocni_zmena_mzdy_cr IS NOT NULL		
GROUP BY
	rok,
	vrmm.mezirocni_zmena_mzdy_cr
-- HAVING round(avg(vrmc.mezirocni_zmena_ceny) - vrmm.mezirocni_zmena_mzdy_cr, 2) > 10	-- nic nevyhodí = NENÍ meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)
ORDER BY
	vrmc.rok;
