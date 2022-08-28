-- Check out the data
SELECT *
FROM dbo.CovidDataCleaned

-- Data Cleaning Process
	-- Revamp Date into months and year
	-- Populate NULL spaces in the database
	-- Convert relevant data into appropiate Data Types


-- Revamping Date into Month and Year
SELECT YEAR(date) AS year,
DATENAME(month, date) AS month
FROM dbo.CovidDataCleaned


-- Adding new date to table
ALTER TABLE dbo.CovidDataCleaned
ADD year nvarchar(255), month nvarchar(255)

UPDATE dbo.CovidDataCleaned
SET year =  YEAR(date)

UPDATE dbo.CovidDataCleaned
SET month =  DATENAME(month, date)


--Convert Data to appropiate Data Types
UPDATE dbo.CovidDataCleaned
SET date = CONVERT(date, date),
	total_deaths = CONVERT(float, total_deaths),
	total_boosters = CONVERT(float, total_boosters),
	total_tests = CONVERT(float, total_tests),
	total_vaccinations = CONVERT(float, total_vaccinations),
	new_deaths = CONVERT(float, new_deaths),
	new_tests = CONVERT(float, new_tests),
	new_vaccinations = CONVERT(float, new_vaccinations),
	people_fully_vaccinated = CONVERT(float, people_fully_vaccinated),
	people_vaccinated = CONVERT(float, people_vaccinated)


-- Populate NULL spaces in Data
UPDATE dbo.CovidDataCleaned
SET total_deaths = ISNULL(total_deaths,0),
	total_boosters = ISNULL(total_boosters,0),
	total_cases = ISNULL(total_cases,0),
	total_tests = ISNULL(total_tests,0),
	total_vaccinations = ISNULL(total_vaccinations,0),
	new_cases = ISNULL(new_cases,0),
	new_deaths = ISNULL(new_deaths,0),
	new_tests = ISNULL(new_tests,0),
	new_vaccinations = ISNULL(new_vaccinations,0),
	tests_units = ISNULL(tests_units,0),
	people_fully_vaccinated = ISNULL(people_fully_vaccinated,0),
	people_vaccinated = ISNULL(people_vaccinated,0)


-- Data Analysis Process
	-- Global Numbers
	-- Regions with the highest number of cases
	-- Regions with the highest number of casualties
	-- Infection Rate per Population
	-- Death Rate per Infection
	-- Vaccination Rate per Population


-- Global Numbers
SELECT population, MAX(total_cases) as TotalCases, MAX(total_deaths) as TotalDeaths, 
		ROUND((MAX(total_deaths)/MAX(total_cases))*100, 2) as DeathRate, 
		ROUND((MAX(total_cases)/population)*100, 2) as InfectionRate
FROM dbo.CovidDataCleaned
WHERE location = 'World'
GROUP BY population

-- Regions with the highest number of cases
	
	-- By Continent
SELECT continent, SUM(new_cases) as TotalCases
FROM dbo.CovidDataCleaned
WHERE continent is not null
GROUP BY continent
ORDER BY TotalCases Desc

	-- By Country
SELECT location, SUM(new_cases) as TotalCases
FROM dbo.CovidDataCleaned
WHERE location is not null AND continent is not null
GROUP BY location
ORDER BY TotalCases Desc



-- Regions with the highest number of casualties
	
	-- By Continent
SELECT continent, SUM(new_deaths) as CasualtiesCount
FROM dbo.CovidDataCleaned
WHERE continent is not null
GROUP BY continent
ORDER BY CasualtiesCount Desc

	-- By Country
SELECT location, SUM(new_deaths) as CasualtiesCount
FROM dbo.CovidDataCleaned
WHERE location is not null AND continent is not null
GROUP BY location
ORDER BY CasualtiesCount Desc


-- Infection rate per population

	-- By Continent
SELECT continent, SUM(DISTINCT(population)) as population, SUM(new_cases) as TotalCases, ROUND((SUM(new_cases)/SUM(DISTINCT(population)))*100, 2)as InfectionRate
FROM dbo.CovidDataCleaned
WHERE continent is not null
GROUP BY continent
ORDER BY population desc

	-- By Country
SELECT location, population, SUM(new_cases) as TotalCases, ROUND((SUM(new_cases)/population)*100, 2)as InfectionRate
FROM dbo.CovidDataCleaned
WHERE location is not null AND continent is not null
GROUP BY location, population
ORDER BY population desc


-- Death rate per infection

	-- By Continent
SELECT continent, SUM(new_cases) as TotalCases, SUM(new_deaths) as DeathCount, ROUND((SUM(new_deaths)/SUM(new_cases))*100, 2) as DeathRate
FROM dbo.CovidDataCleaned
WHERE continent is not null
GROUP BY continent
ORDER BY TotalCases desc

	-- By Country
SELECT location, SUM(new_cases) as TotalCases, SUM(new_deaths) as DeathCount, ROUND((SUM(new_deaths)/SUM(new_cases))*100, 2) as DeathRate
FROM dbo.CovidDataCleaned
WHERE location is not null AND continent is not null AND new_deaths != '0' AND new_cases != '0'
GROUP BY location
ORDER BY DeathCount desc


-- Vaccination Rate
WITH PopvsVac (Continent, Location, Date, Population, NewVaccinations, NewCases, TotalPeopleVaccinated)
AS
(
SELECT continent, location, date, population, new_vaccinations, new_cases,
		SUM(new_vaccinations) OVER (Partition by Location Order by location, date) as TotalPeopleVaccinated
FROM dbo.CovidDataCleaned
WHERE continent is not null AND location is not null
)
Select Location, population, SUM(NewCases) as TotalCases, MAX(TotalPeopleVaccinated) as HighestVaccinationCount, ROUND(MAX(TotalPeopleVaccinated/Population)*100, 2) as VaccinationRate
From PopvsVac
GROUP BY Location, Population
ORDER BY TotalCases desc


