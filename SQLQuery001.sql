--*
--Covid 19 Data Exploration 


*/

Select *
From ['COVIDDEATHS]
--Where continent is not null 
order by 1,2


Select Location, date, total_cases, new_cases, total_deaths, population
From ['COVIDDEATHS]
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths (Shows the likelyhood of dying from COVID-19 if you are in Nigeria)

Select Location, date, total_cases, total_deaths,(cast(total_deaths as float)/total_cases)*100 as DeathPercentage
From ['COVIDDEATHS]
Where location = 'Nigeria'
order by 1,2


-- Total Cases vs Population (Shows what percentage of population is infected with Covid)

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From COVIDVaccinations
--Where location = 'Nigeria'
order by 5 desc 


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ['COVIDDEATHS]
Group by Location, Population
order by 4 desc


-- Countries with Highest Death Count per Population

Select Location, MAX(Convert(int,Total_deaths)) as TotalDeathCount
From ['COVIDDEATHS]
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT (Showing contintents with the highest death count per population)

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ['COVIDDEATHS]
--Where location like '%states%'
Where continent is null AND location not like '%income%'
Group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/NULLIF(SUM(new_Cases), 0)*100 as DeathPercentage
From ['COVIDDEATHS]
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2 desc




-- Total Population vs Vaccinations (Shows Percentage of Population that has recieved at least one Covid Vaccine)
-- 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['COVIDDEATHS] dea
Join COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null AND dea.location NOT LIKE '%income%'
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['COVIDDEATHS] dea
Join COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)* 100 as PercentageRPV
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
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['COVIDDEATHS] dea
Join COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageRPV
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['COVIDDEATHS] dea
Join COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *
From PercentPopulationVaccinated