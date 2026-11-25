-- Laboratory Work 9: Stored Procedures and User-Defined Functions
-- PostgreSQL / PLpgSQL
-- Run this script in a scratch database (e.g. DataGrip).
-- Includes setup, solutions, and test calls for Parts 2-7.
-- Intentional error demonstrations are commented out so the script can run to completion.

-- ============================================================
-- PART 1: DATABASE SETUP
-- ============================================================
DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;

CREATE TABLE stations (
    station_id   INT PRIMARY KEY,
    station_name VARCHAR(50) NOT NULL,
    city         VARCHAR(40) NOT NULL,
    capacity     INT NOT NULL
);

CREATE TABLE bikes (
    bike_id    INT PRIMARY KEY,
    model      VARCHAR(50) NOT NULL,
    station_id INT REFERENCES stations(station_id),
    daily_rate NUMERIC(8,2) NOT NULL
);

CREATE TABLE members (
    member_id INT PRIMARY KEY,
    full_name VARCHAR(60) NOT NULL,
    city      VARCHAR(40) NOT NULL,
    joined_on DATE NOT NULL
);

CREATE TABLE rentals (
    rental_id  INT PRIMARY KEY,
    member_id  INT REFERENCES members(member_id),
    bike_id    INT REFERENCES bikes(bike_id),
    start_date DATE NOT NULL,
    end_date   DATE,
    fee        NUMERIC(8,2)
);

INSERT INTO stations VALUES
 (10, 'Central Park', 'Almaty', 4),
 (20, 'Riverside', 'Almaty', 3),
 (30, 'Expo Gate', 'Astana', 5),
 (40, 'Old Town', 'Shymkent', 2),
 (50, 'Depot', 'Astana', 0);

INSERT INTO bikes VALUES
 (101, 'City Cruiser', 10, 4.50),
 (102, 'City Cruiser', 10, 4.50),
 (103, 'Mountain X', 20, 7.00),
 (104, 'Mountain X', 30, 7.00),
 (105, 'Road Sprint', 30, 9.25),
 (106, 'Folding Mini', 40, 3.75),
 (107, 'Cargo Hauler', 20, 12.00),
 (108, 'Road Sprint', 10, 9.25);

INSERT INTO members VALUES
 (1, 'Aisha Nurlanova', 'Almaty', DATE '2023-03-14'),
 (2, 'Daniyar Serik', 'Almaty', DATE '2023-07-02'),
 (3, 'Marta Kowalski', 'Astana', DATE '2024-01-20'),
 (4, 'Chen Wei', 'Astana', DATE '2024-05-11'),
 (5, 'Omar Haddad', 'Shymkent', DATE '2024-09-30'),
 (6, 'Elena Petrova', 'Almaty', DATE '2025-02-05');

INSERT INTO rentals VALUES
 (1,1,101,DATE '2024-04-05',DATE '2024-04-08',13.50),
 (2,1,103,DATE '2024-06-11',DATE '2024-06-16',35.00),
 (3,1,108,DATE '2025-02-02',DATE '2025-02-04',18.50),
 (4,1,102,DATE '2025-05-20',DATE '2025-05-27',31.50),
 (5,2,101,DATE '2024-05-01',DATE '2024-05-02',4.50),
 (6,2,107,DATE '2024-11-15',DATE '2024-11-19',48.00),
 (7,2,107,DATE '2025-03-08',DATE '2025-03-14',72.00),
 (8,3,104,DATE '2024-02-14',DATE '2024-02-18',28.00),
 (9,3,105,DATE '2024-08-03',DATE '2024-08-06',27.75),
 (10,3,104,DATE '2025-01-09',DATE '2025-01-10',7.00),
 (11,3,105,DATE '2025-06-01',DATE '2025-06-09',74.00),
 (12,4,104,DATE '2024-07-19',DATE '2024-07-21',14.00),
 (13,4,105,DATE '2025-04-12',DATE '2025-04-15',27.75),
 (14,4,103,DATE '2025-07-23',DATE '2025-07-29',42.00),
 (15,5,106,DATE '2024-10-05',DATE '2024-10-12',26.25),
 (16,5,106,DATE '2025-01-18',DATE '2025-01-20',7.50),
 (17,5,106,DATE '2025-08-14',DATE '2025-08-21',26.25),
 (18,2,102,DATE '2025-09-02',DATE '2025-09-05',13.50),
 (19,1,101,DATE '2025-10-10',NULL,NULL),
 (20,4,108,DATE '2024-12-28',DATE '2025-01-03',55.50),
 (21,3,103,DATE '2025-02-26',DATE '2025-03-02',28.00),
 (22,5,104,DATE '2025-05-05',DATE '2025-05-08',21.00);

