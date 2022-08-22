Select *
From PortfolioProject..CovidDeaths$
Where continent IS NOT NULL
order by 3, 4


--Select *
--From PortfolioProject..CovidVacconations$
--order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As death_percentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
AND total_cases IS NOT NULL
AND total_deaths IS NOT NULL
order by 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 As cases_percentage
From PortfolioProject..CovidDeaths$
-- Where location like '%states%'
Where total_cases IS NOT NULL
AND population IS NOT NULL
order by 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS cases_percentage
From PortfolioProject..CovidDeaths$
-- Where location like '%states%'
Where total_cases IS NOT NULL
AND population IS NOT NULL
AND continent IS NOT NULL
Group by location, population
order by cases_percentage desc



-- Showing Countries with Highest Death Count per Population
Select Location, MAX(CAST(total_deaths AS INT)) AS highest_death_count
From PortfolioProject..CovidDeaths$
-- Where location like '%states%'
Where total_deaths IS NOT NULL
AND continent IS NOT NULL
Group by Location
order by highest_death_count desc



-- Showing Continents with Highest Death Count per Population
Select continent, MAX(CAST(total_deaths AS INT)) AS highest_death_count
From PortfolioProject..CovidDeaths$
-- Where location like '%states%'
Where total_deaths IS NOT NULL
AND continent IS NOT NULL
Group By continent
Order By highest_death_count desc



-- Global Numbers
Select SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 As death_percentage
From PortfolioProject..CovidDeaths$
-- Where location like '%states%'
Where new_cases IS NOT NULL
AND new_deaths IS NOT NULL
AND continent IS NOT NULL
-- Group By date
Order By 1, 2



-- Looking at Total Population vs Vaccinations
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER(Partition By cd.location Order By cd.location,
cd.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ AS cd
Join PortfolioProject..CovidVacconations$ AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
Where cd.continent IS NOT NULL
Order By 2, 3



-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER(Partition By cd.location Order By cd.location,
cd.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ AS cd
Join PortfolioProject..CovidVacconations$ AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
Where cd.continent IS NOT NULL
--Order By 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER(Partition By cd.location Order By cd.location,
cd.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ AS cd
Join PortfolioProject..CovidVacconations$ AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
Where cd.continent IS NOT NULL
--Order By 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to Store Date for Later Visualizations
Create View PercentPopulationVaccinated AS
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER(Partition By cd.location Order By cd.location,
cd.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ AS cd
Join PortfolioProject..CovidVacconations$ AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
Where cd.continent IS NOT NULL


Select *
From PercentPopulationVaccinated