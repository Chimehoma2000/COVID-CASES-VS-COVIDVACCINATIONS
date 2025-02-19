select * 
from SQLPROJECT..CovidDeaths
WHERE continent is not null
order by 3, 4

select * 
from SQLPROJECT..CovidVaccinations
WHERE continent is not null

--selecting a few random colmns

select continent, location, date, new_deaths
from SQLPROJECT..CovidDeaths
WHERE continent is not null
order by 3,4

--viewing the continents

select distinct continent
from SQLPROJECT..CovidDeaths

--viewing the locations (countries)

select distinct location
from SQLPROJECT..CovidDeaths



--CODE 3 (selecting data we need)

SELECT location, date, total_cases, total_deaths, population
FROM SQLPROJECT..CovidDeaths
WHERE continent is not null
Order by 1, 2



-- Total cases vs total deaths
-- shows percentage likelihood of dying if you contract COVID

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage -- * results by 100 to get a percentage value
FROM SQLPROJECT..CovidDeaths
where location like '%Nigeria%' AND continent is not null ---- by location
Order by 1, 2



-- Total cases vs population
-- shows the percentage of population with COVID

SELECT location, date, total_cases, population, (total_cases/Population)*100 as PercentPopulationInfected--- lower no./higher no
FROM SQLPROJECT..CovidDeaths
where location like '%Nigeria%' AND continent is not null ---- by location
Order by 1, 2



--Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected--- lower no./higher no
FROM SQLPROJECT..CovidDeaths
Group by Location, population
--where location like '%Nigeria%' AND continent is not null 
Order by PercentPopulationInfected desc


--countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount  
from SQLPROJECT..CovidDeaths
Group by location
--where location like '%Nigeria%' 
Order by TotalDeathCount desc --error in TotalDeathCount column because of an error in data type which is supposed to be Int.(numbers)

--CORRECTIONS

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount  --- cast(convert data type from one to another)
from SQLPROJECT..CovidDeaths
--where location like '%Nigeria%'
WHERE continent is not null
Group by location
Order by TotalDeathCount desc 

--By CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount  --- cast(convert data type from one to another)
from SQLPROJECT..CovidDeaths
--where location like '%Nigeria%'
WHERE continent is not null
Group by continent
Order by TotalDeathCount desc 



--GLOBAL NUMBERS!!

SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
FROM SQLPROJECT..CovidDeaths
--where location like '%Nigeria%' 
Where continent is not null ---- by location
Group by Date
Order by 1, 2


--Select tables
SELECT *
FROM SQLPROJECT..CovidDeaths


SELECT *
FROM SQLPROJECT..CovidVaccinations


--Looking at total population vs vaccination (Join)

SELECT dea.continent, dea. location, dea. date, dea. population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea. location order by dea. location, 
dea. date) as RollingPeopleVaccinated---rolling count
FROM SQLPROJECT..CovidDeaths dea
JOIN SQLPROJECT..CovidVaccinations vac
  ON dea.location = vac. location  --- by location
  and dea.date = vac.date -- by date
Where dea.continent is not null 
order by 2,3

--USE CTE

with Popvsvac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea. location, dea. date, dea. population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea. location order by dea. location, 
dea. date) as RollingPeopleVaccinated
FROM SQLPROJECT..CovidDeaths dea
JOIN SQLPROJECT..CovidVaccinations vac
  ON dea.location = vac. location
  and dea.date = vac.date -- by date
Where dea.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea. location, dea. date, dea. population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea. location order by dea. location, 
dea. date) as RollingPeopleVaccinated
FROM SQLPROJECT..CovidDeaths dea
JOIN SQLPROJECT..CovidVaccinations vac
  ON dea.location = vac. location
  and dea.date = vac.date -- by date
Where dea.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated
 

 --Creating view to store data for visualizations


 Create view PercentPopulationVaccinated as
 SELECT dea.continent, dea. location, dea. date, dea. population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea. location order by dea. location, 
dea. date) as RollingPeopleVaccinated
FROM SQLPROJECT..CovidDeaths dea
JOIN SQLPROJECT..CovidVaccinations vac
  ON dea.location = vac. location
  and dea.date = vac.date -- by date
Where dea.continent is not null 
--order by 2,3