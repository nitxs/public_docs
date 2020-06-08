# 数据库学习

## mysql中的sql使用

### mysql中SQL语句书写规范

SQL语句规范

- SQL语句要以英文分号`;`结尾
- SQL语句不区分大小写，但通常约定：关键字大写；数据库名、表名和列名小写
- 常数书写方式固定(在 SQL 语句中直接书写的字符串、日期或者数字等称为常数)：
	- 书写字符串时用英文单引号`''`括起来
	- 书写日期值时，同样需要使用英文单引号`''`括起来
	- 书写数字时，不需要使用任何符号标识，直接裸写数值就行
- SQL语句的单词之间必须用半角空格(英文空格)或换行来分隔

### mysql的数据类型

数值类型
 - 整数类型包括 TINYINT、SMALLINT、MEDIUMINT、INT、BIGINT
 - 浮点数类型包括 FLOAT 和 DOUBLE
 - 定点数类型为 DECIMAL
 
日期/时间类型
 - 包括 YEAR、TIME、DATE、DATETIME 和 TIMESTAMP
 
字符串类型
 - 包括 CHAR、VARCHAR、BINARY、VARBINARY、BLOB、TEXT、ENUM 和 SET 等
 
二进制类型
 - 包括 BIT、BINARY、VARBINARY、TINYBLOB、BLOB、MEDIUMBLOB 和 LONGBLOB
 

数据类型的选择：

对于数值类型，如果要存储的数字是整数（没有小数部分），则使用整数类型；如果要存储的数字是小数（带有小数部分），则可以选用DECIMAL或浮点类型，但是一般选择 FLOAT 类型。
但如果数值类型需要存储的数据为货币，则可以使用DECIMAL(M,2)类型，它是能提供完美精度的数据类型。

日期和时间类型的选择: 

如果只需要记录年份，则使用 YEAR 类型即可；如果只记录时间，可以使用 TIME 类型。如果同时需要记录日期和时间，则可以使用 TIMESTAMP 或者 DATETIME 类型。
由于TIMESTAMP 列的取值范围小于 DATETIME 的取值范围，因此存储较大的日期最好使用 DATETIME。
TIMESTAMP 也有一个 DATETIME 不具备的属性。默认情况下，当插入一条记录但并没有指定 TIMESTAMP 这个列值时，MySQL 会把 TIMESTAMP 列设为当前的时间。
因此当需要插入记录和当前时间时，使用 TIMESTAMP 是方便的，另外 TIMESTAMP 在空间上比 DATETIME 更有效。
MySQL 没有提供时间部分为可选的日期类型。DATE 没有时间部分，DATETIME 必须有时间部分。
如果时间部分是可选的，那么可以使用 DATE 列来记录日期，再用一个单独的 TIME 列来记录时间。然后，设置 TIME 列可以为 NULL。

字符串类型的选择：

字符串类型根据长度判断，如果需要存储的字符串短于 256 个字符，那么可以使用 CHAR、VARCHAR 或 TINYTEXT。如果需要存储更长一点的字符串，则可以选用 VARCHAR 或某种更长的 TEXT 类型。
如果某个字符串列用于表示某种固定集合的值，那么可以考虑使用数据类型 ENUM 或 SET。
CHAR 和 VARCHAR 的选择：CHAR 是固定长度字符，VARCHAR 是可变长度字符；


### mysql中SQL操作

#### 数据库操作

##### 查看数据库 

查看权限内所有数据库：`SHOW DATABASES`

查看完全匹配名为test_db的数据库：`SHOW DATABASES LIKE 'test_db';`

查看名字中含有test的数据库：`SHOW DATABASES LIKE '%test%';`

查看名字以db开头的数据库：`SHOW DATABASES LIKE 'db%';`

查看名字以db结尾的数据库：`SHOW DATABASES LIKE '%db';`

##### 创建数据库

普通示例：`CREATE DATABASES IF NOT EXISTS test_db;`

新建数据库的同时还可以指定字符集和校对规则：

```SQL
CREATE DATABASES IF NOT EXISTS test_db_char
DEFAULT CHARACTER SET utf8
DEFAULT COLLATE utf8_chinese_ci;
```

##### 修改数据库

以下示例将test_db_char指定字符集修改为 gb2312，默认校对规则修改为 utf8_unicode_ci：

```SQL
ALTER DATABASES test_db_char
DEFAULT CHARACTER SET gb2312
DEFAULT COLLATE gb2312_chinese_ci;
```

##### 删除数据库

`DROP DATABASES IF EXISTS test_db_char;`

##### 选择数据库

`USE test_db;`

#### 数据表操作

由于数据表属于数据库，所以在创建数据表之前先要使用语句 `USE <数据库名>`指定在哪个数据库中进行。如果没有选择数据库，则会抛出 `No database selected` 的错误。

数据表是由行和列构成的，通常把表的“列”称为字段（Field），把表的“行”称为记录（Record）。

##### 创建数据表

创建数据表：`CREATE TABLE tb_emp1;`

创建完了之后可以使用`SHOW TABLES;`查看数据表是否创建成功。

如要查看表结构，确认表的定义是否正确，可以 `DESCRIBE <表名>;` 或 `DESC <表名>;` 查看表的字段信息，包括字段名、字段数据类型、是否为主键、是否有默认值。

```
mysql> DESCRIBE tb_emp1;
+--------+-------------+------+-----+---------+-------+
| Field  | Type        | Null | Key | Default | Extra |
+--------+-------------+------+-----+---------+-------+
| id     | int(11)     | YES  |     | NULL    |       |
| name   | varchar(25) | YES  |     | NULL    |       |
| deptId | int(11)     | YES  |     | NULL    |       |
| salary | float        | YES  |     | NULL    |       |
+--------+-------------+------+-----+---------+-------+
4 rows in set (0.14 sec)

Null：表示该列是否可以存储 NULL 值。
Key：表示该列是否已编制索引。PRI 表示该列是表主键的一部分，UNI 表示该列是 UNIQUE 索引的一部分，MUL 表示在列中某个给定值允许出现多次。
Default：表示该列是否有默认值，如果有，值是多少。
Extra：表示可以获取的与给定列有关的附加信息，如 AUTO_INCREMENT 等。
```

##### 修改数据表

修改数据表的前提是数据库中已经存在该表。修改表指的是修改数据库中已经存在的数据表的结构。

语法：`ALTER TABLE <表名> [修改选项];`

修改选项的语法格式如下：
```
{ ADD COLUMN <列名> <类型>
| CHANGE COLUMN <旧列名> <新列名> <新列类型>
| ALTER COLUMN <列名> { SET DEFAULT <默认值> | DROP DEFAULT }
| MODIFY COLUMN <列名> <类型>
| DROP COLUMN <列名>
| RENAME TO <新表名>
| CHARACTER SET <字符集名>
| COLLATE <校对规则名> }
```

