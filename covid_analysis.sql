Select *
From PortolioProject..CovidDeaths
order by 3, 4


--Select *
--From PortolioProject..CovidVaccinations
--order by 3, 4

-- Select the Data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths for Australia

Select Location, date, total_cases, total_deaths, ROUND((total_deaths / total_cases) * 100, 2) as mortality_rate
From PortolioProject..CovidDeaths
Where location like '%australia%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, population, ROUND((total_cases / population) * 100, 2) as death_percentage
From PortolioProject..CovidDeaths
Where location like '%australia%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to its Population

Select Location, MAX(total_cases) as HighestInfectinoCount, population, MAX((total_cases / population) * 100) as death_percentage
From PortolioProject..CovidDeaths
Group by location, population
order by death_percentage desc

-- Showing Countries/Continents  with the highest mortality rate per population

-- Countries
Select Location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc
-- Continents
Select continent, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Showing total deaths for  countries by continent
Select location, SUM(cast(total_deaths as int)) as TotalDeathCount
From PortolioProject..CovidDeaths
Where continent is not null and continent like '%asia%'
Group by location
Order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100, 3) as DeathPercentage
From PortolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2

-- Joining Vaccinations and Deaths tables

Select *
From PortolioProject..CovidDeaths deaths
Join PortolioProject..CovidVaccinations vaccinatinos
	On deaths.location = vaccinatinos.location
	and deaths.date = vaccinatinos.date

-- Looking at Total Population vs Vaccinations

--USING CTE
With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingVaccinatedCount)
as 
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
SUM(Cast(vaccinations.new_vaccinations as int)) OVER (Partition by deaths.location Order by deaths.location, deaths.date)
as RollingVaccinatedCount
From PortolioProject..CovidDeaths deaths
Join PortolioProject..CovidVaccinations vaccinations
	On deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null
)
Select *, ROUND((RollingVaccinatedCount/Population) * 100, 2) as PercentageVaccinated
From PopvsVac

--TEMPORARY TABLE
--Drop table if it already exists
Drop Table if exists #PercentPopulationVaccinated
-- Create a new table withe the correct columns
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccination numeric
)


-- Insert the data into the new table
Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
SUM(Cast(vaccinations.new_vaccinations as int)) OVER (Partition by deaths.location Order by deaths.location, deaths.date)
as RollingVaccinatedCount
From PortolioProject..CovidDeaths deaths
Join PortolioProject..CovidVaccinations vaccinations
	On deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null

-- Show entire continents from the newly created table
Select * From #PercentPopulationVaccinated


--Creating Views

Create View PercentPopulationVaccinated as 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
SUM(Cast(vaccinations.new_vaccinations as int)) OVER (Partition by deaths.location Order by deaths.location, deaths.date)
as RollingVaccinatedCount
From PortolioProject..CovidDeaths deaths
Join PortolioProject..CovidVaccinations vaccinations
	On deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null

Select * From PercentPopulationVaccinated