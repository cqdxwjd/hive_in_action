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

--游戏玩法分析
create table Activity(
                         player_id int,
                         device_id int,
                         event_date date,
                         games_played int
);

insert into table Activity values
    (1,2,'2016-03-01',5)
    ,(1,2,'2016-05-02',6)
    ,(2,3,'2017-06-25',1)
    ,(3,1,'2016-03-02',0)
    ,(3,4,'2018-07-03',5);

select
    player_id as player_id,
    min(event_date) as first_login
from Activity
group by player_id
;

--员工薪水中位数
create table Employee(
                         Id bigint,
                         Company string,
                         Salary double
);

insert into table Employee values
    (1,'A',2341  )
    ,(2,'A',341   )
    ,(3,'A',15    )
    ,(4,'A',15314 )
    ,(5,'A',451   )
    ,(6,'A',513   )
    ,(7,'B',15    )
    ,(8,'B',13    )
    ,(9,'B',1154  )
    ,(10,'B',1345 )
    ,(11,'B',1221 )
    ,(12,'B',234  )
    ,(13,'C',2345 )
    ,(14,'C',2645 )
    ,(15,'C',2645 )
    ,(16,'C',2652 )
    ,(17,'C',65   );

select
    min(c.Id) as Id,
    c.Company,
    c.Salary
from
    (
        select
            a.Id,
            a.Company,
            a.Salary
        from Employee a
                 left join Employee b
                           on a.Company = b.Company
        group by
            a.Id,
            a.Company,
            a.Salary
        having sum(case when a.Salary>b.Salary then 1 when a.Salary=b.Salary then 0 else -1 end) in (1,-1)
    ) c
group by
    c.Company,
    c.Salary
;

--员工奖金【难度简单】
--选出所有 bonus < 1000 的员工的 name 及其 bonus

create table Employee(
                         empId bigint,
                         name string,
                         supervisor bigint,
                         salary double
);

insert into table Employee values
    (1,'John',3,1000),
    (2,'Dan',3,2000),
    (3,'Brad',null,4000),
    (4,'Thomas',3,4000);

create table Bonus(
                      empId bigint,
                      bonus double
);

insert into table Bonus values
    (2,500),
    (4,2000);

select
    a.name,
    b.bonus
from Employee a
         left join Bonus b
                   on a.empId = b.empId
where b.bonus < 1000 or b.bonus is null;

--至少有5名直接下属的经理

create table Employee(
                         Id bigint,
                         Name string,
                         Department string,
                         ManagerId bigint
);

insert into table Employee values
    (101,'John','A',null),
    (102,'Dan','A',101),
    (103,'James','A',101),
    (104,'Amy','A',101),
    (105,'Anne','A',101),
    (106,'Ron','B',101);

select
    c.Name
from
    (
        select
            a.Id,
            a.Name
        from Employee a
                 left join Employee b
                           on a.Id = b.ManagerId
        group by a.Id,a.Name --用Id分组，防止同名情况
        having count(*) >= 5
    ) c
;

--寻找用户推荐人【难度简单】

create table customer(
                         id bigint,
                         name string,
                         referee_id bigint
);

insert into table customer values
    (1,'Will',null),
    (2,'Jane',null),
    (3,'Alex',2),
    (4,'Bill',null),
    (5,'Zack',1),
    (6,'Mark',2);

select
    name
from customer
where referee_id <> 2 or referee_id is null;

--统计各专业学生人数【难度中等】

create table student(
                        student_id bigint,
                        student_name string,
                        gender string,
                        dept_id bigint
);

create table department(
                           dept_id bigint,
                           dept_name string
);

insert into table student values
    (1,'Jack','M',1),
    (2,'Jane','F',1),
    (3,'Mark','M',2);

insert into table department values
    (1,'Engineering'),
    (2,'Science'),
    (3,'Law');

select
    a.dept_name as dept_name,
    sum(if(b.student_id is null,0,1)) as student_number
from department a
         left join student b
                   on a.dept_id = b.dept_id
group by dept_name
order by student_number desc,dept_name asc
;

-- 判断三角形【难度简单】

create table triangle(
                         x double,
                         y double,
                         z double
)
;

insert into table triangle values
    (13,15,30),
    (10,20,15)
;

select
    a.x as x,
    a.y as y,
    a.z as z,
    if(a.arr[0]+a.arr[1]>a.arr[2],'Yes','No') as triangle -- 最小的两条边之和大于第三边即可构成三角形
from
    (
        select
            x as x,
            y as y,
            z as z,
            sort_array(array(x,y,z)) as arr --升序排序
        from triangle
    ) a
;


