CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department_id INT,
    hire_date DATE NOT NULL,
    salary NUMERIC(15, 2) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    CONSTRAINT fk_department
       FOREIGN KEY(department_id) 
       REFERENCES departments(department_id)
);

-- Create the Departments Table
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    manager_id INT
   -- CONSTRAINT fk_manager
       -- FOREIGN KEY(manager_id)
       -- REFERENCES employees(employee_id)
);
----------
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100),
    manager_id INT,
    CONSTRAINT fk_manager
        FOREIGN KEY(manager_id)
        REFERENCES employees(employee_id)
);
----------

-- Create the Projects Table
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    budget NUMERIC(20, 2)
);

-- Create the Assignments Table
CREATE TABLE assignments (
    assignment_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    project_id INT NOT NULL,
    hours_worked INT CHECK (hours_worked >= 0),
    role VARCHAR(50),
    assignment_date DATE NOT NULL,
    CONSTRAINT fk_employee
        FOREIGN KEY(employee_id) 
        REFERENCES employees(employee_id),
    CONSTRAINT fk_project
        FOREIGN KEY(project_id) 
        REFERENCES projects(project_id)
);

-- Create the Departments Managers Relation Table
CREATE TABLE department_managers (
    department_id INT PRIMARY KEY,
    employee_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    CONSTRAINT fk_department_manager
        FOREIGN KEY(department_id)
        REFERENCES departments(department_id),
    CONSTRAINT fk_manager_employee
        FOREIGN KEY(employee_id)
        REFERENCES employees(employee_id)
);

-- Insert Data into Departments Table
INSERT INTO departments (department_name, location, manager_id)
VALUES 
('Human Resources', 'New York', NULL),
('Engineering', 'San Francisco', NULL),
('Marketing', 'Los Angeles', NULL),
('Sales', 'Chicago', NULL),
('Finance', 'Boston', NULL);

-- Insert Data into Employees Table
INSERT INTO employees (first_name, last_name, department_id, hire_date, salary, email)
VALUES 
('John', 'Doe', 2, '2018-05-10', 75000, 'john.doe@company.com'),
('Jane', 'Smith', 3, '2019-03-15', 80000, 'jane.smith@company.com'),
('Michael', 'Brown', 1, '2020-11-01', 60000, 'michael.brown@company.com'),
('Emily', 'Davis', 2, '2017-02-23', 95000, 'emily.davis@company.com'),
('William', 'Jones', 4, '2021-07-20', 55000, 'william.jones@company.com'),
('Jessica', 'Wilson', 5, '2016-09-30', 72000, 'jessica.wilson@company.com'),
('Daniel', 'Garcia', 3, '2018-01-18', 78000, 'daniel.garcia@company.com');

-- Insert Data into Projects Table
INSERT INTO projects (project_name, start_date, end_date, budget)
VALUES 
('Project Alpha', '2022-01-01', '2022-12-31', 500000),
('Project Beta', '2023-02-15', NULL, 300000),
('Project Gamma', '2021-06-01', '2022-05-31', 750000),
('Project Delta', '2022-09-01', '2023-08-31', 400000),
('Project Epsilon', '2020-03-01', '2021-02-28', 600000);

-- Insert Data into Assignments Table
INSERT INTO assignments (employee_id, project_id, hours_worked, role, assignment_date)
VALUES 
(1, 1, 150, 'Developer', '2022-01-10'),
(2, 2, 200, 'Team Lead', '2023-02-20'),
(3, 3, 100, 'HR Specialist', '2021-06-10'),
(4, 4, 250, 'Senior Developer', '2022-09-05'),
(5, 5, 180, 'Sales Manager', '2020-03-05'),
(1, 2, 50, 'Developer', '2023-03-01'),
(6, 3, 120, 'Financial Analyst', '2021-07-01');

-- Assign Managers to Departments
INSERT INTO department_managers (department_id, employee_id, start_date)
VALUES 
(1, 3, '2020-11-01'),
(2, 4, '2017-02-23'),
(3, 2, '2019-03-15'),
(4, 5, '2021-07-20'),
(5, 6, '2016-09-30')


SELECT 
    e.first_name, 
    e.last_name, 
    (
        SELECT SUM(a.hours_worked) 
        FROM assignments a 
        WHERE a.employee_id = e.employee_id
    ) AS total_hours_worked
FROM 
    employees e;


SELECT 
    e.first_name, 
    e.last_name, 
    AVG(a.hours_worked) AS average_hours_worked
FROM 
    employees e
LEFT JOIN 
    assignments a ON e.employee_id = a.employee_id
GROUP BY 
    e.employee_id;

SELECT 
    e.first_name AS "First Name", 
    e.last_name AS "Last Name", 
    SUM(a.hours_worked) AS "Total Hours Worked", 
    d.department_name AS "Department"
FROM 
    employees e
JOIN 
    assignments a ON e.employee_id = a.employee_id
JOIN 
    departments d ON e.department_id = d.department_id
GROUP BY 
    e.employee_id, d.department_name;

SELECT 
    e.first_name, 
    e.last_name, 
    d.department_name, 
    SUM(a.hours_worked) AS total_hours_worked
FROM 
    employees e
JOIN 
    assignments a ON e.employee_id = a.employee_id
JOIN 
    departments d ON e.department_id = d.department_id
GROUP BY 
    e.employee_id, d.department_name
ORDER BY 
    d.department_name ASC, 
    total_hours_worked DESC;

select 
DISTINCT d.department_name,
count(e.employee_id) as total_employees
from departments d
join
employees e on d.department_id = e.department_id
group by 
d.department_name;