-- Setup verification: expected 5 stations, 8 bikes, 6 members, 22 rentals.
SELECT (SELECT COUNT(*) FROM stations) AS stations,
       (SELECT COUNT(*) FROM bikes) AS bikes,
       (SELECT COUNT(*) FROM members) AS members,
       (SELECT COUNT(*) FROM rentals) AS rentals;

-- ============================================================
-- PART 2: YOUR FIRST FUNCTION
-- ============================================================

-- Exercise 2.1: Rental duration. Open or missing rental returns NULL.
CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT)
RETURNS INT AS $$
DECLARE
    v_days INT;
BEGIN
    SELECT end_date - start_date
      INTO v_days
      FROM rentals
     WHERE rental_id = p_rental_id;
    RETURN v_days;
END;
$$ LANGUAGE plpgsql;

SELECT rental_days(2);   -- 5
SELECT rental_days(11);  -- 8
SELECT rental_days(19);  -- NULL because end_date is NULL (open rental)
SELECT rental_days(999); -- NULL because no matching row was found

-- Exercise 2.2: Count member rentals. COUNT returns 0 for no matching rows.
CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT)
RETURNS INT AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
      FROM rentals
     WHERE member_id = p_member_id;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

SELECT member_rental_count(1); -- 5
SELECT member_rental_count(5); -- 4
SELECT member_rental_count(6); -- 0
SELECT member_rental_count(99); -- 0; COUNT(*) returns zero, not NULL

-- Exercise 2.3: Return station city.
CREATE OR REPLACE FUNCTION station_city(p_station_id INT)
RETURNS VARCHAR AS $$
DECLARE
    v_city VARCHAR(40);
BEGIN
    SELECT city INTO v_city
      FROM stations
     WHERE station_id = p_station_id;
    RETURN v_city;
END;
$$ LANGUAGE plpgsql;

SELECT station_city(30); -- Astana
SELECT station_city(77); -- NULL (not found)

-- Exercise 2.4: Use rental_days() in a query.
SELECT rental_id, member_id, rental_days(rental_id) AS duration_days
FROM rentals
WHERE rental_days(rental_id) > 4
ORDER BY duration_days DESC;

-- ============================================================
-- PART 3: PARAMETER MODES
-- ============================================================

-- Exercise 3.1: IN parameters / discount.
CREATE OR REPLACE FUNCTION fee_with_discount(p_fee NUMERIC, p_percent NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND(p_fee * (1 - p_percent / 100), 2);
END;
$$ LANGUAGE plpgsql;

SELECT fee_with_discount(74.00, 15); -- 62.90

-- Exercise 3.2: OUT parameters / member statistics.
CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT,
    OUT rental_cnt INT,
    OUT total_fee NUMERIC,
    OUT last_start DATE
) AS $$
BEGIN
    SELECT COUNT(*), COALESCE(SUM(fee), 0), MAX(start_date)
      INTO rental_cnt, total_fee, last_start
      FROM rentals
     WHERE member_id = p_member_id;
END;
$$ LANGUAGE plpgsql;

SELECT member_stats(3);
SELECT * FROM member_stats(3);
SELECT * FROM member_stats(6); -- 0 rentals, 0 total, NULL last date
-- SELECT form returns one composite value; SELECT * expands the OUT columns,
-- and is convenient for use in larger queries.

-- Exercise 3.3: INOUT late fee.
CREATE OR REPLACE FUNCTION apply_late_fee(INOUT p_fee NUMERIC)
AS $$
BEGIN
    p_fee := p_fee + 5.00;
END;
$$ LANGUAGE plpgsql;

