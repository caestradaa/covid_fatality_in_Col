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
<!--- - What proportion of the total population and infected population has died from Covid-19?
- How many vaccine doses have been administered to date? How many people have received at least one dose? How many are fully vaccinated?-->
- How has the Covid-19 fatality rate evolved from the start of the pandemic until today?
- Is there a change in trend at any point after the start of vaccination? In general, by age group and by gender.
- Which age group already vaccinated has had a better response to vaccines?
- Is there any relationship between the number of people vaccinated and the evolution of the fatality rate?
- According to the current vaccination rate, when would 70% of the population be fully vaccinated?



## Data Collection
All the data required for this project was searched from multiple sources on the web, from official government websites to the repositories of recognized organizations for data collection and analysis.
1. "Cases": Official data of positive cases of Covid-19 in Colombia (until July 14, 2021), extracted in a CSV file from the official repository of the National Institute of Health. 23 columns and 4.565.372 records. It is updated daily with the new registered cases. [INS Cases dataset](https://www.datos.gov.co/Salud-y-Protecci-n-Social/Casos-positivos-de-COVID-19-en-Colombia/gt2j-8ykr "Casos positivos de COVID19 en Colombia").
2. "Vaccinations": Data corresponding to daily vaccination in Colombia (until July 15, 2021), extracted in a CSV file from the Our World On Data repository compilated from official sources. 12 columns and 33.672 rows. [Vaccinations dataset](https://github.com/owid/covid-19-data/tree/master/public/data/vaccinations "Vacunación").

#### Loading raw datasets:
The two datasets were loaded to a database called "CovidColombia" created on a local server using Microsoft SQL Server. Two tables were created: "Casos" and "Vacunación", corresponding to each CSV file. As shown above, erroneous data was written in the null records of date fields. Those bugs were fixed in the data cleaning.

![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Raw_dataset_preview_Casos_Data_errors.png "Raw data preview")



## Data Cleaning
Cleaning of both datasets was done with SQL in SQL Server Management Studio. All performed procedures are documented in the attached .SQL file (link). The following transformations were performed:  <!---[I'm a relative reference to a repository file](../blob/master/LICENSE)-->
#### 1. Cases:
- Conversion of date format "datetime" to "date" in all date type columns.
- Replacement of record "1899-12-30 00: 00: 00.000" by null records (date records that were originally null in the csv were wrongly imported as "1899-12-30 00: 00: 00.000").
- Change of column name from `estado` to `severidad`, as it better explains the content of the column: the degree of severity of each case.
- Change of column name from `recuperado` by `estado`, as it better explains the content of the column: the current status of the case.
- *Correction of the names of municipalities, departments and countries with wrong characters. ISO code was corrected too.  
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
- `Fecha_reporte_web`: date the case was reported.
- `id_de_caso`: unique id of the case.
- `edad`: age of person with positive diagnosis.
- `unidad_de_medida_edad`: unit of measure of the person's age. (1) year, (2) months, (3) days.
- `sexo`: male (M) or female (F) gender.
- `estado`: the current status of the case. It can be Active (Activo), Recovered (Recuperado), Death (Fallecido) or N/A. N/A refers to the non-COVID deceased.
- `fecha_de_muerte`: declared date of death.

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
Exploratory analisys was carried out by making SQL queries to the database (via %sql magic) from a Jupyter notebook, as well as some calculations and visualizations with Python. This readme file presents the summary of the analysis results, full code and details can be found in the Jupyter notebook.

#### Considerations:
- Fatality rate: proportion of deaths compared to the total number of people diagnosed.
- Mortality rate: proportion of deaths per unit of population (100,000 generally used).
- The total population estimate of Colombia (50.339.000 habitants) is based on the last revision of the United Nations World Population Prospects. 
- Age group: group made up of people of the same or similar age. Cases were classified into 10 age groups.

#### Total Cases and Proportion of the population infected:
```python
r0 = %sql SELECT COUNT(*) FROM Casos
total_cases = r0[0][0]
```
```python
total_pop = 50339000
prop_pop_inf = round((total_cases/total_pop)*100,2)
print('Total cases reported to date =',total_cases)
print('Proportion of the population infected =',prop_pop_inf, '%')
```
> Total cases reported to date = 4.565.372  
> Proportion of the population infected = 9.07 %  

## Distribution analysis: 
#### Cases by status:  
```python
r1 = %sql SELECT estado, COUNT(estado) AS cantidad FROM Casos GROUP BY estado ORDER BY cantidad
df_r1 = r1.DataFrame()
df_r1['porcentaje'] = round((df_r1['cantidad']/total_cases)*100,2)
df_r1
```
<!---
| estado      | cantidad   | porcentaje  |
| ----------- |:----------:| -----------:|
| N/A         | 12926      | 0.28        |
| Fallecido   | 114337     | 2.50        |
| Activo      | 120673     | 2.64        |
| Recuperado  | 4317436    | 94.57       |-->

![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Cases_by_status_with_proportion.PNG "Cases by status") 

```python
r3 = %sql SELECT COUNT(estado) FROM Casos WHERE estado = 'Fallecido'
total_deaths = r3[0][0]
gen_mortality = (total_deaths*100000/total_pop)
gen_fatality = (total_deaths/total_cases)*100

print('Total deaths =', total_deaths)
print('General Mortality rate =', round(gen_mortality,2), 'per 100,000 inhabitants')
print('General Fatality rate =', round(gen_fatality,3), '%')
```  
> Total deaths = 114.337  
> General Mortality rate = 227.13 per 100,000 inhabitants  
> General Fatality rate = 2.50%  
> 94.57% of infected people have recovered from Covid-19.

#### Cases, deaths and fatality rate by gender:  
Retrieving the number of cases and deaths by gendedr, calculating fatality rate and settina a dataframe with the results:  
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Cases_deaths_fatality_by_gender.png "Cases_deaths_fatality_by_gender")  
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Cases_deaths_fatality_by_gender_piechart.png "Deaths_by_gender_piechart")
> The proportion of infected people is similar in both sexes, however, the fatality rate is much higher in men (3.23%) than in women (1.85%).  
> According to the pie chart almost two-thirds (2/3) two-thirds of the deceased are men.  
> 38.67% of the total deaths have been women and 61.33% have been men.  

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