--平面上的最近距离【难度中等】

create table point_2d(
                         x int,
                         y int
);

insert into table point_2d values
    (-1,-1),
    (0,0),
    (-1,-2)
;

select
    min(sqrt((a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y))) as shortest
from point_2d a
         left join point_2d b
                   on (a.x <> b.x or a.y <> b.y)
;

--有趣的电影【难度简单】

create table cinema(
                       id bigint,
                       movie string,
                       description string,
                       rating double
);

insert into table cinema values
    (1,'War','great 3D',8.9),
    (2,'Science','fiction',8.5),
    (3,'irish','boring',6.2),
    (4,'Ice song','Fantacy',8.6),
    (5,'House card','Interesting',9.1)
;

select
    id,
    movie,
    description,
    rating
from cinema
where description <> 'boring' and id%2 <> 0
order by rating desc
;

--平均工资：部门与公司比较【难度困难】

create table salary(
                       id bigint,
                       employee_id bigint,
                       amount double,
                       pay_date date
)
;

insert into table salary values
    (1,1,9000,'2017-03-31'),
    (2,2,6000,'2017-03-31'),
    (3,3,10000,'2017-03-31'),
    (4,1,7000,'2017-02-28'),
    (5,2,6000,'2017-02-28'),
    (6,3,8000,'2017-02-28')
;

create table employee(
                         employee_id bigint,
                         department_id bigint
)
;

insert into table employee values
    (1,1),
    (2,2),
    (3,2)
;

select
    c.pay_month as pay_month,
    c.department_id as department_id,
    c.comparison as comparison
from
    (
        select
            date_format(b.pay_date,'yyyy-MM') as pay_month,
            a.department_id as department_id,
            case when
                     sum(b.amount) over (partition by date_format(b.pay_date,'yyyy-MM'),a.department_id)/count(*) over (partition by date_format(b.pay_date,'yyyy-MM'),a.department_id) --当月部门内平均值
            >
            sum(b.amount) over (partition by date_format(b.pay_date,'yyyy-MM'))/count(*) over (partition by date_format(b.pay_date,'yyyy-MM')) --当月公司总平均值
            then 'higher'
            when
            sum(b.amount) over (partition by date_format(b.pay_date,'yyyy-MM'),a.department_id)/count(*) over (partition by date_format(b.pay_date,'yyyy-MM'),a.department_id) --当月部门内平均值
            <
            sum(b.amount) over (partition by date_format(b.pay_date,'yyyy-MM'))/count(*) over (partition by date_format(b.pay_date,'yyyy-MM')) --当月公司总平均值
            then 'lower'
            else 'same'
            end as comparison
        from employee a
            left join salary b
        on a.employee_id = b.employee_id
    ) c
group by
    c.pay_month,
    c.department_id,
    c.comparison
;

--换座位【难度中等】

create table seat(
                     id int,
                     student string
);

insert into table seat values
    (1,'Abbot'),
    (2,'Doris'),
    (3,'Emerson'),
    (4,'Green'),
    (5,'Jeames')
;

select
    a.id as id,
    case
        when a.id % 2 <> 0 and a.next is not null
    then a.next
    when a.id % 2 = 0
    then a.pre
    else a.student
end as student
from
(
    select
        id,
        student,
        lag(student) over (order by id) as pre,
        lead(student) over (order by id) as next
    from seat
) a
;

--买下所有产品的客户【难度中等】

create table Customer(
                         customer_id int,
                         product_key int
);

create table Product(
    product_key int
);

insert into table Customer values
    (1,5),
    (2,6),
    (3,5),
    (3,6),
    (1,6)
;

insert into table Product values
    (5),
    (6)
;

select
    c.customer_id as customer_id
from
    (
        select
            b.customer_id as customer_id,
            count(distinct a.product_key) over () as prod_num,
                count(*) over (partition by b.customer_id) as cust_num
        from Product a
                 left join Customer b
                           on a.product_key = b.product_key
    ) c
where c.prod_num = c.cust_num
group by c.customer_id
;


--产品销售分析 II【难度简单】
CREATE TABLE sales(
                      sale_id INT,
                      product_id INT,
                      year INT,
                      quantity INT,
                      price INT
);

CREATE TABLE product(
                        product_id INT,
                        product_name STRING
);

INSERT INTO TABLE sales VALUES
    (1,100,2008,10,5000),
    (2,100,2009,12,5000),
    (7,200,2011,15,9000)
;

INSERT INTO TABLE product VALUES
    (100,'Nokia'),
    (200,'Apple'),
    (300,'Samsung')
;

-- 对产品id分组求数量和即可
SELECT
    product_id AS product_id,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY product_id
