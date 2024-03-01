--Select *
--From PortfolioProject..CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccination
--ORDER BY 3,4


---Selecting the data that we are going to be using in this project.

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
ORDER BY 1, 2



--Calculating the Total Cases vs Total Deaths.
-- Shows Likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2


---Calculating Total cases VS Population
--- Shows what percentage of population got Covid 

Select Location, date, population, total_cases, (total_cases/population)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--- WHERE location like '%states%'
ORDER BY 1, 2


---Looking at countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--- WHERE location like '%states%'
GROUP BY Location, population
ORDER BY PercentagePopulationInfected desc


-- Countries with Highest Death Count per population

Select Location, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--- WHERE location like '%states%'
GROUP BY Location
ORDER BY TotalDeathCount desc


-- Showing contintents with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2


Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date =vac.date
	Where dea.continent is not null
	order by 2, 3

	--Note that Cast and Convert basically do the same thing.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date =vac.date
	Where dea.continent is not null
	order by 2, 3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date =vac.date
	Where dea.continent is not null
	--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



--TEMP TABLE

DROP TABLE if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date =vac.date
	--Where dea.continent is not null
	--order by 2, 3

	Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



---- Creating view to store data for later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
--order by 2, 3

SELECT *
FROM PercentPopulationVaccinated