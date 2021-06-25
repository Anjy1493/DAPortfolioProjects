
--selecting Covid_Deaths table
SELECT *
FROM PortfolioProject.dbo.Covid_Deaths 
ORDER BY 3,4 


--selecting Covid_Vaccine table
SELECT *
FROM PortfolioProject.dbo.Covid_Vaccines 
ORDER BY 3,4
 

--Selecting data required from Covid_Deaths table
SELECT location, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject.dbo.Covid_Deaths 
ORDER BY 1,2


--total cases vs total deaths: death rate in residing country ie UAE
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percentage_deaths
FROM PortfolioProject.dbo.Covid_Deaths 
WHERE location='United Arab Emirates'  
ORDER BY 1,2
--Insights:
--latest data:0.28%


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
ORDER BY percentage_infected_risk DESC
--Insights: Andorra>Montenegro

--Countries with highest death recorded in a day 
SELECT location, MAX(CAST(total_deaths AS INT)) AS highest_death 
FROM PortfolioProject.dbo.Covid_Deaths 
WHERE continent IS NOT NULL
--to include only contries under location
GROUP BY location
ORDER BY highest_death DESC
--Insights:Highest death in a day recorded in United States>Brazil>India


--Continent wise highest total deaths in a day recorded
SELECT location, MAX(CAST(total_deaths AS INT)) AS highest_death 
FROM PortfolioProject.dbo.Covid_Deaths 
WHERE continent IS NULL 
--to include only continents
GROUP BY location
ORDER BY highest_death DESC
--Insights: Highest death rate in a day is in Europe>South AMerica> North America


--Total Population VS Vaccinations
Select dea.continent, dea. location, dea.population, dea.date, vac.new_vaccinations, 
		SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS overall_vaccinations
FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vaccines vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--Percentage of people vaccinated countrywise
Select dea.continent, dea. location, dea.population, dea.date, vac.new_vaccinations, 
		SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS overall_vaccinations
FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vaccines vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
--USING TEMP TABLE
DROP TABLE IF EXISTS #population_vaccinated
CREATE TABLE #population_vaccinated
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


--Percentage of people vaccinated in UAE
Select dea.continent, dea. location, dea.population, dea.date, vac.new_vaccinations, 
		SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS overall_vaccinations
FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vaccines vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL and dea.location='United Arab Emirates'
ORDER BY 2,3
--USING TEMP TABLE
DROP TABLE IF EXISTS #population_vaccinated
CREATE TABLE #population_vaccinated
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
WHERE dea.continent IS NOT NULL AND dea.location='United Arab Emirates'

SELECT *, (overall_vaccinations/(population*2))*100 AS percentage_vaccinated
FROM #population_vaccinated
ORDER BY date desc
--percentage UAE population vaccinated as on jun 23, 2021 64.57%