SELECT apply_late_fee((SELECT fee FROM rentals WHERE rental_id = 1)); -- 18.50
-- INOUT is returned as an output parameter, so no RETURNS/RETURN is needed.

-- Exercise 3.4: VARIADIC fee summary.
CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC,
    OUT average NUMERIC,
    OUT largest NUMERIC
) AS $$
BEGIN
    SELECT COALESCE(SUM(p_fees[i]), 0),
           ROUND(AVG(p_fees[i]), 2),
           MAX(p_fees[i])
      INTO total, average, largest
      FROM generate_subscripts(p_fees, 1) AS g(i);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_summary(13.50, 35.00, 18.50, 31.50);
-- With no arguments the array is empty: total is 0; average/largest are NULL.
SELECT * FROM fee_summary();

-- Exercise 3.5: Parameter modes (answers):
-- (a) row id to look up: IN, input only.
-- (b) balance updated and returned: INOUT.
-- (c) unknown-length list of station ids: VARIADIC (last parameter).
-- (d) two stats from one table pass: OUT parameters.

-- ============================================================
-- PART 4: DEFAULT VALUES AND OVERLOADING
-- ============================================================

-- Exercise 4.1: Total fees per member.
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO v_total
      FROM rentals
     WHERE member_id = p_member_id;
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1); -- 99.00 (open rental excluded because fee is NULL)
SELECT total_fees(6); -- 0

-- Exercise 4.2: Overload with a starting date.
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT, p_from_date DATE)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO v_total
      FROM rentals
     WHERE member_id = p_member_id
       AND start_date >= p_from_date;
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1, DATE '2024-01-01'); -- 99.00
SELECT total_fees(1, DATE '2025-01-01'); -- 50.00

-- Exercise 4.3: Demonstrate ambiguity by adding a DEFAULT.
-- This definition is valid, but SELECT total_fees(1) becomes ambiguous
-- while total_fees(INT) still exists.
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT,
                                     p_from_date DATE DEFAULT DATE '2025-01-01')
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO v_total
      FROM rentals
     WHERE member_id = p_member_id
       AND start_date >= p_from_date;
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

-- Uncomment to observe the ambiguity error (and its hint) in PostgreSQL:
-- SELECT total_fees(1);

-- Exercise 4.4: Drop one-argument version to resolve ambiguity.
DROP FUNCTION total_fees(INTEGER);
SELECT total_fees(1); -- resolves to the two-parameter version with default: 50.00
-- Dropping the date version instead would leave the all-time version (99.00).

-- Exercise 4.5: Overload by member name.
CREATE OR REPLACE FUNCTION total_fees(p_member_name VARCHAR)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(r.fee), 0) INTO v_total
      FROM members m
      LEFT JOIN rentals r ON r.member_id = m.member_id
     WHERE m.full_name = p_member_name;
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees('Aisha Nurlanova'); -- 99.00 (name overload, all dates)
SELECT total_fees(1); -- 50.00 (integer overload with default cutoff)
-- String argument resolves to VARCHAR overload; integer resolves to INT overload.

-- ============================================================
-- PART 5: FUNCTIONS THAT RETURN A TABLE
-- ============================================================

