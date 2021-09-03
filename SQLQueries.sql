--DATA CLEANING: Casos

--------------------------------------------------------------------------------
--STANDARIZE DATE FORMAT

--Visualizamos las columnas de la forma que queremos.
SELECT TOP 10 fecha_reporte_web, CONVERT(DATE, fecha_reporte_web), fecha_muerte, CONVERT(DATE, fecha_muerte)
FROM Casos
ORDER BY id_caso

--Convertimos de tipo "datetime" a "date".
ALTER TABLE Casos
ALTER COLUMN fecha_reporte_web DATE;

ALTER TABLE Casos
ALTER COLUMN fecha_muerte DATE;

--Convertimos el resto de columnas tipo datetime (no se utilizarán en el análisis pero servirá para futuros análisis).
ALTER TABLE Casos
ALTER COLUMN fecha_notificacion DATE;

ALTER TABLE Casos
ALTER COLUMN fecha_inicio_sintomas DATE;

ALTER TABLE Casos
ALTER COLUMN fecha_diagnostico DATE;

ALTER TABLE Casos
ALTER COLUMN fecha_recuperacion DATE;


------------------------------------------------------------------------------------
---- CHECKING NULLS:

SELECT * FROM Casos WHERE fecha_diagnostico IS NULL --> Can't analyze all cases by 'fecha_diagnostico' because it has nulls.
SELECT * FROM Casos WHERE fecha_inicio_sintomas IS NULL --> Can't analyze all cases by 'fecha_inicio_sintomas' because it has nulls.
SELECT * FROM Casos WHERE fecha_reporte_web IS NULL
SELECT * FROM Casos WHERE id_caso IS NULL

SELECT COUNT(*) FROM Casos WHERE fecha_inicio_sintomas IS NULL

SELECT COUNT(*) FROM Casos WHERE fecha_diagnostico IS NULL



----------------------------------------------------------------------------------
--CORRECTION OF DATE “1899-12-30” TO NULL
--Corrección de registros que se importaron erróneamente con la fecha de '1899-12-30'. Las Columnas con este error son: fecha_muerte, fecha_recuperación, fecha_inicio_sintomas y fecha_diagnostico.

--Consulta para saber qué columnas tipo "fecha" tienen el error(ejemplo):
SELECT fecha_recuperacion FROM Casos WHERE fecha_recuperacion = '1899-12-30'

SELECT fecha_muerte FROM Casos WHERE fecha_muerte = '1899-12-30'

UPDATE Casos
SET fecha_muerte = NULL
WHERE fecha_muerte = '1899-12-30'

UPDATE Casos
SET fecha_recuperacion = NULL
WHERE fecha_recuperacion = '1899-12-30'

UPDATE Casos
SET fecha_inicio_sintomas = NULL
WHERE fecha_inicio_sintomas = '1899-12-30'

UPDATE Casos
SET fecha_diagnostico = NULL
WHERE fecha_diagnostico = '1899-12-30'




----------------------------------------------------------------------------------
--NAME CORRECTION of DPTOS, MUNICIPIOS AND COUNTRY

--Consulta de los Dptos con errores: 
SELECT DISTINCT(nombre_dpto), codigo_divipola_dpto FROM Casos ORDER BY 1

--Corrección: (Solo un Dpto con error: 'NARIÃ‘O')
UPDATE Casos
SET nombre_dpto = 'NARIÑO'
WHERE nombre_dpto = 'NARIÃ‘O'


--Consulta de los municipios con errores: 
--Se encuentran 15/1118 municipios con error en el nombre. Su correción no es indispensable para continuar con el análisis.
SELECT DISTINCT(nombre_municipio), codigo_divipola_municipio FROM Casos ORDER BY 1 


--Consulta de los paises con errores en nombre y código.
--Se encuentran 20/86 paisess con error en el nombre. Correción no es indispensable en este análisis pero se ejecuta para futuros análisis.
SELECT nombre_pais, codigo_iso_pais, count(nombre_pais) AS cuenta
FROM Casos
GROUP BY nombre_pais, codigo_iso_pais
ORDER BY 1

