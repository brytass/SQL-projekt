3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 

-------------------------
ZA CELÉ SLEDOVANÉ OBDOBÍ
-------------------------
  
WITH zaklad AS (
SELECT
	nazev_produktu,
	round(avg(mezirocni_zmena_ceny), 2) AS prumerna_mezirocni_zmena_ceny
FROM
	v_radek_marval_mezirocni_zmeny_cen
GROUP BY
	nazev_produktu)
SELECT
	*
FROM
	zaklad
WHERE
	prumerna_mezirocni_zmena_ceny > 0
ORDER BY
	prumerna_mezirocni_zmena_ceny
LIMIT 1;

---------------------
DLE JEDNOTLIVÝCH LET
---------------------
	
SELECT
	rok,
	nazev_produktu,
	round(mezirocni_zmena_ceny, 2) AS zaokr_mezirocni_zmena_ceny
FROM
	v_radek_marval_mezirocni_zmeny_cen_pouze_ZDRAZENI
WHERE
	poradi = 1;