;

--产品销售分析 III【难度中等】
--选出每个销售产品的 第一年 的 产品 id、年份、数量 和 价格
--方法：使用排序函数分组排序后取第一行
SELECT
    product_id AS product_id,
    year AS first_year,
    quantity AS quantity,
    price AS price
FROM
    (
    SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY year ASC) AS rn
    FROM sales
    ) a
WHERE a.rn = 1
;

--游戏玩法分析 V【难度困难】
CREATE TABLE activity(
                         player_id INT,
                         device_id INT,
                         event_date DATE,
                         games_played INT
);

INSERT INTO TABLE activity VALUES
    (1,2,'2016-03-01',5),
    (1,2,'2016-03-02',6),
    (2,3,'2017-06-25',1),
    (3,1,'2016-03-01',0),
    (3,4,'2016-07-03',5)
;

--第一步：先通过自连接判断玩家是否有下一天留存
SELECT
    a.player_id AS player_id,
    a.event_date AS event_date,
    IF(b.player_id IS NOT NULL,1,0) AS next_day_retention --玩家是否有下一天的留存，有标记为1，否则标记为0
FROM activity AS a
         LEFT JOIN activity AS b
                   ON a.player_id = b.player_id AND DATE_ADD(a.event_date,1) = b.event_date
;

--结果
-- player_id       event_date      next_day_retention
-- 1       2016-03-01      1
-- 1       2016-03-02      0
-- 2       2017-06-25      0
-- 3       2016-03-01      0
-- 3       2016-07-03      0

--第二步：由于要求安装日期的第一天留存，需要取每个玩家的最小登录日期对应的记录，使用窗口函数分组排序最最小
SELECT
    d.player_id AS player_id,
    d.event_date AS install_dt,
    d.next_day_retention AS first_day_retention --安装日期第一天是否留存
FROM
    (
        SELECT
            c.player_id AS player_id,
            c.event_date AS event_date,
            ROW_NUMBER() OVER(PARTITION BY c.player_id ORDER BY c.event_date ASC) AS rn,
                c.next_day_retention AS next_day_retention
        FROM
            (
                SELECT
                    a.player_id AS player_id,
                    a.event_date AS event_date,
                    IF(b.player_id IS NOT NULL,1,0) AS next_day_retention --玩家是否有下一天的留存，有标记为1，否则标记为0
                FROM activity AS a
                         LEFT JOIN activity AS b
                                   ON a.player_id = b.player_id AND DATE_ADD(a.event_date,1) = b.event_date
            ) c
    ) d
WHERE d.rn = 1
;

--结果
-- player_id       event_date      first_day_retention
-- 1       2016-03-01      1
-- 2       2017-06-25      0
-- 3       2016-03-01      0

--第三步：对安装日期分组，COUNT(*)为当天的安装数量，SUM(first_day_retention)为第一天留存数量
SELECT
    e.install_dt AS install_dt,
    COUNT(*) AS installs,
    ROUND(SUM(first_day_retention)/COUNT(*),2) AS Day1_retention
FROM
    (
        SELECT
            d.player_id AS player_id,
            d.event_date AS install_dt,
            d.next_day_retention AS first_day_retention --安装日期第一天是否留存
        FROM
            (
                SELECT
                    c.player_id AS player_id,
                    c.event_date AS event_date,
                    ROW_NUMBER() OVER(PARTITION BY c.player_id ORDER BY c.event_date ASC) AS rn,
                        c.next_day_retention AS next_day_retention
                FROM
                    (
                        SELECT
                            a.player_id AS player_id,
                            a.event_date AS event_date,
                            IF(b.player_id IS NOT NULL,1,0) AS next_day_retention --玩家是否有下一天的留存，有标记为1，否则标记为0
                        FROM activity AS a
                                 LEFT JOIN activity AS b
                                           ON a.player_id = b.player_id AND DATE_ADD(a.event_date,1) = b.event_date
                    ) c
            ) d
        WHERE d.rn = 1
    ) e
GROUP BY
    e.install_dt
;
--结果
-- install_dt      installs        day1_retention
-- 2016-03-01      2       0.5
-- 2017-06-25      1       0.0

--可对嵌套查询做一下简化，最终SQL如下
SELECT
    d.event_date AS install_dt,
    COUNT(*) AS installs,
    ROUND(SUM(d.next_day_retention)/COUNT(*),2) AS Day1_retention --安装日期第一天留存率
