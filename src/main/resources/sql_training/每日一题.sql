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

--删除重复的电子邮箱
create table Person(
                       Id bigint,
                       Email string
);

insert into table Person values
    (1,'john@example.com'),
    (2,'bob@example.com'),
    (3,'john@example.com');

select
    a.Id,
    a.Email
from
    (
        select
            Id as Id,
            Email as Email,
            row_number() over(partition by Email order by Id asc) as rn
        from Person
    ) a
where a.rn = 1
order by a.Id
;

--行程和用户
create table Trips(
                      Id bigint,
                      Client_Id bigint,
                      Driver_Id bigint,
                      City_Id bigint,
                      Status String,
                      Request_at date
);


insert into table Trips values
    (1,1,10,1,'completed','2013-10-01')
    ,(2,2,11,1,'cancelled_by_driver','2013-10-01')
    ,(3,3,12,6,'completed','2013-10-01')
    ,(4,4,13,6,'cancelled_by_client','2013-10-01')
    ,(5,1,10,1,'completed','2013-10-02')
    ,(6,2,11,6,'completed','2013-10-02')
    ,(7,3,12,6,'completed','2013-10-02')
    ,(8,2,12,12,'completed','2013-10-03')
    ,(9,3,10,12,'completed','2013-10-03')
    ,(10,4,13,12,'cancelled_by_driver','2013-10-03');

create table Users(
                      User_id bigint,
                      Banned string,
                      Role string
);

insert into table Users values
    (1,'No','client')
    ,(2,'Yes','client')
    ,(3,'No','client')
    ,(4,'No','client')
    ,(10,'No','driver')
    ,(11,'No','driver')
    ,(12,'No','driver')
    ,(13,'No','driver');

select
    c.Request_at as Day,
    round(sum(num)/count(*),2) as Cancellation_Rate
from
    (
    select
    b.Request_at as Request_at,
    if(b.Status <> 'completed',1,0) as num --给取消的行程一个计数值1
    from
    (
    select
    User_id
    from Users
    where Banned <> 'Yes' and Role = 'client'
    ) a
    left join Trips b
    on a.User_id = b.Client_Id
    ) c
group by c.Request_at
;

--可以省略一层子查询
select
    b.Request_at as Day,
    round(sum(if(b.Status <> 'completed',1,0))/count(*),2) as Cancellation_Rate --给取消的订单一个计数值1,加总即为取消的订单数，然后除以总订单数
from
    (
    select
    User_id
    from Users
    where Banned <> 'Yes' and Role = 'client'
    ) a
    left join Trips b
on a.User_id = b.Client_Id
group by b.Request_at
;




















