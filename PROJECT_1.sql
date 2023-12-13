select * from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--select * from PortfolioProject.dbo.CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
order by 1,2

--Total cases VS Total deaths (show likelihood of dying when contract covid)

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2

--Total cases VS Population (show what percentage of population got covid)

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


--BREAK THINGS DOWN BY CONTINENT

--Showing continents with the Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage 
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

     

--looking at Total Population vs Vaccination


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject.dbo.CovidDeaths dea
 join PortfolioProject.dbo.CovidVaccinations vac
       on dea.location = vac.location
       and dea.date = vac.date
where dea.continent is not null
order by 2,3


---USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject.dbo.CovidDeaths dea
 join PortfolioProject.dbo.CovidVaccinations vac
       on dea.location = vac.location
       and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject.dbo.CovidDeaths dea
 join PortfolioProject.dbo.CovidVaccinations vac
       on dea.location = vac.location
       and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated 



Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject.dbo.CovidDeaths dea
 join PortfolioProject.dbo.CovidVaccinations vac
       on dea.location = vac.location
       and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * From PercentPopulationVaccinated