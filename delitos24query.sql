-- CLeaning
--DUPLICATE table if it has duplicates
DROP TABLE IF EXISTS delitos_dup2;

CREATE TABLE delitos_dup2 (
    LIKE delitos INCLUDING ALL
);

INSERT INTO delitos_dup2
SELECT *
FROM delitos_dup;

--ADD the column row_num

ALTER TABLE delitos_dup2
ADD COLUMN row_num bigint;

UPDATE delitos_dup2 d
SET row_num = sub.rn
FROM (
    SELECT ctid,
           ROW_NUMBER() OVER (
               PARTITION BY id_mapa, anio, mes, dia, fecha, franja,
                            tipo, subtipo, uso_arma, uso_moto,
                            barrio, comuna, latitud, longitud, cantidad
               ORDER BY id_mapa
           ) AS rn
    FROM delitos_dup2
) sub
WHERE d.ctid = sub.ctid;

--Dataset Overview (size and diversity)
SELECT 
    COUNT(*) AS total_registros,
    COUNT(DISTINCT tipo) AS tipos_delito,
    COUNT(DISTINCT barrio) AS barrios,
    COUNT(DISTINCT comuna) AS comunas
FROM delitos_dup2;

-- Verify rows to be deleted
SELECT *
FROM delitos_dup2
WHERE row_num >1;

-- DELETE the rows
DELETE
FROM delitos_dup2
WHERE row_num >1;

--Check for NULL data
SELECT DISTINCT franja
FROM delitos_dup2;

SELECT franja, fecha
FROM delitos_dup2
WHERE franja IS NULL
ORDER BY fecha DESC;

SELECT DISTINCT tipo
FROM delitos_dup2;

SELECT DISTINCT id_mapa
FROM delitos_dup2;

SELECT DISTINCT cantidad
FROM delitos_dup2;

--Violents crimes (with weapons) by comuna
--Comuna 4 and 8 had the highest freq, from 20-22h
SELECT
	comuna,
	franja,
	uso_arma,
	COUNT(uso_arma) AS tot_armado
FROM delitos_dup2
WHERE uso_arma = 'SI'
GROUP BY uso_arma, franja, comuna
ORDER BY  tot_armado DESC, franja;

--TEMPORAL DISTRIBUTION
--Crime Frequency by month and type of crime (aggregated, subtotal(by month and type of crimes) 
--and total-crimes= 154 916)

SELECT mes, tipo, COUNT(*),
CASE 
WHEN mes = 'ENERO' then 1
WHEN mes = 'FEBRERO' then 2
WHEN mes = 'MARZO' then 3
WHEN mes = 'ABRIL' then 4
WHEN mes = 'MAYO' then 5
WHEN mes = 'JUNIO' then 6
WHEN mes = 'JULIO' then 7
WHEN mes = 'AGOSTO' then 8
WHEN mes = 'SEPTIEMBRE' then 9
WHEN mes = 'OCTUBRE' then 10
WHEN mes = 'NOVIEMBRE'then 11
ELSE 12 END AS mes_num
FROM delitos_dup2
GROUP BY CUBE (mes, tipo)
ORDER BY mes_num, tipo;

-- CRIME TOTAL frequency by month. WE observe that the period between June and October has lower frequency, 
--INCREMENTING from December till May.
WITH total_crime_month AS(
	SELECT mes, tipo, COUNT(*)AS tot_crime,
		CASE 
		WHEN mes = 'ENERO' then 1
		WHEN mes = 'FEBRERO' then 2
		WHEN mes = 'MARZO' then 3
		WHEN mes = 'ABRIL' then 4
		WHEN mes = 'MAYO' then 5
		WHEN mes = 'JUNIO' then 6
		WHEN mes = 'JULIO' then 7
		WHEN mes = 'AGOSTO' then 8
		WHEN mes = 'SEPTIEMBRE' then 9
		WHEN mes = 'OCTUBRE' then 10
		WHEN mes = 'NOVIEMBRE'then 11
		ELSE 12 END AS mes_num
	FROM delitos_dup2
	GROUP BY CUBE (mes, tipo)
	ORDER BY mes_num, tipo)
SELECT *
FROM total_crime_month
WHERE mes IS NOT NULL 
AND tipo IS NULL;

-- MARCH has the highest total crime frequency and SEPTEMBER the lowest.
WITH total_crime_month AS (
    SELECT mes, COUNT(*) AS tot_crime
    FROM delitos_dup2
    GROUP BY mes
)
SELECT
	mes,
	tot_crime
FROM(
	SELECT
		mes,
		tot_crime,
		RANK() OVER(ORDER BY tot_crime DESC) AS r_max,
		RANK() OVER(ORDER BY tot_crime ASC) AS r_min
	FROM total_crime_month) t