修改表名：`ALTER TABLE <旧表名> RENAME <新表名>;`

修改表字符集：`ALTER TABLE <表名> CHARACTER SET <字符集名> COLLATE <校对规则名>;`

修改表字段名：`ALTER TABLE <表名> CHANGE <旧字段名> <新字段名> <新数据类型>;`

修改字段数据类型：`ALTER TABLE <表名> MODIFY <字段名> <数据类型>;`

删除字段：`ALTER TABLE <表名> DROP <字段名>;`

##### 删除数据表

在删除表的同时，表的结构和表中所有的数据都会被删除。所以在删除前最好先备份。

删除一个或多个数据表：`DROP TABLE [IF EXISTS] 表名1 [ ,表名2, 表名3 ...]`

##### 删除被其他表关联的主表

数据表之间经常存在外键关联的情况，这时如果直接删除父表，会破坏数据表的完整性，也会删除失败。

所以应先将关联表的外键约束取消，再删除父表。适用于需要保留子表的数据，只删除父表的情况。

示例如下。

先创建两个关联表：

```SQL
// 创建表 tb_emp4
CREATE TABLE tb_emp4
(
id INT(11) PRIMARY KEY,
name VARCHAR(22),
location VARCHAR (50)
);

// 创建表 tb_emp5，并创建外键约束将该表关联到 tb_emp4
CREATE TABLE tb_emp5
(
id INT(11) PRIMARY KEY,
name VARCHAR(25),
deptId INT(11),
salary FLOAT,
CONSTRAINT fk_emp4_emp5 FOREIGN KEY (deptId) REFERENCES tb_emp4(id)
);

// 这样tb_emp5 表为子表，具有名称为 fk_emp4_emp5 的外键约束；tb_emp4 为父表，其主键 id 被子表 tb_ emp5的字段 deptId 所关联

```

创建好关联表后，如要删除被数据表 `tb_emp5` 关联的数据表 `tb_emp4`，需要先解除子表 `tb_emp5` 的外键约束：
```SQL
ALTER TABLE tb_emp5 DROP FOREIGN KEY fk_emp4_emp5;
```
语句成功执行后，会取消表 tb_emp4 和表 tb_emp5 之间的关联关系。

解除关联关系后，可以使用 DROP TABLE 语句直接删除父表 tb_emp4，SQL 语句如下：
```SQL
DROP TABLE tb_emp4;
```

##### 向数据表中添加字段

MySQL 允许在开头、中间和结尾处添加字段。

一个完整的字段包括字段名、数据类型和约束条件。

在末尾添加字段：`ALTER TABLE <表名> ADD <新字段名><数据类型>[约束条件];`
```
<表名> 为数据表的名字；
<新字段名> 为所要添加的字段的名字；
<数据类型> 为所要添加的字段能存储数据的数据类型；
[约束条件] 是可选的，用来对添加的字段进行约束。
```

在开头添加字段：`ALTER TABLE <表名> ADD <新字段名> <数据类型> [约束条件] FIRST;`

在中间位置添加字段：`ALTER TABLE <表名> ADD <新字段名> <数据类型> [约束条件] AFTER <已经存在的字段名>;`

#### 操作表中数据

##### 查询表中数据

```SQL
SELECT
{*|<字段列名>}			-- {*|<字段列名>}包含星号通配符的字段列表，表示所要查询字段的名称。<表 1>，<表 2>…，表 1 和表 2 表示查询数据的来源，可以是单个或多个
[
FROM <表1>,<表2>...
[WHERE <表达式>		-- WHERE <表达式>是可选项，如果选择该项，将限定查询数据必须满足该查询条件。
[GROUP BY <group by definition>		-- GROUP BY< 字段 >，该子句告诉 MySQL 如何显示查询出来的数据，并按照指定的字段分组。
[HAVING <expression> [{<operator> <expression>}…]]	
[ORDER BY <order by definition>]  --[ORDER BY< 字段 >]，该子句告诉 MySQL 按什么样的顺序显示查询出来的数据，可以进行的排序有升序（ASC）和降序（DESC），默认情况下是升序。
[LIMIT[<offset>,] <row count>]	-- [LIMIT[<offset>，]<row count>]，该子句告诉 MySQL 每次显示查询出来的数据条数。
]
]
```

##### 查询去重

在 MySQL 中使用 SELECT 语句执行简单的数据查询时，返回的是所有匹配的记录。如果表中的某些字段没有唯一性约束，那么这些字段就可能存在重复值。为了实现查询不重复的数据，MySQL 提供了 DISTINCT 关键字。

DISTINCT 关键字的主要作用就是对数据表中一个或多个字段重复的数据进行过滤，只返回其中的一条数据给用户。

```SQL
SELECT DISTINCT <字段名> FROM <表名>;
```
其中，“字段名”为需要消除重复记录的字段名称，多个字段时用逗号隔开。

使用 DISTINCT 关键字时需要注意以下几点：
- DISTINCT 关键字只能在 SELECT 语句中使用。
- 在对一个或多个字段去重时，DISTINCT 关键字必须在所有字段的最前面。
- 如果 DISTINCT 关键字后有多个字段，则会对多个字段进行组合去重，也就是说，只有多个字段组合起来完全是一样的情况下才会被去重。

##### 设置别名

MySQL 提供了 AS 关键字来为表和字段指定别名。

为表指定别名

当表名很长或者执行一些特殊查询的时候，为了方便操作，可以为表指定一个别名，用这个别名代替表原来的名称。`<表名> [AS] <别名>;`
- <表名>：数据库中存储的数据表的名称。
- <别名>：查询时指定的表的新名称。
- AS关键字可以省略，省略后需要将表名和别名用空格隔开。

注意：表的别名不能与该数据库的其它表同名。字段的别名不能与该表的其它字段同名。在条件表达式中不能使用字段的别名，否则会出现“ERROR 1054 (42S22): Unknown column”这样的错误提示信息。

```SQL
-- 为 tb_students_info 表指定别名 stu
SELECT stu.name,stu.height FROM tb_students_info AS stu;
```

为字段指定别名

在使用 SELECT 语句查询数据时，MySQL 会显示每个 SELECT 后面指定输出的字段。有时为了显示结果更加直观，我们可以为字段指定一个别名。

为字段指定别名的基本语法格式为：`<字段名> [AS] <别名>`
- <字段名>：为数据表中字段定义的名称。
- <字段别名>：字段新的名称。
- AS关键字可以省略，省略后需要将字段名和别名用空格隔开。

