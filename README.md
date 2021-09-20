# Project: Effect of Vaccines on Covid-19 fatality rate in Colombia
*Data analysis project about the effect of vaccines on covid-19 fatality in Colombia.*


## Overview
- A data analysis on Covid-19 in Colombia was made in order to understand the effects that mass vaccination is having on the fatality rate, and determine if there really is a positive impact on vaccinated population.
- Two datasets were used: Covid-19 positive cases data in Colombia extracted from the oficial repository of the National Institute of Health (4.9M rows up to Sep 14, 2021), and Vaccination data extracted from the official Our World in Data repository (208 rows).
- Project tools: SQL Server for loading and cleaning data: **[SQL file][sqlfile]**. SQL and Python for exploratory and explanatory analysis on a **[Jupyter notebook][notebook]** via %sql magic.
- It was found that during the first six months after the start of vaccination, there has only been a slight decrease in the fatality rate. The change has been slow and only begins to be noticeable after the seventh month (09-2021). In the last two months fatality rate has decreased on average by 28%. <!---In people over 70 years old, fatality rate has decreased on average by 21.25%. In the age group from 70 to 79 fatality rate has decreased by 25.27%.-->



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
<!---- According to the current vaccination rate, when would 70% of the population be fully vaccinated?-->



## Data Collection
All the data required for this project was searched from multiple sources on the web, from official government websites to the repositories of recognized organizations for data collection and analysis.
1. **"Cases"**: Official data of positive cases of Covid-19 in Colombia (until July 14, 2021), extracted in a CSV file from the official repository of the National Institute of Health. 23 columns and 4.565.372 records. It is updated daily with the new registered cases. [INS Cases dataset](https://www.datos.gov.co/Salud-y-Protecci-n-Social/Casos-positivos-de-COVID-19-en-Colombia/gt2j-8ykr "Casos positivos de COVID19 en Colombia").
2. **"Vaccinations"**: Data corresponding to daily vaccination in Colombia (until July 15, 2021), extracted in a CSV file from the Our World On Data repository compilated from official sources. 12 columns and 33.672 rows. [Vaccinations dataset](https://github.com/owid/covid-19-data/tree/master/public/data/vaccinations "Vacunación").

**Loading raw datasets:** The two datasets were loaded to a database called "CovidColombia" created on a local server using Microsoft SQL Server. Two tables were created: `Casos` and `Vacunación`, corresponding to each CSV file. As shown above, erroneous data was written in the null records of date fields. Those bugs were fixed in the data cleaning.

![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Raw_dataset_preview_Casos_errors.png "Raw data preview")




## Data Cleaning
Cleaning of both datasets was done with SQL in SQL Server Management Studio. All performed procedures are documented in the attached **[.SQL file][sqlfile]**. The following transformations were performed:
#### 1. Cases:
- Conversion of date format "datetime" to "date" in all date type columns.
- Replacement of record "1899-12-30 00: 00: 00.000" by null records (date records that were originally null in the csv were wrongly imported as "1899-12-30 00: 00: 00.000").
- Change column name from `estado` to `severidad`, as it better explains the content of the field: the degree of severity of each case.
- Change column name from `recuperado` by `estado`, as it better explains the content of the column: the current status of the case.
- *Correction of the names of municipalities, departments and countries with wrong characters. ISO code was corrected too. **<font size="0.5">Not necessary for this analysis but for future ones.</font>*

Some cleaning procedures executed:
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
Finally after cleanig, we retrieve only the columns that interest to this analysis:

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
- Convert "datetime" type to "date" type.
- Retrieving data concerning Colombia.
```sql
SELECT * FROM Vaccinations WHERE location = 'Colombia' ORDER BY fecha
```  

<!---![alt text]( "") -->




## Exploratory Data Analysis (EDA)
Exploratory analisys was carried out by making SQL queries to the database (via %sql magic) from a Jupyter notebook, as well as some calculations and visualizations with Python. This readme file presents the summary of the analysis results, **full code and details can be found in the [Jupyter notebook][notebook]**. Considerations:
- Fatality rate: proportion of deaths compared to the total number of people diagnosed.
- Mortality rate: proportion of deaths per unit of population (100,000 generally used).
- The total population estimate of Colombia (50.339.000 habitants) is based on the last revision of the United Nations World Population Prospects.
- Age group: group made up of people of the same or similar age. Cases were classified into 10 age groups.

### Total Cases and Proportion of the population infected:
```python
r0 = %sql SELECT COUNT(*) FROM Casos
total_cases = r0[0][0]

total_pop = 50339000
prop_pop_inf = round((total_cases/total_pop)*100,2)
print('Total cases reported to date =',total_cases)
print('Proportion of the population infected =',prop_pop_inf, '%')
```
- Total cases reported to date = 4.565.372  
- Proportion of the population infected = 9.07 %  


### Cases by status:  
Retrieving the number of cases by status and calculating the proportion from total cases:  

![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Cases_by_status_with_proportion.PNG "Cases by status") 

```python
r2 = %sql SELECT COUNT(estado) FROM Casos WHERE estado = 'Fallecido'
total_deaths = r2[0][0]
gen_mortality = (total_deaths*100000/total_pop)
gen_fatality = (total_deaths/total_cases)*100

print('Total deaths =', total_deaths)
print('General Mortality rate =', round(gen_mortality,2), 'per 100,000 inhabitants')
print('General Fatality rate =', round(gen_fatality,3), '%')
```  
- Total deaths = 114.337  
- General Mortality rate = 227.13 per 100,000 inhabitants  
- General Fatality rate = 2.50%  
- 94.57% of infected people have recovered from Covid-19.


### Cases, deaths and fatality rate by gender:  
Retrieving the number of cases and deaths by gender, calculating fatality rate and setting a dataframe with the results:  

![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Cases_deaths_fatalityrate_by_gender.png "Cases_deaths_fatality_by_gender")  
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Cases_deaths_fatality_by_gender_piechart.png "Deaths_by_gender_piechart")  
- The proportion of infected people is similar in both genders, however, the fatality rate is much higher in men (3.23%) than in women (1.85%). This means men are 42% more likely to die than women if they contract the virus.  
- 38.67% of the total deaths have been women and 61.33% have been men.  
- According to the pie chart almost two-thirds (2/3) of the deceased are men.   




## Explanatory Analysis
### Categorization of Cases by Age Group:
In order to calculate the fatality rate of each group we created a SQL View called `Casos_con_grupo_etario` from the main dataset `Casos`.
```python
%%sql
CREATE VIEW Casos_con_grupo_etario AS
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
```

Once the main view is created `Casos_con_grupo_etario`, we make a series of groupings by age group, gender and month using CTEs and Joins. We obtain several result sets that we save in different SQL Views:
- `agrupacion_por_grupoetario_y_sexo`: number of cases and deaths by **age group** and **gender**.
- `letalidad_por_grupoetario`: number of cases, deaths and fatality rate just by **age group**.
- `agrupacion_por_mes_y_grupoetario`: number of cases and deaths by **month** and **age group**.
- `letalidad_por_grupoetario_por_mes`: number of cases, deaths and fatality Rate by **month** and **age group**.

From the view `agrupacion_por_grupoetario_y_sexo`, we calculate fatality rate for each age group and gender and retrive the segment of the population with the highest fatality rate:  

![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Segment_highes_%20fatality_rate.png "segment with the highest fatality rate")

Calculating **fatality rate** by age group:
```python
%%sql
--CREATE VIEW letalidad_por_grupoetario AS
SELECT grupo_etario, SUM(fallecidos) AS fallecidos, SUM(casos) AS casos, ROUND((CONVERT(FLOAT, SUM(fallecidos))/CONVERT(FLOAT,SUM(casos)))*100,2) AS letalidad
FROM agrupacion_por_grupoetario_y_sexo
GROUP BY grupo_etario;
```  
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Fatality_rate_by_age_group.png "Fatality_rate_by_age_group")
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Cases_by_agegroup_barchart.png "Cases_by_age_group")
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Deaths_by_agegroup_barchart.png "Deaths_by_age_group")  
- The age groups with the highest fatality rate are the more advance ones: `60 - 69`, `70 - 79` and `80 o más` with 7.2%, 15.4% and 26.7% respectively.  
- The fatality rate of these groups is quite high compared with the general rate that is 2.50%.
- It is shown that we cannot use the general fatality rate as a comparable measure for all age groups.