WHERE r_max = 1 OR r_min = 1;
-- In March the 'comuna' that had higher 'robo' frequency was 1 folowed by 4, 7 and 14 
SELECT
	mes,
	comuna,
	tipo,
	COUNT(*)AS tot_crime
FROM delitos_dup2
WHERE mes = 'MARZO' AND tipo = 'Robo'
GROUP BY tipo, mes, comuna
order by tot_crime DESC;

--In March the 'comuna' that had higher 'hurto' frequency was 1 folowed by 14, 3 and 13 
SELECT
	mes,
	comuna,
	tipo,
	COUNT(*)AS tot_crime
FROM delitos_dup2
WHERE mes = 'MARZO' AND tipo = 'Hurto'
GROUP BY tipo, mes, comuna
order by tot_crime DESC;

--In March the 'comuna' that had higher 'vialidad' frequency was 12 folowed by 15, 1 and 13
SELECT
	mes,
	comuna,
	tipo,
	COUNT(*)AS tot_crime
FROM delitos_dup2
WHERE mes = 'MARZO' AND tipo = 'Vialidad'
GROUP BY tipo, mes, comuna
order by tot_crime DESC;

-- Types of crimes frequency
-- Robo (68304) was the most frequent type followed by hurto(62655), and homicidios (78) was the lowest
SELECT 
	tipo,
	COUNT(*) AS subtotal
FROM delitos_dup2
GROUP BY tipo
ORDER BY subtotal DESC;

--Robo has its higher peek at 20h and 7am
SELECT 
	tipo,
	franja,
	COUNT(*) AS subtotal
FROM delitos_dup2
WHERE tipo = 'Robo'
GROUP BY tipo, franja
ORDER BY tipo, franja DESC, subtotal DESC
;

-- Ranking of neighborhoods by crime. Palermo is first, followed by Balvanera and then Flores
SELECT 
    barrio,	
    COUNT(*) AS total,
    DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM delitos_dup2
GROUP BY barrio
ORDER BY total DESC
LIMIT 20;
-- Top 10 Ranking of neighborhoods by 'Amenaza'type crime. Villa Lugano is first.
SELECT 
    barrio,	
    COUNT(*) AS total,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM delitos_dup2
WHERE tipo = 'Amenazas'
GROUP BY barrio
ORDER BY total DESC
LIMIT 10;

-- %of crime by comuna
SELECT 
    comuna,
    COUNT(*) AS total,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS porcentaje
FROM delitos_dup2
GROUP BY comuna
ORDER BY total DESC;

--Month to month variation
WITH monthly AS (
    SELECT 
        mes,
		CASE 
		WHEN mes = 'ENERO' then 1
		WHEN mes = 'FEBRERO' then 2
		WHEN mes = 'MARZO' then 3
		WHEN mes = 'ABRIL' then 4
		WHEN mes = 'MAYO' then 5
		WHEN mes = 'JUNIO' then 6
		WHEN mes = 'JULIO' then 7
		WHEN mes = 'AGOSTO' then 8
		WHEN mes = 'SEPTIEMBRE' then 9
		WHEN mes = 'OCTUBRE' then 10
		WHEN mes = 'NOVIEMBRE'then 11
		ELSE 12 END AS mes_num,
        COUNT(*) AS total
    FROM delitos_dup2
    GROUP BY mes
)
SELECT 
	mes_num,
    mes,
    total,
    total - LAG(total) OVER (ORDER BY mes_num) AS variacion,
	ROUND(100.0 * (total - LAG(total) OVER (ORDER BY mes_num)) / LAG(total) OVER (ORDER BY mes_num), 2) AS porc_var
FROM monthly
ORDER BY mes_num;

-- Month with higher types of crimes
WITH monthly_tipo AS (
    SELECT 
        mes,
        tipo,
        COUNT(*) AS total
    FROM delitos_dup2
    GROUP BY mes, tipo
)
SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY tipo ORDER BY total DESC) AS rnk
    FROM monthly_tipo
) t
WHERE rnk = 1
ORDER BY total DESC;

-- Create VIEW monthly crime summary
CREATE VIEW resumen_mensual AS
SELECT 
    mes,
    COUNT(*) AS total
FROM delitos_dup2
GROUP BY mes;

--VIEW monthly crime summary
SELECT *
FROM resumen_mensual
ORDER BY array_position(
    ARRAY[
        'ENERO','FEBRERO','MARZO','ABRIL','MAYO','JUNIO',
        'JULIO','AGOSTO','SEPTIEMBRE','OCTUBRE','NOVIEMBRE','DICIEMBRE'
    ], mes);
