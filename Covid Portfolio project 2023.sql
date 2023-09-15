select * from PortfolioProject..covid_deaths

select * from PortfolioProject..covid_vaccinations


select location, date, total_cases, total_deaths, population
from PortfolioProject..covid_deaths
order by 1,2

--looking at total cases vs Total Deaths
-- shows the likelihood of dying if you contract covid
select location, date, total_cases, total_deaths, (Total_deaths/total_cases)* 100 as Death_percentage
from PortfolioProject..covid_deaths
where location like '%Nigeria%'
order by 1,2

-- looking at Total Cases vs Population
-- shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population) as Percent_population_infected
from PortfolioProject..covid_deaths
where location like '%Nigeria%'
order by 1,2


-- looking at countries with Highest Infection Rate compared to population
select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))* 100 as Percent_population_infected
from PortfolioProject..covid_deaths
-- where location like '%Nigeria%'
group by location, population
order by Percent_population_infected desc


-- showing countries with the highest death count per population
select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..covid_deaths
-- where location like '%Nigeria%'
where continent is not null
group by location
order by TotalDeathCount desc


---lets break things down by continent
--showing the contient with the highest death count per population

select continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..covid_deaths
-- where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global numbers
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases)) * 100 as death_percentage
from PortfolioProject..covid_deaths
--where location like '%Nigeria%'
where continent is not null
order by 1,2



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..covid_vaccinations vac
join PortfolioProject..covid_deaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select * from PercentPopulationVaccinated