SELECT e.first_name, e.last_name
FROM employees e
WHERE NOT EXISTS (
  SELECT 1 FROM projects p
  WHERE NOT EXISTS (
    SELECT 1 FROM assignments a
    WHERE a.project_id = p.project_id AND a.employee_id = e.employee_id
  )
);



SELECT e.first_name, e.last_name, d.department_name, SUM(a.hours_worked) AS hours_worked
FROM employees e
JOIN assignments a ON e.employee_id = a.employee_id
JOIN departments d ON e.department_id = d.department_id
GROUP BY e.first_name, e.last_name, d.department_name, hours_worked
HAVING (d.department_name = 'Engineering' AND hours_worked > 50)
   OR (d.department_name = 'Marketing' AND hours_worked < 20);


SELECT e.first_name, e.last_name, SUM(a.hours_worked) AS total_hours
FROM employees e
JOIN assignments a ON e.employee_id = a.employee_id
GROUP BY e.first_name, e.last_name
HAVING SUM(a.hours_worked) > 10
ORDER BY total_hours DESC
LIMIT 5;



SELECT e.first_name, e.last_name
FROM employees e
WHERE e.department_id IN (
  SELECT d.department_id FROM Departments d
  JOIN assignments a ON d.department_id = a.employee_id
  GROUP BY d.department_id
  HAVING COUNT(a.project_id) > 5
);



SELECT p.project_name
FROM projects p
WHERE p.project_id BETWEEN (
  SELECT MIN(a.project_id) FROM assignments a
  JOIN employees e ON a.employee_id = e.employee_id
  WHERE e.department_id = (
    SELECT department_id FROM Departments WHERE department_name = 'Engineering'
  )
) AND (
  SELECT MAX(a.project_id) FROM assignments a
  JOIN employees e ON a.employee_id = e.employee_id
  WHERE e.department_id = (
    SELECT department_id FROM Departments WHERE department_name = 'Engineering'
  )
);



SELECT e.first_name, e.last_name
FROM employees e
WHERE e.first_name LIKE 'M%ael';


SELECT e.first_name, e.last_name
FROM employees e
JOIN Departments d ON e.department_id = d.department_id
LEFT JOIN assignments a ON e.employee_id = a.employee_id
WHERE a.hours_worked IS NULL AND d.department_name = 'Human Resources';




--nested join with alias table
select 
e.employee_id ,
e.first_name,
e.last_name,
d.department_name,
p.project_name
from
employees as e
join 
departments d on e.department_id=d.department_id
join 
projects p on e.department_id=p.project_id;

--inner join with aggregation
SELECT 
    d.department_name,
    e.employee_id,
    e.first_name,
    e.last_name,
    SUM(a.hours_worked) AS total_hours_worked
FROM 
    employees AS e
INNER JOIN 
    departments AS d ON e.department_id = d.department_id
INNER JOIN 
    assignments AS a ON e.employee_id = a.employee_id
GROUP BY
    d.department_name,
    e.employee_id,
    e.first_name,
    e.last_name
ORDER BY
    d.department_name, e.employee_id;

--left join with conditional logic
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM 
    employees AS e
LEFT JOIN 
    departments AS d ON e.department_id = d.department_id
WHERE 
    d.department_name IS NOT NULL OR e.first_name LIKE 'A%'
ORDER BY 
    e.employee_id;


--self join 
SELECT 
    e1.employee_id AS employee_1_id,
    e1.first_name AS employee_1_first_name,
    e1.last_name AS employee_1_last_name,
    e2.employee_id AS employee_2_id,
    e2.first_name AS employee_2_first_name,
    e2.last_name AS employee_2_last_name,
    e1.department_id,
    a1.hours_worked AS employee_1_hours,
    a2.hours_worked AS employee_2_hours
FROM 
    employees AS e1
JOIN 
    employees AS e2 ON e1.department_id = e2.department_id
                   AND e1.employee_id <> e2.employee_id
JOIN 
    assignments AS a1 ON e1.employee_id = a1.employee_id
JOIN 
    assignments AS a2 ON e2.employee_id = a2.employee_id
WHERE 
    ABS(a1.hours_worked - a2.hours_worked) < 5
ORDER BY 
    e1.department_id, e1.employee_id, e2.employee_id;


--full outer join 
SELECT 
    d.department_id,
    d.department_name,
    e.employee_id,
    e.first_name,
    e.last_name
FROM 
    departments AS d
FULL OUTER JOIN 
    employees AS e ON d.department_id = e.department_id
WHERE 
    d.department_id IS NULL 
    OR e.employee_id IS NULL
ORDER BY 
    d.department_name, e.employee_id;



--4
SELECT e.first_name, p.project_name
FROM employees e
CROSS JOIN projects p
WHERE p.project_id IN (
  SELECT a.project_id FROM assignments a
  WHERE a.employee_id = e.employee_id
);


SELECT e.first_name, e.last_name, d.department_name
FROM employees e
NATURAL JOIN departments d;


SELECT e.first_name, e.last_name, d.department_name, 
  (SELECT SUM(a.hours_worked) FROM assignments a WHERE a.employee_id = e.employee_id) AS total_hours
FROM employees e
JOIN departments d ON e.department_id = d.department_id;


SELECT d.department_name, SUM(a.hours_worked) AS total_hours
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN assignments a ON e.employee_id = a.employee_id
GROUP BY d.department_name;

SELECT e.first_name, e.last_name, COUNT(a.project_id) AS num_projects, SUM(a.hours_worked) AS total_hours
FROM employees e
JOIN assignments a ON e.employee_id = a.employee_id
GROUP BY e.first_name, e.last_name;