```SQL
-- 查询 tb_students_info 表，为 name 指定别名 student_name，为 age 指定别名 student_age，
SELECT name AS student_name, age AS student_age FROM tb_students_info;
```
表别名只在执行查询时使用，并不在返回结果中显示。而字段定义别名之后，会返回给客户端显示，显示的字段为字段的别名。


##### 限制查询结果的条数

```SQL
-- 指定初始位置
LIMIT 初始位置，记录数;  -- “初始位置”表示从哪条记录开始显示，索引从0开始；“记录数”表示显示记录的条数。 LIMIT 后的两个参数必须都是正整数

-- 不指定初始位置
-- LIMIT 关键字不指定初始位置时，记录从第一条记录开始显示。显示记录的条数由 LIMIT 关键字指定。
LIMIT 记录数; 	-- “记录数”表示显示记录的条数。如果“记录数”的值小于查询结果的总数，则会从第一条记录开始，显示指定条数的记录。如果“记录数”的值大于查询结果的总数，则会直接显示查询出来的所有记录。
```

##### 对查询结果排序
```SQL
ORDER BY <字段名> [ASC|DESC];
```

字段名：表示需要排序的字段名称，多个字段时用逗号隔开。
ASC|DESC：ASC表示字段按升序排序；DESC表示字段按降序排序。其中ASC为默认值。

使用 ORDER BY 关键字应该注意以下几个方面：
- ORDER BY 关键字后可以跟子查询。
- 当排序的字段中存在空值时，ORDER BY 会将该空值作为最小值来对待。
- ORDER BY 指定多个字段进行排序时，MySQL 会按照字段的顺序从左到右依次进行排序

示例：
```SQL
-- 单字段排序
SELECT * FROM tb_students_info ORDER BY height;

-- 多字段排序  
-- 查询 tb_students_info 表中的 name 和 height 字段，先按 height 排序，再按 name 排序
-- 默认情况下，查询数据按字母升序进行排序（A～Z）
SELECT name,height FROM tb_students_info ORDER BY height,name;

-- 查询 tb_students_info 表，先按 height 降序排序，再按 name 升序排序，SQL 语句和运行结果如下。
SELECT name,height FROM tb_student_info ORDER BY height DESC,name ASC;
```
注意：在对多个字段进行排序时，排序的第一个字段必须有相同的值，才会对第二个字段进行排序。如果第一个字段数据中所有的值都是唯一的，MySQL 将不再对第二个字段进行排序。

##### 条件查询

如果需要有条件的从数据表中查询数据，可以使用 WHERE 关键字来指定查询条件

```SQL
WHERE 查询条件;

-- 单一条件的查询语句
SELECT name,height FROM tb_students_info WHERE height=170;
SELECT name,age FROM tb_students_info WHERE age<22;

-- 多条件的查询语句
-- 在 WHERE 关键词后可以有多个查询条件，这样能够使查询结果更加精确。多个查询条件时用逻辑运算符 AND（&&）、OR（||）或 XOR 隔开
-- AND：记录满足所有查询条件时，才会被查询出来。
-- OR：记录满足任意一个查询条件时，才会被查询出来
-- XOR：记录满足其中一个条件，并且不满足另一个条件时，才会被查询出来。
SELECT name,age,height FROM tb_students_info WHERE age>21 AND height>=175;
SELECT name,age,height FROM tb_students_info WHERE age>20 OR height>=175;
SELECT name,age,height FROM tb_students_info WHERE age>21 XOR height>=175;  -- 查询结果中所有记录的 age 字段都大于 21 且 height 字段都小于 175
```
查询条件可以是：
- 带比较运算符和逻辑运算符的查询条件
- 带 BETWEEN AND 关键字的查询条件
- 带 IS NULL 关键字的查询条件
- 带 IN 关键字的查询条件
- 带 LIKE 关键字的查询条件

##### 模糊查询 LIKE

LIKE 关键字主要用于搜索匹配字段中的指定内容
```SQL
[NOT] LIKE  '字符串';		-- NOT ：可选参数，字段中的内容与指定的字符串不匹配时满足条件; 字符串：指定用来匹配的字符串。“字符串”可以是一个很完整的字符串，也可以包含通配符。
```
LIKE 关键字支持百分号“%”和下划线“_”通配符。

带有“%”通配符的查询： %”是 MySQL 中最常用的通配符，它能代表任何长度的字符串，字符串的长度可以为 0。例如，a%b表示以字母 a 开头，以字母 b 结尾的任意长度的字符串。该字符串可以代表 ab、acb、accb、accrb 等字符串。

```SQL
SELECT name FROM tb_students_info WHERE name LIKE 'T%';  -- 查找所有以字母“T”开头的学生姓名  匹配的字符串必须加单引号或双引号

-- NOT LIKE 表示字符串不匹配时满足条件
SELECT name FROM tb_students_info WHERE name NOT LIKE 'T%';  -- 查找所有不以字母“T”开头的学生姓名

-- 查找所有包含字母“e”的学生姓名
SELECT name FROM tb_students_info WHERE name LIKE '%e%';
```

带有`'_'`通配符的查询，`'_'`只能代表单个字符，字符的长度不能为0。例如，a_b可以代表 acb、adb、aub 等字符串。

```SQL
-- 查找所有以字母“y”结尾，且“y”前面只有 4 个字母的学生姓名
SELECT name FROM tb_students_info WHERE name LIKE '____y';
```

LIKE 关键字匹配字符时不区分大小写，如需要区分大小写，可以加入`BINARY`关键字。

```SQL
-- 查找所有以字母“t”开头的学生姓名，区分大小写和不区分大小写
SELECT name FROM tb_students_info WHERE name LIKE 't%';  -- 不区分大小写(默认)
SELECT name FROM tb_students_info WHERE name LIKE BINARY 't%';  -- 区分大小写
```

如果查询内容中包含通配符，可以使用“\”转义符：
```SQL
SELECT NAME FROM test.`tb_students_info` WHERE NAME LIKE '%\%';
```

使用通配符的注意事项和技巧
- 注意大小写。MySQL 默认是不区分大小写的。如果区分大小写，像“Tom”这样的数据就不能被“t%”所匹配到。
- 注意尾部空格，尾部空格会干扰通配符的匹配。例如，“T% ”就不能匹配到“Tom”。
- 注意 NULL。“%”通配符可以到匹配任意字符，但是不能匹配 NULL。也就是说 “%”匹配不到 tb_students_info 数据表中值为 NULL 的记录。
- 不要过度使用通配符，如果其它操作符能达到相同的目的，应该使用其它操作符。因为 MySQL 对通配符的处理一般会比其他操作符花费更长的时间。
- 在确定使用通配符后，除非绝对有必要，否则不要把它们用在字符串的开始处。把通配符置于搜索模式的开始处，搜索起来是最慢的。
- 仔细注意通配符的位置。如果放错地方，可能不会返回想要的数据。