FROM
    (
        SELECT
            c.player_id AS player_id,
            c.event_date AS event_date,
            ROW_NUMBER() OVER(PARTITION BY c.player_id ORDER BY c.event_date ASC) AS rn,
                c.next_day_retention AS next_day_retention
        FROM
            (
                SELECT
                    a.player_id AS player_id,
                    a.event_date AS event_date,
                    IF(b.player_id IS NOT NULL,1,0) AS next_day_retention --玩家是否有下一天的留存，有标记为1，否则标记为0
                FROM activity AS a
                         LEFT JOIN activity AS b
                                   ON a.player_id = b.player_id AND DATE_ADD(a.event_date,1) = b.event_date
            ) c
    ) d
WHERE d.rn = 1
GROUP BY
    d.event_date
;

--每日新用户统计【难度中等】
CREATE TABLE traffic(
                        user_id INT,
                        activity STRING,
                        activity_date DATE
);

INSERT INTO TABLE traffic VALUES
    (1,'login','2019-05-01'),
    (1,'homepage','2019-05-01'),
    (1,'logout','2019-05-01'),
    (2,'login','2019-06-21'),
    (2,'logout','2019-06-21'),
    (3,'login','2019-01-01'),
    (3,'jobs','2019-01-01'),
    (3,'logout','2019-01-01'),
    (4,'login','2019-06-21'),
    (4,'groups','2019-06-21'),
    (4,'logout','2019-06-21'),
    (5,'login','2019-03-01'),
    (5,'logout','2019-03-01'),
    (5,'login','2019-06-21'),
    (5,'logout','2019-06-21')
;

-- 第一步：得到每个用户的首次登录时间
SELECT
    activity_date AS login_date,
    ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY activity_date ASC) AS rn
FROM traffic
WHERE activity = 'login'

--第二步：得到每个用户在过去90天内的首次登录时间
SELECT
    a.login_date AS login_date
FROM
    (
        SELECT
            activity_date AS login_date,
            ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY activity_date ASC) AS rn
        FROM traffic
        WHERE activity = 'login'
    ) a
WHERE a.rn = 1
  AND a.login_date BETWEEN DATE_SUB('2019-06-30',90) AND '2019-06-30'

--第三步：根据日期分组计数等到过去90天某天首次登录的用户数
SELECT
    b.login_date AS login_date,
    COUNT(*) AS user_count
FROM
    (
        SELECT
            a.login_date AS login_date
        FROM
            (
                SELECT
                    activity_date AS login_date,
                    ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY activity_date ASC) AS rn
                FROM traffic
                WHERE activity = 'login'
            ) a
        WHERE a.rn = 1
          AND a.login_date BETWEEN DATE_SUB('2019-06-30',90) AND '2019-06-30'
    ) b
GROUP BY
    b.login_date
;

--将当前时间用函数替换并简化SQL后，最终SQL如下
SELECT
    a.login_date AS login_date,
    COUNT(*) AS user_count
FROM
    (
        SELECT
            activity_date AS login_date,
            ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY activity_date ASC) AS rn
        FROM traffic
        WHERE activity = 'login'
    ) a
WHERE a.rn = 1
  AND a.login_date BETWEEN DATE_SUB(CURRENT_DATE(),90) AND CURRENT_DATE()
GROUP BY
    a.login_date
;


--每位学生的最高成绩【难度中等】
CREATE TABLE enrollments(
                            student_id INT,
                            course_id INT,
                            grade INT
);

INSERT INTO TABLE enrollments VALUES
    (2,2,95),
    (2,3,95),
    (1,1,90),
    (1,2,99),
    (3,1,80),
    (3,2,75),
    (3,3,82)
;

SELECT
    a.student_id AS student_id,
    a.course_id AS course_id,
    a.grade AS grade
FROM
    (
        SELECT
            student_id AS student_id,
            course_id AS course_id,
            grade AS grade,
            ROW_NUMBER() OVER(PARTITION BY student_id ORDER BY grade DESC,course_id ASC) AS rn
        FROM enrollments
    ) a
WHERE a.rn = 1
ORDER BY student_id ASC
;

--报告的记录 I【难度简单】
CREATE TABLE actions(
                        user_id INT,
                        post_id INT,
                        action_date DATE,
                        action STRING,
                        extra STRING
);

INSERT INTO TABLE actions VALUES
    (1,1,'2019-07-01','view',null),
    (1,1,'2019-07-01','like',null),
    (1,1,'2019-07-01','share',null),
    (2,4,'2019-07-04','view',null),
    (2,4,'2019-07-04','report','spam'),
    (3,4,'2019-07-04','view',null),
    (3,4,'2019-07-04','report','spam'),
    (4,3,'2019-07-02','view',null),
    (4,3,'2019-07-02','report','spam'),
    (5,2,'2019-07-04','view',null),
    (5,2,'2019-07-04','report','racism'),
    (5,5,'2019-07-04','view',null),
    (5,5,'2019-07-04','report','racism')