--Corrección:
UPDATE Casos
SET nombre_pais = 'AFGANISTAN' WHERE nombre_pais = 'AFGANISTÃN'

UPDATE Casos
SET nombre_pais = 'ARABIA SAUDITA' WHERE nombre_pais = 'ARABIA SAUDÃ'

UPDATE Casos
SET nombre_pais = 'BELGICA' WHERE codigo_iso_pais = 56

UPDATE Casos
SET codigo_iso_pais = 76 WHERE nombre_pais = 'BRASIL'

UPDATE Casos
SET nombre_pais = 'CAMERUN' WHERE codigo_iso_pais = 120

UPDATE Casos
SET nombre_pais = 'CANADA' WHERE codigo_iso_pais = 124

UPDATE Casos
SET codigo_iso_pais = 152 WHERE nombre_pais = 'CHILE'

UPDATE Casos
SET codigo_iso_pais = 531 WHERE nombre_pais = 'CURAZAO'

UPDATE Casos
SET codigo_iso_pais = 218 WHERE nombre_pais = 'ECUADOR'

UPDATE Casos
SET nombre_pais = 'ESPAÑA' WHERE nombre_pais = 'ESPAÃ‘A'

UPDATE Casos
SET codigo_iso_pais = 724 WHERE nombre_pais = 'ESPAÑA'

UPDATE Casos
SET nombre_pais = 'ESTADOS UNIDOS DE AMERICA' WHERE nombre_pais = 'ESTADOS UNIDOS DE AMÃ‰RICA'

UPDATE Casos
SET codigo_iso_pais = 840 WHERE nombre_pais = 'ESTADOS UNIDOS DE AMERICA'

UPDATE Casos
SET nombre_pais = 'FEDERACION DE RUSIA' WHERE nombre_pais = 'FEDERACIÃ“N DE RUSIA'

UPDATE Casos
SET codigo_iso_pais = 250 WHERE nombre_pais = 'FRANCIA'

UPDATE Casos
SET nombre_pais = 'ISLAS VIRGENES DE LOS ESTADOS UNIDOS' WHERE nombre_pais = 'ISLAS VÃRGENES DE LOS ESTADOS UNIDOS'

UPDATE Casos
SET nombre_pais = 'MEXICO' WHERE nombre_pais = 'MÃ‰XICO'

UPDATE Casos
SET nombre_pais = 'PAISES BAJOS' WHERE nombre_pais = 'PAÃSES BAJOS'

UPDATE Casos
SET codigo_iso_pais = 528 WHERE nombre_pais = 'PAISES BAJOS'

UPDATE Casos
SET nombre_pais = 'PANAMA' WHERE nombre_pais = 'PANAMÃ'

UPDATE Casos
SET codigo_iso_pais = 591 WHERE nombre_pais = 'PANAMA'

UPDATE Casos
SET nombre_pais = 'PERU' WHERE codigo_iso_pais IN (604,1589)

UPDATE Casos
SET codigo_iso_pais = 604 WHERE nombre_pais = 'PERU'

UPDATE Casos
SET nombre_pais = 'REINO UNIDO' WHERE codigo_iso_pais = 826

UPDATE Casos
SET codigo_iso_pais = 380 WHERE nombre_pais = 'ITALIA'

UPDATE Casos
SET nombre_pais = 'REPUBLICA ARABE SIRIA' WHERE codigo_iso_pais = 760

UPDATE Casos
SET nombre_pais = 'REPUBLICA CENTROAFRICANA' WHERE codigo_iso_pais = 140

UPDATE Casos
SET nombre_pais = 'REPUBLICA DE COREA' WHERE codigo_iso_pais = 410

UPDATE Casos
SET nombre_pais = 'REPUBLICA DOMINICANA' WHERE codigo_iso_pais = 214

