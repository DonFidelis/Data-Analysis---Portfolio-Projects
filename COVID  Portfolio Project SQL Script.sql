Select *
From PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
order by 3,4

Select *
From PortfolioProject.dbo.CovidVaccinations$
order by 3,4

--Select Data that we are going to be using

SELECT Location, date, total_deaths, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY Location,date

-- Looking at the total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in Zambia

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%zambia%'
ORDER BY Location,date

-- Total cases vs Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PerPopulationInfected 
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location like '%zambia%'
AND continent is not null
ORDER BY Location,date

-- Countries with highest infection rates to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PerPopulationInfected 
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY population, location
ORDER BY PerPopulationInfected DESC

-- Countries with highest covid deaths per population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Broken down by Continent

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global stats

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2

-- Global stats per day

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Accessing te Covid Vaccinations Table

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations$

-- Join the two tables
-- Total population vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedIncrement
FROM PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Use CTE to above query

With PopvsVac (Continent, Location, Date, population, New_Vaccinations, PeopleVaccinatedIncrement) 
AS( SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedIncrement
FROM PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (PeopleVaccinatedIncrement/population)*100 
FROM PopvsVac

-- USING TEMP TABLE TO BUILD AND EXECUTE ABOVE QUERY 

DROP Table if Exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinatedIncrement numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedIncrement
FROM PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (PeopleVaccinatedIncrement/population)*100 
FROM #PercentPopulationVaccinated





-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedIncrement
FROM PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated