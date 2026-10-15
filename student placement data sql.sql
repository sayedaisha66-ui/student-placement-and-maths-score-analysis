create database student_data;
use student_data;


-- Question 1: Which math subjects distinguish inland placement from foreign placement, after accounting for GPA? 
-- Step 1: Compare average GPA and subject scores by placement
-- Run this first to see each group’s overall academic profile:

SELECT
    `placement status`,
    COUNT(*) AS students,
    ROUND(AVG(GPA), 2) AS avg_gpa,
    ROUND(AVG(Algebra), 2) AS avg_algebra,
    ROUND(AVG(Calculus1), 2) AS avg_calculus1,
    ROUND(AVG(Calculus2), 2) AS avg_calculus2,
    ROUND(AVG(Statistics), 2) AS avg_statistics,
    ROUND(AVG(Probability), 2) AS avg_probability,
    ROUND(AVG(Measure), 2) AS avg_measure,
    ROUND(AVG(Functional_analysis), 2) AS avg_functional_analysis
FROM `student_data`.`student data updated`
GROUP BY `placement status`;


-- Step 2: Compare each subject score with the student’s GPA
-- This checks whether a subject tends to be a relative strength within each placement group. 
-- For example, a positive Algebra-to-GPA difference means the group’s average Algebra score is above its average GPA.

SELECT
    `placement status`,
    COUNT(*) AS students,
    ROUND(AVG(Algebra-gpa), 2) AS algebra_vs_gpa,
    ROUND(AVG(Calculus1-gpa), 2) AS calculus1_vs_gpa,
    ROUND(AVG(Calculus2-gpa), 2) AS calculus2_vs_gpa,
    ROUND(AVG(Statistics-gpa), 2) AS statistics_vs_gpa,
    ROUND(AVG(Probability-gpa), 2) AS probability_vs_gpa,
    ROUND(AVG(Measure-gpa),2) AS measure_vs_gpa,
    ROUND(AVG(Functional_analysis-gpa), 2) AS functional_analysis_vs_gpa
FROM `student_data`.`student data updated`
GROUP BY `placement status`;
-- outcome: negative subject to gpa difference means students have higher gpa then maths score ,that means they have scored higher in other subjects.


-- Question 2: Do students with similar GPAs but different math strengths have different placement outcomes?
-- We’ll compare inland and foreign placement rates within GPA bands. This helps check whether placement patterns differ among students with roughly similar GPAs.
--  Since your sample has only 105 students, the bands are broad and the results are exploratory.

SELECT
    CASE
        WHEN GPA < 70 THEN 'Below 70'
        WHEN GPA < 80 THEN '70 to 79.99'
        WHEN GPA < 90 THEN '80 to 89.99'
        ELSE '90 and above'
    END AS gpa_band,
    `placement status`,
    COUNT(*) AS students,
    ROUND(AVG(Algebra), 2) AS avg_algebra,
    ROUND(AVG(Calculus1), 2) AS avg_calculus1,
    ROUND(AVG(Calculus2), 2) AS avg_calculus2,
    ROUND(AVG(Statistics), 2) AS avg_statistics,
    ROUND(AVG(Probability), 2) AS avg_probability,
    ROUND(AVG(Measure), 2) AS avg_measure,
    ROUND(AVG(Functional_analysis), 2) AS avg_functional_analysis
FROM `student_data`.`student data updated`
GROUP BY gpa_band, `placement status`;

use student_data;


-- Question 3: Are students’ math scores balanced, or do they have a standout strength or weakness?
-- We’ll compare each student’s highest and lowest math subject score, then summarize that score spread by placement. 
-- A larger spread means the student’s subject scores vary more; a smaller spread means they’re more even. 

with maths_score as(
select greatest(algebra,calculus1,calculus2,statistics,probability,measure,functional_analysis)-
least(algebra,calculus1,calculus2,statistics,probability,measure,functional_analysis) as score_spread,`placement status`
 from `student data updated`)
select `placement status`,score_spread from maths_score;


WITH student_spread AS (
    SELECT
        ID,
        `placement status`,
        GREATEST(
            Algebra, Calculus1, Calculus2, Statistics,
            Probability, Measure, Functional_analysis
        ) -
        LEAST(
            Algebra, Calculus1, Calculus2, Statistics,
            Probability, Measure, Functional_analysis
        ) AS score_spread
    FROM `student_data`.`student data updated`
)
SELECT
    `placement status`,
    COUNT(*) AS students,
    ROUND(AVG(score_spread), 2) AS avg_score_spread
FROM student_spread
GROUP BY `placement status`
ORDER BY `placement status`;



with student_spread as (select greatest(algebra,calculus1,calculus2,statistics,probability,measure,functional_analysis)-
least(algebra,calculus1,calculus2,statistics,probability,measure,functional_analysis) as score_spread,`placement status`
 from `student data updated`)
select `placement status`,count(*)as student_count ,round(avg(score_spread),2) as avg_score_difference from student_spread
group by `placement status`
order by `placement status`;


-- Question 4: Does the relationship between math performance and placement differ by gender or class?
-- We’ll compare the number and percentage of students in each placement group within each gender and class. 
-- This can reveal whether the placement pattern looks different across these groups. It won’t explain why, 
-- and small group sizes can make percentages unstable.


SELECT
    class,
    `placement status`,
    COUNT(*) AS students,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (PARTITION BY class),
        2
    ) AS percent_within_class
FROM `student_data`.`student data updated`
GROUP BY class, `placement status`
ORDER BY class, `placement status`;


-- Question 5: Does family wealth relate to placement outcomes?
-- First, check the exact wealth categories and placement counts. Your column name contains a space, so keep it inside backticks:

select `placement status`,`family wealth`,count(*)as student_count
from `student data updated`
group by `placement status`,`family wealth`;


-- Question 6: Do some students have a high GPA but a weaker score in one math subject?
-- This looks for students whose score in at least one math subject is 10 or more points below their GPA.
--  It’s a way to find subject-specific gaps for follow-up—not evidence that the gap caused their placement.


select ID,gpa,algebra,calculus1,calculus2,statistics,probability,measure, Functional_analysis,`placement status` from  `student data updated`
where gpa>=80 
and (algebra<=gpa-10 or calculus1<=gpa-10 or calculus2<=gpa-10 or statistics<=gpa-10 or probability<=gpa-10 or measure<=gpa-10 or  Functional_analysis<=gpa-10);

SELECT
    ID,
    GPA,
    Algebra,
    Calculus1,
    Calculus2,
    Statistics,
    Probability,
    Measure,
    Functional_analysis,
    `placement status`
FROM `student_data`.`student data updated`
WHERE GPA >= 80
  AND (
      Algebra <= GPA - 10
      OR Calculus1 <= GPA - 10
      OR Calculus2 <= GPA - 10
      OR Statistics <= GPA - 10
      OR Probability <= GPA - 10
      OR Measure <= GPA - 10
      OR Functional_analysis <= GPA - 10
  )
ORDER BY GPA DESC;
