;

SELECT
    extra AS report_reason,
    COUNT(DISTINCT post_id) AS report_count
FROM actions
WHERE action = 'report' AND extra IS NOT NULL AND action_date = '2019-07-04'
GROUP BY extra
;

--重新格式化部门表【难度中等】
CREATE TABLE department(
                           id INT,
                           revenue INT,
                           month STRING
);

INSERT OVERWRITE TABLE department VALUES
    (1,8000,'Jan'),
    (2,9000,'Jan'),
    (3,10000,'Feb'),
    (1,7000,'Feb'),
    (1,6000,'Mar')
;

SELECT
    id AS id,
    SUM(IF(month = 'Jan',revenue,NULL)) AS Jan_Revenue,
    SUM(IF(month = 'Feb',revenue,NULL)) AS Feb_Revenue,
    SUM(IF(month = 'Mar',revenue,NULL)) AS Mar_Revenue,
    SUM(IF(month = 'Apr',revenue,NULL)) AS Apr_Revenue,
    SUM(IF(month = 'May',revenue,NULL)) AS May_Revenue,
    SUM(IF(month = 'Jun',revenue,NULL)) AS Jun_Revenue,
    SUM(IF(month = 'Jul',revenue,NULL)) AS Jul_Revenue,
    SUM(IF(month = 'Aug',revenue,NULL)) AS Aug_Revenue,
    SUM(IF(month = 'Sep',revenue,NULL)) AS Sep_Revenue,
    SUM(IF(month = 'Oct',revenue,NULL)) AS Oct_Revenue,
    SUM(IF(month = 'Nov',revenue,NULL)) AS Nov_Revenue,
    SUM(IF(month = 'Dec',revenue,NULL)) AS Dec_Revenue
FROM department
GROUP BY id
;

--Hive中生成日期维度表
CREATE TABLE dim_date(
                         day STRING COMMENT '日期,yyyy-MM-dd 格式',
                         week BIGINT COMMENT '本周星期几,数值型,1-星期一,2-星期二,......,7-星期天',
                         week_en STRING COMMENT '本周星期几英文名,文本型,Mon,Tue,Wed,Thu,Fri,Sat,Sun',
                         week_of_year BIGINT COMMENT '本年第几周,数值型,1,2,3......',
                         week_of_month BIGINT COMMENT '本月第几周,数值型,1,2,3......',
                         day_of_year BIGINT COMMENT '本年第几天,数值型,1,2,3......',
                         mon_dt STRING COMMENT '本周周一日期',
                         tue_dt STRING COMMENT '本周周二日期',
                         wed_dt STRING COMMENT '本周周三日期',
                         thu_dt STRING COMMENT '本周周四日期',
                         fri_dt STRING COMMENT '本周周五日期',
                         sat_dt STRING COMMENT '本周周六日期',
                         sun_dt STRING COMMENT '本周周日日期',
                         year STRING COMMENT '本年',
                         month STRING COMMENT '本月,yyyy-MM 格式',
                         month_short BIGINT COMMENT '本月简写,MM格式1~12',
                         first_day_of_month STRING COMMENT '本月第一天日期',
                         last_day_of_month STRING COMMENT '本月最后一天日期',
                         first_day_of_last_month STRING COMMENT '上月第一天日期',
                         last_day_of_last_month STRING COMMENT '上月最后一天日期',
                         quarter STRING COMMENT '本季度,yyyy-Q1/2/3/4 格式',
                         quarter_short BIGINT COMMENT '本季度简写,数字型 1-4'
);

WITH dates AS
         (
             SELECT
                 DATE_ADD("2021-01-01", a.pos) AS day
FROM
    (
    SELECT POSEXPLODE(SPLIT(REPEAT("o", DATEDIFF("2030-12-31", "2021-01-01")), "o")) AS (pos,value)
    ) a
    )
