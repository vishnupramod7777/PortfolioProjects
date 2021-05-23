SELECT
*
FROM
PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4 



SELECT
location,
date,
total_cases,
new_cases,
total_deaths,
population
FROM
PortfolioProject..CovidDeaths
ORDER BY 1,2


-- looking at Total Cases vs Total Deaths
-- shows covid cases, deaths , deathPopulation in india
SELECT
location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 AS DeathPercentage
FROM
PortfolioProject..CovidDeaths
WHERE 
location like '%india%'
ORDER BY 1,2

--looking at Total cases VS population
-- shows what percentage of the population got covid

SELECT
location,
date,
population,
total_cases,
(total_cases/population)*100 AS DeathPercentage
FROM
PortfolioProject..CovidDeaths
--WHERE location like '%india%'
ORDER BY 1,2


-- LOOKING at contries at Highest Infetion rate compared to Population

SELECT
location,
Population,
MAX(total_cases) AS HighestInfectionCount,
MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM
PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like '%india%'
GROUP BY location, population
ORDER BY  PercentPopulationInfected DESC

--Showing countries with Highest Death Count per Population


SELECT
location,
MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM
PortfolioProject..CovidDeaths
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--LETS BREAK THINGS DOWN BY CONTINENT


--showing continents with highest death count per population

SELECT
continent,
MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM
PortfolioProject..CovidDeaths
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT
SUM(new_cases) AS total_cases,
SUM(CAST(new_deaths AS int)) AS total_deaths,
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS	DeathPercentage
FROM
PortfolioProject..CovidDeaths
--WHERE location like '%india%'
WHERE 
continent is not null
--GROUP BY date
ORDER BY 1,2

--looking at total population vs vaccinations 

SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated,
--(RollingPeopleVaccinated/Population)*100
FROM
PortfolioProject..CovidDeaths dea
JOIN
PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE
dea.continent is not null
ORDER BY 2,3
  

 --USE CTE
 WITH PopvsVac
 (Continent,
 Location,
 Date,
 Population,
 New_Vaccinations,
 RollingPeopleVaccinated)
  AS
  (
SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM
PortfolioProject..CovidDeaths dea
JOIN
PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE
dea.continent is not null
--ORDER BY 2,3
)
SELECT
*,
(RollingPeopleVaccinated/Population)*100
FROM
PopvsVac




--TEMP TABLE


DROP TABLE IF exists #PercentgePopulationVaccinated
CREATE TABLE #PercentgePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vacccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentgePopulationVaccinated
SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM
PortfolioProject..CovidDeaths dea
JOIN
PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE
dea.continent is not null
--ORDER BY 2,3
SELECT
*,
(RollingPeopleVaccinated/Population)*100
FROM
#PercentgePopulationVaccinated





--Creating view to store data for later visualizations

CREATE VIEW  
PercentPopulationVaccinated  AS 
SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM
PortfolioProject..CovidDeaths dea
JOIN
PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE
dea.continent is not null
--ORDER BY 2,3


SELECT
*
FROM
PercentgePopulationVaccinated
