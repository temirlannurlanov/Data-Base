-- Part A: Database and Table Setup
-- 1. Create database and tables

CREATE DATABASE "advanced_Lab";

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50) DEFAULT 'General',
    salary INTEGER DEFAULT 30000,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);

INSERT INTO departments (dept_name, budget, manager_id) VALUES
('IT', 120000, 1),
('Sales', 80000, 2),
('HR', 40000, 3);

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status) VALUES
('John', 'Doe', 'IT', 75000, '2019-03-15', 'Active'),
('Jane', 'Smith', 'IT', 55000, '2021-06-20', 'Active'),
('Alice', 'Johnson', 'Sales', 45000, '2018-11-01', 'Active'),
('Bob', 'Brown', 'Sales', 35000, '2023-02-10', 'Active'),
('Charlie', 'Green', 'HR', 65000, '2019-01-10', 'Inactive'),
('David', 'White', 'IT', 85000, '2017-05-12', 'Active'),
('Eve', 'Black', 'Marketing', 38000, '2023-04-01', 'Terminated');

INSERT INTO projects (project_name, dept_id, start_date, end_date, budget) VALUES
('Cloud Migration', 1, '2022-01-01', '2022-12-31', 60000),
('CRM Upgrade', 2, '2023-01-15', '2023-11-30', 45000),
('AI Platform', 1, '2024-01-01', '2024-12-31', 150000);

-- Part B: Advanced INSERT Operations
-- 2. INSERT with column specification

INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (DEFAULT, 'Michael', 'Scott', 'Management');

-- 3. INSERT with DEFAULT values

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Jim', 'Halpert', 'Sales', DEFAULT, '2022-08-01', DEFAULT);

-- 4. INSERT multiple rows in single statement

INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('Marketing', 50000, 4),
    ('Finance', 90000, 5),
    ('Legal', 30000, 6);

-- 5. INSERT with expressions

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Pam', 'Beesly', 'Reception', 50000 * 1.1, CURRENT_DATE, 'Active');

-- 6. INSERT from SELECT (subquery)

CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE FALSE; -- создаем структуру без данных

INSERT INTO temp_employees
SELECT * FROM employees
WHERE department = 'IT';

-- Part C: Complex UPDATE Operations
-- 7. UPDATE with arithmetic expressions

UPDATE employees
SET salary = salary * 1.10;

-- 8. UPDATE with WHERE clause and multiple conditions

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

-- 9. UPDATE using CASE expression

UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

-- 10. UPDATE with DEFAULT

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

-- 11. UPDATE with subquery

UPDATE departments d
SET budget = (
    SELECT COALESCE(AVG(e.salary), 0) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
)
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.department = d.dept_name
);

-- 12. UPDATE multiple columns

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

-- Part D: Advanced DELETE Operations
-- 13. DELETE with simple WHERE condition

DELETE FROM employees
WHERE status = 'Terminated';

-- 14. DELETE with complex WHERE clause

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

-- 15. DELETE with subquery

DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

-- 16. DELETE with RETURNING clause

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

-- Part E: Operations with NULL Values
-- 17. INSERT with NULL values

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Ryan', 'Howard', NULL, NULL, '2023-05-01', 'Active');

-- 18. UPDATE NULL handling

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

-- 19. DELETE with NULL conditions

DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

-- Part F: RETURNING Clause Operations
-- 20. INSERT with RETURNING

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Stanley', 'Hudson', 'Sales', 60000, '2020-02-15', 'Active')
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

-- 21. UPDATE with RETURNING

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, (salary - 5000) AS old_salary, salary AS new_salary;

-- 22. DELETE with RETURNING all columns

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

-- Part G: Advanced DML Patterns
-- 23. Conditional INSERT

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
SELECT 'Dwight', 'Schrute', 'Sales', 70000, '2018-04-01', 'Active'
WHERE NOT EXISTS (
    SELECT 1 FROM employees WHERE first_name = 'Dwight' AND last_name = 'Schrute'
);

-- 24. UPDATE with JOIN logic using subqueries

UPDATE employees e
SET salary = CASE
    WHEN (SELECT budget FROM departments d WHERE d.dept_name = e.department) > 100000
        THEN salary * 1.10
    ELSE salary * 1.05
END
WHERE e.department IS NOT NULL;

-- 25. Bulk operations

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status) VALUES
('User1', 'Test', 'IT', 40000, CURRENT_DATE, 'Active'),
('User2', 'Test', 'IT', 41000, CURRENT_DATE, 'Active'),
('User3', 'Test', 'Sales', 42000, CURRENT_DATE, 'Active'),
('User4', 'Test', 'Sales', 43000, CURRENT_DATE, 'Active'),
('User5', 'Test', 'HR', 44000, CURRENT_DATE, 'Active');


UPDATE employees
SET salary = salary * 1.10
WHERE last_name = 'Test';

-- 26. Data migration simulation

CREATE TABLE employee_archive (
    emp_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INT,
    hire_date DATE,
    status VARCHAR(20),
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


WITH moved_rows AS (
    DELETE FROM employees
    WHERE status = 'Inactive'
    RETURNING emp_id, first_name, last_name, department, salary, hire_date, status
)
INSERT INTO employee_archive (emp_id, first_name, last_name, department, salary, hire_date, status)
SELECT emp_id, first_name, last_name, department, salary, hire_date, status
FROM moved_rows;

-- 27. Complex business logic

UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
      SELECT COUNT(*)
      FROM employees e
      JOIN departments d ON e.department = d.dept_name
      WHERE d.dept_id = p.dept_id
  ) > 3;