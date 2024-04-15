## percentage of questions with "?" at the end having accepted answers

select round(sum(case when accepted_answer_id is null then 0 else 1 end) / count(*),2) PercentAccepted
from bigquery-public-data.stackoverflow.posts_questions
where title like '%?'

## which tags are more likely to have accepted answers?

# check tags for first 10 rows
select title, accepted_answer_id, tags
from bigquery-public-data.stackoverflow.posts_questions
order by title
limit 10

# unnest tags to create one row per tag
select title, accepted_answer_id, tag
from bigquery-public-data.stackoverflow.posts_questions
cross join unnest(split(tags, '|')) tag
order by title
limit 10

# find tags with highest percentage of accepted answers (at least 500 questions)
select tag, round(sum(case when accepted_answer_id is null then 0 else 1 end) / count(*),2) PercentAccepted
from bigquery-public-data.stackoverflow.posts_questions
cross join unnest(split(tags, '|')) tag
group by tag
having count(*) >= 500
order by PercentAccepted desc

## which tags have questions that get answered the quickest?

# join questions with answers and find time it takes to answer question
select q.title, q.accepted_answer_id, a.id, a.body, tag, q.creation_date, a.creation_date, date_diff(a.creation_date, q.creation_date, second) AS TimeToAnswer
from bigquery-public-data.stackoverflow.posts_questions q
cross join unnest(split(tags, '|')) tag
join bigquery-public-data.stackoverflow.posts_answers a
  on q.accepted_answer_id = a.id
order by title
limit 10

# find tags that have the lowest average TimeToAnswer (at least 500 questions)
select tag, round(avg(date_diff(a.creation_date, q.creation_date, second))) AS AvgTimeToAnswer
from bigquery-public-data.stackoverflow.posts_questions q
cross join unnest(split(tags, '|')) tag
join bigquery-public-data.stackoverflow.posts_answers a
  on q.accepted_answer_id = a.id
group by tag
having count(*) >= 500
order by AvgTimeToAnswer

## which tags have questions that get the most answers?

# join questions with answers and find tags with the most answers on average (at least 500 questions)
select tag, round(avg(answer_count),2) AS AvgNumAnswers
from bigquery-public-data.stackoverflow.posts_questions
cross join unnest(split(tags, '|')) tag
group by tag
having count(*) >= 500
order by AvgNumAnswers desc