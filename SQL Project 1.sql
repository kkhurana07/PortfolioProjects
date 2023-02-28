select *
from PortfolioProject..CovidDeaths$
where continent is not null
ORDER BY 3,4


--select *
--from PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

--- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
ORDER BY 1,2


-- Looking at total cases vs total deaths (how many deaths per entire cases)
-- shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%india%'
ORDER BY 1,2


-- Looking at the total cases vs the population

Select Location, date, population, total_cases,  (total_cases/population)*100 CovidPopPercentage
From PortfolioProject..CovidDeaths$
Where location like '%india%'
ORDER BY 1,2


-- Looking at countries with highest infectionr rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 PercentpopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%india%'
Group by Location, population
ORDER BY PercentpopulationInfected desc

-- Showing the countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%india%'
where continent is not null
Group by Location
ORDER BY TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%india%'
where continent is null
Group by location
ORDER BY TotalDeathCount desc


-- showing continent with highest deathcount


Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%india%'
where continent is not null
Group by location
ORDER BY TotalDeathCount desc


-- Global numbers

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
-- Where location like '%india%'
where continent is not null
-- Group by date
ORDER BY 1,2



---- Looking at total population vs Vaccincations

With PopvsVac(Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated) 
as
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int , vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

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

INSERT INTO #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int , vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From  #PercentPopulationVaccinated



--- creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int , vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *
from PercentPopulationVaccinated