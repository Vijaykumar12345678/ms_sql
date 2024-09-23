"""
@Author:Vijay Kumar M N
@Date: 2024-09-18
@Last Modified by: Vijay Kumar M N
@Last Modified: 2024-09-18
@Title : crud operations on mssql.
"""
-- CRUD OPERATIONS

-- create the database 
create database company;

--using the database
use company;

--create a table


--create a table for Employees

create table Employee(
Eid int primary key,
EName varchar(255),
Depcode varchar(255),
salary int,
age int);

--inserting the values to the employee tabl;e
insert into Employee values(1,'sameer sharma','123',75000,39),
(2,'raguvindra k','101',86000,29),
(3,'rama gupta','119',52500,43),
(4,'menon c r','103',67000,38),
(5,'mohan kumar','103',63000,33),
(6,'rajesh kumar','119',74000,44),
(7,'sanjeev','101',92600,54),
(8,'ganesh','123',32000,39);


--reading the data for the employee table
select * from Employee;

--create a table for department
create table department (
Depcode varchar(255) primary key,
DName varchar(255),
DHead varchar(255));


--inserting a values for the department
insert into department values('101','Accounts','Rajiv kumar'),('103','HR','P K Singh'),('119','IT','Yogish shetty'),('123','Research','Ajay Dutta');


--adding foreign key constraint in the employee table
ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_department
FOREIGN KEY (Depcode)
REFERENCES department(Depcode);

--reading the data for the department table
select * from department;

--updating the depcode for the employee where id is 5

update Employee
set Depcode='123'
where Eid=5;

--update the deparment head of research
update department
set DHead='Rahul'
where DName='Research';


--delete a value in the employee table where id 3
delete from Employee
where Eid=3;

--delete a table 
begin transaction;
drop table Employee;
drop table department;
--roll back the tables
rollback;


