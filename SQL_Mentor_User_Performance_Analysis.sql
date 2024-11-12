create database user_db;
use user_db;

CREATE TABLE user_submissions (
    id SERIAL PRIMARY KEY,
    user_id varchar(20),
    question_id INT,
    points INT,
    submitted_at TIMESTAMP,
    username varchar(50)
);

select * from user_submissions;

alter table user_submissions
modify column user_id bigint;

describe user_submissions;

-- Q1. List All Distinct Users and Their Stats
-- Description: Return the user name, total submissions, and total points earned by each user.
-- Expected Output: A list of users with their submission count and total points.

select * from user_submissions;

select username,count(question_id)as total_submissions,sum(points)as total_points
from user_submissions
group by username
order by sum(points) desc;

-- Q2. Calculate the Daily Average Points for Each User
-- Description: For each day, calculate the average points earned by each user.
-- Expected Output: A report showing the average points per user for each day.


select aa.user_id,aa.month,aa.day,round((aa.total_points/aa.count_user),2)as avg_point_per_day 
from
(select a.user_id,a.month,a.day,sum(a.points)as total_points,count(a.user_id)as count_user
from
(select *,month(submitted_at)as month,day(submitted_at)as day
from user_submissions)as a
group by a.month,a.day,a.user_id)as aa;



-- Q3. Find the Top 3 Users with the Most Correct Submissions for Each Day
-- Description: Identify the top 3 users with the most correct submissions for each day.
-- Expected Output: A list of users and their correct submissions, ranked daily.


select d.user_id,d.username,d.submitted_at,d.total_correct_ans,d.original_rank
from
(select * ,row_number()over(partition by month(aaaa.submitted_at),day(aaaa.submitted_at)) as ranked
from
(select *,dense_rank()over(partition by month(aaa.submitted_at),day(aaa.submitted_at) order by aaa.total_correct_ans desc)as original_rank
from 
(select *,row_number()over(partition by month(aa.submitted_at),day(aa.submitted_at),aa.user_id)as rank_
from
(select a.user_id,a.submitted_at,a.username,
sum(a.status)over(partition by month(a.submitted_at),day(a.submitted_at),a.user_id)as total_correct_ans
from
(select *,dense_rank()over(partition by month(submitted_at),day(submitted_at),user_id),
case
when points<=0 then 0
else 1
end as status 
 from user_submissions)as a)as aa)as aaa
 where aaa.rank_=1)as aaaa)as d
 where d.ranked in (1,2,3)
 ;

-- Q4. Find the Top 5 Users with the Highest Number of Incorrect Submissions
-- Description: Identify the top 5 users with the highest number of incorrect submissions.
-- Expected Output: A list of users with the count of incorrect submissions.

select a.user_id,a.username,count(a.points)as incorrect_submissions
from
(select *
from user_submissions
where points<=0)as a
group by a.user_id,a.username
order by count(a.points) desc
limit 5;

-- Q5. Find the Top 10 Performers for Each Week
-- Description: Identify the top 10 users with the highest total points earned each week.
-- Expected Output: A report showing the top 10 users ranked by total points per week.
select * from user_submissions;

select * 
from
(select *,
row_number()over(partition by aa.week)as rank_
from
(select a.user_id,a.username,a.week,sum(a.points)as total_points
from
(select *,month(submitted_at) as month,week(submitted_at)as week
from user_submissions) as a
group by a.week,a.user_id,a.username
order by a.week asc,sum(a.points) desc)as aa)as aaa
where aaa.rank_ between 1 and 10;