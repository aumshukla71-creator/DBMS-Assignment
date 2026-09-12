-- ===================================================
-- DATABASE SCHEMA: College & Event Management System
-- ===================================================

CREATE DATABASE CollegeManagementDB;
USE CollegeManagementDB;

-- 1. Departments Table
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL,
    dept_code VARCHAR(10) UNIQUE NOT NULL,
    office_location VARCHAR(100)
);

-- 2. Faculty Table
CREATE TABLE Faculty (
    faculty_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id) ON DELETE SET NULL
);

-- 3. Students Table
CREATE TABLE Students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    enrollment_number VARCHAR(20) UNIQUE NOT NULL,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id) ON DELETE CASCADE
);

-- 4. Courses Table
CREATE TABLE Courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(15) UNIQUE NOT NULL,
    course_title VARCHAR(100) NOT NULL,
    credits INT DEFAULT 3,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
);

-- 5. Events Table (College Event Management)
CREATE TABLE Events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    event_name VARCHAR(120) NOT NULL,
    event_type VARCHAR(50),
    event_date DATE NOT NULL,
    venue VARCHAR(100),
    organized_by_dept INT,
    faculty_coordinator_id INT,
    FOREIGN KEY (organized_by_dept) REFERENCES Departments(dept_id),
    FOREIGN KEY (faculty_coordinator_id) REFERENCES Faculty(faculty_id)
);

-- 6. Event Registrations Table
CREATE TABLE EventRegistrations (
    registration_id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT NOT NULL,
    student_id INT NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    attendance_status ENUM('Registered', 'Attended', 'Absent') DEFAULT 'Registered',
    FOREIGN KEY (event_id) REFERENCES Events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE
);

-- 7. Fees / Payments Table
CREATE TABLE Fees (
    fee_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    amount_due DECIMAL(10,2) NOT NULL,
    amount_paid DECIMAL(10,2) DEFAULT 0.00,
    payment_status ENUM('Paid', 'Partial', 'Pending') DEFAULT 'Pending',
    due_date DATE,
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- ===================================================
-- SAMPLE DATA POPULATION
-- ===================================================

INSERT INTO Departments (dept_name, dept_code, office_location) VALUES
('Information Technology', 'IF', 'Tech Wing B-201'),
('Computer Engineering', 'CO', 'Tech Wing A-101');

INSERT INTO Faculty (first_name, last_name, email, phone, dept_id) VALUES
('Suresh', 'Kulkarni', 'suresh.k@college.edu', '9820011223', 1),
('Anita', 'Deshmukh', 'anita.d@college.edu', '9820044556', 2);

INSERT INTO Students (first_name, last_name, email, enrollment_number, dept_id) VALUES
('Aum', 'Shukla', 'aumshukla71@gmail.com', 'EN24019284', 1),
('Sai', 'Pallavi', 'sai.p@college.edu', 'EN24019285', 1),
('Unniti', 'Hawaldar', 'unniti.h@college.edu', 'EN24019286', 1);

INSERT INTO Events (event_name, event_type, event_date, venue, organized_by_dept, faculty_coordinator_id) VALUES
('CyberSecurity Symposium 2026', 'Technical Seminar', '2026-09-25', 'Auditorium 1', 1, 1),
('Data Hackathon', 'Competition', '2026-10-10', 'Computer Lab 3', 1, 1);

INSERT INTO EventRegistrations (event_id, student_id, attendance_status) VALUES
(1, 1, 'Attended'),
(1, 2, 'Attended'),
(2, 1, 'Registered');

-- ===================================================
-- ANALYTICAL QUERIES
-- ===================================================

-- Query 1: Retrieve student registrations per event with department tracking
SELECT 
    e.event_name,
    e.event_date,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    d.dept_name,
    er.attendance_status
FROM Events e
JOIN EventRegistrations er ON e.event_id = er.event_id
JOIN Students s ON er.student_id = s.student_id
JOIN Departments d ON s.dept_id = d.dept_id
ORDER BY e.event_date DESC;

-- Query 2: Attendance aggregation by event
SELECT 
    e.event_name,
    COUNT(er.student_id) AS total_registrations,
    SUM(CASE WHEN er.attendance_status = 'Attended' THEN 1 ELSE 0 END) AS attendees
FROM Events e
LEFT JOIN EventRegistrations er ON e.event_id = er.event_id
GROUP BY e.event_id, e.event_name;