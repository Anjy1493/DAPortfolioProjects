--selecting Covid_Deaths table
SELECT *
FROM PortfolioProject.dbo.Covid_Deaths 
"we can use PortfolioProject.dbo.Covid_Deaths or PortfolioProject..Covid_Deaths"
ORDER BY 3,4 
--"sorting by column 3 and 4 default ascending"

--selecting Covid_Vaccine table
SELECT *
FROM PortfolioProject.dbo.Covid_Vaccines 
ORDER BY 3,4
 
--Selecting the required data
SELECT location, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject.dbo.Covid_Deaths 
ORDER BY 1,2

--total cases vs total deaths: death rate in residing country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percentage_deaths
FROM PortfolioProject.dbo.Covid_Deaths 
WHERE location='United Arab Emirates'  --WHERE location like '%arab%' incase not sure of exact fieldname
ORDER BY 1,2

--total cases vs population; percentage of people affected by covid in UAE
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percentage_covid
FROM PortfolioProject.dbo.Covid_Deaths 
WHERE location='United Arab Emirates'  
ORDER BY 1,2
--Insights:
--1% population contracted covid in Oct 2020
--6% population contracted covid by Jun 2021; covid ON RISE

--Countries with highest infection rate in a day Vs population ie risk of getting infected
SELECT location, population, MAX(total_cases) AS highest_case, MAX(total_cases/population)*100 AS percentage_infected_risk
FROM PortfolioProject.dbo.Covid_Deaths 
GROUP BY location, population
--GROUP BY statement is often used with aggregate functions(here-MAX) to group the result-set by one or more columns.
ORDER BY percentage_infected_risk DESC

--Countries with highest death recorded in a day 
SELECT location, MAX(CAST(total_deaths AS INT)) AS highest_death 
--how to select date of highest death?
FROM PortfolioProject.dbo.Covid_Deaths 
WHERE continent IS NOT NULL
--to include only contries under location
GROUP BY location
ORDER BY highest_death DESC
--need to CAST total_death as INT else result will not show highest death since the datatype for highest_death was in incorrect format ie varchar
--Highest death in a day recorded in United States>Brazil>India

--Continent wise highest total deaths in a day recorded
SELECT location, MAX(CAST(total_deaths AS INT)) AS highest_death 
FROM PortfolioProject.dbo.Covid_Deaths 
WHERE continent IS NULL 
--to include only continents
GROUP BY location
ORDER BY highest_death DESC
--Highest death rate in a day is in Europe>South AMerica> North America

--HOW TO FIND TOTAL DEATHS TILL NOW PER COUNTRY
--SELECT location, SUM(CAST(total_deaths AS INT)) AS sumtotal_deaths 
--FROM PortfolioProject.dbo.Covid_Deaths 
--WHERE continent IS NOT NULL
----to include only contries under location
--GROUP BY location
--ORDER BY sumtotal_deaths DESC



--Total Population VS Vaccinations
Select dea.continent, dea. location, dea.population, dea.date, vac.new_vaccinations, 
		SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS overall_vaccinations
--to find sum of new_vaccinations within 1 location use PARTITION BY, counting will be stopped when reaching a new location
--ORDER BY loc and date-for partition else sum shows incorrect values
--covert dataype use CAST or CONVERT
--rolling count using over and partition by
FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vaccines vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



--to find percentage of people vaccinated
Select dea.continent, dea. location, dea.population, dea.date, vac.new_vaccinations, 
		SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS overall_vaccinations
--		(overall_vaccinations/population*2)*100 AS percentage_vaccinated
-- sum or other calculation cannot be carried out a newly created column ie overall_vaccinations, hence need to create temp table
FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vaccines vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USING CTE
WITH Popn_Vacc(continent, location, population, date, new_vaccinations, overall_vaccinations) 
					--(overall_vaccinations/population*2)*100 AS percentage_vaccinated
--CTE table must have same number of columns 
AS
(
Select dea.continent, dea. location, dea.population, dea.date, vac.new_vaccinations, 
		SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS overall_vaccinations
FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vaccines vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3 cannot be used
)
SELECT *, (overall_vaccinations/(population*2))*100 AS percentage_vaccinated
FROM Popn_Vacc
--run along with CTE

--to find highest percentage vaccinated remove date
--WITH Popn_Vacc(continent, location, population, new_vaccinations, overall_vaccinations) 
--AS
--(
--Select dea.continent, dea.location, dea.population, vac.new_vaccinations, 
--		SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS overall_vaccinations
--FROM PortfolioProject..Covid_Deaths dea
--JOIN PortfolioProject..Covid_Vaccines vac
--	ON dea.location=vac.location 
--WHERE dea.continent IS NOT NULL 
--)

--SELECT *, MAX((overall_vaccinations/(population*2))*100) AS percentage_vaccinated
--FROM Popn_Vacc

--USING TEMP TABLE
DROP TABLE IF EXISTS #population_vaccinated
--by Dropping the table it prevents to delete the view ot temp table multiple times
CREATE TABLE #population_vaccinated
--temp table syntax
	(
	continent nvarchar(250), 
	location nvarchar(250),
	population numeric,
	date datetime,
	new_vaccinations numeric,
	overall_vaccinations numeric
	)
INSERT INTO #population_vaccinated
Select dea.continent, dea. location, dea.population, dea.date, vac.new_vaccinations, 
		SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS overall_vaccinations
FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vaccines vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL 

SELECT *, (overall_vaccinations/(population*2))*100 AS percentage_vaccinated
FROM #population_vaccinated

--To Create a view

CREATE VIEW population_vaccinated AS
Select dea.continent, dea. location, dea.population, dea.date, vac.new_vaccinations, 
		SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS overall_vaccinations
FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vaccines vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--after excecution, click on View in Obj Explorer->Refresh->right click on the population_vaccinated view->select 1000 rows

SELECT * 
FROM population_vaccinated