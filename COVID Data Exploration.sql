/* 
COVID Data Exploration

Skills Displayed: Joins CTE's, Temp Tables, Windows Functions, Aggregate Functions Creating Views, Converting Data Types

*/


--Selects the data we are going to be using in our first table
Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
Order By 1,2;

--Total Cases vs Total Deaths in the United States (shows likelihood of dying if infected by COVID)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From Portfolio..CovidDeaths
Where location = 'United States'
Order By 1,2;

--Total Cases vs Population in United States (shows the percentage of the population that has been infected by COVID)
Select location, date, population, total_cases, (total_cases/population)*100 as percent_infected
From Portfolio..CovidDeaths
Where location = 'United States'
Order By 1,2;

--Countries with the highest infection rate
Select location, population, max(total_cases) as max_infection_count, max((total_cases/population))*100 as max_infection_rate
From Portfolio..CovidDeaths
Group By location, population
Order By max_infection_rate DESC;

--Countries with the highest death count
Select location, max(total_deaths) as max_death_count
From Portfolio..CovidDeaths
Where continent is Not Null 
Group By location
Order By max_death_count DESC;

--Lets break down highest death count by continent
Select continent, max(total_deaths) as max_death_count
From Portfolio..CovidDeaths
Where continent is Not Null 
Group By continent
Order By max_death_count DESC;

--Global death percentage by date
Select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as death_percentage
From Portfolio..CovidDeaths
Where continent is not null
Group By date
Order By 1,2;




--(1)Total Population vs Vaccinations by joining tables
Select dea.continent, dea.location, dea.date, population, new_vaccinations, 
sum(cast(new_vaccinations as int)) OVER (Partition By dea.location Order By dea.location, dea.date) as running_total_vaccinations
From Portfolio..CovidDeaths dea join Portfolio..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
Where dea.continent is Not Null and new_vaccinations is Not Null;

--Using a CTE to run calculations on new column in example (1)
With pop_vs_vac (continent, location, date, population, new_vaccinations, running_total_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, population, new_vaccinations, 
sum(cast(new_vaccinations as int)) OVER (Partition By dea.location Order By dea.location, dea.date) as running_total_vaccinations
From Portfolio..CovidDeaths dea join Portfolio..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
Where dea.continent is Not Null and new_vaccinations is Not Null
)
Select *, (running_total_vaccinations/population)*100 as percent_vaccinated
From pop_vs_vac

--Using Temp Table to run calculations on new column in example (1)
--We use drop table if exists in case we are updating or altering this table after we have run it for the first time
Drop Table if exists percentage_vac
Create Table percentage_vac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
running_total_vaccinations numeric
) 
Insert into percentage_vac
Select dea.continent, dea.location, dea.date, population, new_vaccinations, 
sum(cast(new_vaccinations as int)) OVER (Partition By dea.location Order By dea.location, dea.date) as running_total_vaccinations
From Portfolio..CovidDeaths dea join Portfolio..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
Where dea.continent is Not Null and new_vaccinations is Not Null

Select *, (running_total_vaccinations/population)*100 as percent_vaccinated
From percentage_vac



--Creating view to store data for later visualizations
Create View vaccination_percentage as 
Select dea.continent, dea.location, dea.date, population, new_vaccinations, 
sum(cast(new_vaccinations as int)) OVER (Partition By dea.location Order By dea.location, dea.date) as running_total_vaccinations
From Portfolio..CovidDeaths dea join Portfolio..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
Where dea.continent is Not Null and new_vaccinations is Not Null