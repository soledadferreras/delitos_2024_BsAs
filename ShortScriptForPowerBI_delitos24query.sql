-- Summary of principals KPI's
CREATE OR REPLACE VIEW vw_kpi_general AS
SELECT
    COUNT(*) AS total_delitos,
    COUNT(DISTINCT tipo) AS tipos_delito,
    COUNT(DISTINCT barrio) AS barrios,
    COUNT(DISTINCT comuna) AS comunas,
    SUM(CASE WHEN uso_arma = 'SI' THEN 1 ELSE 0 END) AS delitos_con_arma
FROM delitos_dup2;

SELECT *
FROM vw_kpi_general;

--MONTHLY tendency

CREATE OR REPLACE VIEW vw_tendencia_mensual AS
SELECT
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
    COUNT(*) AS total_delitos
FROM delitos_dup2
GROUP BY mes_num
ORDER BY mes_num;

SELECT *
FROM vw_tendencia_mensual;

--  Frequency and percentage of crime's type.
CREATE OR REPLACE VIEW vw_top_tipos AS
SELECT
    tipo,
    COUNT(*) AS total_delitos,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS porcentaje
FROM delitos_dup2
GROUP BY tipo
ORDER BY total_delitos DESC;

SELECT *
FROM vw_top_tipos;

-- Crime distribution by comuna. Ranking
CREATE OR REPLACE VIEW vw_delitos_comuna AS
SELECT
    comuna,
    COUNT(*) AS total_delitos,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM delitos_dup2
GROUP BY comuna
ORDER BY total_delitos DESC;

SELECT *
FROM vw_delitos_comuna;

--
CREATE OR REPLACE VIEW vw_uso_arma_comuna AS
SELECT
    comuna,
    COUNT(*) FILTER (WHERE uso_arma = 'SI') AS delitos_con_arma,
    COUNT(*) AS total_delitos,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE uso_arma = 'SI') 
        / COUNT(*), 2
    ) AS porcentaje_arma
FROM delitos_dup2
GROUP BY comuna
ORDER BY porcentaje_arma DESC;

SELECT * FROM vw_uso_arma_comuna;

-- Month over month variation and percentage var.
CREATE OR REPLACE VIEW vw_variacion_mensual AS
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

SELECT * FROM vw_variacion_mensual;