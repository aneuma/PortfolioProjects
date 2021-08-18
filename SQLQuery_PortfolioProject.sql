
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
Order by 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations$
--Order by 3,4

-- Select Data that we are going to be using

SELECT location, continent, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country

SELECT location, continent, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2

-- Looking at Total Case vs Population
-- Shows what percentage of population got Covid

SELECT location, continent, date, total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
Order by 1,2


-- Looking at Countries with Highest Infection Rate compare to Population

SELECT location, continent,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
Group By location, continent, population
Order by 1,2

-- Showing Countries with Highest Death Count per Population

SELECT location, continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
Group By location, continent, population
Order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the Continents with the Highest Death Count per Population


SELECT location, continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
Group By location, continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS


SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%' 
WHERE continent is not null
--Group By date
Order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
Order By 2,3



-- USE CTE

WITH PopvsVac (Continent, locastion, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order By 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order By 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data later visualizations

CREATE VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order By 2,3

Select * 
FROM PercentPopulationVaccinated
