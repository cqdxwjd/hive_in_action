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















































