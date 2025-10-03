# Průvodní listina k SQL projektu

> **Téma:** Vývoj cen vybraných potravin vs. mzdy a HDP v ČR (2006–2018)  
> **Prostředí:** PostgreSQL  
> **Autor:** Radek Marval

---

## 🎯 Cíl projektu
Analyzuji vývoj **cen vybraných potravin** v kontextu **mezd** a **HDP** v České republice v letech **2006–2018** a odpovídám na sadu výzkumných otázek.  
V tabulkách záměrně ponechávám širší sadu sloupců (kódy produktů/odvětví apod.), aby si uživatel mohl dle potřeby flexibilně vybrat pole pro další práci.

---

## 🧭 Stručné závěry

- **Mzdy 2006–2018:** pouze **3/19 odvětví** neměly v žádném roce pokles průměrné mzdy  
  → **Zdravotní a sociální péče, Zpracovatelský průmysl, Ostatní činnosti**.
- **Kupní síla (ČR):**  
  2006 → **1 211,63 kg** chleba, **1 353,11 l** mléka  
  2018 → **1 321,99 kg** chleba, **1 616,91 l** mléka
- **Nejpomaleji zdražující kategorie:** **Banány žluté** (průměrný YoY ≈ **0,81 %**).
- **Ceny vs. mzdy (>10 p. b.):** nenašel jsem rok, kdy by průměrné zdražení potravin **převýšilo** růst mezd o **více než 10 p. b.** (maximum ≈ **6,01 p. b.** v r. 2013).
- **HDP → ceny/mzdy:** vazba na **mzdy** je zřetelnější (stejný/následující rok); **ceny potravin** reagují **slabě a nekonzistentně**.

---

## 🗂 Výchozí tabulky

### **TABULKA 1:** `t_radek_marval_project_SQL_primary_final` (`trmpspf`)
Agregovaná roční data pro ČR:
- **Ceny potravin** (rok, kód/název produktu, průměrná cena, počet jednotek, jednotka).
- **Mzdy po odvětvích** (rok, kód/název odvětví, průměrná mzda odvětví).
- **Mzda na národní úrovni** (rok, průměrná mzda ČR).

**Poznámky:**
- `czechia_price`: počítám **průměrnou roční cenu** a **vylučuji řádky bez regionu** (`cp.region_code IS NOT NULL`).  
- `czechia_price_category`: beru názvy produktů, **`price_value`** (počet jednotek) a **`price_unit`** (jednotka).  
- `czechia_payroll` (mzdy po odvětvích): filtruji **`value_type_code = 5958`** (Průměrná hrubá mzda na zaměstnance) a **`calculation_code = 200`** (přepočtený), odvětví musí být vyplněné.  
- `czechia_payroll` (mzda ČR): **`value_type_code = 5958`** (Průměrná hrubá mzda na zaměstnance) a **`calculation_code = 200`** (přepočtený), odvětví `NULL`.

> **Mzdy – metodika:**  
> - Pracuji s **přepočtenými mzdami**, nikoli s počty fyzických osob.  
> - Na **národní úrovni** používám **vážené průměry mezd**.  

---

### **TABULKA 2:** `t_radek_marval_project_SQL_secondary_final` (`trmpssf`)
Makroekonomická data pro evropské země:
- **HDP**, **Gini**, **populace** po rocích; filtruji na země s dostupným HDP a na roky přítomné v primární tabulce.

**Poznámky z query:**
- Filtruji **Evropu** (`countries.continent = 'Europe'`) a **přebírám jen roky, které existují v primární tabulce**.  
- Vyřazuji řádky s `e.gdp IS NULL`.  
- _Poznámka k pokrytí_: **chybí HDP za Gibraltar a Liechtenstein; u Faroe Islands je ve sledovaném období HDP vyplněné jen za rok 2010.**

---

## 🔎 Výzkumné otázky a zjištění

### 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
Z dat 2006–2018 mi vychází, že **pouze 3 z 19 odvětví** neměly v žádném roce pokles průměrné mzdy:  
**Zdravotní a sociální péče, Zpracovatelský průmysl, Ostatní činnosti.**  
Ve zbývajících **16 odvětvích** alespoň jednou pokles nastal.