UPDATE Casos
SET nombre_pais = 'SAN BARTOLOME' WHERE codigo_iso_pais = 652

UPDATE Casos
SET nombre_pais = 'TURQUIA' WHERE nombre_pais = 'TURQUÃA'

UPDATE Casos
SET nombre_pais = 'VENEZUELA' WHERE nombre_pais = 'VENEUELA'



-------------------------------------------------------------------------------------
--RENAMING COLUMNS "estado" AND "recuperado"

--Renombrando "estado" por "severidad".
EXEC SP_RENAME 'Casos.estado', 'severidad', 'COLUMN';


--Renombrando "recuperado" por "estado".
EXEC SP_RENAME 'Casos.recuperado', 'estado', 'COLUMN';




-------------------------------------------------------------------------------------
--RETRIEVING CLEANED DATA SET

--Traemos solo las columnas necesarias para el análisis.
SELECT TOP 5 fecha_reporte_web, id_caso, edad, unidad_medida_edad, sexo, estado, fecha_muerte
FROM Casos
ORDER BY fecha_reporte_web




-------------------------------------------------------------------------------------
--DATA CLEANING: Vaccinations

SELECT TOP 10 * FROM Vaccinations

--Convertimos de tipo "datetime" a "date".
ALTER TABLE Vaccinations
ALTER COLUMN [date] DATE;


--Retrieving Vaccination Data concerning Colombia
SELECT * FROM Vaccinations WHERE location = 'Colombia'




---------------------------------------------------------------------------------------
--EXPLORATORY ANALYSIS AND TABLE LAYOUT FOR VISUALIZATIONS

--0.agrupación de casos por estado: activos, fallecidos, recuperados, fallecidos no covid.
--0.1.Exploración sobre la vacunación
--1.Categorización y Creación de la view de la tabla Casos agregando la categoria grupo_etario (CASE y CREATE VIEW)

--3.1.agrupación de fallecimientos por grupo etario y sexo (GROUP BY)
--3.2.agrupación de casos por grupo etario y sexo (GROUP BY)
--4.1.unión de las dos agrupaciones por grupo etario y sexo (CTE y JOIN)
--4.2.creación de la view de Casos y Muertes por Grupo Etario y Sexo
--5.1.Calculando letalidad por grupo etario y sexo:
--5.2.Calculando letalidad solo por grupo etario (HACER VISUALIZACIÓN Y VIEW)
--5.3.Creación de la VIEW de Letalidad por Grupo Etario
--6.1.Tabla de casos por grupo etario mes a mes
--6.2.Tabla de fallecidos por grupo etario mes a mes
--6.3.Creando la VIEW de la agrupacion de los casos y fallecimientos mes a mes
--7.0. Agrupando por mes para sacar la letalidad general mes a mes:
--7.1.Tabla de calculo de letalidad de cada grupo etario mes a mes (HACER ViEW)
--7.2.Creando la view especial de letalidad por grupo etario mes a mes
--7.3.Filtrando por un solo grupo etario:

--5.Calculando letalidad por grupo etario y sexo
--5.agrupación por mes y año

--0.Agrupación de casos por estado: activos, fallecidos, recuperados, fallecidos no covid:
SELECT estado, COUNT(estado) AS cantidad
FROM Casos
GROUP BY estado
ORDER BY cantidad



--0.1 Exporación sobre la vacunación
SELECT COUNT(*) FROM Vaccinations WHERE location = 'Colombia'

--0.2 Cuando empezó la vacunación
SELECT MIN([date]) as vac_start_date FROM Vaccinations WHERE location = 'Colombia'

--0.3 Cuantas dosis se han administrado hasta la fecha
SELECT MAX(total_vaccinations) as total_vaccinations FROM Vaccinations WHERE location = 'Colombia'

--0.4 Cuantas personas tienen el esquema completo hasta la fecha
SELECT MAX(people_fully_vaccinated) as people_fully_vaccinated FROM Vaccinations WHERE location = 'Colombia'



