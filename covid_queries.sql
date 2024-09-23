
/*
@Author:Vijay Kumar M N 
@Date: 2024-09-21
@Last Modified by: Rahul
@Last Modified: 2024-09-21
@Title :Sql Queries on covid dataset

*/

create database covid;
use covid;

--1. To find out the death percentage locally and globally

--to find death percentage globally
select 
	country_region,totalcases,totaldeaths, 
	round(CONVERT(FLOAT, totaldeaths) / CONVERT(FLOAT, totalcases) * 100,2) AS DeathPercentage
from 
	worldometer_data;

--to find death percentage locally


SELECT 
    state_unionterritory,
	 SUM(CAST(Confirmed AS FLOAT)) AS Total_Confirmed,
    SUM(CAST(Deaths AS FLOAT)) AS Total_Deaths,
    ROUND((SUM(CAST(Deaths AS FLOAT)) / SUM(CAST(Confirmed AS FLOAT)) * 100), 2) as percentage_locally
FROM 
    covid_19_india
GROUP BY 
    state_unionterritory
order by percentage_locally desc;



--2. To find out the infected population percentage locally and globally

--globally infected percentage

select 
	sum(convert(bigint,TotalCases)) as Total_Infected,
	sum(convert(bigint,Population)) as Total_population, 
	ROUND(SUM(CONVERT(FLOAT, TotalCases)) / SUM(CONVERT(FLOAT, Population)) * 100, 2) AS InfectionPercentage
from 
	worldometer_data;



-- locally infected percentage
select
	sum(convert(bigint,totalsamples)) as Total_population,
	sum(convert(bigint,positive)) as Total_infected,
	round(sum(convert(float,positive))/sum(convert(float,totalsamples)) *100,2) as Infection_percentage
from
	StatewiseTestingDetails;



--3. To find out the countries with the highest infection rates



SELECT 
    Country_Region,
    SUM(CAST(TotalCases AS BIGINT)) AS TotalCases,
    SUM(CAST(Population AS BIGINT)) AS Population,
    ROUND(SUM(CONVERT(FLOAT, TotalCases)) / SUM(CONVERT(FLOAT, Population)) * 100, 2) AS Infection_Rates
FROM 
    worldometer_data
GROUP BY 
    Country_Region
ORDER BY 
    Infection_Rates DESC;



--4. To find out the countries and continents with the highest death counts

--continenets with the highest death counts

select
	Continent,
	sum(convert(bigint,totaldeaths)) as total_deaths
from
	worldometer_data
group by 
	Continent
order by 
	total_deaths desc;


--countries with highest death counts

select country_region,sum(convert(bigint ,Deaths)) as total_deaths
from covid_19_clean_complete
group by
	Country_Region
order by
	total_deaths desc;


--5. Average number of deaths by day (Continents and Countries) 

--deaths average per day for the countries


select 
	Country_Region,
	sum(convert(bigint,deaths))/count(distinct date) as deaths_per_day_average
from 
	covid_19_clean_complete
group by 
	Country_Region
order by
	deaths_per_day_average desc;


----deaths average per day for the countinent

select
	w.Continent,
	sum(convert(bigint,c.deaths))/count(distinct c.date) as deaths_per_day_average
from 
	covid_19_clean_complete c
join 
	worldometer_data w 
on
	w.Country_Region=c.Country_Region
group by
	w.Continent
order by
	w.Continent;



--6. Average of cases divided by the number of population of each country (TOP 10) 
	
--to find top 10 rows 

SELECT 
	top 10
    Country_Region,
    ROUND(CONVERT(FLOAT, AVG(TotalCases)) / CONVERT(FLOAT, MAX(Population)), 2) AS cases_per_population
FROM 
    worldometer_data
GROUP BY 
    Country_Region
ORDER BY 
    cases_per_population desc;


--7. Considering the highest value of total cases, which countries have the highest rate of infection in relation to population? 


--to find top 10 records 

