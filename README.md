# Effect of Vaccines on Covid-19 fatality rate in Colombia
*Data analysis project about the effect of vaccines on covid-19 fatality in Colombia.*



## Overview
- A data analysis on Covid-19 in Colombia was made in order to understand the effects that mass vaccination is having on the fatality rate, and determine if there really is a positive impact on vaccinated population.
- Two datasets were used: Covid-19 positive cases data in Colombia extracted from the oficial repository of the National Institute of Health (4.9M rows up to Sep 14, 2021), and Vaccination data extracted from the official Our World in Data repository (208 rows).
- Project tools: SQL Server for loading and cleaning data. **[SQL file][sqlfile]**. And SQL and Python for exploratory and explanatory analysis on a **[Jupyter notebook][notebook]** via %sql magic.
- It was found that during the first six months after the start of vaccination, there has been a slight decrease in the fatality rate. The change has been slow and only begins to be noticeable after the seventh month (09-2021). In the last two months fatality rate has decreased on average by 28%. <!---In people over 70 years old, fatality rate has decreased on average by 21.25%. In the age group from 70 to 79 fatality rate has decreased by 25.27%.-->




## Problem statement
This project seeks to have a deeper knowledge of the behaviour of the pandemic in Colombia and to know specifically if the vaccination process is being effective or not. If it is, to what extent, and also, what is the trend in the future according to the rate of vaccination and the rate of infections.
<!---This pandemic has put us to the test as humanity, exposing the fragility of our economic systems, however, it has also been a trigger to reflect on our consumer lifestyle and accelerate the transformation towards new, more sustainable production models.-->

#### Some questions to answer:
- **Q1**: How many vaccine doses have been administered to date? How many people have received at least one dose? How many are fully vaccinated?  
- **Q2**: How has the Covid-19 fatality rate evolved from the start of the pandemic until today?  
- **Q3**: Is there a change in trend at any point after the start of vaccination? In general, by age group and by gender.  
- **Q4**: Which age group already vaccinated has had a better response to vaccines?  
- **Q5**: Is there any relationship between the number of people vaccinated and the evolution of the fatality rate?  
<!---- According to the current vaccination rate, when would 70% of the population be fully vaccinated?-->