--1.Categorización y Creación de la view de la tabla Casos agregando la categoria grupo_etario
--DROP VIEW IF EXISTS Casos_con_grupo_etario
--CREATE VIEW Casos_con_grupo_etario AS
SELECT fecha_reporte_web, id_caso, edad, unidad_medida_edad, sexo, estado, fecha_muerte,
CASE
 WHEN unidad_medida_edad = 1 THEN
   CASE
     WHEN edad <= 4 THEN '0 - 04'
     WHEN edad <= 9 THEN '05 - 09'
     WHEN edad <= 19 THEN '10 - 19'
     WHEN edad <= 29 THEN '20 - 29'
     WHEN edad <= 39 THEN '30 - 39'
	 WHEN edad <= 49 THEN '40 - 49'
	 WHEN edad <= 59 THEN '50 - 59'
	 WHEN edad <= 69 THEN '60 - 69'
	 WHEN edad <= 79 THEN '70 - 79'
	 ELSE '80 o más'
   END
 ELSE '0 - 04'
END AS grupo_etario
FROM Casos;

--Chequeando la view
SELECT TOP 100 * FROM Casos_con_grupo_etario ORDER BY fecha_reporte_web


--3.1.agrupación de fallecimientos por grupo etario y sexo (GROUP BY)
SELECT grupo_etario, sexo, COUNT(grupo_etario) AS fallecidos
FROM Casos_con_grupo_etario
GROUP BY grupo_etario, sexo, estado
HAVING estado = 'Fallecido'
ORDER BY grupo_etario

--3.2.agrupación de casos por grupo etario y sexo (GROUP BY)
SELECT grupo_etario, sexo, COUNT(grupo_etario) AS casos
FROM Casos_con_grupo_etario
GROUP BY grupo_etario, sexo
ORDER BY grupo_etario



--4.1.unión de las dos agrupaciones DE casos y muertes por grupo etario y sexo (CTE y JOIN)
WITH CTE1_muertes (grupo_etario, sexo, fallecidos) AS (
        SELECT grupo_etario, sexo, COUNT(grupo_etario) AS fallecidos
        FROM Casos_con_grupo_etario
        GROUP BY grupo_etario, sexo, estado
        HAVING estado = 'Fallecido'
        ),
    CTE2_casos (grupo_etario, sexo, casos) AS (
        SELECT grupo_etario, sexo, COUNT(grupo_etario) AS casos
        FROM Casos_con_grupo_etario
        GROUP BY grupo_etario, sexo
        )
SELECT m.grupo_etario, m.sexo, fallecidos, casos
FROM CTE1_muertes m
JOIN CTE2_casos c ON m.grupo_etario = c.grupo_etario AND m.sexo = c.sexo
ORDER BY m.grupo_etario


--4.2.creación de la view de Casos y Muertes por Grupo Etario y Sexo
--DROP VIEW IF EXISTS agrupacion_por_grupoetario_y_sexo
CREATE VIEW agrupacion_por_grupoetario_y_sexo AS
WITH CTE1_muertes (grupo_etario, sexo, fallecidos) AS (
        SELECT grupo_etario, sexo, COUNT(grupo_etario) AS fallecidos
        FROM Casos_con_grupo_etario
        GROUP BY grupo_etario, sexo, estado
        HAVING estado = 'Fallecido'
        ),
    CTE2_casos (grupo_etario, sexo, casos) AS (
        SELECT grupo_etario, sexo, COUNT(grupo_etario) AS casos
        FROM Casos_con_grupo_etario
        GROUP BY grupo_etario, sexo
        )
SELECT m.grupo_etario, m.sexo, fallecidos, casos
FROM CTE1_muertes m
JOIN CTE2_casos c ON m.grupo_etario = c.grupo_etario AND m.sexo = c.sexo
--ORDER BY m.grupo_etario

--Chequeando la view
SELECT * FROM agrupacion_por_grupoetario_y_sexo ORDER BY grupo_etario