### Effect of vaccines on Fatality Rate
Here we study how the fatality rate of each age group has evolved from month to month. We focused on comparing the behavior of this measure before and after the start of vaccination in February 2021, looking for any positive effect on each age group.

First we group cases and deaths by **month** and **age group** using CTEs statements and then joining the results in one table.
```python
%%sql
--CREATE VIEW agrupacion_por_mes_y_grupoetario AS
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
```
Then, calculating fatality rate by **month**, capturing the result table in a dataframe and ploting we get:  

![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Fatality_rate_by_month.png "")
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Fatality_rate_by_month_linechart.png "Fatality rate by month linechart")  
- During the first months the general fatality rate remains is very high. It begins to stabilize at values between 2% and 3% from month 08-2020.
- After 3 months of vaccination, from month 05-2021, a downward trend in fatality is observed reaching 1.95% in 07-2021. It is the lowest value in the entire pandemic.


Finally, calculating fatality rate for **each age group** by **month**: and capturing the result table in a dataframe we get:
```python
%%sql
--CREATE VIEW letalidad_por_grupoetario_por_mes AS
SELECT año, mes, CONCAT(año,'-', mes) AS año_mes, grupo_etario, fallecidos, casos, ROUND((CONVERT(FLOAT, fallecidos)/CONVERT(FLOAT,casos))*100,2) AS letalidad
FROM agrupacion_por_mes_y_grupoetario
ORDER BY año, mes, grupo_etario
```
```python
r5 = %sql SELECT * FROM letalidad_por_grupoetario_por_mes ORDER BY año, mes, grupo_etario
df_5 = r5.DataFrame()
df_5.iloc[:,2:]
```

