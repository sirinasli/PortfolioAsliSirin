/****** Script for SelectTopNRows command from SSMS  ******/
SELECT * 
from
Portfolio..[covid-deaths]
order by 3,4


SELECT Location
,date
,total_cases
,new_cases
,total_deaths
,population
from
Portfolio..[covid-deaths]
order by 1,2


--Total Cases vs Total Deaths

Select 
Location
,date
,total_cases
,total_deaths
,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from
Portfolio..[covid-deaths]
where location like '%states%'
order by 1,2


--Total Cases vs Population

Select 
Location
,date
,population
,total_cases
,(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS CasePercentage
from
Portfolio..[covid-deaths]
--where location like '%states%'
where continent is not null
order by 1,2


--Countries with the highest infection rate compared to location

Select 
Location
,population
,Max(total_cases) as HighestInfectCount
,Max((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100) AS CasePercentage
from
Portfolio..[covid-deaths]
--where location like '%states%'
where continent is not null
group by population, location
order by CasePercentage desc


--Countries with the highest death count per population

Select 
Location
,MAX(CAST(ISNULL(total_deaths, '0') AS INT)) AS TotalDeathCount
from
Portfolio..[covid-deaths]
where continent is not null
group by location
order by TotalDeathCount desc


--Continents with the highest death count

Select 
continent
,MAX(CAST(ISNULL(total_deaths, '0') AS INT)) AS TotalDeathCount
from
Portfolio..[covid-deaths]
where continent is not null 
group by continent
order by TotalDeathCount desc




Select 
continent
,MAX(CAST(ISNULL(total_deaths, '0') AS INT)) AS TotalDeathCount
from
Portfolio..[covid-deaths]
where continent is not null 
group by continent
order by TotalDeathCount desc


--Global Numbers (check for the error !!!)

Select 

SUM(new_cases) as totalcases
,SUM(cast(new_deaths as integer)) as totaldeaths
,CASE 
        WHEN SUM(new_cases) = 0 THEN 0
        ELSE (SUM(CAST(new_deaths AS INTEGER)) / SUM(new_cases)) * 100 
    END AS DeathPercentage

from
Portfolio..[covid-deaths]
--where location like '%states%'
where continent is not null 
--group by date
order by 1,2


--Total Population vs. Vaccinations

Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
,SUM(CAST(CV.new_vaccinations as float)) OVER (Partition by CD.location order by cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/CD.population
from Portfolio..[covid-deaths] CD
Join Portfolio..[covid-vax] CV
on CD.location=CV.location
and CD.date=CV.date
where CD.continent is not null
order by 2,3


-- USE CTE

With PopvsVax (Continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
,SUM(CAST(CV.new_vaccinations as float)) OVER (Partition by CD.location order by cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/CD.population
from Portfolio..[covid-deaths] CD
Join Portfolio..[covid-vax] CV
on CD.location=CV.location
and CD.date=CV.date
where CD.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as RollingPerc
from PopvsVax


--Temp Table

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(Continent nvarchar(255)
, location nvarchar(255)
, date datetime
, population numeric
, new_vaccinations numeric
,RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
,SUM(CAST(CV.new_vaccinations as float)) OVER (Partition by CD.location order by cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/CD.population
from Portfolio..[covid-deaths] CD
Join Portfolio..[covid-vax] CV
on CD.location=CV.location
and CD.date=CV.date
--where CD.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100 as RollingPerc
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as

Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
,SUM(CAST(CV.new_vaccinations as float)) OVER (Partition by CD.location order by cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/CD.population
from Portfolio..[covid-deaths] CD
Join Portfolio..[covid-vax] CV
on CD.location=CV.location
and CD.date=CV.date
where CD.continent is not null
--order by 2,3