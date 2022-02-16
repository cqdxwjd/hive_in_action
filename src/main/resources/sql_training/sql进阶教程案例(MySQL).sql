CREATE TABLE seqtbl(
                       seq INT,
                       name VARCHAR(30)
);

INSERT INTO seqtbl VALUES
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

SELECT MIN(seq + 1) AS gap
FROM seqtbl
WHERE (seq+ 1) NOT IN ( SELECT seq FROM seqtbl);

CREATE TABLE graduates(
                          name VARCHAR(30),
                          income INT
);

INSERT INTO graduates VALUES
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

--求收入的众数
SELECT
    income,
    COUNT(*) AS cnt
FROM graduates
GROUP BY income
HAVING COUNT(*) >= ALL (
    SELECT COUNT(*) FROM graduates GROUP BY income
)
;

-- 求众数的 SQL 语句 (2) :使用极值函数
SELECT income, COUNT(*) AS cnt
FROM graduates GROUP BY income
HAVING COUNT(*) >= ( SELECT MAX(cnt)
                     FROM ( SELECT COUNT(*) AS cnt
                            FROM graduates
                            GROUP BY income) TMP ) ;

--求中位数的SQL语句:在HAVING子句中使用非等值自连接
SELECT
    AVG(DISTINCT income)
FROM
    (
        SELECT
            T1.income
        FROM graduates T1, graduates T2
        GROUP BY T1.income
        HAVING SUM(CASE WHEN T2.income >= T1.income THEN 1 ELSE 0 END)
            >= COUNT(*) / 2
           AND SUM(CASE WHEN T2.income <= T1.income THEN 1 ELSE 0 END) >= COUNT(*) / 2
    ) TMP;

--找出哪些学院的学生全部都􏰀交了报告
CREATE TABLE students(
                         student_id INT,
                         dpt VARCHAR(30),
                         sbmt_date DATE
);

INSERT INTO students VALUES
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

-- 求全部的缺失编号
CREATE TABLE seqtbl(
    seq INT
);

INSERT INTO seqtbl VALUES (1),(2),(4),(5),(6),(7),(8),(11),(12);
SELECT * FROM seqtbl;

CREATE VIEW sequence (
                      seq
    )
AS
SELECT
        d1.digit+(d2.digit*10)+(d3.digit*100) AS seq
FROM digits d1
         CROSS JOIN digits d2
         CROSS JOIN digits d3
ORDER BY seq;

SELECT
    seq
FROM
    sequence
WHERE
    seq BETWEEN 1
        AND 12
  AND seq NOT IN ( SELECT seq FROM SeqTbl )
ORDER BY
    seq;

-- 三个人能坐得下吗，求连续的序列
INSERT INTO seats VALUES
(1,'已预订')
                       ,(2,'已预订')
                       ,(3,'未预订')
                       ,(4,'未预订')
                       ,(5,'未预订')
                       ,(6,'已预订')
                       ,(7,'未预订')
                       ,(8,'未预订')
                       ,(9,'未预订')
                       ,(10,'未预订')
                       ,(11,'未预订')
                       ,(12,'已预订')
                       ,(13,'已预订')
                       ,(14,'未预订')
                       ,(15,'未预订');

-- 找出需要的空位 (1):不考虑座位的换排
SELECT S1.seat AS start_seat, '~' , S2.seat AS end_seat
FROM seats S1, seats S2
WHERE S2.seat = S1.seat + (3 -1) -- 决定起点和终点
  AND NOT EXISTS (SELECT *
                  FROM seats S3
                  WHERE S3.seat BETWEEN S1.seat AND S2.seat
                    AND S3.status <> '未预订' );

CREATE TABLE seats2(
                       seat INT,
                       row_id VARCHAR(2),
                       status VARCHAR(30)
);

INSERT INTO seats2 VALUES
(1,'A','已预定'),
(2,'A','已预定'),
(3,'A','未预定'),
(4,'A','未预定'),
(5,'A','未预定'),
(6,'B','已预定'),
(7,'B','已预定'),
(8,'B','未预定'),
(9,'B','未预定'),
(10,'B','未预定'),
(11,'C','未预定'),
(12,'C','未预定'),
(13,'C','未预定'),
(14,'C','已预定'),
(15,'C','未预定');

SELECT * FROM seats2;