![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Fatality_rate_by_age_group_and_month.png "Fatality rate by age group and month_df")
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Fatality_rate_by_age_group_and_month_linechart.png "Fatality rate by age group and month linechart")


## Conclusions
- Fatality rate tends to be higher in older age groups. This behavior is maintained month by month throughout the pandemic, confirming that older people have been the hardest hit by the virus. Therefore, it is correct to conclude that the older a person is, the greater risk of dying if they contract the disease.
- According to the graphs, the people least affected by the pandemic are between 0 and 49 years old. In these age groups, fatality averages below 2%.
- For the more advanced age groups, from 50 years old onwards, the changes in fatality rate are much more sensitive to the number of cases in each month.
- During the first 3 months after the start of vaccination (02-2021), there does not seem to be a significant change that indicates a decrease in fatality rate, on the contrary, there are notable peaks and valleys in its behavior, given the sudden increase and decrease in the number of infections during those same months.
- A decrease in the fatality rate is notorious only from 05-2021, which is the 4th month after the start of vaccination. Naturally, this change is noticeable in the more advanced age groups since they were a priority in the country's vaccination scheme.
- The downward trend in the fatality rate is very pronounced in the "70 -79" and "80 or more" groups. 
- Fatality rate in the group of "80 or more" has decreased from an average of 26.21% in the last 10 months, to 21.69% in 07-2021. Fatality rate in the group of "70 - 79" has decreased from an average of 15.51% to 11.59% in 07-2021.
- In other words, fatality rate has decreased by 17.24% for the group of "80 or more" and by 25.27% for the group of "70 - 79" after 6 months from the start of vaccination.



[notebook]:https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Notebook%20-%20Effect%20of%20Vaccines%20on%20Covid19%20fatality%20rate%20in%20Colombia.ipynb
[sqlfile]:https://github.com/caestradaa/covid_fatality_in_Col/blob/main/SQLQueries.sql

<!---## Specific Analysis

### First analysis

![alt text]( "")
![alt text]( "")

### Second analysis

![alt text]( "")
![alt text]( "")


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


<!---
| estado      | cantidad   | porcentaje  |
| ----------- |:----------:| -----------:|
| N/A         | 12926      | 0.28        |
| Fallecido   | 114337     | 2.50        |
| Activo      | 120673     | 2.64        |
| Recuperado  | 4317436    | 94.57       |-->

-->
