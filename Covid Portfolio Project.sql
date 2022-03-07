--Select *
--From PortfolioProject..CovidDeaths
--order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..CovidDeaths
--order by 1,2

----Total cases vs total deaths
--Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--Where location like '%Australia%'
--order by 1,2

---- Looking total cases vs population
---- Shows what percentage of the population got covid
--Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
--From PortfolioProject..CovidDeaths
----Where location like '%Hungary%'
--order by 1,2

---- Looking at countries with highest infection rates compared to population
--Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
--From PortfolioProject..CovidDeaths
----Where location like '%Hungary%'
--Group by Location, Population
--order by PercentPopulationInfected desc

-- Showing countries with highest death count per population

--Select Location, MAX(cast(Total_cases as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths
----Where location like '%Hungary%'
--Where continent is not null
--Group by Location
--order by TotalDeathCount desc


---- Breaking figures down by continent
--Select location, MAX(cast(Total_cases as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths
----Where location like '%Hungary%'
--Where continent is null
--Group by location
--order by TotalDeathCount desc

-- Global numbers
--Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/(SUM(new_cases))*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%Hungary%'
--Where continent is not null
----Group by date
--order by 1,2

-- Merging total population vs vaccination
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--From PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--     On dea.location = vac.location
--	 and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3


-- USE CTE

--With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
--as
--(
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--From PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--     On dea.location = vac.location
--	 and dea.date = vac.date
--Where dea.continent is not null
---- order by 2,3
--)
--Select *, (RollingPeopleVaccinated/Population)*100
--From PopvsVac

--  TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3

Select *
From PercentPopulationVaccinated