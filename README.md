# Project: Effect of Vaccines on Covid-19 fatality in Colombia (currently working on it)
*Data analysis project about the effect of vaccines on covid-19 fatality in Colombia.*

## Overview
- A data analysis on Covid-19 in Colombia was made in order to understand the effects that mass vaccination is having on the fatality rate, and determine if there really is a positive impact on vaccinated population.
- Two datasets were used: Covid-19 positive cases data in Colombia extracted from the oficial repository of the National Institute of Health (4.5M rows up to July 14, 2021), and Vaccination data extracted from the official Our World in Data repository (127 rows).
- Project tools: SQL Server and ADS for loading and cleaning data. SQL and Python for exploratory analysis on a Jupyter notebook via %sql magic (ipython-sql).
- It was found that during the first 3 months after the start of vaccination, there is no significant change in the fatality rate, however, from 06-2021 there is a notable decrease. In people older than 70 years fatality rate has decreased on average by 21.25%. <!---In the age group from 70 to 79 fatality rate has decreased by 25.27%.-->

## Problem statement
This project seeks to have a deeper knowledge of the behaviour of the pandemic in Colombia and to know specifically if the vaccination process is being effective or not. If it is, to what extent, and also, what is the trend in the future according to the rate of vaccination and the rate of infections.
<!---This pandemic has put us to the test as humanity, exposing the fragility of our economic systems, however, it has also been a trigger to reflect on our consumer lifestyle and accelerate the transformation towards new, more sustainable production models.-->

#### Some questions to answer:
- What proportion of the total population and infected population has died from Covid-19?
- How many vaccine doses have been administered to date? How many people have received at least one dose? How many are fully vaccinated?
- How has the Covid-19 fatality rate evolved from the start of the pandemic until today?
- Is there a change in trend at any point after the start of vaccination? In general, by age group and by gender.
- Which age group already vaccinated has had a better response to vaccines?
- Is there any relationship between the number of people vaccinated and the evolution of the fatality rate?
- According to the current vaccination rate, when would 70% of the population be fully vaccinated?


## Data Collection
All the data required for this project was searched from multiple sources on the web, from official government websites to the repositories of recognized organizations for data collection and analysis.
1. Cases: Official data of positive cases of Covid-19 in Colombia (until July 14, 2021), extracted in a CSV file from the official repository of the National Institute of Health. This dataset contains all the information corresponding to cases with a positive diagnosis of Covid-19 and deaths with a total of 23 columns and 4.565.372 records. It is updated daily with the new registered cases. https://www.datos.gov.co/Salud-y-Protecci-n-Social/Casos-positivos-de-COVID-19-en-Colombia/gt2j-8ykr
2. Vaccination: Data corresponding to daily vaccination in Colombia (until July 15, 2021), extracted in a CSV file from the Our World On Data repository. It has 12 columns and 33.672 rows that corresponds to the daily compilation of vaccination data that OWOD does from official sources. https://github.com/owid/covid-19-data/tree/master/public/data/vaccinations.

#### Loading raw datasets:
<!---
```
  Dataset      Columns       Rows
1.Casos          23        4.565.372
2.Vacunación     12         33.672
```
-->
The two datasets were loaded to a database called "CovidColombia" created on a local server using Microsoft SQL Server. Two tables were created: "Cases" and "Vaccinations", corresponding to each CSV file. As shown above, there were inconsistencies in the transformation of the data types and erroneous data was written in the null records of date fields. That and other bugs were fixed in data cleaning.

![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Raw_dataset_preview_Casos_Data_errors.png "Raw data preview")



## Data Cleaning
Cleaning of both datasets was done with SQL in SQL Server Management Studio. All performed procedures are documented in the attached .SQL file (link). The following transformations were performed:
#### 1. Cases:
- Conversion of date format "datetime" to "date" in all date type columns.
- Replacement of record "1899-12-30 00: 00: 00.000" by null records (date records that were originally null in the csv were wrongly imported as "1899-12-30 00: 00: 00.000").
- Change of column name from `estado` to `severidad`, as it better explains the content of the column: the degree of severity of each case.
- Change of column name from `recuperado` by `estado`, as it better explains the content of the column: the current status of the case.
- *Correction of the names of municipalities and departments with wrong characters.
- *Correction of the names and ISO code of countrie wrong characterss: accents, letter ñ and misspelled.
 
 **<font size="0.5">Not necessary for this analysis but for future ones.</font>*

Some procedures executed:
```sql
--STANDARIZE DATE FORMAT: Converting "datetime" to "date".
SELECT TOP 10 fecha_reporte_web, CONVERT(DATE, fecha_reporte_web), fecha_muerte, CONVERT(DATE, fecha_muerte)
FROM Casos
ORDER BY id_caso;

ALTER TABLE Casos
ALTER COLUMN fecha_reporte_web DATE;

ALTER TABLE Casos
ALTER COLUMN fecha_muerte DATE;

--CORRECTION OF DATE “1899-12-30” TO NULL: Correction of records that were wrongly imported with the date of '1899-12-30'.
SELECT fecha_muerte FROM Casos WHERE fecha_muerte = '1899-12-30';

UPDATE Casos
SET fecha_muerte = NULL
WHERE fecha_muerte = '1899-12-30';

--RENAMING COLUMNS: "recuperado" for "estado".
EXEC SP_RENAME 'Casos.recuperado', 'estado', 'COLUMN';

```
Finally retrieving only the columns that interest to this analysis in the notebook:

```sql
SELECT TOP 5 fecha_reporte_web, id_caso, edad, unidad_medida_edad, sexo, estado, fecha_muerte
FROM Casos
ORDER BY fecha_reporte_web
```

![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Clean_dataset_preview_Casos_azure.png "Clean data preview")

Column explanation:
- `Fecha_reporte_web`: date the case was reported
- `id_de_caso`: unique id of the case
- `edad`: age of person with positive diagnosis
- `unidad_de_medida_edad`: unit of measure of the person's age. (1) year, (2) months, (3) days.
- `sexo`: male (M) or female (F) gender.
- `estado`: the current status of the case. It can be Active (Activo), Recovered (Recuperado), Death (Fallecido) or N/A. N/A refers to the non-COVID deceased.
- `fecha_de_muerte`: Declared date of death.

#### 2. Vaccinations:
- Retrieving data concerning Colombia.
```sql
SELECT *
FROM Vaccinations
WHERE location = 'Colombia'
ORDER BY fecha
```

![alt text]( "")




## Exploratory Data Analysis (EDA)
- 4M records, 10 age groups, 2 geners were analized.

### Considerations/Calculations and Explanations
- Fatality rate: proportion of deaths compared to the total number of people diagnosed.
- Mortality rate: proportion of deaths per unit of population (100,000 generally used)
- Age group:
- The population estimate used to calculate proportions metrics is based on the last revision of the United Nations World Population Prospects. The exact values can be viewed here. 

![alt text]( "Count")

## Distribution analysis: 

![alt text]( "")
![alt text]( "")

## Correlation analysis

![alt text]( "")
![alt text]( "")




## Specific Analysis

### First analysis

![alt text]( "")
![alt text]( "")

### Second analysis

![alt text]( "")
![alt text]( "")




## Conclusions
- 1
- 2
- 3
- 4 

`para inline code`

```
para bloque
de codigo
```

```python
for i in range(0,6):
  if i :
```



<!---Para ocultar-->
