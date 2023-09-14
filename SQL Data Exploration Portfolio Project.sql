SELECT *
FROM Portfolioproject..CovidDeaths
WHERE continent is not null

--SELECT*
--FROM Portfolioproject..CovidVaccinations


--SELECT Data that we are going to be using


SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM Portfolioproject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Looking ata Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country


SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
FROM Portfolioproject..CovidDeaths
WHERE location like '%India%' 
and  continent is not null
ORDER BY 1,2

--Looking at TotalCases vs Population
--shows what percentage of population got covid


SELECT Location,date,population,total_cases,(total_cases/population)*100 as percentpopulationInfected
FROM Portfolioproject..CovidDeaths
--WHERE location like '%India%'
WHERE continent is not null
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to population


SELECT Location,population,max(total_cases)as HighestInfecionCount,(max(total_cases/population))*100 as PercentPopulationInfected
FROM Portfolioproject..CovidDeaths
--WHERE location like '%India%'
WHERE continent is not null
GROUP BY Location,population
ORDER BY PercentPopulationInfected desc


-- Showing Countries with Highest Death Count Per Population


SELECT Location,max(CAST(total_deaths as int))as TotalDeathCount
FROM Portfolioproject..CovidDeaths
--WHERE location like '%India%'
WHERE continent is not null
GROUP BY Location,population
ORDER BY TotalDeathCount desc

-- Let's Break things down by continent

-- showing continents with highest death count per population


SELECT continent, max(CAST(total_deaths as int))as TotalDeathCount
FROM Portfolioproject..CovidDeaths
--WHERE location like '%India%'
WHERE continent is not null
GROUP BY continent,
ORDER BY TotalDeathCount desc



-- Global Numbers


SELECT sum(total_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM Portfolioproject..CovidDeaths
--WHERE location like '%India%' 
where continent is not null
--group by date
ORDER BY 1,2


--- Looking at Total Population 


SELECT dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as
RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3



--USING CTE


WITH  popvsvac(continent,date,location,population,new_vaccinations,RollingPeopleVaccinated) as
(
SELECT dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as
RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
from  popvsvac


--- Temp Table


Drop Table if exists #PercentPopulationVaccinated2
Create Table #PercentPopulationVaccinated2
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into  #PercentPopulationVaccinated2
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as
RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100
from  #PercentPopulationVaccinated2



--Creating view to store data for later visualizations


 Create view PercentPopulationVaccinated2 as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as
RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated2