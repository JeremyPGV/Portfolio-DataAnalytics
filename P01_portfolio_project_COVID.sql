SELECT*
from PortfolioProject..CovidDeaths2
WHERE continent is not null
Order by 3,4

SELECT*
from PortfolioProject..CovidVaccinations
Order by 3,4


-- _____________________________________________________ Début du projet _________________________________

-- Sélection des données que nous allons utiliser

SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidData
WHERE continent is not null
Order by 1,2

-- Comparaison entre Cas totaux et le total de décès en France

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths2
WHERE continent is not null AND location like '%FRANCE%'
Order by 1,2

-- Comparaison entre la population et le nombre de cas totaux en france et dans le monde

SELECT location,date,population,total_cases, (total_cases/population)*100 AS CASESPERCENTAGE
FROM PortfolioProject..CovidDeaths2
WHERE continent is not null
WHERE location like '%FRANCE%' --pour avoir la vue mondiale on commente cette ligne
Order by 1,2

-- Recherche du pays avec le taux d'infection le plus haut

SELECT location,population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS MAXCASESPERCENTAGE
FROM PortfolioProject..CovidDeaths2
WHERE continent is not null
Group by location,population
ORDER BY MAXCASESPERCENTAGE DESC



-- Recherche du pays avec le taux de mortalité le plus élevé

SELECT location,population,MAX(total_deaths) AS HighestDeathsCount, MAX((total_deaths/total_cases)*100) AS MaxDeathsPercentage
FROM PortfolioProject..CovidDeaths2
WHERE continent is not null
--WHERE location like '%FRANCE%' --pour avoir la vue mondiale on commente cette ligne
Group by location,population
ORDER BY MaxDeathsPercentage DESC

-- Recherche du pays avec le grand nombre de mort

SELECT location,MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths2
WHERE continent is not null
Group by location
Order by TotalDeathsCount DESC

-- Recherche du continent avec le grand nombre de mort

SELECT location,MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths2
WHERE continent is null
Group by location
Order by TotalDeathsCount DESC

-- Par date, le nombre de nouveaux cas, le nombre de nouveaux décès et le % entre nouveau cas et nouveaux décès

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases) AS DeathPercentage
FROM PortfolioProject..CovidDeaths2
Where continent is not null
GROUP BY date
Order by 1,2

-- Dans le monde, le nombre de nouveaux cas, le nombre de nouveaux décès et le % entre nouveau cas et nouveaux décès

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths2
Where continent is not null
--GROUP BY date
Order by 1,2


-- JOINTURE entre les tables covid deaths et covid vaccinations 
-- pour obtenir un rapport entre la population totale et les vaccinations

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths2 dea
JOIN PortfolioProject..CovidVaccinations2 vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



-- Somme par pays et par jour du nombre de vaccinés

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths2 dea
JOIN PortfolioProject..CovidVaccinations2 vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3


-- Somme par pays et par jour du nombre de vaccinés

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths2 dea
JOIN PortfolioProject..CovidVaccinations2 vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Création de vues pour la future visualisation

CREATE View TotalDeathsCountperContinent as
SELECT location,MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths2
WHERE continent is null
Group by location