--5.1.Calculando letalidad por grupo etario y sexo: Se observa que dentro de cada grupo etario el género con mayor tasa de latilidad es el Masculino, teniendo un mayor riesgo de fallecimiento si contraen la enfermedad.
SELECT *, ROUND((CONVERT(FLOAT, fallecidos)/CONVERT(FLOAT, casos))*100,2) AS letalidad
FROM agrupacion_por_grupoetario_y_sexo
ORDER BY grupo_etario;

      --¿Cual es es el segmento de la población (grupo etario y sexo) con una mayor tasa de latalidad?
      WITH CTE1_letalidad (grupo_etario, sexo, fallecidos, casos, letalidad) AS (
        SELECT *, ROUND((CONVERT(FLOAT, fallecidos)/CONVERT(FLOAT, casos))*100,2) AS letalidad
        FROM agrupacion_por_grupoetario_y_sexo
        )
      SELECT * 
      FROM CTE1_letalidad
      WHERE letalidad = (SELECT MAX(letalidad) FROM CTE1_letalidad)

--5.2.Calculando letalidad solo por grupo etario (HACER VISUALIZACIÓN Y VIEW)
SELECT grupo_etario, SUM(fallecidos) AS fallecidos, SUM(casos) AS casos, ROUND((CONVERT(FLOAT, SUM(fallecidos))/CONVERT(FLOAT,SUM(casos)))*100,2) AS letalidad
FROM agrupacion_por_grupoetario_y_sexo
GROUP BY grupo_etario
ORDER BY grupo_etario

--5.3.Creación de la VIEW de Letalidad por Grupo Etario
CREATE VIEW letalidad_por_grupoetario AS
SELECT grupo_etario, SUM(fallecidos) AS fallecidos, SUM(casos) AS casos, ROUND((CONVERT(FLOAT, SUM(fallecidos))/CONVERT(FLOAT,SUM(casos)))*100,2) AS letalidad
FROM agrupacion_por_grupoetario_y_sexo
GROUP BY grupo_etario;

      --¿Cual es el grupo etario con una MAYOR tasa de latalidad?
      SELECT * FROM letalidad_por_grupoetario
      WHERE letalidad = (SELECT MAX(letalidad) FROM letalidad_por_grupoetario);

      --¿Cual es el grupo etario con una MENOR tasa de latalidad?
      SELECT * FROM letalidad_por_grupoetario
      WHERE letalidad = (SELECT MIN(letalidad) FROM letalidad_por_grupoetario);



--6.1.Tabla de casos por grupo etario mes a mes
SELECT YEAR(fecha_reporte_web) AS año, MONTH(fecha_reporte_web) AS mes, CONCAT(YEAR(fecha_reporte_web),'-', MONTH(fecha_reporte_web)) AS año_mes, grupo_etario, COUNT(fecha_reporte_web) AS casos
FROM Casos_con_grupo_etario
GROUP BY YEAR(fecha_reporte_web), MONTH(fecha_reporte_web), grupo_etario
ORDER BY YEAR(fecha_reporte_web), MONTH(fecha_reporte_web), grupo_etario


--6.2.Tabla de fallecidos por grupo etario mes a mes
SELECT CONCAT(YEAR(fecha_muerte),'-', MONTH(fecha_muerte)) AS año_mes, grupo_etario, COUNT(fecha_muerte) AS fallecidos
FROM Casos_con_grupo_etario
GROUP BY YEAR(fecha_muerte), MONTH(fecha_muerte), grupo_etario, estado
HAVING estado = 'Fallecido'
ORDER BY YEAR(fecha_muerte), MONTH(fecha_muerte), grupo_etario


