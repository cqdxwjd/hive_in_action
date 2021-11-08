--1.编写一个 SQL 查询，找出每个部门工资最高的员工。例如，根据上述给定的表格，Max 在 IT 部门有最高工资，Henry 在 Sales 部门有最高工资。

create table Employee(
                         Id bigint,
                         Name string,
                         Salary double,
                         DepartmentId bigint
);

insert into table Employee values
    (1,'Joe',70000,1),
    (2,'Henry',80000,2),
    (3,'Sam',60000,2),
    (4,'Max',90000,1);

create table Department(
                           Id bigint,
                           Name string
);

insert into table Department values
    (1,'IT'),
    (2,'Sales');

select
    DepartmentName,
    EmployeeName,
    Salary
from
    (
        select
            a.Name as DepartmentName,
            b.Name as EmployeeName,
            b.Salary as Salary,
            rank() over (partition by a.Name order by b.Salary desc) as rn
        from Department a
                 left join Employee b
                           on a.Id = b.DepartmentId
    ) c
where c.rn = 1;