INSERT OVERWRITE TABLE dim_date
SELECT
    day AS day,--日期,yyyy-MM-dd 格式
    DATE_FORMAT(day,'u') AS week,--本周星期几,数值型
    DATE_FORMAT(day,'E') AS week_en,--本周星期几英文名,文本型
    DATE_FORMAT(day,'w') AS week_of_year,--本年第几周,数值型,1,2,3......
    DATE_FORMAT(day,'W') AS week_of_month,--本月第几周,数值型,1,2,3......
    DATE_FORMAT(day,'D') AS day_of_year,--本年第几天,数值型,1,2,3......
    DATE_ADD(day,1-CAST(DATE_FORMAT(day,'u') AS INT)) AS mon_dt,--本周周一日期
    DATE_ADD(day,2-CAST(DATE_FORMAT(day,'u') AS INT)) AS tue_dt,--本周周二日期
    DATE_ADD(day,3-CAST(DATE_FORMAT(day,'u') AS INT)) AS wed_dt,--本周周三日期
    DATE_ADD(day,4-CAST(DATE_FORMAT(day,'u') AS INT)) AS thu_dt,--本周周四日期
    DATE_ADD(day,5-CAST(DATE_FORMAT(day,'u') AS INT)) AS fri_dt,--本周周五日期
    DATE_ADD(day,6-CAST(DATE_FORMAT(day,'u') AS INT)) AS sat_dt,--本周周六日期
    DATE_ADD(day,7-CAST(DATE_FORMAT(day,'u') AS INT)) AS sun_dt,--本周周日日期
    YEAR(day) AS year,--本年
    DATE_FORMAT(day,'yyyy-MM') AS month,--本月
    MONTH(day) AS month_short,--本月简写
    TRUNC(day,'MM') AS first_day_of_month,--本月第一天日期
    LAST_DAY(day) AS last_day_of_month,--本月最后一天日期
    TRUNC(ADD_MONTHS(day,-1),'MM') AS first_day_of_last_month,--上月第一天日期
    DATE_SUB(TRUNC(day,'MM'),1) AS last_day_of_last_month,--上月最后一天日期
    CONCAT(YEAR(day),'-Q',QUARTER(day)) AS quarter,--本季度
    QUARTER(day) AS quarter_short --本季度简写
FROM dates
;

--用户购买平台【难度困难】
CREATE TABLE spending(
                         user_id INT,
                         spend_date DATE,
                         platform STRING,
                         amount INT
);

INSERT INTO TABLE spending VALUES
    (1,'2019-07-01','mobile',100),
    (1,'2019-07-01','desktop',100),
    (2,'2019-07-01','mobile',100),
    (2,'2019-07-02','mobile',100),
    (3,'2019-07-01','desktop',100),
    (3,'2019-07-02','desktop',100)
;

--先根据用户和日期分组统计desktop端、mobile端和总的金额以及购买人数，总共6列，然后使用Hive带指针的explode函数进行列转行
SELECT
    B.spend_date AS spend_date,
    CASE C.pos1 WHEN 0 THEN 'desktop'
                WHEN 1 THEN 'mobile'
                WHEN 2 THEN 'both'
                ELSE NULL END AS platform,
    C.amount AS total_amount,
    D.users AS total_users
FROM
    (
        SELECT
            A.spend_date AS spend_date,
            SUM(A.desktop) AS desktop,
            SUM(A.mobile) AS mobile,
            SUM(A.both_platform) AS both_platform,
            SUM(A.desktop_user) AS desktop_user,
            SUM(A.mobile_user) AS mobile_user,
            SUM(A.both_user) AS both_user
        FROM
            (
                SELECT
                    user_id AS user_id,
                    spend_date AS spend_date,
                    IF(
                            SUM(IF(platform = 'desktop',amount,0)) != 0 AND SUM(IF(platform = 'mobile',amount,0)) !=0,
                            0,
                            SUM(IF(platform = 'desktop',amount,0))
                        ) AS desktop,
                    IF(
                            SUM(IF(platform = 'desktop',amount,0)) != 0 AND SUM(IF(platform = 'mobile',amount,0)) !=0,
                            0,
                            SUM(IF(platform = 'mobile',amount,0))
                        ) AS mobile,
                    IF(
                            SUM(IF(platform = 'desktop',amount,0)) != 0 AND SUM(IF(platform = 'mobile',amount,0)) !=0,
                            SUM(amount),
                            0
                        ) AS both_platform,
                    IF(
                            SUM(IF(platform = 'desktop',amount,0)) != 0 AND SUM(IF(platform = 'mobile',amount,0)) !=0,
                            0,
                            SUM(IF(platform = 'desktop',1,0))
                        ) AS desktop_user,
                    IF(
                            SUM(IF(platform = 'desktop',amount,0)) != 0 AND SUM(IF(platform = 'mobile',amount,0)) !=0,
                            0,
                            SUM(IF(platform = 'mobile',1,0))
                        ) AS mobile_user,
                    IF(
                            SUM(IF(platform = 'desktop',amount,0)) != 0 AND SUM(IF(platform = 'mobile',amount,0)) !=0,
                            1,
                            0
                        ) AS both_user
                FROM spending
                GROUP BY
                    user_id,
                    spend_date
            ) A
        GROUP BY A.spend_date
    ) B
    LATERAL VIEW POSEXPLODE(ARRAY(B.desktop,B.mobile,B.both_platform)) C AS pos1,amount
