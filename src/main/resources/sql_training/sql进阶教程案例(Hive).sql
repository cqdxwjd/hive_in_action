CREATE TABLE poptbl(pref_name STRING,population BIGINT);

INSERT INTO TABLE poptbl VALUES
    ('德岛',100),
    ('香川',200),
    ('爱媛',150),
    ('高知',200),
    ('福冈',300),
    ('佐贺',100),
    ('长崎',200),
    ('东京',400),
    ('群马',50)
;

SELECT
    CASE pref_name
        WHEN '德岛' THEN '四国'
        WHEN '香川' THEN '四国'
        WHEN '爱媛' THEN '四国'
        WHEN '高知' THEN '四国'
        WHEN '福冈' THEN '九州'
        WHEN '佐贺' THEN '九州'
        WHEN '长崎' THEN '九州'
        ELSE '其他' END AS district,
    SUM(population)
FROM poptbl
GROUP BY
    CASE pref_name
        WHEN '德岛' THEN '四国'
        WHEN '香川' THEN '四国'
        WHEN '爱媛' THEN '四国'
        WHEN '高知' THEN '四国'
        WHEN '福冈' THEN '九州'
        WHEN '佐贺' THEN '九州'
        WHEN '长崎' THEN '九州'
        ELSE '其他' END
;

CREATE TABLE poptbl2(
                        pref_name STRING,
                        sex INT,
                        population BIGINT
);

INSERT INTO TABLE poptbl2 VALUES
    ('德岛',1,60),
    ('德岛',2,40),
    ('香川',1,100),
    ('香川',2,100),
    ('爱媛',1,100),
    ('爱媛',2,50),
    ('高知',1,100),
    ('高知',2,100),
    ('福冈',1,100),
    ('福冈',2,200),
    ('佐贺',1,20),
    ('佐贺',2,80),
    ('长崎',1,125),
    ('长崎',2,125),
    ('东京',1,250),
    ('东京',2,150)
;

SELECT
    pref_name,
    SUM(CASE WHEN sex = '1' THEN population ELSE 0 END) AS cnt_m,
    SUM(CASE WHEN sex = '2' THEN population ELSE 0 END) AS cnt_f
FROM poptbl2
GROUP BY pref_name
;

CREATE TABLE salaries(
                         name STRING,
                         salary BIGINT
);

INSERT INTO TABLE salaries VALUES
    ('相田',300000),
    ('神崎',270000),
    ('木村',220000),
    ('齐藤',290000)
;

SELECT
    name,
    CASE WHEN salary >= 300000
             THEN salary*0.9
         WHEN salary >= 250000 AND salary < 280000
             THEN salary*1.2
         ELSE salary END
FROM salaries
;

CREATE TABLE coursemaster(
                             course_id INT,
                             course_name STRING
);

CREATE TABLE opencourses(
                            month STRING,
                            course_id INT
);

INSERT INTO TABLE coursemaster VALUES
    (1,'会计入门'),
    (2,'财务知识'),
    (3,'簿记考试'),
    (4,'税务师')
;

INSERT INTO TABLE opencourses VALUES
    ('200706',1),
    ('200706',3),
    ('200706',4),
    ('200707',4),
    ('200708',2),
    ('200708',4)
;

SELECT
    b.course_name AS course_name,
    if(SUM(CASE WHEN a.month = '200706' THEN 1 ELSE 0 END) = 1,'O','X') AS six,
    if(SUM(CASE WHEN a.month = '200707' THEN 1 ELSE 0 END) = 1,'O','X') AS seven,
    if(SUM(CASE WHEN a.month = '200708' THEN 1 ELSE 0 END)= 1,'O','X') AS eight
FROM opencourses a
         LEFT JOIN coursemaster b
                   ON a.course_id = b.course_id
GROUP BY b.course_name
;

CREATE TABLE studentclub(
                            std_id BIGINT,
                            club_id INT,
                            club_name STRING,
                            main_club_flag STRING
);

INSERT INTO TABLE studentclub VALUES
    (100,1,'棒球','Y'),
    (100,2,'管弦乐','N'),
    (200,2,'管弦乐','N'),
    (200,3,'羽毛球','Y'),
    (200,4,'足球','N'),
    (300,4,'足球','N'),
    (400,5,'游泳','N'),
    (500,6,'围棋','N')
;

--获取只加入了一个社团的学生的社团 ID
--获取加入了多个社团的学生的主社团 ID

-- 方式1
SELECT
    a.std_id,
    CASE WHEN COUNT(*) = 1 THEN MAX(a.club_id)
         ELSE MAX(a.main_club) END AS main_club
FROM
    (
        SELECT
            std_id,
            club_id,
            CASE WHEN main_club_flag = 'Y' THEN club_id
                 ELSE 0
                END AS main_club
        FROM studentclub
    ) a
GROUP BY a.std_id
;

