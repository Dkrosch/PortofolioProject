/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


select* from ['covid death$']
order by 3,4

select* from ['covid vaccination$']
order by 3,4

-- Select Data that we are going to be starting with
select location, date, total_cases, new_cases, total_deaths, population
from ['covid death$']
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercantage
from ['covid death$']
where location like '%indonesia%'
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date, population,total_cases,  (total_cases/population)*100 as percentPopulationInfected
from ['covid death$']
--where location like '%indonesia%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

select location,population,MAX(total_cases) as highestInfection ,max((total_cases/population))*100 as percentPopulationInfected
from ['covid death$']
--where location like '%indonesia%'
group by location,population
order by percentPopulationInfected desc



-- Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as totalDeathCount
from ['covid death$']
--where location like '%indonesia%'
where continent is not null
group by location,population
order by totalDeathCount desc





-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent, max(cast(total_deaths as int)) as totalDeathCount
from ['covid death$']
--where location like '%indonesia%'
where continent is not null
group by continent
order by totalDeathCount desc



-- GLOBAL NUMBERS

select date, SUM(new_cases) as total_case2  , SUM(cast (new_deaths as int)) as total_death,  SUM(cast (new_deaths as int))/SUM(new_cases)  *100 as deathPercantage
from ['covid death$']
--where location like '%indonesia%'
where continent is not null
group by date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert (bigint, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_vaccination
from ['covid death$']dea
join ['covid vaccination$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

with PopulationvsVaccinated (continent,location,date,population,new_vaccinations,total_vaccinations)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert (bigint, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_vaccination
from ['covid death$']dea
join ['covid vaccination$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (total_vaccinations/population) *100 as vaccination_percentage
from PopulationvsVaccinated


-- Using Temp Table to perform Calculation on Partition By in previous query
drop table if exists #percentage_vaccination
create table #percentage_vaccination
(continent nvarchar(255), location nvarchar (255), date datetime, population numeric, new_vaccinations numeric, total_vaccination numeric)

insert into #percentage_vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert (bigint, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_vaccination
from ['covid death$']dea
join ['covid vaccination$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (total_vaccination/population) *100 as vaccination_percentage
from #percentage_vaccination




-- Creating View to store data for later visualizations

create view percentage_vaccination as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert (bigint, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_vaccination
from ['covid death$']dea
join ['covid vaccination$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
