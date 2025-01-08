select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select data that we are going to be using

select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country.

select Location,date,total_cases,total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at the total cases vs population
--shows what percentage of population got Covid

select Location,date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking for Country Highest Infection Rate Compared To Population
select Location, population, MAX(total_cases)as HighestInfectionCount, Max((total_cases/population))*100 as
PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by Location, population
order by PercentagePopulationInfected desc

--Showing Countries With Highest Death Count Per Population
select Location,MAX(Cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc


--LET'S BREAK THINGS UP A LITTLE BIT BY CONTINENT

--Showing continents with highest death count per population
select continent, MAX(Cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--Total Population Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) Over (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) Over (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric )

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) Over (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated


--Creating Views To Store Data For later Visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) Over (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3