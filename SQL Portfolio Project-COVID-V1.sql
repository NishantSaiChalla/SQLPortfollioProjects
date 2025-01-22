Select *
from CovidDeaths
where continent is not null
order by 3,4

--Select *
--from CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
order by 1, 2

--Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
Where location='india'
order by 1, 2

--Looking at Total Cases vs Population 
Select location, date, total_cases, population, (total_cases/population)*100 as CovidPopulationPercentage
from CovidDeaths
Where location='india'
order by 1, 2

--Looking at countries with highest infection rate compared to population
Select location, Max(total_cases) as highesinfectioncount, population, MAX((total_cases/population))*100 as PopulationPercentageinfected
from CovidDeaths
--Where location='india'
Group by population, location
order by 4 DESC

--Looking at countries with highest Deathcount per population
Select location, Max(cast( total_deaths as int)) as totaldeathcount, population, MAX((total_deaths/population))*100 as PopulationPercentagedeaths
from CovidDeaths
--Where location='india'
where continent is not null
Group by population, location
order by 2 DESC

-------

Select continent, Max(cast( total_deaths as int)) as totaldeathcount
from CovidDeaths
--Where location='india'
where continent is not null
Group by continent
order by 2 DESC

--Global numbers

Select  /*date,*/ sum(new_cases) as totalcases ,sum(cast(new_deaths as int)) as totaldeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
--Where location='india'
where continent is not null
--group by date
order by 1, 2

--total population vs vaccinated
select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as int)) 
OVER (partition by cd.location order by cd.location, cd.date) as RollingPeopleVac
from CovidDeaths as cd
join  CovidVaccinations as cv
    On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3
 


 --CTE

 With PopVsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVac)
 as
(
select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as int)) 
OVER (partition by cd.location order by cd.location, cd.date) as RollingPeopleVac
from CovidDeaths as cd
join  CovidVaccinations as cv
    On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVac/population)*100
from PopVsVac

--temp table
Drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingpeopleVac numeric
)
insert into #percentPopulationVaccinated
select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as int)) 
OVER (partition by cd.location order by cd.location, cd.date) as RollingPeopleVac
from CovidDeaths as cd
join  CovidVaccinations as cv
    On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3

Select *,(RollingpeopleVac/population)*100
from #percentPopulationVaccinated

-- creating view fos vis
create view percentPopulationVaccinated as

select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as int)) 
OVER (partition by cd.location order by cd.location, cd.date) as RollingPeopleVac
from CovidDeaths as cd
join  CovidVaccinations as cv
    On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3

select*
from percentPopulationVaccinated

