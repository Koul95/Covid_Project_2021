select * from covid_deaths where continent='';

#Select data that we have to use
select location,date,total_cases,new_cases, total_deaths,population
from covid_deaths
order by 1,2;

#Looking at Total Cases vs Total Deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from covid_deaths
where continent!=''
order by 1,2;

#Looking at Total Cases vs Population
select location,date,population,total_cases,(total_cases/population)*100 as infected_percentage
from covid_deaths
where continent!=''
order by 1,2;

#Countries with Highest Infestion to Population ratio
select location,population,max(total_cases) as Total_cases, 
max(total_cases)/max(population)*100 as Infected_population
from covid_deaths
where continent!=''
group by population,location
order by 4 desc;


#Countries with Highest deaths
select location,max(cast(total_deaths as SIGNED))  as Total_death_count
from covid_deaths
where continent!=''
and total_deaths!=''
group by location
order by 2 desc;


#Breakdown by continent
#SHowing the continents with highest death count
select location,max(cast(total_deaths as SIGNED))  as Total_death_count
from covid_deaths
where continent=''
and total_deaths!=''
group by location
order by 2 desc;


#Global Figures
select date,sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, 
sum(new_deaths)/sum(new_cases)*100 as Death_Percentage
from covid_deaths
where continent!=''
group by date
order  by date;


#Looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) 
as Rolling_people_vaccinated 
from covid_deaths dea
join covid_vaccinations vac
on dea.date= vac.date
and dea.location=vac.location
where dea.continent!=''
## and dea.location like'%States%'
order by 1,2,3;

#Using CTE

with popvsvac(continent,location,date,population,new_vaccinations,Rolling_people_vaccinated)
as 
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) 
as Rolling_people_vaccinated 
from covid_deaths dea
join covid_vaccinations vac
on dea.date= vac.date
and dea.location=vac.location
where dea.continent!='')
select *,(Rolling_people_vaccinated/population)*100 from  popvsvac;



#Tmp Table

drop table if exists PercentPopulationVaccinated;
create table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date date,
population numeric ,
new_vaccinations numeric,
rolling_people_vaccinated numeric) ;

insert into PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) 
as Rolling_prople_vaccinated 
from covid_deaths dea
join covid_vaccinations vac
on dea.date= vac.date
and dea.location=vac.location
where dea.continent!='';


select *, (rolling_people_vaccinated/population)*100
from PercentPopulationVaccinated;








#Creating view to store data for later visualizations

create view Percentage_Population_Vaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) 
as Rolling_people_vaccinated 
from covid_deaths dea
join covid_vaccinations vac
on dea.date= vac.date
and dea.location=vac.location
where dea.continent!='';