##### 范围查询

关键字 `BETWEEN AND`，用来判断字段的数值是否在指定范围内。BETWEEN AND 需要两个参数，即范围的起始值和终止值。如果字段值在指定的范围内，则这些记录被返回。如果不在指定范围内，则不会被返回。

`[NOT] BETWEEN 取值1 AND 取值2`

NOT：可选参数，表示指定范围之外的值。如果字段值不满足指定范围内的值，则这些记录被返回。
取值1：表示范围的起始值。
取值2：表示范围的终止值。

在 MySQL 中，BETWEEN AND 能匹配指定范围内的所有值，包括起始值和终止值。

```SQL
SELECT name,age FROM tb_students_info WHERE age BETWEEN 20 AND 23;
SELECT name,age FROM tb_students_info WHERE age NOT BETWEEN 20 AND 23;
SELECT name,login_date FROM tb_students_info WHERE login_date BETWEEN '2015-10-01' AND '2016-05-01';
```

##### 空值查询

关键字 `IS NULL`，用来判断字段的值是否为空值（NULL）。空值不同于 0，也不同于空字符串。如果字段的值是空值，则满足查询条件，该记录将被查询出来。如果字段的值不是空值，则不满足查询条件。

`IS [NOT] NULL`
“NOT”是可选参数，表示字段值不是空值时满足条件。

```SQL
SELECT `name`,`login_date` FROM tb_students_info WHERE login_date IS NULL;
SELECT `name`,login_date FROM tb_students_info WHERE login_date IS NOT NULL;
```

##### 分组查询
关键字 `GROUP BY` 可以根据一个或多个字段对查询结果进行分组。

`GROUP BY  <字段名>` “字段名”表示需要分组的字段名称，多个字段时用逗号隔开。

单独使用 GROUP BY 关键字时，查询结果会只显示每个分组的第一条记录

```SQL
-- 根据 tb_students_info 表中的 sex 字段进行分组查询
SELECT `name`,`sex` FROM tb_students_info GROUP BY sex;
```

GROUP BY 关键字可以和 GROUP_CONCAT() 函数一起使用。GROUP_CONCAT() 函数会把每个分组的字段值都显示出来。
```SQL
-- 根据 tb_students_info 表中的 sex 字段进行分组查询，使用 GROUP_CONCAT() 函数将每个分组的 name 字段的值都显示出来
SELECT `sex`, GROUP_CONCAT(name) FROM tb_students_info GROUP BY sex;

/**
| sex  | GROUP_CONCAT(name)         |
+------+----------------------------+
| 女   | Henry,Jim,John,Thomas,Tom  |
| 男   | Dany,Green,Jane,Lily,Susan |
*/
-- 由结果可以看到，查询结果分为两组，sex 字段值为“女”的是一组，值为“男”的是一组，且每组的学生姓名都显示出来了
```

```SQL
-- 根据 tb_students_info 表中的 age 和 sex 字段进行分组查询
SELECT age,sex,GROUP_CONCAT(name) FROM tb_students_info GROUP BY age,sex;

/**
| age  | sex  | GROUP_CONCAT(name) |
+------+------+--------------------+
|   21 | 女   | John               |
|   22 | 女   | Thomas             |
|   22 | 男   | Jane,Lily          |
|   23 | 女   | Henry,Tom          |
|   23 | 男   | Green,Susan        |
|   24 | 女   | Jim                |
|   25 | 男   | Dany               |
*/
-- 先按照 age 字段进行分组，当 age 字段值相等时，再把 age 字段值相等的记录按照 sex 字段进行分组
-- 多个字段分组查询时，会先按照第一个字段进行分组。如果第一个字段中有相同的值，MySQL 才会按照第二个字段进行分组。如果第一个字段中的数据都是唯一的，那么 MySQL 将不再对第二个字段进行分组。
```

在数据统计时，GROUP BY 关键字经常和聚合函数一起使用。

聚合函数包括 COUNT()，SUM()，AVG()，MAX() 和 MIN()。其中，COUNT() 用来统计记录的条数；SUM() 用来计算字段值的总和；AVG() 用来计算字段值的平均值；MAX() 用来查询字段的最大值；MIN() 用来查询字段的最小值。

```SQL
-- 根据 tb_students_info 表的 sex 字段进行分组查询，使用 COUNT() 函数计算每一组的记录数
SELECT sex,COUNT(sex) FROM tb_students_info GROUP BY sex;
```

`WITH POLLUP` 关键字用来在所有记录的最后加上一条记录，这条记录是上面所有记录的总和，即统计记录数量。

```SQL
-- 根据 tb_students_info 表中的 sex 字段进行分组查询，并使用 WITH ROLLUP 显示记录的总和。
SELECT sex,GROUP_CONCAT(name) FROM tb_students_info GROUP BY sex WITH ROLLUP;

/**
| sex  | GROUP_CONCAT(name)                                   |
+------+------------------------------------------------------+
| 女   | Henry,Jim,John,Thomas,Tom                            |
| 男   | Dany,Green,Jane,Lily,Susan                           |
| NULL | Henry,Jim,John,Thomas,Tom,Dany,Green,Jane,Lily,Susan |
*/
-- GROUP_CONCAT(name) 显示了每个分组的 name 字段值。同时，最后一条记录的 GROUP_CONCAT(name) 字段的值刚好是上面分组 name 字段值的总和
```

##### 过滤分组

关键字 `HAVING` 对分组后的数据进行过滤: `HAVING <查询条件>;`

HAVING 关键字和 WHERE 关键字都可以用来过滤数据，且 HAVING 支持 WHERE 关键字中所有的操作符和语法。

两者区别：
- 一般情况下，WHERE 用于过滤数据行，而 HAVING 用于过滤分组。
- WHERE 查询条件中不可以使用聚合函数，而 HAVING 查询条件中可以使用聚合函数。
- WHERE 在数据分组前进行过滤，而 HAVING 在数据分组后进行过滤 。
- WHERE 针对数据库文件进行过滤，而 HAVING 针对查询结果进行过滤。也就是说，WHERE 根据数据表中的字段直接进行过滤，而 HAVING 是根据前面已经查询出的字段进行过滤。
- WHERE 查询条件中不可以使用字段别名，而 HAVING 查询条件中可以使用字段别名。

示例：

分别使用 HAVING 和 WHERE 关键字查询出 tb_students_info 表中身高大于 150 的学生姓名，性别和身高

