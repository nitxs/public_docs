REM 切到mongodb安装目录，
cd D:\MongoDB\Server\4.2\bin
REM 启动mongodb，其中F:\data是我的数据存放目录，如果该目录放在默认位置C:\data时，则只需执行mongod命令即可。
mongod --dbpath F:\data