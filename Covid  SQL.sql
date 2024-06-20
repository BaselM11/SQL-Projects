/*
Covid 19 Data Exploration
*/

SELECT *
FROM CovidDeaths

SELECT *
FROM CovidVaccinations



-- Select Data that we are going to be starting with
SELECT *
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY location,date ASC

-- Select Data that we are going to be starting with
SELECT location,date,new_cases,total_cases,new_deaths,total_deaths,population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths
SELECT location,date,population,total_deaths,total_cases,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
AND location LIKE '%gypt'
ORDER BY 1,2


-- Total Cases vs Population
SELECT location,date,total_cases,population,(total_cases/population)*100 as PercentInfection
FROM CovidDeaths 
WHERE continent IS NOT NULL
AND location LIKE '%gypt'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population
SELECT location,population,MAX(total_cases) as TotalCases,MAX(total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 4 DESC


-- Countries with Highest Death Count per Population
SELECT location,population,MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
order by 3 DESC


-- Showing contintents with the highest death count per population
SELECT continent,max(total_deathS) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC


-- GLOBAL NUMBERS
SELECT SUM(new_cases) as TotalCases,SUM(new_deaths) as TotalDeaths,(SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL


-- Total Population vs Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated,
MAX(vac.total_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinatedAccurate
FROM CovidDeaths as dea
INNER JOIN CovidVaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
AND dea.location LIKE 'Egypt'
ORDER BY 2,3


-- Shows Percentage of Population that has recieved at least one Covid Vaccine USING STORED PROCEDURES

DROP PROCEDURE IF EXISTS PopVsVac

CREATE PROCEDURE PopVsVac
AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths as dea
INNER JOIN CovidVaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

PopVsVac



-- Shows Percentage of Population that has recieved at least one Covid Vaccine Using Common Table Expression

WITH PopVsVac_CTE(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths as dea
INNER JOIN CovidVaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,(RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
FROM PopVsVac_CTE




-- Shows Percentage of Population that has recieved at least one Covid Vaccine Using Temp Tables

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths as dea
INNER JOIN CovidVaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100 as RollingPercentageVaccinated
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations
CREATE VIEW PopVsVac_View
AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths as dea
INNER JOIN CovidVaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/Population)*100 as RollingPercentageVaccinated
FROM PopVsVac_View



-- Total Cases and Total Deaths vs Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
MAX(vac.total_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated,
SUM(dea.new_cases) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingCases,
SUM(dea.new_deaths) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingDeaths
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
AND dea.location LIKE 'Egypt'
ORDER BY 2,3