```SQL
-- 例一： 
SELECT name,sex,height FROM tb_students_info HAVING height>150;

SELECT name,sex,height FROM tb_students_info WHERE height>150;

-- 因为在 SELECT 关键字后已经查询出了 height 字段，所以 HAVING 和 WHERE 都可以使用。但是如果 SELECT 关键字后没有查询出 height 字段，MySQL 就会报错
```

使用 HAVING 和 WHERE 关键字分别查询出 tb_students_info 表中身高大于 150 的学生姓名和性别（与例 1 相比，这次没有查询 height 字段）
```SQL
-- 例二： 
SELECT name,sex,height FROM tb_students_info WHERE height>150;
-- 正确查询出结果

SELECT name,sex FROM tb_students_info HAVING height>150;
-- 查询结果 ERROR 1054 (42S22): Unknown column 'height' in 'having clause'

-- 因为在 SELECT 关键字后已经查询出了 height 字段，所以 HAVING 和 WHERE 都可以使用。但是如果 SELECT 关键字后没有查询出 height 字段，MySQL 就会报错
```

##### 交叉连接

在实际应用中，经常使用多表查询。多表查询就是同时查询两个或两个以上的表。

在 MySQL 中，多表查询主要有交叉连接、内连接和外连接。

交叉连接（CROSS JOIN）一般用来返回连接表的笛卡尔积。

笛卡尔积是指两个集合 X 和 Y 的乘积。

例如，有 A 和 B 两个集合，它们的值如下：
```
A = {1,2}
B = {3,4,5}
```
集合 A×B 和 B×A 的结果集分别表示为：
```
A×B={(1,3), (1,4), (1,5), (2,3), (2,4), (2,5) };
B×A={(3,1), (3,2), (4,1), (4,2), (5,1), (5,2) };
```
以上 A×B 和 B×A 的结果就叫做两个集合的笛卡尔积。

并且，从以上结果我们可以看出：
- 两个集合相乘，不满足交换率，即 A×B≠B×A。
- A 集合和 B 集合的笛卡尔积是 A 集合的元素个数 × B 集合的元素个数。

多表查询遵循的算法就是以上提到的笛卡尔积，表与表之间的连接可以看成是在做乘法运算。在实际应用中，应避免使用笛卡尔积，因为笛卡尔积中容易存在大量的不合理数据，简单来说就是容易导致查询结果重复、混乱。

交叉连接的语法：`SELECT <字段名> FROM <表1> CROSS JOIN <表2> [WHERE子句];`或者`SELECT <字段名> FROM <表1>, <表2> [WHERE子句];`
- 字段名：需要查询的字段名称。
- <表1><表2>：需要交叉连接的表名。
- WHERE 子句：用来设置交叉连接的查询条件。

多个表交叉连接时，在 FROM 后连续使用 CROSS JOIN 或,即可。以上两种语法的返回结果是相同的，但是第一种语法才是官方建议的标准写法。

当连接的表之间没有关系时，我们会省略掉 WHERE 子句，这时返回结果就是两个表的笛卡尔积，返回结果数量就是两个表的数据行相乘。需要注意的是，如果每个表有 1000 行，那么返回结果的数量就有 1000×1000 = 1000000 行，数据量是非常巨大的。

所以，通过交叉连接的方式进行多表查询的这种方法并不常用，我们应该尽量避免这种查询。

如果在交叉连接时使用 WHERE 子句，MySQL 会先生成两个表的笛卡尔积，然后再选择满足 WHERE 条件的记录。因此，表的数量较多时，交叉连接会非常非常慢。一般情况下不建议使用交叉连接。

在 MySQL 中，多表查询一般使用内连接和外连接，它们的效率要高于交叉连接。

##### 内连接

多表查询的另一种方式——内连接。

内连接（INNER JOIN）主要通过设置连接条件的方式，来移除查询结果中某些数据行的交叉连接。简单来说，就是利用条件表达式来消除交叉连接的某些数据行。

内连接使用 INNER JOIN 关键字连接两张表，并使用 ON 子句来设置连接条件。如果没有连接条件，INNER JOIN 和 CROSS JOIN 在语法上是等同的，两者可以互换。

`SELECT <字段名> FROM <表1> INNER JOIN <表2> [ON子句];`
- 字段名：需要查询的字段名称。
- <表1><表2>：需要内连接的表名。
- INNER JOIN ：内连接中可以省略 INNER 关键字，只用关键字 JOIN。
- ON 子句：用来设置内连接的连接条件。

多个表内连接时，在 FROM 后连续使用 INNER JOIN 或 JOIN 即可。

内连接可以查询两个或两个以上的表。

示例：
在 tb_students_info 表和 tb_course 表之间，使用内连接查询学生姓名和相对应的课程名称
```SQL
SELECT s.name,c.course_name FROM tb_students_info AS s INNER JOIN tb_course AS c ON s.course_id = c.id;
```
当对多个表进行查询时，要在 SELECT 语句后面指定字段是来源于哪一张表。因此，在多表查询时，SELECT 语句后面的写法是表名.列名。另外，如果表名非常长的话，也可以给表设置别名，这样就可以直接在 SELECT 语句后面写上表的别名.列名。

##### 外连接

内连接的查询结果都是符合连接条件的记录，而外连接会先将连接的表分为基表和参考表，再以基表为依据返回满足和不满足条件的记录。

外连接可以分为左外连接和右外连接，下面根据实例分别介绍左外连接和右外连接。

左外连接又称为左连接，使用 LEFT OUTER JOIN 关键字连接两个表，并使用 ON 子句来设置连接条件。`SELECT <字段名> FROM <表1> LEFT OUTER JOIN <表2> <ON子句>;`
- 字段名：需要查询的字段名称。
- <表1><表2>：需要左连接的表名。
- LEFT OUTER JOIN：左连接中可以省略 OUTER 关键字，只使用关键字 LEFT JOIN。
- ON 子句：用来设置左连接的连接条件，不能省略。

上述语法中，“表1”为基表，“表2”为参考表。左连接查询时，可以查询出“表1”中的所有记录和“表2”中匹配连接条件的记录。如果“表1”的某行在“表2”中没有匹配行，那么在返回结果中，“表2”的字段值均为空值（NULL）。

