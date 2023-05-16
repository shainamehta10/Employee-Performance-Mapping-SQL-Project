-- Create a database named employee, then import data_science_team.csv, proj_table.csv and emp_record_table.csv into the employee database
 CREATE DATABASE employee;
CREATE DATABASE project;


-- query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT
FROM employee.emp_record_table;


-- to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is less than two , greater than four , two and four
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM employee.emp_record_table
WHERE EMP_RATING < 2;
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM employee.emp_record_table
WHERE EMP_RATING between 2 and 4;
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM employee.emp_record_table
WHERE EMP_RATING > 4;


-- concatenate the FIRST_NAME and the LAST_NAME of employees in theFinancedepartment from the employee table and then give the resultant column alias as NAME.
SELECT CONCAT(FIRST_NAME,' ',LAST_NAME) AS 'NAME' FROM employee.emp_record_table
WHERE DEPT='FINANCE';

-- to list only those employees who have someone reporting to them
SELECT
m.EMP_ID, m.FIRST_NAME, m.LAST_NAME, m.ROLE,
m.EXP, m.DEPT, COUNT(e.EMP_ID) as 'EMP_COUNT'
FROM
employee.emp_record_table m
INNER JOIN employee.emp_record_table e
ON m.EMP_ID = e.MANAGER_ID
AND e.EMP_ID = e.MANAGER_ID
WHERE m.ROLE IN ('MANAGER', 'PRESIDENT', 'CEO') 
GROUP BY m.EMP_ID
ORDER BY m.EMP_ID;

-- to list down all the employees from the healthcare and finance departments using union.
SELECT e.EMP_ID as ID,
CONCAT(e.FIRST_NAME,' ',e.LAST_NAME) AS `NAME`,
e.DEPT
FROM employee.emp_record_table e
WHERE e.DEPT IN ('HEALTHCARE' )
UNION
SELECT e.EMP_ID as ID,
CONCAT(e.FIRST_NAME,' ',e.LAST_NAME) AS `NAME`,
e.DEPT
FROM employee.emp_record_table e
WHERE e.DEPT IN ('FINANCE')
ORDER BY DEPT, ID;

-- to list down employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept. Also include the respective employee rating along with the max emp rating for the department.
SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, EMP_RATING,
MAX(EMP_RATING)
OVER (PARTITION BY DEPT) AS MAX_EMP_RATING
FROM employee.emp_record_table;

-- to calculate the minimum and the maximum salary of the employees in each role.
SELECT DISTINCT(ROLE), MAX(SALARY)
OVER (PARTITION BY ROLE) MAX_SALARY, MIN(SALARY)
OVER (PARTITION BY ROLE) MIN_SALARY
FROM employee.emp_record_table;

-- to assign ranks to each employee based on their experience.
SELECT EMP_ID, FIRST_NAME, LAST_NAME, DEPT, EXP,
RANK() OVER (ORDER BY EXP) EXP_RANK,
DENSE_RANK() OVER (ORDER BY EXP) EXP_DENSE_RANK
FROM employee.emp_record_table;

-- to create a view that displays employees in various countries whose salary is more than six thousand.
use employee;
CREATE VIEW Employee_View
AS
SELECT EMP_ID, FIRST_NAME, LAST_NAME, COUNTRY, SALARY
FROM employee.emp_record_table
WHERE SALARY > 6000;

-- to find employees with experience of more than ten years.
SELECT * FROM Employee_view;
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, ROLE, EXP
FROM employee.emp_record_table
WHERE EXP>10 ;

-- to create a stored procedure to retrieve the details of the employees whose experience is more than three years.
DELIMITER \\
CREATE PROCEDURE experienced_personal()
BEGIN

SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, ROLE, EXP
FROM employee.emp_record_table WHERE EXP > 3;
END \\
DELIMITER ;
call experienced_personal();

/* query using stored functions in the project table to check whether the job profile assigned to each employee in the data science team matches the organization’s set standard
The standard is given as follows:
Employee with experience less than or equal to 2 years, assign 'JUNIOR DATA SCIENTIST’
Employee with experience of 2 to 5 years, assign 'ASSOCIATE DATA SCIENTIST’
Employee with experience of 5 to 10 years, assign 'SENIOR DATA SCIENTIST’
Employee with experience of 10 to 12 years, assign 'LEAD DATA SCIENTIST’,
Employee with experience of 12 to 16 years, assign 'MANAGER' */
DELIMITER $$
drop FUNCTION Employee_details;
CREATE FUNCTION Employee_details (EXP int)
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN DECLARE Employee_details VARCHAR(255);
IF EXP <= 2 THEN SET Employee_details = 'JUNIOR DATA SCIENTIST';
ELSEIF EXP <= 5 THEN SET Employee_details = 'ASSOCIATE DATA SCIENTIST';
ELSEIF EXP <= 10 THEN SET Employee_details = 'SENIOR DATA SCIENTIST';
ELSEIF EXP <= 12 THEN SET Employee_details = 'LEAD DATA SCIENTIST';
ELSEIF EXP <= 16 THEN SET Employee_details = 'MANAGER';
END IF;
RETURN (Employee_details);
END$$
DELIMITER $$;
SELECT FIRST_NAME, LAST_NAME, DEPT, EXP, ROLE, Employee_details(EXP) as
DESIGNATION
FROM employee.emp_record_table ORDER BY EXP;


-- an index to improve the cost and performance of the query to find the employee whose FIRST_NAME is ‘Eric’ in the employee table after checking the execution plan. 
SELECT *FROM employee.emp_record_table
WHERE FIRST_NAME='Eric';
CREATE INDEX query1 ON employee.emp_record_table(FIRST_NAME);

-- to calculate the bonus for all the employees, based on their ratings and salaries
SELECT *
FROM employee.emp_record_table
WHERE FIRST_NAME='Eric';
SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, SALARY, EMP_RATING,
(SALARY/20)*EMP_RATING AS BONUS
FROM employee.emp_record_table;
