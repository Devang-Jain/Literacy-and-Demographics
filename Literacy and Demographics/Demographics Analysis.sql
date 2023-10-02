Select * from Portfolio.dbo.demographics

select * from Portfolio.dbo.literacy

--No of Rows in our Dataset
select count(*) from Portfolio..demographics
select count(*) from Portfolio..literacy

--District with High Litercay Rate
Select *
from portfolio..literacy
where Literacy >90

--Data for Two Different States

--using OR
Select *
from Portfolio.dbo.literacy
where state_name = 'Uttar Pradesh' or state_name = 'Punjab'

--using union
Select *
from Portfolio.dbo.literacy
where state_name = 'Uttar Pradesh' 
Union
Select *
from Portfolio.dbo.literacy
where state_name = 'Punjab'

--In Function
Select *
from Portfolio.dbo.literacy
where State_name in ('Uttar Pradesh','Punjab')

--Population of India
select sum(Population) Population_of_India
from Portfolio.dbo.demographics

--Average Growth
select AVG(Growth)*100 as Avg_Growth_of_India
from Portfolio.dbo.literacy

--Average growth by States
select State_name, AVG(Growth)*100 as Avg_Growth_of_State
from Portfolio.dbo.literacy
where Growth is not null
Group by State_name 

--Average Sex Ratio
select AVG(Sex_Ratio)*100 as Avg_Sex_Ratio_of_India
from Portfolio.dbo.literacy



--Average Sex Ratio by States
select State_name, AVG(Sex_Ratio) as Avg_Sex_Ratio_of_State
from Portfolio.dbo.literacy
where Sex_Ratio is not null
Group by State_name

--Round off Value in average sex ratio
select State_name, round(AVG(Sex_Ratio),0) as Avg_Sex_Ratio_of_State
from Portfolio.dbo.literacy
where Sex_Ratio is not null
Group by State_name
order by  Avg_Sex_Ratio_of_State desc

-- Average Literacy Rate
select AVG(Literacy)*100 as Avg_Literacy_of_India
from Portfolio.dbo.literacy

--Average Literacy Rate by States
select State_name, round(AVG(Literacy),0) as Avg_Literacy_Rate_of_State
from Portfolio.dbo.literacy
where Literacy is not null
Group by State_name
having  round(AVG(Literacy),0)>90
order by  Avg_Literacy_Rate_of_State desc

--Top 3 States showing highest growth ration
select top 3 State_name, AVG(Growth)*100 as Avg_Growth_of_State
from Portfolio.dbo.literacy
where Growth is not null
Group by State_name 
order by Avg_Growth_of_State desc


--Bottom 3 States showing lowest sex ration
select top 3 State_name, AVG(Sex_Ratio) as Avg_Sex_Ratio_of_State
from Portfolio.dbo.literacy
where Sex_Ratio is not null
Group by State_name 
order by Avg_Sex_Ratio_of_State



--Temporary Table
-- top and bottom 3 states in literacy state

drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
  topstate float

  )

insert into #topstates
select State_name,round(avg(literacy),0) avg_literacy_ratio
from literacy
group by State_name
order by avg_literacy_ratio desc;

select top 3 * 
from #topstates 
order by #topstates.topstate desc;

drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
  bottomstate float

  )

insert into #bottomstates
select state_name,round(avg(literacy),0) avg_literacy_ratio
from literacy
group by State_name 
order by avg_literacy_ratio desc;

select top 3 * 
from #bottomstates
where #bottomstates.bottomstate is not null 
order by #bottomstates.bottomstate asc;

--union opertor

select * from (
select top 3 * 
from #topstates 
order by #topstates.topstate desc) a

union

select * from (
select top 3 * from #bottomstates 
where #bottomstates.bottomstate is not null 
order by #bottomstates.bottomstate asc) b;

--Select starting with letter a

select * from literacy
where State_name like 'a%'

select * from literacy
where lower(State_name) like 'a%'

-- joining both table
---- District wise

select c.district,c.state_name,round(c.Population/(c.sex_ratio+1),0) males, ROUND((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.District,a.State_name,b.Sex_Ratio/1000 sex_ratio,a.Population
from Portfolio..demographics a
inner join Portfolio..literacy b
on a.District=b.District)c

----State wise
select d.State_name,sum(d.males) Total_males,sum(d.females) Total_females from
(select c.District,c.state_name,round(c.Population/(c.sex_ratio+1),0) males, ROUND((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.District,a.State_name,b.Sex_Ratio/1000 sex_ratio,a.Population
from Portfolio..demographics a
inner join Portfolio..literacy b
on a.District=b.District)c)d
group by d.State_name

--Literace vs Illiterate (District wise)
select c.district,c.State_name, round(c.literacy_ratio*c.Population,0) literate_people,round((1-c.literacy_ratio)*c.Population,0) illiterate_people from
(select a.District,a.State_name, b.Literacy/100 literacy_ratio,a.Population
from Portfolio..demographics a
inner join Portfolio..literacy b
on a.District=b.District)c)

--Literace vs Illiterate (State wise)
select d.State_name,sum(d.literate_people) total_literate, SUM(d.illiterate_people) total_illiterate from
(select c.district,c.State_name, round(c.literacy_ratio*c.Population,0) literate_people,round((1-c.literacy_ratio)*c.Population,0) illiterate_people from
(select a.District,a.State_name, b.Literacy/100 literacy_ratio,a.Population
from Portfolio..demographics a
inner join Portfolio..literacy b
on a.District=b.District)c)d
group by d.State_name


--Population in previous sensus (State_wise)
select d.State_name,sum(d.Previous_census_Population) Previous_census_Population ,sum(d.Current_census_population) Current_census_population from
(select c.district, c.State_name,c.Growth,round(c.Population/(1+c.Growth),0) Previous_census_Population, c.Population Current_census_population from
(select a.State_name,a.District,a.Population,b.Growth
from Portfolio..demographics a
inner join Portfolio..literacy b
on a.District=b.District)c)d
group by d.State_name


--Population in previous sensus (Country)
select SUM(e.Previous_census_Population) total_Previous_census_Population, SUM(e.Current_census_population) total_Current_census_population FROM 
(select d.State_name,sum(d.Previous_census_Population) Previous_census_Population ,sum(d.Current_census_population) Current_census_population from
(select c.district, c.State_name,c.Growth,round(c.Population/(1+c.Growth),0) Previous_census_Population, c.Population Current_census_population from
(select a.State_name,a.District,a.Population,b.Growth
from Portfolio..demographics a
inner join Portfolio..literacy b
on a.District=b.District)c)d
group by d.State_name)e


--Population vs Area
select 'India' Country,l.* from
(Select(z.total_area/z.total_Previous_census_Population) Area_by_previous_population,(z.total_area/z.total_Current_census_population) Area_by_current_population from
(select x.*, y.total_area from
(Select 'India'  Country,f.* from
(select SUM(e.Previous_census_Population) total_Previous_census_Population, SUM(e.Current_census_population) total_Current_census_population FROM 
(select d.State_name,sum(d.Previous_census_Population) Previous_census_Population ,sum(d.Current_census_population) Current_census_population from
(select c.district, c.State_name,c.Growth,round(c.Population/(1+c.Growth),0) Previous_census_Population, c.Population Current_census_population from
(select a.State_name,a.District,a.Population,b.Growth
from Portfolio..demographics a
inner join Portfolio..literacy b
on a.District=b.District)c)d
group by d.State_name)e)f)x inner join
(select 'India' Country,m.* from (
select sum(area_km2) total_area from Portfolio..demographics)m)y on x.country=y.country)z)l