在 tb_students_info 表和 tb_course 表中查询所有学生姓名和相对应的课程名称，包括没有课程的学生
```SQL
/**
SELECT * FROM tb_course;
| id | course_name |
+----+-------------+
|  1 | Java        |
|  2 | MySQL       |
|  3 | Python      |
|  4 | Go          |
|  5 | C++         |
|  6 | HTML        |

SELECT * FROM tb_students_info;
| id | name   | age  | sex  | height | course_id |
+----+--------+------+------+--------+-----------+
|  1 | Dany   |   25 | 男   |    160 |         1 |
|  2 | Green  |   23 | 男   |    158 |         2 |
|  3 | Henry  |   23 | 女   |    185 |         1 |
|  4 | Jane   |   22 | 男   |    162 |         3 |
|  5 | Jim    |   24 | 女   |    175 |         2 |
|  6 | John   |   21 | 女   |    172 |         4 |
|  7 | Lily   |   22 | 男   |    165 |         4 |
|  8 | Susan  |   23 | 男   |    170 |         5 |
|  9 | Thomas |   22 | 女   |    178 |         5 |
| 10 | Tom    |   23 | 女   |    165 |         5 |
| 11 | LiMing |   22 | 男   |    180 |         7 |
*/
SELECT s.name,c.course_name FROM tb_students_info AS s LEFT OUTER JOIN tb_course AS c ON s.`course_id`=c.`id`;
/**
-- 查询结果
| name   | course_name |
+--------+-------------+
| Dany   | Java        |
| Henry  | Java        |
| NULL   | Java        |
| Green  | MySQL       |
| Jim    | MySQL       |
| Jane   | Python      |
| John   | Go          |
| Lily   | Go          |
| Susan  | C++         |
| Thomas | C++         |
| Tom    | C++         |
| LiMing | NULL        |
*/
-- 可以看到，运行结果显示了 12 条记录，name 为 LiMing 的学生目前没有课程，因为对应的 tb_course 表中没有该学生的课程信息，所以该条记录只取出了 tb_students_info 表中相应的值，而从 tb_course 表中取出的值为 NULL。
```

右外连接又称为右连接，右连接是左连接的反向连接。使用 RIGHT OUTER JOIN 关键字连接两个表，并使用 ON 子句来设置连接条件。

`SELECT <字段名> FROM <表1> RIGHT OUTER JOIN <表2> <ON子句>`
- 字段名：需要查询的字段名称。
- <表1><表2>：需要右连接的表名。
- RIGHT OUTER JOIN：右连接中可以省略 OUTER 关键字，只使用关键字 RIGHT JOIN。
- ON 子句：用来设置右连接的连接条件，不能省略。

与左连接相反，右连接以“表2”为基表，“表1”为参考表。右连接查询时，可以查询出“表2”中的所有记录和“表1”中匹配连接条件的记录。如果“表2”的某行在“表1”中没有匹配行，那么在返回结果中，“表1”的字段值均为空值（NULL）。

```SQL
在 tb_students_info 表和 tb_course 表中查询所有课程，包括没有学生的课程
SELECT s.name,c.course_name FROM tb_students_info AS s RIGHT OUTER JOIN tb_course as c ON s.`course_id`=c.`id`;
/**
| name   | course_name |
+--------+-------------+
| Dany   | Java        |
| Green  | MySQL       |
| Henry  | Java        |
| Jane   | Python      |
| Jim    | MySQL       |
| John   | Go          |
| Lily   | Go          |
| Susan  | C++         |
| Thomas | C++         |
| Tom    | C++         |
| NULL   | HTML        |
*/
```
可以看到，结果显示了 11 条记录，名称为 HTML 的课程目前没有学生，因为对应的 tb_students_info 表中并没有该学生的信息，所以该条记录只取出了 tb_course 表中相应的值，而从 tb_students_info 表中取出的值为 NULL。

多个表左/右连接时，在 ON 子句后连续使用 LEFT/RIGHT OUTER JOIN 或 LEFT/RIGHT JOIN 即可。

使用外连接查询时，一定要分清需要查询的结果，是需要显示左表的全部记录还是右表的全部记录，然后选择相应的左连接和右连接。

##### 子查询

子查询是 MySQL 中比较常用的查询方法，通过子查询可以实现多表查询。子查询指将一个查询语句嵌套在另一个查询语句中。子查询可以在 SELECT、UPDATE 和 DELETE 语句中使用，而且可以进行多层嵌套。在实际开发时，子查询经常出现在 WHERE 子句中。

`WHERE <表达式> <操作符> (子查询)`

操作符可以是比较运算符和 IN、NOT IN、EXISTS、NOT EXISTS 等关键字。

`IN | NOT IN` 当表达式与子查询返回的结果集中的某个值相等时，返回 TRUE，否则返回 FALSE；若使用关键字 NOT，则返回值正好相反。

`EXISTS | NOT EXISTS` 用于判断子查询的结果集是否为空，若子查询的结果集不为空，返回 TRUE，否则返回 FALSE；若使用关键字 NOT，则返回的值正好相反。

使用子查询在 tb_students_info 表和 tb_course 表中查询学习 Java 课程的学生姓名
```SQL
SELECT name FROM tb_students_info WHERE course_id IN (SELECT id FROM tb_course WHERE course_name = 'Java');
/**  
查询结果：学习 Java 课程的只有 Dany 和 Henry
| name  |
+-------+
| Dany  |
| Henry |
*/
```

上述步骤可以分成以下两步来理解：

```SQL
-- 首先单独执行内查询，查询出 tb_course 表中课程为 Java 的 id
SELECT id FROM tb_course WHERE course_name = 'Java';

-- 然后执行外层查询，在 tb_students_info 表中查询 course_id 等于 1 的学生姓名
SELECT name FROM tb_students_info WHERE course_id IN (1);
```
习惯上，外层的 SELECT 查询称为父查询，圆括号中嵌入的查询称为子查询（子查询必须放在圆括号内）。MySQL 在处理上例的 SELECT 语句时，执行流程为：先执行子查询，再执行父查询。

在 SELECT 语句中使用 NOT IN 关键字，查询没有学习 Java 课程的学生姓名：
```SQL
SELECT name FROM tb_students_info WHERE course_id NOT IN (SELECT id FROM tb_course WHERE course_name = 'Java');
-- 可以看出，运行结果与上例刚好相反，没有学习 Java 课程的是除了 Dany 和 Henry 之外的学生
```

使用`=`运算符，在 tb_course 表和 tb_students_info 表中查询出所有学习 Python 课程的学生姓名：
```SQL
SELECT name FROM tb_students_info WHERE course_id = (SELECT id FROM tb_course WHERE course_name = 'Python');
-- 结果显示，学习 Python 课程的学生只有 Jane
```

使用`<>`运算符，在 tb_course 表和 tb_students_info 表中查询出没有学习 Python 课程的学生姓名：
```SQL
SELECT name FROM tb_students_info WHERE course_id <> (SELECT id FROM tb_course WHERE course_name = 'Python');
```

