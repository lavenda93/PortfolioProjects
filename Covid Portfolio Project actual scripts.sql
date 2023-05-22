--select *
--from dbo.coviddeathscsv

select *
from portfolioproject..coviddeathscsv
where continent is not null
order by 3, 4

--select *
--from portfolioproject..Covidvaccinations
--order by 3, 4

--select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From portfolioproject..coviddeathscsv
Order by 1,2

--Looking at the Total cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolioproject..coviddeathscsv
Order by 1,2

--because i modified a few columns prior to loading, the datatype was varchar and so threw an error. proceed to change it to float:

SELECT * FROM INFORMATION_SCHEMA.COLUMNS where table_name = 'coviddeathscsv' AND column_name = 'total_cases';
--above query shows that my datatype is varchar

ALTER TABLE coviddeathscsv
ALTER COLUMN total_cases float

ALTER TABLE coviddeathscsv
ALTER COLUMN total_deaths float

SELECT * FROM INFORMATION_SCHEMA.COLUMNS where table_name = 'coviddeathscsv' AND column_name = 'total_deaths';
--above query reflects the change to float  


--shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolioproject..coviddeathscsv
Where location = 'Nigeria'
Order by 1,2

--looking at the total cases vs population in Nigeria
--shows what percentage of population has got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPoppulationInfected
From portfolioproject..coviddeathscsv
--Where location like %states%
Order by 1,2


-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentpopulationInfected
From portfolioproject..coviddeathscsv
--Where location like %states%
Group by location, population
Order by 4 desc


--showing the countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolioproject..coviddeathscsv
--Where location like %states%
Where continent is not null
Group by location
Order by TotalDeathCount desc


--LETS LOOK AT CONTINENT
 --Showing the continents with the highest death counts

Select continent, MAX(total_deaths) as TotalDeathCount
From portfolioproject..coviddeathscsv
--Where location like %states%
Where continent is not null
Group by continent
Order by TotalDeathCount desc 



--Global numbers


Select date, SUM(CAST(new_cases as float))as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as Death_percentage
From portfolioproject..coviddeathscsv
--Where location like %states%
where continent is not null and new_cases <> 0 and new_deaths <> 0
Group by date
Order by 1,2

--Aggregate

Select SUM(CAST(new_cases as float))as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as Death_percentage
From portfolioproject..coviddeathscsv
--Where location like %states%
where continent is not null
--Group by date
Order by 1,2


--looking at total population vs vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacc
--(RollingPeopleVacc/population)*100
From Portfolioproject..coviddeathscsv dea
Join Portfolioproject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (Continent, location, date, population,new_vaccinations, RollingPeopleVacc) as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacc
--(RollingPeopleVacc/population)*100
From Portfolioproject..coviddeathscsv dea
Join Portfolioproject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVacc/population)*100
From PopvsVac


--Temp Table

DROP table if exists #percentPopulationVaccinated
DROP table if exists #percentPopulationVaccinated2
Create Table #percentPopulationVaccinated
(
continent nvarchar(50),
location nvarchar(50),
date date,
population varchar(50),
new_vaccinations nvarchar(50),
RollingPeopleVacc numeric
)

Insert into #percentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacc
--(RollingPeopleVacc/population)*100
From Portfolioproject..coviddeathscsv dea
Join Portfolioproject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
-- where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVacc/Population)*100
From #percentPopulationVaccinated




--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacc
--(RollingPeopleVacc/population)*100
From Portfolioproject..coviddeathscsv dea
Join Portfolioproject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated

Create View DeathPercentageBydate as
Select date, SUM(CAST(new_cases as float))as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as Death_percentage
From portfolioproject..coviddeathscsv
--Where location like %states%
where continent is not null and new_cases <> 0 and new_deaths <> 0
Group by date
--Order by 1,2

Select *
From DeathPercentageBydate

