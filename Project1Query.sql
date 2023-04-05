Select *
From [Project 1]..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From [Project 1]..CovidVaccinations
--order by 3,4

--Select data that we will be using

Select location, date, total_cases, new_cases, total_deaths, population
From [Project 1]..CovidDeaths
Where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
-- shows likelyhood of dying from Covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Project 1]..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


-- looking at Total Cases vs Population
-- Shows what percentage got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
From [Project 1]..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at highest Infection Rate vs Population
-- Highest Infection Rate compared by population Select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
-- Shows what percentage got Covid

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Project 1]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- Looking at countries with the highest death count per population
--- Without adding cast and int syntax the numbers came up as 9s due to them not being nvarchar data format 
---- Would read as Select location, Max(total_deaths) as TotalDeathCount

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Project 1]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc



-- LETS BREAK THINGS DOWN BY CONTINENT



-- Showing continets with highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Project 1]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Breaking global numbers
-- Showing total cases, total deaths
Select date, sum(new_cases) as total_cases, SUM(cast (New_Deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Project 1]..CovidDeaths
--Where location like '%states%'
where continent is not null
group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
-- Cannot use table just made, so we need to create CTE
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Project 1]..CovidDeaths dea
join [Project 1]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Project 1]..CovidDeaths dea
join [Project 1]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)* 100
From PopvsVac



-- Temp Table
DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Project 1]..CovidDeaths dea
join [Project 1]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)* 100
From #PercentPopulationVaccinated






-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Project 1]..CovidDeaths dea
join [Project 1]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