--方式2
SELECT
    std_id,
    CASE WHEN COUNT(*) = 1 THEN MAX(club_id)
         ELSE MAX(CASE WHEN main_club_flag = 'Y' THEN club_id ELSE null END)
        END AS main_club
FROM studentclub
GROUP BY std_id
;

--多列数据的最大值

CREATE TABLE greatests(
                          key STRING,
                          x INT,
                          y INT,
                          z INT
);

INSERT INTO TABLE greatests VALUES
    ('A',1,2,3),
    ('B',5,5,2),
    ('C',4,7,1),
    ('D',3,3,8)
;

SELECT
    key,
    CASE WHEN x >= y and x >= z THEN x
    WHEN y >= x and y >= z THEN y
    ELSE z END as max_value
FROM greatests
;

--或者使用 hive 内置 sort_array()函数,代码省略

--转换行列——在表头里加入汇总和再揭

SELECT
    sex,
    SUM(population),
    SUM(CASE WHEN pref_name = '德岛' THEN population ELSE 0 END),
    SUM(CASE WHEN pref_name = '香川' THEN population ELSE 0 END),
    SUM(CASE WHEN pref_name = '爱媛' THEN population ELSE 0 END),
    SUM(CASE WHEN pref_name = '高知' THEN population ELSE 0 END),
    SUM(CASE pref_name WHEN '德岛' THEN population
                       WHEN '香川' THEN population
                       WHEN '爱媛' THEN population
                       WHEN '高知' THEN population
                       ELSE 0 END)
FROM poptbl2
GROUP BY sex
;

--用 ORDER BY 生成“排序”列 请思考一个查询语句，使得结果按照 B-A-D-C 这样的指定顺 序进行排列

SELECT
    CASE key WHEN 'A' THEN 1
        WHEN 'B' THEN 1
        WHEN 'C' THEN 2
        ELSE 2 END as group_id,
    key
FROM greatests
ORDER BY
    CASE key WHEN 'A' THEN 1
        WHEN 'B' THEN 1
        WHEN 'C' THEN 2
    ELSE 2 END ASC,
    key DESC
;

--删除产品表里面重复的行
CREATE TABLE product(
                        name STRING,
                        price INT
);

INSERT INTO TABLE product VALUES
    ('苹果',50),
    ('橘子',100),
    ('橘子',100),
    ('橘子',100),
    ('香蕉',80)
;

-- 方式1：使用排序函数分组排序后取第一行
SELECT
    name AS name,
    price AS price
FROM
    (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY name,price) AS rn
        FROM product
    ) a
WHERE a.rn = 1
;

-- 方式2：使用hive DISTINCT去重,DISTINCT会对后面所有列都起作用
SELECT DISTINCT name,price FROM product;

-- 方式3：使用hive GROUP BY去重
SELECT name,price FROM product GROUP BY name,price;

-- 自从hive1.1.0版本引入SELECT DISTINCT *以来，在所有版本中，方式2和方式3完全等价，查看两者的执行计划可以发现完全一样，所以效率是一样的。
-- 另外当开启数据倾斜负载均衡的情况下，即设置set hive.groupby.skewindata=true时，hive为对DISTINCT和GROUP BY进行优化，多出一个job首先进行部分的聚合，将数据随机分散到不通过的reducer中，再通过后续的job继续进行数据的处理

--从下面这张商品表里找出价格相等的商品的组合
CREATE TABLE products(
                         name STRING,
                         price INT
);

INSERT INTO TABLE products VALUES
    ('苹果',50),
    ('橘子',100),
    ('葡萄',50),
    ('西瓜',80),
    ('柠檬',30),
    ('草莓',100),
    ('香蕉',100)
;

SELECT
    DISTINCT a.name,a.price
FROM products a
         CROSS JOIN products b
    on a.price = b.price AND a.name <> b.name
;

-- 排序从 1 开始。如果已出现相同位次，则跳过之后的位次
-- 方式1：不使用窗口函数实现排序，出现相同位次时，跳过之后的位次
SELECT
    c.name,
    c.price,
    SUM(c.num)+1 AS less_num
FROM
    (
        SELECT
            a.name AS name,
            a.price AS price,
            IF(b.price IS NULL,0,1) AS num
        FROM products a
                 LEFT JOIN products b
                           ON a.price > b.price
    ) c
GROUP BY
    c.name,
    c.price
ORDER BY
    less_num
;

-- 方式2：使用窗口函数实现排序
SELECT
    name,
    price,
    RANK() OVER (ORDER BY price) AS rn1,
        ROW_NUMBER() OVER (ORDER BY price) AS rn2,
        DENSE_RANK() OVER (ORDER BY price) AS rn3
FROM products
;

--可重组合
CREATE TABLE products(
    name STRING
);

INSERT INTO TABLE products VALUES
    ('香蕉'),
    ('苹果'),
    ('橘子')
