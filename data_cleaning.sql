
-- Data Cleaning 

alter table hr
change column id emp_id varchar(20) null;

describe hr; 

select birthdate. its text instead of date
from hr;


set sql_safe_updates = 0;

update hr 
set birthdate = Case 
	when birthdate like '%/%' then date_format(
	str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
	when birthdate like '%-%' then date_format(
	str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
	else null
	end;

select birthdate from hr;

alter table hr
modify column birthdate DATE;


change hire_rate from text to date;
change termndate from timestamp to date;

update hr 
set hire_date = Case 
	when hire_date like '%/%' then date_format(
	str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
	when hire_date like '%-%' then date_format(
	str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
	else null
	end;
    
alter table hr
modify column hire_date date ;

UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', 
date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

SELECT termdate from hr;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

-- add age column ;

    alter table hr
add column age int;

update hr
set age = timestampdiff(year , birthdate , curdate());

-- check outliers
select min(age) as youngest,
		max(age) as oldest
        from hr;
    
select  count(*)
from hr
where age < 18;


-- 1  what is the gender breakdown of employees in the company? 

select gender,
	   count(*) as gender_total
from hr
where age >= 18 and termdate = '0000-00-00'
group by gender ;

-- 2- what is the race breackdown of employees in the company?

select race,
		count(*) as race_count 
from hr
where age >= 18 and termdate = '0000-00-00' 
group by race
order by race_count desc;

-- 3- what is the age distribution of employees in the company?

select min(age) as youngest,
	   max(age) as oldest
from hr
where age >= 18 

select 
     case 
         when age >= 18 and age <= 24 then '18-24'
         when age >= 25 and age <= 34 then '25-34'
          when age >= 35 and age <= 44 then '35-44'
           when age >= 45 and age <= 54 then '45-54'
            when age >= 55 and age <= 64 then '55-64'
            else '+65' end as age_group, gender,
	count(*) as age_count
from hr
where age >= 18 and termdate = '0000-00-00' 
group by age_group, gender
order by age_group, gender;


select 
     case 
         when age >= 18 and age <= 24 then '18-24'
         when age >= 25 and age <= 34 then '25-34'
          when age >= 35 and age <= 44 then '35-44'
           when age >= 45 and age <= 54 then '45-54'
            when age >= 55 and age <= 64 then '55-64'
            else '+65' end as age_group, 
	count(*) as age_count
from hr
where age >= 18 and termdate = '0000-00-00' 
group by age_group
order by age_group;

-- 4 how many employeeswork at headquarters versus remote locations?

	select location,
			count(*) as location_count
	from hr
	where age >= 18 and termdate = '0000-00-00' 
	group by location;
    
  -- 5 what is the average lenght of employment for employees who have been terminated?
  
  select round(avg(datediff(termdate,hire_date))/365,0 )as avg_employment
  from hr
where termdate <> '0000-00-00' and termdate<= curdate() and age >= 18;
  
  -- 6 how does gender distribution varies along department and job titles?
  select department, 
		gender,
		 count(*) as count
  from hr
  where termdate = '0000-00-00' and age >= 18
  group by department,gender
  order by department;
  -- 7 what is the distribution of job titles across the company?
  
  select jobtitle, count(*) as count
  from hr
   where termdate = '0000-00-00' and age >= 18
   group by jobtitle
   order by jobtitle asc ;
  
  -- 8 which department has the highest turnover rate?
  
  select department, 
		 total_count,
         terminated_count, 
         terminated_count/total_count as termination_rate
  from (
		select department,
        count(*) as total_count,
        sum(case when termdate <>'0000-00-00' and termdate <= curdate() then
        1 else 0 end ) as terminated_count
        from hr
        where age >= 18
        group by department) sub
	order by termination_rate desc;
  
  
-- 9 what is the distribution of employees across locations by city and state?

select location_state, count(*) as count
from hr
where termdate = '0000-00-00' and age >= 18
group by location_state
order by  count DESC ;


-- 10how was the companys employee count change over time based on hire and termdates?

select year,
		hires,
        terminations,
        hires - terminations  as net_change,
        round((hires-terminations )/hires*100,2 ) as net_change_percent
from ( select 
			year(hire_date) as year,
            count(*) as hires,
            sum(case when termdate <>'0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminations
            from hr 
            where age >=18
            group by year(hire_date)) as sub
order by year asc;
        



-- 11 what is the tenure distribution for each department?

select department ,
	   round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
from hr
where termdate <> '0000-00-00' and age >= 18 and termdate <= curdate()
group by department
order by department;