查询 tb_course 表中是否存在 id=1 的课程，如果存在，就查询出 tb_students_info 表中的记录：
```SQL
SELECT * FROM tb_students_info WHERE EXISTS(SELECT course_name FROM tb_course WHERE id=1);
```
由结果可以看到，tb_course 表中存在 id=1 的记录，因此 EXISTS 表达式返回 TRUE，外层查询语句接收 TRUE 之后对表 tb_students_info 进行查询，返回所有的记录。
EXISTS 关键字可以和其它查询条件一起使用，条件表达式与 EXISTS 关键字之间用 AND 和 OR 连接。

查询 tb_course 表中是否存在 id=1 的课程，如果存在，就查询出 tb_students_info 表中 age 字段大于 24 的记录：
```SQL
SELECT * FROM tb_students_info WHERE age>24 AND EXISTS(SELECT course_name FROM tb_course WHERE id=1);
```
内层查询语句从 tb_course 表中查询到记录，返回 TRUE。外层查询语句开始进行查询。根据查询条件，从 tb_students_info 表中查询 age 大于 24 的记录。

子查询的功能也可以通过表连接完成，但是子查询会使 SQL 语句更容易阅读和编写。

一般来说，表连接（内连接和外连接等）都可以用子查询替换，但反过来却不一定，有的子查询不能用表连接来替换。子查询比较灵活、方便、形式多样，适合作为查询的筛选条件，而表连接更适合于查看连接表的数据。

子查询的注意事项：
- 子查询语句可以嵌套在 SQL 语句中任何表达式出现的位置
  在 SELECT 语句中，子查询可以被嵌套在 SELECT 语句的列、表和查询条件中，即 SELECT 子句，FROM 子句、WHERE 子句、GROUP BY 子句和 HAVING 子句。
  嵌套在 SELECT 语句的 SELECT 子句中的子查询语法格式:`SELECT (子查询) FROM 表名;`子查询结果为单行单列，但不必指定列别名
  嵌套在 SELECT 语句的 FROM 子句中的子查询语法格式:`SELECT * FROM (子查询) AS 表的别名;`注意必须为表指定别名。一般返回多行多列数据记录，可以当作一张临时表。
- 只出现在子查询中而没有出现在父查询中的表不能包含在输出列中
  多层嵌套子查询的最终数据集只包含父查询（即最外层的查询）的 SELECT 子句中出现的字段，而子查询的输出结果通常会作为其外层子查询数据源或用于数据判断匹配。

##### 正则表达式查询

使用 `REGEXP` 关键字指定正则表达式的字符匹配模式。 

`属性名 REGEXP '匹配方式'`

其中，“属性名”表示需要查询的字段名称；“匹配方式”表示以哪种方式来匹配查询。“匹配方式”中有很多的模式匹配字符，它们分别表示不同的意思。下表列出了 REGEXP 操作符中常用的匹配方式。

| 选项 | 说明   | 例子  | 匹配值示例  |
|  ----  | ----  |  ----  | ----  |
|  ^ | 匹配文本的开始字符  |   '^b' 匹配以字母 b 开头的字符串 | book、big、banana、bike   |
|  $ | 匹配文本的结束字符  |   'st$' 匹配以 st 结尾的字符串  | test、resist、persist   |
|  . | 匹配任何单个字符  |   'b.t' 匹配任何 b 和 t 之间有一个字符 | bit、bat、but、bite   |
|  * | 匹配零个或多个在它前面的字符 |  'f*n' 匹配字符 n 前面有任意个字符 f | fn、fan、faan、abcn   |
|  + | 匹配前面的字符 1 次或多次    |   'ba+' 匹配以 b 开头，后面至少紧跟一个 a | ba、bay、bare、battle   |
|  <字符串> | 匹配包含指定字符的文本   |   'fa' 匹配包含‘fa’的文本 | fan、afa、faad   |
|  [字符集合] | 匹配字符集合中的任何一个字符   |   '[xz]' 匹配 x 或者 z | dizzy、zebra、x-ray、extra   |
|  [^] | 匹配不在括号中的任何字符  |   '[^abc]' 匹配任何不包含 a、b 或 c 的字符串 | desk、fox、f8ke   |
|  字符串{n,} | 匹配前面的字符串至少 n 次 |   'b{2}' 匹配 2 个或更多的 b | bbb、bbbb、bbbbbbb   |
| 字符串{n,m} | 匹配前面的字符串至少 n 次， 至多 m 次    |   'b{2,4}' 匹配最少 2 个，最多 4 个 b | bbb、bbbb   |


查询以特定字符或字符串开头的记录，使用`^`

在 tb_students_info 表中，查询 name 字段以“J”开头的记录
`SELECT * FROM tb_students_info WHERE name REGEXP '^J';`

查询以特定字符或字符串结尾的记录，使用`$`

在 tb_students_info 表中，查询 name 字段以“y”结尾的记录
`SELECT * FROM tb_students_info WHERE name REGEXP 'y$';`


##### 插入数据

在 MySQL 中可以使用 INSERT 语句向数据库已有的表中插入一行或者多行元组数据。

INSERT 语句有两种语法形式，分别是 INSERT…VALUES 语句和 INSERT…SET 语句。

INSERT…VALUES语句:
```SQL
INSERT INTO <表名> [ <列名1> [ , … <列名n>] ]
VALUE (值1) [… , (值n) ];
```
- <表名>：指定被操作的表名。
- <列名>：指定需要插入数据的列名。若向表中的所有列插入数据，则全部的列名均可以省略，直接采用 INSERT<表名>VALUES(…) 即可。
- VALUES 或 VALUE 子句：该子句包含要插入的数据清单。数据清单中数据的顺序要和列的顺序相对应。

INSERT…SET语句:
```SQL
INSERT INTO <表名>
SET <列名1> = <值1>,
	<列名2> = <值2>,
	…
```
此语句用于直接给表中的某些列指定对应的列值，即要插入的数据的列名在 SET 子句中指定，col_name 为指定的列名，等号后面为指定的数据，而对于未指定的列，列值会指定为该列的默认值。

INSERT 语句的作用：
- 使用 INSERT…VALUES 语句可以向表中插入一行数据，也可以插入多行数据
- 使用 INSERT…SET 语句可以指定插入行中每列的值，也可以指定部分列的值；
- INSERT…SELECT 语句向表中插入其他表的数据。
- 采用 INSERT…SET 语句可以向表中插入部分列的值，这种方式更为灵活；
- INSERT…VALUES 语句可以一次插入多条数据。
- 在 MySQL 中，用单条 INSERT 语句处理多个插入要比使用多条 INSERT 语句更快。
- 当使用单条 INSERT 语句插入多行数据的时候，只需要将每行数据用圆括号括起来即可。