## Data Collection
All the data required for this project was searched from multiple sources on the web, from official government websites to the repositories of recognized organizations for data collection and analysis. Two datasets were loaded to a database called "CovidColombia" created on a local server using Microsoft SQL Server:
1. **"Cases"**: Official data of positive cases of Covid-19 in Colombia (until Sep 14, 2021), extracted in a CSV file from the official repository of the National Institute of Health. 23 columns and 4.932.998 records. It is updated daily with the new registered cases. [INS Cases dataset](https://www.datos.gov.co/Salud-y-Protecci-n-Social/Casos-positivos-de-COVID-19-en-Colombia/gt2j-8ykr "Casos positivos de COVID19 en Colombia").
2. **"Vaccinations"**: Data corresponding to daily vaccination in Colombia (until Sep 14, 2021), extracted in a CSV file from the Our World On Data repository compilated from official sources. 14 columns and 47.844 rows. [Vaccinations dataset](https://github.com/owid/covid-19-data/tree/master/public/data/vaccinations "Vacunación").  





## Data Cleaning
Cleaning of both datasets was done with SQL in SQL Server Management Studio. All performed procedures are documented in the attached **[.SQL file][sqlfile]**.

#### 1. Cases:   
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Raw_dataset_preview_Casos_errors.png "Raw data preview")  
As shown above, erroneous data was written in the null records of date fields. The following transformations were performed:
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
```
- Total cases reported to date = 4.932.998  
- Proportion of the population infected = 9.8 %  


### Cases by status:  
Retrieving the number of cases by status and calculating the proportion from total cases:  

![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Cases_by_status_with_proportion.PNG "Cases by status") 

```python
r2 = %sql SELECT COUNT(estado) FROM Casos WHERE estado = 'Fallecido'
total_deaths = r2[0][0]
gen_mortality = (total_deaths*100000/total_pop)
gen_fatality = (total_deaths/total_cases)*100
```  
- Total deaths = 125.713 
- General Mortality rate = 249.73 per 100,000 inhabitants  
- General Fatality rate = 2.55%  
- 96.72% of infected people have recovered from Covid-19.


### Cases, deaths and fatality rate by gender:  
Retrieving the number of cases and deaths by gender, calculating fatality rate and setting a dataframe with the results:  

![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Cases_deaths_fatalityrate_by_gender.png "Cases_deaths_fatality_by_gender")  
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Piechart_Cases_by_gender.PNG "Cases_by_gender_piechart")
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Piechart_%20Deaths_by_gender.png "Deaths_by_gender_piechart")  
- The proportion of infected people is similar in both genders, however, the fatality rate is much higher in men (3.28%) than in women (1.89%). This means men are about 45% more likely to die compared to women if they contract the virus.  
- 38.91% of the total deaths have been women and 61.09% have been men.  
- According to the data almost two-thirds (2/3) of the deceased are men. It is noticeable on the pie chart #2.   


### Vaccinations exploration: 
**Q1: How many vaccine doses have been administered to date? How many people have received at least one dose? How many are fully vaccinated?**  
```python
v1 = %sql SELECT COUNT(*) FROM Vaccinations
v2 = %sql SELECT COUNT(*) FROM Vaccinations WHERE location = 'Colombia'
v3 = %sql SELECT MIN([date]) FROM Vaccinations WHERE location = 'Colombia'
v4 = %sql SELECT MAX(total_vaccinations) FROM Vaccinations WHERE location = 'Colombia'
v5 = %sql SELECT MAX(people_vaccinated) FROM Vaccinations WHERE location = 'Colombia'
v6 = %sql SELECT MAX(people_fully_vaccinated) FROM Vaccinations WHERE location = 'Colombia'
```  
- Total number of rows:                                47.844
- Number of Vaccination dates in Colombia:                208
- Vaccination start date:                          2021-02-17
- Total number of doses administered:              37.444.197
- People vaccinaed (at least one vaccine dose):    24.499.752
- People with the complete scheme to date:         15.746.173  

![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Vaccinations_day_by_day.PNG "Vaccinations day by day")  






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
Once the main view is created `Casos_con_grupo_etario`, we make a series of groupings by age group, gender and month using CTEs and Joins. We obtain several result sets that we save in different SQL Views and that we later use to do the analyzes:
- `agrupacion_por_grupoetario_y_sexo`: number of cases and deaths by **age group** and **gender**.
- `letalidad_por_grupoetario`: number of cases, deaths and fatality rate by **age group** only.
- `agrupacion_por_mes_y_grupoetario`: number of cases and deaths by **month** and **age group**.
- `letalidad_por_grupoetario_por_mes`: number of cases, deaths and fatality Rate by **month** and **age group**.  


### Fatality rate by Age Group:
```python
%%sql
--CREATE VIEW letalidad_por_grupoetario AS
SELECT grupo_etario, SUM(fallecidos) AS fallecidos, SUM(casos) AS casos, ROUND((CONVERT(FLOAT, SUM(fallecidos))/CONVERT(FLOAT,SUM(casos)))*100,2) AS letalidad
FROM agrupacion_por_grupoetario_y_sexo
GROUP BY grupo_etario;
```  
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Fatality_rate_by_age_group.png "Fatality_rate_by_age_group")
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Cases_by_agegroup_barchart.png "Cases_by_age_group")
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Deaths_by_age_group_barchart.png "Deaths_by_age_group")  

- When calculating fatality rate by age group and gender we figure out that the segment of the population with the highest fatality rate are **men over 80 years old**:  
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Segment_highes_%20fatality_rate.png "segment with the highest fatality rate")
- The age groups with the highest fatality rate are the more advance ones: `60 - 69`, `70 - 79` and `80 o más` with 7.3%, 15.6% and 27.1% respectively.  
- The fatality rate of these groups is quite high compared with the general rate that is 2.55%.
- The people least affected by the pandemic are between 0 and 49 years old. In these groups, fatality averages below 2%.
- It is shown that we cannot use the general fatality rate as a comparable measure for all age groups.


### Effect of vaccines on Fatality Rate
Here we study how the fatality rate of each age group has evolved through time. We will focus primarily on comparing fatality rate before and after the start of vaccination (Feb 2021), but also, we will see how **this measure is related with the number of vaccines dosed week by week**. We will see if there is any positive effect by reducing fatality rate for each age group.

**By Month**:  
First we grouped cases and deaths by **month** and **age group** using CTEs statements and then joining the results in one table. Then, calculating fatality rate and ploting the results we get the next chart. The dotted line represents the start of vaccinations in the country. 

![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Fatality_rate_by_month_linechart.png "Fatality rate by month linechart")  

**Q2: How has the Covid-19 fatality rate evolved from the start of the pandemic until today?**  
- During the first five months of pandemic the general fatality rate remains is very high. It begins to stabilize at values between 2% and 3% from month 08-2020.
- If we analyze from 08-2020 to 09-2021, it it hard to say that there is a significant difference before and after the start vaccination at leats at this level of granularity.
- We must take a closer look at the data and analyze the behavior of the fatality rate week by week.

**By Week**:  
Due to the lack of details we got from month to month, we analyze fatality rate **week by week**. Using CTEs statements and then joining the results in one table, we follow the same procedure as we did before. Finally, we capture the result table in a dataframe and then calculate fatality rate:

```python
%%sql r6 <<
WITH CTE5_casos (año, semana, casos) AS (
      SELECT YEAR(fecha_reporte_web) AS año, DATEPART(WEEK,fecha_reporte_web), COUNT(fecha_reporte_web) AS casos
      FROM Casos_con_grupo_etario
      GROUP BY YEAR(fecha_reporte_web), DATEPART(WEEK,fecha_reporte_web)
      ),
    CTE6_muertes (año, semana, fallecidos) AS (
      SELECT YEAR(fecha_muerte) AS año, DATEPART(WEEK,fecha_reporte_web), COUNT(fecha_muerte) AS fallecidos
      FROM Casos_con_grupo_etario
      GROUP BY YEAR(fecha_muerte), DATEPART(WEEK,fecha_reporte_web), estado
      HAVING estado = 'Fallecido'
      )
SELECT c.año, c.semana, fallecidos, casos
FROM CTE5_casos c
LEFT JOIN CTE6_muertes m ON c.año = m.año AND c.semana = m.semana
ORDER BY año, semana
```
```python
df_r6 = r6.DataFrame()
df_r6['letalidad'] = round((df_r6.fallecidos/df_r6.casos)*100,2)
df_r6['año-semana'] = df_r6.año.astype(str)+'-'+df_r6.semana.astype(str)
df_r6
```
We proceed to make the visuals: The color lines represents the fatality rate week by week, and the pink bars in the background represents the number of deaths each week. We can clearly see the three peaks of deaths that have occurred in the country so we can compare what is its relation with fatality rate:

*General Fatality Rate:*  
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Fatality_rate_and_Deaths_by_week_linechart_v1.PNG "Fatality rate and Deaths by week linechart") 

*Fatality Rate by Age Group:*  
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Fatality_rate_and_Deaths_by_AG_and_week_linechart.PNG "Fatality rate and Deaths by age group and week linechart")

**Q3: Is there a change in trend at any point after the start of vaccination? In general, by age group?**  
- According to the graphs above, a general downward trend in fatality is observed.
- However, during the first three months after the start of vaccination, there does not seem to be a significant change that indicates a decrease in fatality rate. During this time, there are notable peaks and valleys in its behavior given the sudden increase and decrease in the number of infections during those months.
- A slight decrease in the fatality rate starts to be noticeable only four months after the start of vaccination (from week 2021-23). From there, a downward trend in fatality is observed reaching 2.03% in 09-2021 which is the lowest value in the entire pandemic.
- Fatality rate tends to be higher in older age groups. This behavior is maintained throughout the pandemic, confirming that older people have been the hardest hit by the virus.
- The final downward trend in the fatality rate is very pronounced in the "70 -79" and "80 or more" groups. 

**Q4: Which age group already vaccinated has had a better response to the virus?**  
- As we already know, the vaccination plan gives priority to the elderly. Therefore, the oldest age groups are more advanced in the vaccination schedule. One might think that these groups should have the best response to the virus. However, we cannot know with certainty if the difference in  thereduction of the fatality rate for each group is due to the administration of vaccines or to the reduction of infections.  
- We have analyzed the behavior of the fatality rate individually in each age group. As we will see below, age group '60 - 69' is the one that has had the greatest reduction in the fatality rate since the beginning of vaccination.

*Fatality Rate (Age Group: 60 - 69):*  
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Fatality_rate_and_Deaths_by_AG60-69_and_week_linechart.PNG)

<!--*Relationship between Cases and Deaths by Age Group:*
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Scatterplot_Cases_vs_Deaths_relationship_by_AG.PNG)-->



### Vaccinations vs Fatality Rate
In this section we evaluate the relationship that exists between the fatality rate by week with the accumulated weekly vaccines, in order to determine if an increase in the number of vaccinated people is correlated with a change in the fatality rate.

Grouping vaccinations **by week**:  
```python
%%sql r8 <<
SELECT YEAR(date) AS año, DATEPART(WEEK, date) AS semana, SUM(daily_vaccinations) AS vaccinations
FROM Vaccinations
WHERE location = 'Colombia'
GROUP BY YEAR(date), DATEPART(WEEK, date)
```
Joining Vaccinations by week with Fatality rate by week:  
```python
df_r9 = df_r6.loc[(df_r6.año==2021) & (df_r6.semana >=8) ,:].reset_index(drop=True)
df_r8_9 = df_r9.merge(df_r8, how='left', on='año' and 'semana').drop('año_y', axis = 1).rename({'año_x' : 'año'}, axis=1)
```  
*Vaccinations vs Fatallity Rate:*  
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/Scatterplot_Vaccinations_vs_FatallityRate.PNG "Vaccinations vs Fatallity Rate")

*Comparig Fatality Rate and Vaccinations through time (by week):*  
![alt text](https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Images/FatalityRate_vs_Vaccinations_by_week.PNG "Vaccinations vs Fatallity Rate through time")

**Q5: Is there any relationship between the number of people vaccinated and the evolution of the fatality rate?** 
- As shown in the two previous visualizations, there is an interesting relationship between the fatality rate and vaccination: as the number of doses applied increases, the overall fatality rate decreases.
- Of course, this is only a correlation that does not show causality in its entirety, however, it is true that there is a slight but evident decrease in the fatality rate and it is likely that its main cause is the advance in the vaccination.





## Conclusions
- Fatality rate tends to be higher in older age groups. This behavior is maintained throughout the pandemic. Therefore, it is correct to conclude that the older a person is, the greater risk of dying if they contract the disease.
- According to the research, the people least affected by the pandemic are between 0 and 49 years old. In these age groups, fatality averages below 2%.
- During the first three months after the start of vaccination, there does not seem to be a significant change that indicates a decrease in fatality rate, however, a slight decrease in the fatality rate starts to be noticeable four months after the start of vaccination (from week 2021-23). Naturally, this change is evident in the more advanced age groups since they were a priority in the country's vaccination scheme.
- The age group of '60 - 69' is the one that has had the greatest reduction in the fatality rate since the beginning of vaccination: about 31% on average. In general, fatality rate has decreased on average by 28% in the last two months.
- If we look the whole picture, a general downward trend in the fatality rate is observed. It can be caused by multiple reasons: from a better effectiveness in hospital treatments to the immunity obtained by the vaccine. The data presented here show us that even though it is slight, the correlation exists: as the number of doses applied increases, the overall fatality rate decreases.
- It is true that there is a long way to go in the vaccination scheme, but the results of the advances may already begin to be noticed. In the coming months, vaccines will be able to be tested upon the arrival of a fourth wave of infections.


[notebook]:https://github.com/caestradaa/covid_fatality_in_Col/blob/main/Notebook%20-%20Effect%20of%20Vaccines%20on%20Covid19%20fatality%20rate%20in%20Colombia.ipynb
[sqlfile]:https://github.com/caestradaa/covid_fatality_in_Col/blob/main/SQLQueries.sql





<!---
- The downward trend in the fatality rate is very pronounced in the "70 -79" and "80 or more" groups. 
- Fatality rate in the group of "80 or more" has decreased from an average of 26.21% in the last 10 months, to 21.69% in 07-2021. Fatality rate in the group of "70 - 79" has decreased from an average of 15.51% to 11.59% in 07-2021.
- In other words, fatality rate has decreased by 17.24% for the group of "80 or more" and by 25.27% for the group of "70 - 79" after 6 months from the start of vaccination..

![alt text]( "")
![alt text]( "")


`para inline code`

```
para bloque
de codigo
```

<!---Para ocultar-->

<!---| estado      | cantidad   | porcentaje  |
| ----------- |:----------:| -----------:|
| N/A         | 12926      | 0.28        |
| Fallecido   | 114337     | 2.50        |
| Activo      | 120673     | 2.64        |
| Recuperado  | 4317436    | 94.57       |-->
