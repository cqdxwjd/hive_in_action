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

--2.寻找连续出现的数字

create table Logs(
                     Id bigint,
                     Num bigint
);

insert into table Logs values
    (1,1),
    (2,1),
    (3,1),
    (4,2),
    (5,1),
    (6,2),
    (7,2);

--方式1，使用窗口函数求差值
select
    a.Num as ConsecutiveNums
from
    (
        select
            Id as Id,
            Num as Num,
            row_number() over (partition by Num order by Id) as rn
        from Logs
    ) a
group by
        a.Id-a.rn,--如果是连续出现的数字，那么根据数字分组，在组内排序之后得到的序号与原始序号差值相等。
        a.Num
having count(*) >= 3 --过滤至少出现3次的数字。
;

--方式2，连续join自身2次
select
    distinct ConsecutiveNums
from(
        select
            t1.Num as Num1,
            t2.Num as Num2,
            t3.Num as Num3,
            if(t1.Num=t2.Num=t3.Num,t1.Num,null) as ConsecutiveNums
        from Logs t1
                 left join Logs t2 on t1.Id = t2.Id - 1
                 left join Logs t3 on t2.Id = t3.Id - 1
    ) a
where a.ConsecutiveNums is not null
;