向表中的全部字段添加值示例:

首先创建数据表：
```SQL
CREATE TABLE tb_courses
(
	course_id INT NOT NULL AUTO_INCREMENT,
	course_name CHAR(40) NOT NULL,
	course_grade FLOAT NOT NULL,
	course_info CHAR(100) NULL,
	PRIMARY KEY(course_id)
);
```

接下来向该表中插入数据：
```SQL
-- 方法一：
-- 在插入数据时，指定了 tb_courses 表的所有字段，因此将为每一个字段插入新的值
INSERT INTO tb_course (course_id,course_name,course_grade,course_info)
VALUES (1,'Network',3,'Computer Network');

-- 方法二：
-- INSERT 语句后面的列名称顺序可以不是 tb_courses 表定义时的顺序，即插入数据时，不需要按照表定义的顺序插入，只要保证值的顺序与列字段的顺序相同就可以。
INSERT INTO tb_courses (course_name,course_info,course_id,course_grade)
VALUES ('Database','MySQL',2,3);

-- 方法三：
-- 使用 INSERT 插入数据时，允许列名称列表 column_list 为空，此时值列表中需要为表的每一个字段指定值，并且值的顺序必须和数据表中字段定义时的顺序相同
INSERT INTO tb_courses
VLAUES(3,'Java',4,'Java EE');

```

向表中指定字段添加值

为表的指定字段插入数据，是在 INSERT 语句中只向部分字段中插入值，而其他字段的值为表定义时的默认值。这个可以使用 INSERT…VALUES 或 INSERT…SET语句。

INSERT INTO…SELECT…FROM 语句用于快速地从一个或多个表中取出数据，并将这些数据作为行数据插入另一个表中。

例如：从 tb_courses 表中查询所有的记录，并将其插入 tb_courses_new 表中
```SQL
INSERT INTO tb_courses_new (course_id,course_name,course_grade,course_info)
SELECT course_id,course_name,course_grade,course_info FROM tb_courses;
```

插入多行数据
```SQL
INSERT INTO tb_students_info ( name, age, sex, height, course_id )
VALUES
	( 'Dany', 25, '男', 160, 1 ),
	( 'Green', 23, '男', 158, 2 ),
	( 'Henry', 23, '女', 185, 1 ),
	( 'Jane', 22, '男', 162, 3 ),
	( 'Jim', 24, '女', 175, 2 ),
	( 'John', 21, '女', 172, 4 ),
	( 'Lily', 22, '男', 165, 4 ),
	( 'Susan', 23, '男', 170, 5 ),
	( 'Thomas', 22, '女', 178, 5 ),
	( 'Tom', 23, '女', 165, 5 );
```

##### 修改数据

在 MySQL 中，可以使用 UPDATE 语句来修改、更新一个或多个表的数据。

使用 UPDATE 语句修改单个表的语法：
```SQL
UPDATE <表名> SET 字段 1=值 1 [,字段 2=值 2… ] [WHERE 子句 ]
[ORDER BY 子句] [LIMIT 子句]
```
- <表名>：用于指定要更新的表名称。
- SET 子句：用于指定表中要修改的列名及其列值。其中，每个指定的列值可以是表达式，也可以是该列对应的默认值。如果指定的是默认值，可用关键字 DEFAULT 表示列值。
- WHERE 子句：可选项。用于限定表中要修改的行。若不指定，则修改表中所有的行。
- ORDER BY 子句：可选项。用于限定表中的行被修改的次序。
- LIMIT 子句：可选项。用于限定被修改的行数。

示例：
在 tb_courses_new 表中，更新所有行的 course_grade 字段值为 4
```SQL
UPDATE tb_courses_new
SET course_grade=4;
```

在 tb_courses 表中，更新 course_id 值为 2 的记录，将 course_grade 字段值改为 3.5，将 course_name 字段值改为“DB”
```SQL
UPDATE tb_courses_new
SET course_name='DB',course_grade=3.5
WHERE course_id=2;
```

保证 UPDATE 以 WHERE 子句结束，通过 WHERE 子句指定被更新的记录所需要满足的条件，如果忽略 WHERE 子句，MySQL 将更新表中所有的行。

##### 删除数据

在 MySQL 中，可以使用 DELETE 语句来删除表的一行或者多行数据。

使用 DELETE 语句从单个表中删除数据语法格式：
`DELETE FROM <表名> [WHERE 子句] [ORDER BY 子句] [LIMIT 子句]`
- <表名>：指定要删除数据的表名。
- ORDER BY 子句：可选项。表示删除时，表中各行将按照子句中指定的顺序进行删除。
- WHERE 子句：可选项。表示为删除操作限定删除条件，若省略该子句，则代表删除该表中的所有行。
- LIMIT 子句：可选项。用于告知服务器在控制命令被返回到客户端前被删除行的最大值。
- 在不使用 WHERE 条件的时候，将删除所有数据。

删除 tb_courses_new 表中的全部数据
`DELETE FROM tb_courses_new;`

在 tb_courses_new 表中，删除 course_id 为 4 的记录
`DELETE FROM tb_courses WHERE course_id=4;`

##### 清空表记录

关键字 TRUNCATE 用于完全清空一个表。
`TRUNCATE [TABLE] 表名`

示例： `TRUNCATE TABLE tb_student_course;`

TRUNCATE 和 DELETE 的区别

从逻辑上说，TRUNCATE 语句与 DELETE 语句作用相同，但是在某些情况下，两者在使用上有所区别
- DELETE 是 DML 类型的语句；TRUNCATE 是 DDL 类型的语句。它们都用来清空表中的数据。
- DELETE 是逐行一条一条删除记录的；TRUNCATE 则是直接删除原来的表，再重新创建一个一模一样的新表，而不是逐行删除表中的数据，执行数据比 DELETE 快。因此需要删除表中全部的数据行时，尽量使用 TRUNCATE 语句， 可以缩短执行时间。
- DELETE 删除数据后，配合事件回滚可以找回数据；TRUNCATE 不支持事务的回滚，数据删除后无法找回。
- DELETE 删除数据后，系统不会重新设置自增字段的计数器；TRUNCATE 清空表记录后，系统会重新设置自增字段的计数器。
- DELETE 的使用范围更广，因为它可以通过 WHERE 子句指定条件来删除部分数据；而 TRUNCATE 不支持 WHERE 子句，只能删除整体。
- DELETE 会返回删除数据的行数，但是 TRUNCATE 只会返回 0，没有任何意义。

当不需要该表时，用 DROP；当仍要保留该表，但要删除所有记录时，用 TRUNCATE；当要删除部分记录时，用 DELETE。