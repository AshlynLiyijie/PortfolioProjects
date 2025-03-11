USE COVID;

-- Select Data that will be used
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths;

SELECT DISTINCT new_vaccinations 
FROM CovidVaccinations;

-- Look at Total Cases vs Total Deaths: shows the likehood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, 
    (CAST(total_deaths AS FLOAT)/total_cases)*100 AS death_rate
FROM CovidDeaths
WHERE Location like '%United States%';

-- Look at Total Cases vs Population: shows what percentage of population got covid
SELECT Location, date, total_cases, population, 
    (CAST(total_cases AS FLOAT)/population)*100 AS infection_rate
FROM CovidDeaths;

-- Look at country with highest infection rate
SELECT Location, population, MAX(total_cases) cases_count,
    MAX(CAST(total_cases AS FLOAT)/population)*100 AS max_infection_rate
FROM CovidDeaths
GROUP BY Location, population
ORDER BY max_infection_rate DESC;

-- Show countries with the highest count per population
SELECT Location, MAX(total_deaths) death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY death_count DESC;

-- Break things down by continent: show the continents with the highest death count per population
SELECT Location, MAX(total_deaths) death_count
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY Location
ORDER BY death_count DESC;

-- Global numbers: global new infection number and death number each day
SELECT date, SUM(new_cases) AS new_infection_count, SUM(new_deaths) AS new_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Look at total population vs vaccination
WITH CTE_popVac AS
(
    SELECT cd.continent, cd.Location, cd.date, cd.population, cv.new_vaccinations,
        SUM(cv.new_vaccinations) OVER(PARTITION BY cd.Location ORDER BY cd.Location, cd.date) AS rolling_people_vaccinated
    FROM CovidDeaths AS cd 
        JOIN CovidVaccinations AS cv ON cd.Location = cv.location AND
            cd.date = cv.date 
    WHERE cd.continent IS NOT NULL AND 
        cv.new_vaccinations IS NOT NULL
)
SELECT *, (CAST(rolling_people_vaccinated AS FLOAT)/population)*100 AS vaccination_rate
FROM CTE_popVac;

-- Create views to store data for later visualization
GO
CREATE VIEW VaccinationRecord AS
(
    SELECT cd.continent, cd.Location, cd.date, cd.population, cv.new_vaccinations,
        SUM(cv.new_vaccinations) OVER(PARTITION BY cd.Location ORDER BY cd.Location, cd.date) AS rolling_people_vaccinated
    FROM CovidDeaths AS cd 
        JOIN CovidVaccinations AS cv ON cd.Location = cv.location AND
            cd.date = cv.date 
    WHERE cd.continent IS NOT NULL AND 
        cv.new_vaccinations IS NOT NULL
)
GO

SELECT *
FROM VaccinationRecord;