LATERAL VIEW POSEXPLODE(ARRAY(B.desktop_user,B.mobile_user,B.both_user)) D AS pos2,users
WHERE C.pos1 = D.pos2
;

--另一种解法，这种解法会漏掉当天既没有在desktop端也没有在mobile端购买的情况
SELECT
    B.spend_date,
    B.platform,
    B.amount,
    COUNT(B.user_id) OVER (PARTITION BY spend_date,platform) AS total_users
FROM
    (
        SELECT
            DISTINCT
            A.user_id,
            A.spend_date,
            CASE WHEN A.num = 1 AND A.platform = 'desktop' THEN 'desktop'
                 WHEN A.num = 1 AND A.platform = 'mobile' THEN 'mobile'
                 ELSE 'both' END AS platform,
            A.amount
        FROM
            (
                SELECT
                    user_id,
                    spend_date,
                    platform,
                    COUNT(*) OVER (PARTITION BY user_id,spend_date) AS num,
                        SUM(amount) OVER (PARTITION BY user_id,spend_date) AS amount
                FROM spending
            ) A
    ) B
;

--查询活跃业务【难度中等】
CREATE TABLE events(
                       business_id INT,
                       event_type STRING,
                       occurences INT
);

INSERT INTO TABLE events VALUES
    (1,'reviews',7),
    (3,'reviews',3),
    (1,'ads',11),
    (2,'ads',7),
    (3,'ads',6),
    (1,'page views',3),
    (2,'page views',12)
;

SELECT
    A.business_id AS business_id
FROM
    (
        SELECT
            *,
            IF(SUM(occurences) OVER(PARTITION BY event_type)/COUNT(*) OVER(PARTITION BY event_type) < occurences,1,0) AS active
        FROM events
    ) A
WHERE A.active = 1
GROUP BY
    A.business_id
HAVING
        COUNT(*) >=2
;

--报告的记录 II【难度中等】
CREATE TABLE actions(
                        user_id INT,
                        post_id INT,
                        action_date DATE,
                        action STRING,
                        extra STRING
);

INSERT OVERWRITE TABLE actions VALUES
    (1,1,'2019-07-01','view',NULL),
    (1,1,'2019-07-01','like',NULL),
    (1,1,'2019-07-01','share',NULL),
    (2,2,'2019-07-04','view',NULL),
    (2,2,'2019-07-04','report','spam'),
    (3,4,'2019-07-04','view',NULL),
    (3,4,'2019-07-04','report','spam'),
    (4,3,'2019-07-02','view',NULL),
    (4,3,'2019-07-02','report','spam'),
    (5,2,'2019-07-03','view',NULL),
    (5,2,'2019-07-03','report','racism'),
    (5,5,'2019-07-03','view',NULL),
    (5,5,'2019-07-03','report','racism')
;

CREATE TABLE removals(
                         post_id INT,
                         remove_date DATE
);

INSERT OVERWRITE TABLE removals VALUES
    (2,'2019-07-20'),
    (3,'2019-07-18')
;

--求在被报告为垃圾广告的帖子中，被移除的帖子的每日平均占比，四舍五入到小数点后 2 位。

-- Result table:
-- +-----------------------+
-- | average_daily_percent |
-- +-----------------------+
-- | 75.00                 |
-- +-----------------------+
-- 2019-07-04 的垃圾广告移除率是 50%，因为有两张帖子被报告为垃圾广告，但只有一个得到移除。
-- 2019-07-02 的垃圾广告移除率是 100%，因为有一张帖子被举报为垃圾广告并得到移除。
-- 其余几天没有收到垃圾广告的举报，因此平均值为：(50 + 100) / 2 = 75%
-- 注意，输出仅需要一个平均值即可，我们并不关注移除操作的日期。

SELECT
    ROUND(100*SUM(C.remove_rate)/COUNT(*),2) AS average_daily_percent
FROM
    (
        SELECT
            A.action_date AS action_date,
            COUNT(B.post_id)/COUNT(*) AS remove_rate
        FROM
            (
                SELECT
                    DISTINCT
                    post_id,
                    action_date
                FROM actions
                WHERE action = 'report' AND extra = 'spam'
            ) A
                LEFT JOIN removals B
                          ON A.post_id = B.post_id
        GROUP BY A.action_date
    ) C
;

