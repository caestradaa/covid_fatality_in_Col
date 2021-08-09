# Project: Effect of Vaccines on Covid-19 fatality in Colombia
*Data analysis project about the effect of vaccines on covid-19 fatality in Colombia.*

## Overview
- A data analysis on Covid-19 in Colombia was made in order to understand the effects that mass vaccination is having on the lethality of the virus. The main objective is to understand if there really is any positive effect on the vaccinated population.
- Two datasets were used: Covid-19 positive cases data in Colombia extracted from the oficial repository of the National Institute of Health (4.5M rows up to July 14, 2021), and Vaccination data extracted from the official Our World in Data repository (127 rows).
- Project tools: SQL Server and ADS for loading and cleaning data. SQL and Python for exploratory analysis on a jupyter notebook via %sql magic (ipython-sql).
- It was found that during the first 3 months after the start of vaccination (02-2021), there is no significant change that indicates a decrease in lethality, however, from 05-2021 there is a notable decrease. It is much more evident in the more advanced age groups since they were a priority in the country's vaccination scheme.

## Problem statement
This project seeks to have a deeper knowledge of the behaviour of the pandemic in Colombia and to know specifically if the vaccination process is being effective or not. If it is, to what extent, and also, what is the trend in the future according to the rate of vaccination rithm and the rate of infections.

This pandemic has put us to the test as humanity, exposing the fragility of our economic systems, however, it has also been a trigger to reflect on our consumer lifestyle and accelerate the transformation towards new, more sustainable production models.

### Some questions to answer
- What proportion of the total population and infected population has died from Covid-19?
- Vaccination: How many doses have been administered to date? How many people have received at least one dose? How many are fully vaccinated?
- According to the current vaccination rate, when would 70% of the population be fully vaccinated?
- How has the Covid-19 fatality rate evolved from the start of the pandemic until today?
- Is there a change in trend at any point after the start of vaccination? In general, by age group and by gender.
- Which age group already vaccinated has had a better response to vaccines?
- Is there any relationship between the number of people vaccinated and the evolution of the fatality rate?


## Data Collection
All the data required for this project was searched from multiple sources on the web, from official government websites to the repositories of recognized organizations for data collection and analysis.
1. Official data of positive cases of Covid-19 in Colombia (until July 14, 2021), extracted in a CSV file from the official repository of the National Institute of Health. This dataset contains all the information corresponding to cases with a positive diagnosis of Covid-19 and deaths with a total of 23 columns and more than 4.5M records. It is updated daily with the new registered cases. https://www.datos.gov.co/Salud-y-Protecci-n-Social/Casos-positivos-de-COVID-19-en-Colombia/gt2j-8ykr
2. Data corresponding to daily vaccination in Colombia (until July 15, 2021), extracted in a CSV file from the Our World On Data repository. This database corresponds to the daily compilation of vaccination data that OWOD does from official sources. https://github.com/owid/covid-19-data/tree/master/public/data/vaccinations.

Raw datasets:
```
  Dataset      Columns       Rows
1.Casos          23        4.565.372
2.Vacunación     12         33.672
```
The two datasets were loaded to a database called "CovidColombia" created on a local server using Microsoft SQL Server. Two tables were created: "Cases" and "Vaccinations", corresponding to each CSV file.

![alt text]( "Raw data preview")



## Data Cleaning
The two datasets were loaded to a database called "CovidColombia" created on a local server using Microsoft SQL Server. Two tables were created: "Cases" and "Vaccinations", corresponding to each CSV file.
Ater extrating the data it needed to be cleaned so it was...and made the following changes:
- Removed duplicates, errors and empty rows...
- Splited columns...
- Outliers were analized...
- Cleaninng process and sql scrips

![alt text]( "Clean data preview")




## Considerations/Calculations and Explanations
- Fatality rate:
- Mortality rate:
- Age group

![alt text]( "")




## Exploratory Data Analysis (EDA)
- 4M records, 10 age groups, 2 geners were analized.

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
