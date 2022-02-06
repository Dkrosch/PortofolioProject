select* from ['covid death$']
order by 3,4

--select* from ['covid vaccination$']
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from ['covid death$']
order by 1,2

-- total case vs total death

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercantage
from ['covid death$']
where location like '%indonesia%'
order by 1,2

-- total case vs population

select location, date, population,total_cases,  (total_cases/population)*100 as percentPopulationInfected
from ['covid death$']
--where location like '%indonesia%'
order by 1,2

-- highest infection rate

select location,population,MAX(total_cases) as highestInfection ,max((total_cases/population))*100 as percentPopulationInfected
from ['covid death$']
--where location like '%indonesia%'
group by location,population
order by percentPopulationInfected desc

-- highest death count per population

select location, max(cast(total_deaths as int)) as totalDeathCount
from ['covid death$']
--where location like '%indonesia%'
where continent is not null
group by location,population
order by totalDeathCount desc

-- break by continent



-- continent highest death count

select continent, max(cast(total_deaths as int)) as totalDeathCount
from ['covid death$']
--where location like '%indonesia%'
where continent is not null
group by continent
order by totalDeathCount desc


-- global numbers

select date, SUM(new_cases) as total_case2  , SUM(cast (new_deaths as int)) as total_death,  SUM(cast (new_deaths as int))/SUM(new_cases)  *100 as deathPercantage
from ['covid death$']
--where location like '%indonesia%'
where continent is not null
group by date
order by 1,2


-- total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert (bigint, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_vaccination
from ['covid death$']dea
join ['covid vaccination$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- cte

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


-- temp table
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

--create view for later

create view percentage_vaccination as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert (bigint, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_vaccination
from ['covid death$']dea
join ['covid vaccination$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3