;

SELECT
    a.name,
    b.name
FROM products a
         LEFT JOIN products b
                   ON a.name >= b.name
;


CREATE TABLE seqtbl(
                       seq INT,
                       name STRING
);

INSERT OVERWRITE TABLE seqtbl VALUES
(1,'DIKE'),
(2,'AN'),
(3,'LAILU'),
(5,'KA'),
(6,'MALI'),
(8,'BEN')
;

SELECT
    'not successive' AS gap
FROM seqtbl
HAVING COUNT(*) <> MAX(seq)
;

SELECT
    MIN(A.seq + 1)
FROM seqtbl A
         LEFT JOIN seqtbl B
                   ON A.seq + 1 = B.seq
WHERE B.seq IS NULL
;


CREATE TABLE graduates(
                          name STRING,
                          income INT
);

INSERT OVERWRITE TABLE graduates VALUES
('桑普森',400000),
('迈克',30000),
('怀特',20000),
('阿诺德',20000),
('史密斯',20000),
('劳伦斯',15000),
('哈德逊',15000),
('肯特',10000),
('贝克',10000),
('斯科特',10000)
;

--求收入的众数
SELECT
    income AS income
FROM
    (
        SELECT
            A.income AS income,
            RANK() OVER(ORDER BY A.cnt DESC) AS rank
        FROM
            (
                SELECT
                    income AS income,
                    COUNT(income) AS cnt
                FROM graduates
                GROUP BY income
            ) A
    ) B
WHERE B.rank = 1
;

--求中位数的SQL语句:在HAVING子句中使用非等值自连接
SELECT
    AVG(TMP.income)
FROM
    (
        SELECT
            T1.income AS income
        FROM graduates T1
                 CROSS JOIN graduates T2
        GROUP BY T1.income
        HAVING SUM(CASE WHEN T2.income >= T1.income THEN 1 ELSE 0 END) >= CAST(COUNT(*) / 2 AS INT)
           AND SUM(CASE WHEN T2.income <= T1.income THEN 1 ELSE 0 END) >= CAST(COUNT(*) / 2 AS INT)
    ) TMP
;

--找出哪些学院的学生全部都􏰀交了报告
CREATE TABLE students(
                         student_id INT,
                         dpt STRING,
                         sbmt_date DATE
);

INSERT OVERWRITE TABLE students VALUES
(100,'理学院','2005-10-10'),
(101,'理学院','2005-09-22'),
(102,'文学院',NULL),
(103,'文学院','2005-09-10'),
(200,'文学院','2005-09-22'),
(201,'工学院',NULL),
(202,'经济学院','2005-09-25')
;

SELECT
    dpt
FROM students
GROUP BY dpt
HAVING COUNT(*) = COUNT(sbmt_date)
;

CREATE TABLE Items(
    item STRING
);

CREATE TABLE ShopItems(
                          shop STRING,
                          item STRING
);

INSERT OVERWRITE TABLE Items VALUES
('啤酒'),('纸尿裤'),('自行车')
;

INSERT OVERWRITE TABLE ShopItems VALUES
('仙台','啤酒'),
('仙台','纸尿裤'),
('仙台','自行车'),
('仙台','窗帘'),
('东京','啤酒'),
('东京','纸尿裤'),
('东京','自行车'),
('大阪','电视'),
('大阪','纸尿裤'),
('大阪','自行车')
;

-- 查询啤酒、纸尿裤和自行车同时在库的店铺
SELECT
    SI.shop
FROM
    (
        SELECT
            item AS item,
            COUNT(*) OVER() AS num
        FROM Items
    ) I
        LEFT JOIN ShopItems SI
                  ON I.item = SI.item
GROUP BY SI.shop,I.num
HAVING COUNT(SI.item) = MAX(I.num)
;

-- 查询啤酒、纸尿裤和自行车同时在库的店铺，且只有这三种商品的店铺
SELECT
    SI.shop
FROM
    (
        SELECT
            item AS item,
            COUNT(*) OVER() AS num
        FROM Items
    ) I
        FULL OUTER JOIN ShopItems SI
                        ON I.item = SI.item
GROUP BY SI.shop
HAVING COUNT(SI.item) = MAX(I.num)
   AND COUNT(I.item) = MAX(I.num)
;

--修改编号缺失的检查逻辑，使结果总是返回一行数据
SELECT
    IF(COUNT(*) <> MAX(seq),'not successive','successive') AS gap
FROM seqtbl
;

--全体学生都在 9 月份提交了报告的学院
SELECT
    A.dpt AS dpt
FROM
    (
        SELECT
            student_id AS student_id,
            dpt AS dpt,
            IF(MONTH(sbmt_date) = '9','9',NULL) AS nine
        FROM students
    ) A
GROUP BY A.dpt
HAVING COUNT(*) = COUNT(A.nine)
;








