--市场分析 II【难度困难】
CREATE TABLE users(
                      user_id INT,
                      join_date DATE,
                      favorite_brand STRING
);

CREATE TABLE orders(
                       order_id INT,
                       order_date DATE,
                       item_id INT,
                       buyer_id INT,
                       seller_id INT
);

CREATE TABLE items(
                      item_id INT,
                      item_brand STRING
);

INSERT OVERWRITE TABLE users VALUES
    (1,'2019-01-01','Lenovo'),
    (2,'2019-02-09','Samsung'),
    (3,'2019-01-19','LG'),
    (4,'2019-05-21','HP')
;

INSERT OVERWRITE TABLE orders VALUES
    (1,'2019-08-01',4,1,2),
    (2,'2019-08-02',2,1,3),
    (3,'2019-08-03',3,2,3),
    (4,'2019-08-04',1,4,2),
    (5,'2019-08-04',1,3,4),
    (6,'2019-08-05',2,2,4)
;

INSERT OVERWRITE TABLE items VALUES
    (1,'Samsung'),
    (2,'Lenovo'),
    (3,'LG'),
    (4,'HP')
;

-- 写一个 SQL 查询确定每一个用户按日期顺序卖出的第二件商品的品牌是否是他们最喜爱的品牌。如果一个用户卖出少于两件商品，查询的结果是 no 。

-- 题目保证没有一个用户在一天中卖出超过一件商品

-- Result table:
-- +-----------+--------------------+
-- | seller_id | 2nd_item_fav_brand |
-- +-----------+--------------------+
-- | 1         | no                 |
-- | 2         | yes                |
-- | 3         | yes                |
-- | 4         | no                 |
-- +-----------+--------------------+

-- id 为 1 的用户的查询结果是 no，因为他什么也没有卖出
-- id为 2 和 3 的用户的查询结果是 yes，因为他们卖出的第二件商品的品牌是他们自己最喜爱的品牌
-- id为 4 的用户的查询结果是 no，因为他卖出的第二件商品的品牌不是他最喜爱的品牌

SELECT
    D.user_id AS seller_id,
    IF(SUM(IF(D.rn = 1,0,IF(D.favorite_brand = D.item_brand,1,0))) = 1,'yes','no') AS 2nd_item_fav_brand
FROM
    (
        SELECT
            A.user_id,
            B.order_date,
            A.favorite_brand,
            C.item_brand,
            ROW_NUMBER() OVER(PARTITION BY A.user_id ORDER BY B.order_date) AS rn
        FROM users A
                 LEFT JOIN orders B
                           ON A.user_id = B.seller_id
                 LEFT JOIN items C
                           ON B.item_id = C.item_id
    ) D
WHERE D.rn <=2
GROUP BY D.user_id
;

--文章浏览 I【难度简单】
CREATE TABLE views(
                      article_id INT,
                      author_id INT,
                      viewer_id INT,
                      view_date DATE
);

INSERT OVERWRITE TABLE views VALUES
(1,3,5,'2019-08-01'),
(1,3,6,'2019-08-02'),
(2,7,7,'2019-08-01'),
(2,7,6,'2019-08-02'),
(4,7,1,'2019-07-22'),
(3,4,4,'2019-07-21'),
(3,4,4,'2019-07-21')
;

-- 结果表：
-- +------+
-- | id   |
-- +------+
-- | 4    |
-- | 7    |
-- +------+

SELECT
    DISTINCT
    author_id AS id
FROM views
WHERE author_id = viewer_id
ORDER BY author_id ASC
;

SELECT
    author_id AS id
FROM views
WHERE author_id = viewer_id
GROUP BY author_id
ORDER BY author_id ASC
;


--文章浏览 II【难度中等】
CREATE TABLE views(
                      article_id INT,
                      author_id INT,
                      viewer_id INT,
                      view_date DATE
);

INSERT OVERWRITE TABLE views VALUES
(1,3,5,'2019-08-01'),
(3,4,5,'2019-08-01'),
(1,3,6,'2019-08-02'),
(2,7,7,'2019-08-01'),
(2,7,6,'2019-08-02'),
(4,7,1,'2019-07-22'),
(3,4,4,'2019-07-21'),
(3,4,4,'2019-07-21')
;

-- Result table:
-- +------+
-- | id   |
-- +------+
-- | 5    |
-- | 6    |
-- +------+

--编写一条 SQL 查询来找出在同一天阅读至少两篇文章的人，结果按照 id 升序排序。

SELECT
    viewer_id AS id
FROM views
GROUP BY
    view_date,
    viewer_id
HAVING COUNT(DISTINCT article_id) >= 2
ORDER BY viewer_id ASC
;