-- Exercise 5.1: Case-insensitive bike search.
CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR)
RETURNS TABLE(found_id INT, found_model VARCHAR, found_rate NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model::VARCHAR, b.daily_rate
      FROM bikes b
     WHERE b.model ILIKE p_pattern
     ORDER BY b.bike_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM find_bikes('%road%');
SELECT * FROM find_bikes('%Mini');
-- SELECT find_bikes('%road%') without FROM returns a composite value per row.

-- Exercise 5.2: Member rental history.
CREATE OR REPLACE FUNCTION member_history(p_member_id INT)
RETURNS TABLE(
    rental_id INT,
    bike_model VARCHAR,
    station_name VARCHAR,
    duration_days INT,
    fee NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.rental_id, b.model::VARCHAR, s.station_name::VARCHAR,
           (r.end_date - r.start_date)::INT, r.fee
      FROM rentals r
      JOIN bikes b ON b.bike_id = r.bike_id
      JOIN stations s ON s.station_id = b.station_id
     WHERE r.member_id = p_member_id
     ORDER BY r.start_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM member_history(3);

-- Exercise 5.3: Name collision demonstration (broken version).
-- CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
-- RETURNS TABLE (bike_id INT, model VARCHAR) AS $$
-- BEGIN
--     RETURN QUERY SELECT bike_id, model FROM bikes WHERE station_id = p_station_id;
-- END; $$ LANGUAGE plpgsql;
-- SELECT * FROM bike_list(10);
-- The call fails because output variable bike_id/model conflict with table columns.
-- Fix #1: rename output columns.
CREATE OR REPLACE FUNCTION bike_list_renamed(p_station_id INT)
RETURNS TABLE(found_bike_id INT, found_model VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model::VARCHAR
      FROM bikes b
     WHERE b.station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list_renamed(10);

-- Fix #2: retain output names, qualify columns with table alias.
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE(bike_id INT, model VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model::VARCHAR
      FROM bikes AS b
     WHERE b.station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);

-- Exercise 5.4: Station board. COUNT is BIGINT, cast to INT for RETURNS TABLE.
CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE(s_name VARCHAR, s_bikes INT, s_free INT) AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_name::VARCHAR,
           COUNT(b.bike_id)::INT,
           (s.capacity - COUNT(b.bike_id))::INT
      FROM stations s
      LEFT JOIN bikes b ON b.station_id = s.station_id
     WHERE s.city = p_city
     GROUP BY s.station_id, s.station_name, s.capacity
     ORDER BY s.station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM station_board('Almaty');
-- Without ::INT, PostgreSQL reports a return-type mismatch (COUNT is BIGINT).

-- ============================================================
-- PART 6: BLOCK STRUCTURE, DO BLOCKS AND SUBBLOCKS
-- ============================================================

-- Exercise 6.1: Labelled anonymous block.
DO $$
<<rental_report>>
DECLARE
    total_rentals INTEGER := 0;
BEGIN
    SELECT COUNT(*) INTO total_rentals FROM rentals;
    RAISE NOTICE 'The rentals table holds % rows.', total_rentals;
END rental_report;
$$;

-- Exercise 6.2: Shadowed variable / access outer variable by label.
DO $$
<<outer_block>>
DECLARE
    fee_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO fee_total FROM rentals;
    RAISE NOTICE 'Outer before subblock: %', fee_total; -- 583.00
    DECLARE
        fee_total NUMERIC;
    BEGIN
        SELECT COALESCE(SUM(fee), 0) INTO fee_total
          FROM rentals
         WHERE start_date >= DATE '2025-01-01';
        RAISE NOTICE 'Subblock local: %', fee_total; -- 363.00
        RAISE NOTICE 'Outer via label: %', outer_block.fee_total; -- 583.00
    END;
    RAISE NOTICE 'Outer after subblock: %', fee_total; -- 583.00
END outer_block;
$$;

-- Exercise 6.3: Variables are local to their block.
-- The following commented block would fail: inner_value is out of scope.
-- DO $$
-- BEGIN
--   DECLARE inner_value INT := 5;
--   BEGIN RAISE NOTICE '%', inner_value; END;
--   BEGIN RAISE NOTICE '%', inner_value; END; -- ERROR: variable does not exist
-- END;
-- $$;
-- Declare the variable in the outer block instead to make it visible in both subblocks.

-- Exercise 6.4: Fee totals before/after a date.
CREATE OR REPLACE FUNCTION fee_split(p_from_date DATE,
    OUT before_total NUMERIC,
    OUT after_total NUMERIC)
AS $$
BEGIN
    SELECT COALESCE(SUM(fee) FILTER (WHERE start_date < p_from_date), 0),
           COALESCE(SUM(fee) FILTER (WHERE start_date >= p_from_date), 0)
      INTO before_total, after_total
      FROM rentals;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_split(DATE '2025-01-01');
SELECT (before_total + after_total) AS combined_total
FROM fee_split(DATE '2025-01-01'); -- 583.00

-- ============================================================
-- PART 7: PRACTICAL SCENARIOS
-- ============================================================

-- Exercise 7.1: Station occupancy. For zero capacity, percentage is NULL.
CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT,
    OUT bikes_parked INT,
    OUT capacity_pct NUMERIC
) AS $$
DECLARE
    v_capacity INT;
BEGIN
    SELECT COUNT(b.bike_id)::INT, s.capacity
      INTO bikes_parked, v_capacity
      FROM stations s
      LEFT JOIN bikes b ON b.station_id = s.station_id
     WHERE s.station_id = p_station_id
     GROUP BY s.station_id, s.capacity;

    IF v_capacity IS NULL THEN
        bikes_parked := NULL;
        capacity_pct := NULL;
    ELSIF v_capacity = 0 THEN
        capacity_pct := NULL; -- undefined for zero capacity, avoid division by zero
    ELSE
        capacity_pct := ROUND(bikes_parked * 100.0 / v_capacity, 1);
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT s.station_id, s.station_name, l.*
FROM stations s, LATERAL station_load(s.station_id) l
ORDER BY s.station_id;

-- Exercise 7.2: Top members by total amount spent, default limit 3.
CREATE OR REPLACE FUNCTION top_members(p_limit INT DEFAULT 3)
RETURNS TABLE(member_name VARCHAR, rental_count BIGINT, amount_spent NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name::VARCHAR,
           COUNT(r.rental_id),
           COALESCE(SUM(r.fee), 0)::NUMERIC
      FROM members m
      LEFT JOIN rentals r ON r.member_id = m.member_id
     GROUP BY m.member_id, m.full_name
     ORDER BY COALESCE(SUM(r.fee), 0) DESC, COUNT(r.rental_id) DESC, m.member_id
     LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM top_members();
SELECT * FROM top_members(6);
-- Ranking is by money spent, not rental count; a member with fewer but expensive
-- rentals can rank higher. Ties are deterministically broken by count then ID.

-- Exercise 7.3: Invoice for closed/open rental.
CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
RETURNS TABLE(
    member_name VARCHAR,
    bike_model VARCHAR,
    duration_days INT,
    amount_owed NUMERIC,
    status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name::VARCHAR,
           b.model::VARCHAR,
           (COALESCE(r.end_date, CURRENT_DATE) - r.start_date)::INT,
           ROUND((COALESCE(r.end_date, CURRENT_DATE) - r.start_date)
                 * b.daily_rate, 2)::NUMERIC,
           CASE WHEN r.end_date IS NULL THEN 'OPEN'::VARCHAR
                ELSE 'CLOSED'::VARCHAR END
      FROM rentals r
      JOIN members m ON m.member_id = r.member_id
      JOIN bikes b ON b.bike_id = r.bike_id
     WHERE r.rental_id = p_rental_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM rental_invoice(11);
SELECT * FROM rental_invoice(19);
-- CURRENT_DATE makes the open-rental invoice change each day; this function
-- cannot be IMMUTABLE (use STABLE or VOLATILE; default is VOLATILE).

-- Exercise 7.4: City reports; date condition belongs in LEFT JOIN ON clause
-- so members with zero rentals after cutoff remain counted.
CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR)
RETURNS TABLE(member_count BIGINT, rental_count BIGINT, revenue NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(DISTINCT m.member_id),
           COUNT(r.rental_id),
           COALESCE(SUM(r.fee), 0)::NUMERIC
      FROM members m
      LEFT JOIN rentals r ON r.member_id = m.member_id
     WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR, p_from_date DATE)
RETURNS TABLE(member_count BIGINT, rental_count BIGINT, revenue NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(DISTINCT m.member_id),
           COUNT(r.rental_id),
           COALESCE(SUM(r.fee), 0)::NUMERIC
      FROM members m
      LEFT JOIN rentals r
        ON r.member_id = m.member_id
       AND r.start_date >= p_from_date
     WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM city_report('Almaty');
SELECT * FROM city_report('Almaty', DATE '2025-01-01');
-- If date condition is moved into WHERE, unmatched members are filtered out,
-- effectively converting the LEFT JOIN into an INNER JOIN for that condition.

-- ============================================================
-- LAB QUESTIONS: answers in comments
-- ============================================================
-- 1. Name is the identifier; signature is name plus argument types/modes.
--    DROP needs a signature to distinguish overloaded functions.
-- 2. Dollar quoting encloses function body without escaping internal quotes.
--    Example: RETURN 'It''s stored'; inside $$ ... $$.
-- 3. OUT is convenient for a fixed set of scalar outputs; RETURNS TABLE is
--    better for row sets that can be queried/filtered/joined with FROM.
-- 4. VARIADIC must be last so the remaining arguments can be collected
--    unambiguously into its array; otherwise later arguments cannot be separated.
-- 5. RETURN returns a scalar/composite result; RETURN QUERY appends rows
--    from a query in a set-returning function.
-- 6. DEFAULT can overlap an existing shorter signature and make calls ambiguous.
--    Avoid by removing conflicting overloads or choosing distinct names/signatures.
-- 7. Subblock variables cease to be accessible outside that block. Use
--    outer_block.variable to access a shadowed outer variable inside a subblock.
-- 8. Advantage: centralised consistent rule. Disadvantage: DB-specific code
--    and added database CPU / harder testing and versioning.
-- 9. Trusted PL/pgSQL cannot access outside the DB server and can be used by
--    ordinary permitted users; untrusted PL/Python can access OS/network and
--    generally requires superuser privilege.
-- 10. CREATE OR REPLACE with changed argument types creates a different overload;
--     it does not replace the old signature, potentially leaving ambiguity/old code.

-- ============================================================
-- OPTIONAL CHALLENGE 1: Busiest station since a date
-- ============================================================
CREATE OR REPLACE FUNCTION busiest_station(p_from_date DATE DEFAULT DATE '2024-01-01')
RETURNS TABLE(station_id INT, station_name VARCHAR, rented_days BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_id, s.station_name::VARCHAR,
           COALESCE(SUM(COALESCE(r.end_date, CURRENT_DATE) - r.start_date), 0)::BIGINT
      FROM stations s
      JOIN bikes b ON b.station_id = s.station_id
      LEFT JOIN rentals r ON r.bike_id = b.bike_id
                         AND r.start_date >= p_from_date
     GROUP BY s.station_id, s.station_name
     ORDER BY rented_days DESC, s.station_id
     LIMIT 1;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM busiest_station();

-- OPTIONAL CHALLENGE 2: Loop through members and print summary.
DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT m.member_id, m.full_name,
               COUNT(r.rental_id) AS rental_count,
               COALESCE(SUM(r.fee), 0) AS total_fee
        FROM members m
        LEFT JOIN rentals r ON r.member_id = m.member_id
        GROUP BY m.member_id, m.full_name
        ORDER BY m.member_id
    LOOP
        RAISE NOTICE 'Member % (%): rentals %, total fee %',
            rec.member_id, rec.full_name, rec.rental_count, rec.total_fee;
    END LOOP;
END;
$$;

-- OPTIONAL CHALLENGE 3: Raise an exception for unknown rental id.
-- To change rental_days to throw an error instead of NULL, replace its body
-- with a SELECT ... INTO followed by IF NOT FOUND THEN RAISE EXCEPTION ... END IF.
-- This is not always better when used inside a large query, because one unknown
-- id would abort the whole query rather than yield NULL for that row.

-- OPTIONAL CHALLENGE 5: Procedure to close a rental.
CREATE OR REPLACE PROCEDURE close_rental(p_rental_id INT, p_end_date DATE DEFAULT CURRENT_DATE)
LANGUAGE plpgsql AS $$
DECLARE
    v_start DATE;
    v_rate NUMERIC;
BEGIN
    SELECT r.start_date, b.daily_rate
      INTO v_start, v_rate
      FROM rentals r
      JOIN bikes b ON b.bike_id = r.bike_id
     WHERE r.rental_id = p_rental_id
       AND r.end_date IS NULL;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Rental % not found or already closed', p_rental_id;
    END IF;

    UPDATE rentals
       SET end_date = p_end_date,
           fee = (p_end_date - v_start) * v_rate
     WHERE rental_id = p_rental_id;
END;
$$;

-- Example (commented because it modifies sample data):
-- CALL close_rental(19, CURRENT_DATE);
-- A PROCEDURE is invoked with CALL and can perform transaction control in
-- permitted contexts; functions are called in queries and cannot commit/rollback.

-- End of Laboratory Work 9.