SELECT 
	  top 10
      [Country_Region], 
      ROUND(CAST(TotalCases AS FLOAT) / NULLIF(CAST(Population AS FLOAT), 0) * 100, 3) AS cases_per_population
FROM 
    worldometer_data
order by
	cases_per_population desc;



--Using JOINS to combine the covid_deaths and covid_vaccine tables :

--1. To find out the population vs the number of people vaccinated

select 
	Country_Region as country,
	totalcases,
	convert(float,TotalCases)/convert(float,Population) *100 as infection_rate 
from 
	worldometer_data
order by
	infection_rate desc;



--2. To find out the percentage of different vaccine taken by people in a country


WITH HighestPopulationCTE AS (
    SELECT 
        TRY_CAST(MAX(Population) AS BIGINT) AS HighestPopulation
    FROM 
        worldometer_data
    WHERE 
        Continent = 'Asia'
        AND TRY_CAST(Population AS BIGINT) IS NOT NULL
),

LatestDoses AS (
    SELECT 
        COALESCE(SUM(TRY_CAST([Covaxin_Doses_Administered] AS BIGINT)), 0) AS CovaxinDoses,
        COALESCE(SUM(TRY_CAST([CoviShield_Doses_Administered] AS BIGINT)), 0) AS CoviShieldDoses,
        COALESCE(SUM(TRY_CAST([Sputnik_V_Doses_Administered] AS BIGINT)), 0) AS SputnikVDoses
    FROM 
        covid_vaccine_statewise
    WHERE 
        State = 'India' 
        AND [Updated_On] = (
            SELECT 
                MAX([Updated_On])
            FROM 
                covid_vaccine_statewise
            WHERE 
                State = 'India'
                AND TRY_CAST([Total_Doses_Administered] AS BIGINT) IS NOT NULL
        )
)

SELECT 
    ROUND(TRY_CAST(ld.CovaxinDoses AS FLOAT) * 100.0 / TRY_CAST(hp.HighestPopulation AS FLOAT), 2) AS Covaxin_Percentage,
    ROUND(TRY_CAST(ld.CoviShieldDoses AS FLOAT) * 100.0 / TRY_CAST(hp.HighestPopulation AS FLOAT), 2) AS CoviShield_Percentage,
    ROUND(TRY_CAST(ld.SputnikVDoses AS FLOAT) * 100.0 / TRY_CAST(hp.HighestPopulation AS FLOAT), 2) AS SputnikV_Percentage
FROM 
    LatestDoses ld
CROSS JOIN 
    HighestPopulationCTE hp;



--3. To find out percentage of people who took both the doses



WITH VaccinePercentages AS (
   SELECT 
        [Updated_On] AS Date,
        State,
        TRY_CAST([Total_Doses_Administered] AS FLOAT) AS TotalDoses,
        TRY_CAST(Covaxin_Doses_Administered AS FLOAT) AS CovaxinDoses,
        TRY_CAST(CoviShield_Doses_Administered AS FLOAT) AS CoviShieldDoses,
        TRY_CAST(Sputnik_V_Doses_Administered AS FLOAT) AS SputnikVDoses
    FROM 
        covid_vaccine_statewise
)

SELECT 
    Date,
    State,
    CASE 
        WHEN NULLIF(TotalDoses, 0) IS NULL THEN NULL
        ELSE ROUND((CovaxinDoses * 100.0 / TotalDoses), 2)
    END AS [Covaxin_Percentage],
    CASE 
        WHEN NULLIF(TotalDoses, 0) IS NULL THEN NULL
        ELSE ROUND((CoviShieldDoses * 100.0 / TotalDoses), 2)
    END AS [CoviShield_Percentage],
    CASE 
        WHEN NULLIF(TotalDoses, 0) IS NULL THEN NULL
        ELSE ROUND((SputnikVDoses * 100.0 / TotalDoses), 2)
    END AS [Sputnik_V_Percentage]
FROM 
    VaccinePercentages
ORDER BY 
    Date;

