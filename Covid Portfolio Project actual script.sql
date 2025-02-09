Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVacinations
--order by 3,4

-- select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contact covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
where location like '%Nigeria%'
and continent is not null 
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulatioInfected 
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulatioInfected 
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by Location, Population
order by PercentPopulatioInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by Location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast (New_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
-- where location like '%Nigeria%'
where continent is not null
-- group by date
order by 1,2


-- Looking at Total Population vs Vacinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location 
 Order by dea.location, dea.Date) as RollingPeopleVacinated
 --, (RollingPeopleVacinated/Population)*100

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (continent, Location, Date, Population, New_Vacinations, RollingPeopleVaccinated)
as
(  
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location 
 Order by dea.location, dea.Date) as RollingPeopleVacinated
 --, (RollingPeopleVacinated/Population)*100

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location 
 Order by dea.location, dea.Date) as RollingPeopleVacinated
 --, (RollingPeopleVacinated/Population)*100

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated



 -- Creating view to store data for later visualizations 


create view PercentPopulationVacinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location 
 Order by dea.location, dea.Date) as RollingPeopleVacinated
 --, (RollingPeopleVacinated/Population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
 --order by 2,3

 select *
 from PercentPopulationVacinated 