-- 找出需要的空位 (2):考虑座位的换排
SELECT S1.seat AS start_seat, '~' , S2.seat AS end_seat
FROM seats2 S1, seats2 S2
WHERE S2.seat = S1.seat + (3 -1) -- 决定起点和终点
  AND NOT EXISTS (SELECT *
                  FROM seats2 S3
                  WHERE S3.seat BETWEEN S1.seat AND S2.seat
                    AND ( S3.status <> '未预定'
                      OR S3.row_id <> S1.row_id));

-- 连续序列，最多能坐下多少人
CREATE TABLE seats3(
                       seat INT,
                       status VARCHAR(30)
);

INSERT INTO seats3 VALUES
(1,'已预订'),
(2,'未预订'),
(3,'未预订'),
(4,'未预订'),
(5,'未预订'),
(6,'已预订'),
(7,'未预订'),
(8,'已预订'),
(9,'未预订'),
(10,'未预订');

-- 第一阶段 :生成存储了所有序列的视图
CREATE VIEW sequences (start_seat, end_seat, seat_cnt) AS
SELECT
    S1.seat AS start_seat,
    S2.seat AS end_seat,
    S2.seat - S1.seat + 1 AS seat_cnt
FROM Seats3 S1, Seats3 S2
WHERE S1.seat <= S2.seat -- 第一步:生成起点和终点的组合
  AND NOT EXISTS -- 第二步:描述序列内所有点需要满足的条件
    (
        SELECT *
        FROM seats3 S3
        WHERE ( S3.seat BETWEEN S1.seat AND S2.seat AND S3.status <>'未预订') -- 条件1的否定
           OR (S3.seat = S2.seat + 1 AND S3.status = '未预订' ) -- 条件2的否定
           OR (S3.seat = S1.seat - 1 AND S3.status = '未预订' )); -- 条件3的否定

-- 第二阶段 :求最长的序列
SELECT start_seat, '~', end_seat, seat_cnt
FROM sequences
WHERE seat_cnt = (SELECT MAX(seat_cnt) FROM Sequences);

-- 单调递增和单调递减
CREATE TABLE mystock(
                        deal_date DATE,
                        price INT
);

INSERT INTO mystock VALUES
('2007-01-06',1000),
('2007-01-08',1050),
('2007-01-09',1050),
('2007-01-12',900),
('2007-01-13',880),
('2007-01-14',870),
('2007-01-16',920),
('2007-01-17',1000);

SELECT * FROM mystock;

-- 生成起点和终点的组合的SQL语句
SELECT
    S1.deal_date AS start_date,
    S2.deal_date AS end_date
FROM mystock S1,mystock S2
WHERE S1.deal_date < S2.deal_date;

-- 求单调递增的区间的SQL语句：子集也输出
SELECT
    s1.deal_date AS start_date,
    s2.deal_date AS end_date
FROM mystock s1,mystock s2
WHERE s1.deal_date < s2.deal_date -- 第一步：生成起点和终点的组合
  AND NOT EXISTS (
        SELECT * -- 第二步：描述区间内所有日期需要满足的条件
        FROM mystock s3,mystock s4
        WHERE s3.deal_date BETWEEN s1.deal_date AND s2.deal_date
          AND s4.deal_date BETWEEN s1.deal_date AND s2.deal_date
          AND s3.deal_date < s4.deal_date
          AND s3.price >= s4.price
    );

-- 排除掉子集，只取最长的时间区间
SELECT
    MIN(start_date) AS start_date, -- 最大限度地向前延伸起点
    end_date
FROM
    (
        SELECT
            s1.deal_date AS start_date,
            MAX(s2.deal_date) AS end_date -- 最大限度地向后延伸终点
        FROM mystock s1,mystock s2
        WHERE s1.deal_date < s2.deal_date -- 第一步：生成起点和终点的组合
          AND NOT EXISTS (
                SELECT * -- 第二步：描述区间内所有日期需要满足的条件
                FROM mystock s3,mystock s4
                WHERE s3.deal_date BETWEEN s1.deal_date AND s2.deal_date
                  AND s4.deal_date BETWEEN s1.deal_date AND s2.deal_date
                  AND s3.deal_date < s4.deal_date
                  AND s3.price >= s4.price
            )
        GROUP BY s1.deal_date
    ) tmp
GROUP BY end_date;