**Poznámka z query:** meziroční klasifikaci `růst / stagnace / pokles` dělám přes `LAG()` v rámci odvětví.

---

### 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období?
**Česká republika (po sjednocení na FTE – calc_code=200):**
- **2006:** chléb **1 211,63 kg**, mléko **1 353,11 l**  
- **2018:** chléb **1 321,99 kg**, mléko **1 616,91 l**  
**Rozdíl 2018 − 2006:** **+110,36 kg** chleba a **+263,80 l** mléka.

**Poznámky z query:**
- Počítám `průměrná mzda / cena produktu`; jednotky v datech: **kg** (chléb) a **l** (mléko), **počet jednotek = 1**.  
- Vyrábím dvě perspektivy: **odvětví + ČR** a **pouze ČR**.

---

### 3) Která kategorie potravin zdražuje nejpomaleji (nejnižší % meziroční nárůst)?
Za celé období mi vycházejí **Banány žluté** jako kategorie s **nejnižším průměrným meziročním nárůstem ceny** (≈ **0,81 %**).  
Pro doplnění uvádím i dlouhodobé tempo růstu jako **CAGR** (≈ **0,60 %**).

**Poznámky z query:**
- Pro „celé období“ beru **průměrné YoY změny** z pohledu `v_radek_marval_mezirocni_zmeny_cen` (**zohledňuji i zlevnění** – negativní YoY).  
- Pro „dle let“ používám pohled `v_radek_marval_mezirocni_zmeny_cen_pouze_ZDRAZENI` (tj. **jen kladné** YoY) a vybírám **nejmenší kladný** YoY v každém roce (`RANK`).

---

### 4) Existuje rok, kdy byly ceny potravin meziročně výrazně výš než mzdy (> 10 p. b.)?
**Ne.**  
Největší zjištěný rozdíl (průměrné ceny vs. mzdy) je **pod 10 p. b.**; při pohledu pouze na zdražující kategorie je maximum okolo **9,2 p. b.** (2013).

**Poznámka z query:** porovnávám průměrné YoY změny cen za rok vůči YoY změně mezd v témže roce.

---

### 5) Má výška HDP vliv na změny ve mzdách a cenách potravin (ve stejném nebo následujícím roce)?
- **HDP → mzdy:** pozoruji častější **pozitivní souběh** – v letech s výrazně nadprůměrným růstem HDP mají mzdy tendenci růst **nadprůměrně** (ve stejném nebo následujícím roce).  
- **HDP → ceny potravin:** vztah je **slabý a nekonzistentní** (ceny ovlivňuje širší sada faktorů).  
- **Závěr:** Silný přímý vliv HDP na zdražování potravin jsem **neprokázal**; vazba na mzdy je **zřetelnější**.

**Poznámky z query:**
- Rok označuji jako **„výrazný růst HDP“**, pokud je meziroční změna HDP **nad dlouhodobým průměrem**.  
- Porovnávám, zda je „výrazný růst“ vidět u **cen/mezd** v **tom roce** a také přes `LEAD()` v **následujícím roce**.  
- Pro průměrné změny cen používám pohled, který **zahrnuje i zlevnění** (negativní YoY).

---

## 🧪 Metodika a transformace

- **Ceny:** počítám průměrnou roční cenu produktu (agregace přes regiony).  
- **Mzdy:** pracuji s **přepočtenými mzdami (FTE)**; na národní úrovni používám **vážené průměry** převzaté ze zdroje; **národní mzdu sjednocuji na calc_code=200**.  
- **Meziroční změny (YoY):** počítám pomocí `LAG()` v rámci kategorie/odvětví/časové řady.  
- **„Výrazný růst HDP“:** rok, ve kterém je meziroční změna HDP **nad dlouhodobým průměrem**.  
- **Jednotky dostupnosti (Q2):** `mzda/cena` vyjadřuje **kg** (chléb) a **l** (mléko).

---

## 🧩 Repo & skripty (doporučená struktura)