--6.3.Creando la VIEW de la agrupacion de los casos y fallecimientos mes a mes
CREATE VIEW agrupacion_por_mes_y_grupoetario AS
WITH CTE3_casos (año, mes, grupo_etario, casos) AS (
      SELECT YEAR(fecha_reporte_web) AS año, MONTH(fecha_reporte_web) AS mes, grupo_etario, COUNT(fecha_reporte_web) AS casos
      FROM Casos_con_grupo_etario
      GROUP BY YEAR(fecha_reporte_web), MONTH(fecha_reporte_web), grupo_etario
      ),
    CTE4_muertes (año, mes, grupo_etario, fallecidos) AS (
      SELECT YEAR(fecha_muerte) AS año, MONTH(fecha_muerte) AS mes, grupo_etario, COUNT(fecha_muerte) AS fallecidos
      FROM Casos_con_grupo_etario
      GROUP BY YEAR(fecha_muerte), MONTH(fecha_muerte), grupo_etario, estado
      HAVING estado = 'Fallecido'
      )
SELECT c.año, c.mes, c.grupo_etario, fallecidos, casos
FROM CTE3_casos c
LEFT JOIN CTE4_muertes m ON c.año = m.año AND c.mes = m.mes AND c.grupo_etario = m.grupo_etario
--ORDER BY c.año, c.mes, c.grupo_etario;


--7.0. Agrupando por mes para sacar la letalidad general mes a mes:
SELECT CONCAT(año,'-', mes) AS año_mes, SUM(fallecidos) AS fallecidos, SUM(casos) AS casos, ROUND((CONVERT(FLOAT, SUM(fallecidos))/CONVERT(FLOAT,SUM(casos)))*100,2) AS letalidad
FROM agrupacion_por_mes_y_grupoetario
GROUP BY año, mes
ORDER BY año, mes


--7.1.Tabla de calculo de letalidad de cada grupo etario mes a mes (HACER ViEW)
SELECT CONCAT(año,'-', mes) AS año_mes, grupo_etario, fallecidos, casos, ROUND((CONVERT(FLOAT, fallecidos)/CONVERT(FLOAT,casos))*100,2) AS letalidad
FROM agrupacion_por_mes_y_grupoetario
ORDER BY año, mes, grupo_etario


--7.2.Hacerle una view especial letalidad por grupo etario mes a mes
CREATE VIEW letalidad_por_grupoetario_por_mes AS
SELECT año, mes, CONCAT(año,'-', mes) AS año_mes, grupo_etario, fallecidos, casos, ROUND((CONVERT(FLOAT, fallecidos)/CONVERT(FLOAT,casos))*100,2) AS letalidad
FROM agrupacion_por_mes_y_grupoetario
--ORDER BY año, mes, grupo_etario


--7.3.Filtrando por un solo grupo etario:
SELECT año_mes, casos, fallecidos, grupo_etario, letalidad
FROM letalidad_por_grupoetario_por_mes
WHERE grupo_etario = '70 - 79'
ORDER BY año, mes, grupo_etario



--8.1 Fallecidos mes a mes
--SELECT YEAR(fecha_muerte) AS año, MONTH(fecha_muerte) AS mes, COUNT(fecha_muerte) AS fallecidos
--FROM Casos
--GROUP BY MONTH(fecha_muerte), YEAR(fecha_muerte), estado
--HAVING estado = 'Fallecido'
--ORDER BY año, mes;

--8.2 Casos mes a mes
--SELECT YEAR(fecha_reporte_web) AS año, MONTH(fecha_reporte_web) AS mes, COUNT(fecha_reporte_web) AS casos
--FROM Casos
--GROUP BY MONTH(fecha_reporte_web), YEAR(fecha_reporte_web)
----HAVING estado = 'Fallecido'
--ORDER BY año, mes;


--9.Tabla de fallecidos  dia a día
--SELECT fecha_muerte, COUNT(fecha_muerte) AS fallecimientos
--FROM Casos
--GROUP BY fecha_muerte, estado
--HAVING fecha_muerte > '2020-12-31' AND estado = 'Fallecido'
--ORDER BY fecha_muerte



--**************************************************************************************
--**************************************************************************************