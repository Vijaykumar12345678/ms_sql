/*
@Author:Vijay Kumar M N
@Date: 2024-09-23
@Last Modified by: Vijay Kumar M N
@Last Modified: 2024-09-23
@Title : Basics joins in mssql
*/

-- create the database 
--create database company2;

--using the database
use company2;

--create a table

--create table company
CREATE TABLE Company (
    CompanyID INT PRIMARY KEY IDENTITY(1,1),
    CompanyName VARCHAR(255) NOT NULL,
    Location VARCHAR(255),
    EstablishedDate DATE,
    Industry VARCHAR(255)
);

-- Insert sample records


INSERT INTO Company (CompanyName, Location, EstablishedDate, Industry) VALUES
('Tech Innovations Inc.', 'Silicon Valley, CA', '2015-01-15', 'Technology'),
('Green Solutions Ltd.', 'Austin, TX', '2018-03-22', 'Environmental Services'),
('HealthCare Plus', 'New York, NY', '2010-06-30', 'Healthcare'),
('EduTech Systems', 'Boston, MA', '2012-09-10', 'Education'),
('FinCorp Group', 'Chicago, IL', '2016-02-25', 'Finance');


--create a table department

CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName VARCHAR(255) NOT NULL,
    CompanyID INT,
    FOREIGN KEY (CompanyID) REFERENCES Company(CompanyID)
);

-- Insert sample records

INSERT INTO Department (DepartmentName, CompanyID) VALUES
('Software Development', 1),
('Sales', 1),
('Research & Development', 2),
('Customer Service', 3),
('Finance', 4),
('Human Resources', 5);


--create a table employee

CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE,
    PhoneNumber VARCHAR(20),
    HireDate DATE,
    DepartmentID INT,
    CompanyID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    FOREIGN KEY (CompanyID) REFERENCES Company(CompanyID)
);

-- Insert sample records

INSERT INTO Employee (Name, Email, PhoneNumber, HireDate, DepartmentID, CompanyID) VALUES
('Alice Johnson', 'alice.johnson@techinnovations.com', '555-1234', '2015-02-20', 1, 1),
('Bob Smith', 'bob.smith@techinnovations.com', '555-5678', '2017-04-15', 2, 1),
('Charlie Brown', 'charlie.brown@greensolutions.com', '555-8765', '2019-01-10', 3, 2),
('Dana White', 'dana.white@healthcareplus.com', '555-4321', '2011-05-01', 4, 3),
('Eva Green', 'eva.green@edutechsystems.com', '555-3456', '2013-08-15', 5, 4);


--inner join

--to fetch the employee who all are working in which company
select 
	e.Name,
	c.Companyname 
from
	Company c 
join
	Employee e
on
	e.CompanyID=c.CompanyID;


--to fetch the employee who all are working in which department


select
	e.Name,
	d.DepartmentName 
from 
	Employee e
join
	department d 
on
	e.DepartmentId=d.DepartmentId;



--left join

select 
	* 
from
	company c 
left join
	Employee e 
on
	c.CompanyID=e.CompanyId;


--right join


select 
	* 
from
	Employee e 
right join
	department d 
on
	d.departmentId=e.departmentId;


--full outer join 

select 
	* 
from
	company c 
full outer join
	Employee e 
on
	c.CompanyID=e.CompanyId;

--cross/cartesian join




select 
	* 
from
	company c 
cross join
	Employee e ;



--Natural join

select 
	* 
from
	company 
inner join
	Employee  
on
	company.CompanyID=Employee.CompanyId;
