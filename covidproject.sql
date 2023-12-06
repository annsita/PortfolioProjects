
SELECT * FROM coviddeaths ORDER BY 3,4

SELECT * FROM covidvaccinations ORDER BY 3,4

SELECT TABLE_CATALOG,TABLE_SCHEMA,TABLE_NAME,COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='COVIDDEATHS'

SELECT LOCATION,DATE,TOTAL_CASES,NEW_CASES,TOTAL_DEATHS,POPULATION FROM coviddeaths ORDER BY 1,2;

----> looking at the total cases v/s total deaths 
----->Likelihood of a person dying if they contract covid in a particular country

SELECT LOCATION,DATE,TOTAL_CASES,TOTAL_DEATHS,(CONVERT(FLOAT,TOTAL_DEATHS)/NULLIF(CONVERT(FLOAT,TOTAL_CASES),0))*100 AS 'DEATHPERCENTAGE' FROM coviddeaths 
WHERE LOCATION LIKE 'INDIA'
ORDER BY 1,2 

---->looking at population v/s total cases
----->what % of population got covid

SELECT LOCATION,DATE,POPULATION,TOTAL_CASES,(CONVERT(FLOAT,TOTAL_CASES)/NULLIF(CONVERT(FLOAT,POPULATION),0))*100 AS 'PercentagePeopleInfected' FROM coviddeaths 
ORDER BY 1,2 


----->countries with highest infection rates

SELECT LOCATION,POPULATION,MAX(TOTAL_CASES) as 'highestInfectionCount',MAX((total_cases/population)*100) AS 'PercentagePeopleInfected' FROM
coviddeaths 
group by LOCATION,population
ORDER BY PercentagePeopleInfected DESC


------->countries with highest deaths

SELECT LOCATION,MAX(CAST(TOTAL_DEATHS AS INT)) AS 'DEATH_COUNT' FROM coviddeaths 
WHERE continent IS NOT NULL
GROUP BY LOCATION
ORDER BY DEATH_COUNT DESC;

------->Continents with highest death counts

SELECT continent,MAX(CAST(TOTAL_DEATHS AS INT)) AS 'DEATH_COUNT' FROM coviddeaths 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DEATH_COUNT DESC;

------->Global numbers

SELECT DATE,SUM(NEW_CASES) AS 'TOTAL CASES',SUM(NEW_DEATHS) AS 'TOTAL DEATHS' FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY DATE
ORDER BY DATE

-------->location wise daily vaccination count 
 
SELECT CD.CONTINENT,CD.LOCATION,CD.DATE,CD.POPULATION,CV.NEW_VACCINATIONS,SUM(CAST(CV.new_vaccinations AS FLOAT)) OVER (partition by CD.LOCATION 
ORDER BY CD.DATE) AS 'RollingPeopleVaccinated'
FROM coviddeaths CD INNER JOIN covidvaccinations CV
ON CD.location=CV.location
AND CD.date=CV.date
WHERE CD.CONTINENT IS NOT NULL 
ORDER BY 2,3

---------->population v/s rolling people vaccinated
 
     ------>USE CTE

WITH POPVSVACC(CONTINENT,LOCATION,DATE,POPULATION,NEW_VACCINATIONS,ROLLINGPEOPLEVACCINATED)
AS
(
SELECT CD.CONTINENT,CD.LOCATION,CD.DATE,CD.POPULATION,CV.NEW_VACCINATIONS,SUM(CAST(CV.new_vaccinations AS FLOAT)) OVER (partition by CD.LOCATION 
ORDER BY CD.DATE) AS 'RollingPeopleVaccinated'
FROM coviddeaths CD INNER JOIN covidvaccinations CV
ON CD.location=CV.location
AND CD.date=CV.date
WHERE CD.CONTINENT IS NOT NULL 
)

SELECT *,(RollingPeopleVaccinated/POPULATION)*100 AS 'PopulationVaccinationRate' FROM POPVSVACC

-------->CREATE VIEW

CREATE VIEW INFECTIONRATE AS
SELECT LOCATION,POPULATION,MAX(TOTAL_CASES) as 'highestInfectionCount',MAX((total_cases/population)*100) AS 'PercentagePeopleInfected' FROM
coviddeaths 
group by LOCATION,population

SELECT * FROM INFECTIONRATE