-- 练习题 1-9-1 :求所有的缺失编号——NOT EXIST 和外连接
SELECT
    seq
FROM sequence b
WHERE seq BETWEEN 1 AND 12
  AND NOT EXISTS (
        SELECT
            *
        FROM seqtbl a
        WHERE b.seq = a.seq
    )
ORDER BY seq;

SELECT
    a.seq
FROM sequence a
         LEFT JOIN seqtbl b
                   ON a.seq = b.seq
WHERE a.seq BETWEEN 1 AND 12
  AND b.seq IS NULL
ORDER BY a.seq;

-- 练习题1-9-2:求序列——面向集合的思想
-- 使用HAVING子句解决“三个人能坐下吗”，分别考虑换排和不换排的情况
SELECT S1.seat AS start_seat, '~' , S2.seat AS end_seat
FROM seats S1, seats S2, seats s3
WHERE S2.seat = S1.seat + (3 -1) -- 决定起点和终点
  AND s3.seat BETWEEN s1.seat AND s2.seat
GROUP BY s1.seat,s2.seat
HAVING COUNT(*) = SUM(CASE WHEN s3.`status` = '未预订' THEN 1 ELSE 0 END);

SELECT S1.seat AS start_seat, '~' , S2.seat AS end_seat
FROM seats2 S1, seats2 S2, seats2 s3
WHERE S2.seat = S1.seat + (3 -1) -- 决定起点和终点
  AND s3.seat BETWEEN s1.seat AND s2.seat
GROUP BY s1.seat,s2.seat
HAVING COUNT(*) = SUM(CASE WHEN s3.`status` = '未预定' AND s3.row_id = s1.row_id THEN 1 ELSE 0 END);

-- 练习题1-9-3:求所有的序列——面向集合的思想
-- 使用HAVING子句解决“最多能坐下多少人”
SELECT
    S1.seat AS start_seat,
    S2.seat AS end_seat,
    S2.seat - S1.seat + 1 AS seat_cnt
FROM Seats3 S1, Seats3 S2,seats3 s3
WHERE S1.seat <= S2.seat -- 第一步:生成起点和终点的组合
  AND s3.seat BETWEEN s1.seat - 1 AND s2.seat + 1
GROUP BY s1.seat,s2.seat
HAVING COUNT(*) = SUM(
        CASE WHEN S3.seat BETWEEN S1.seat AND S2.seat AND S3.status = '未预订' THEN 1
             WHEN S3.seat = S2.seat + 1 AND S3.status <> '未预订' THEN 1
             WHEN S3.seat = S1.seat - 1 AND S3.status <> '未预订' THEN 1
             ELSE 0 END
    );

-- 各队，全体点名
CREATE TABLE teams (
                       member VARCHAR(30),
                       team_id INT,
                       status VARCHAR(30)
);

INSERT INTO teams VALUES
('乔',1,'待命'),
('肯',1,'出勤中'),
('米',1,'待命'),
('卡伦',2,'出勤中'),
('凯斯',2,'休息'),
('简',3,'待命'),
('哈特',3,'待命'),
('迪克',3,'待命'),
('贝斯',4,'待命'),
('阿伦',5,'出勤中'),
('罗伯特',5,'休息'),
('卡根',5,'待命');

-- 用谓词表达全称量化命题
EXPLAIN SELECT team_id, member
        FROM Teams T1 WHERE NOT EXISTS (SELECT *
                                        FROM Teams T2
                                        WHERE T1.team_id = T2.team_id
                                          AND status <> '待命' );

-- ALTER TABLE teams ADD INDEX status_index (status(10));
-- CREATE INDEX status_index ON teams(status(10));
-- DROP INDEX status_index ON teams;
-- SHOW CREATE TABLE teams2;
-- CREATE TABLE `teams2` (
--   `member` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL,
--   `team_id` int DEFAULT NULL,
--   `status` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL,
--   INDEX `status_index` (`status`(10))
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci

SELECT team_id
FROM Teams GROUP BY team_id
HAVING MAX(status) = '待命' AND MIN(status) = '待命';

-- 列表显示各个队伍是否所有队员都在待命
SELECT team_id,
       CASE WHEN MAX(status) = '待命' AND MIN(status) = '待命' THEN '全都在待命'
            ELSE '队长!人手不够' END AS status FROM Teams
GROUP BY team_id;