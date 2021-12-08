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