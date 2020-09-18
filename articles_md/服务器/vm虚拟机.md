使用vm虚拟机安装liunx系统作为服务器

## 虚拟机中ubuntu安装使用

### ubuntu系统版本16.04

虚拟机中安装ubuntu过程简单，略过不提。

系统安装完后，需要将默认的ubuntu小界面改为自适应撑满虚拟机界面大小，需要进行如下配置：

- 1.在虚拟机软件工具栏中点击 “虚拟机(M) - 重新安装VMware Tools”，如果 “重新安装VMware Tools” 项是灰色无法点击，则 在“虚拟机(M) - 设置”中将CD/DVD、CD/DVD2和软盘均设为自动检测。
- 2.点击“重新安装VMware Tools”后，虚拟机会自动启动光驱下载 vmware tool工具包，把WMwareTools(tar包)拷贝到桌面–鼠标选中vmwaretools10.0.6-3595377.tar.gz,点鼠标右键,选”复制到”,鼠标右键点击”桌面”,则压缩包被复制到桌面.进入桌面鼠标选中压缩包,点鼠标右键命令”提取到这里”,即把压缩包解压到桌面。鼠标左键双击vmware-tools-distrib目录,点击鼠标右键命令” 在终端打开”。
- 3.`sudo ./vmware-install.pl`，安装过程选择默认安装直接回车或输入yes/no。安装完毕,重启虚拟机。

#### 修改root密码：
- 输入 `sudo passwd` 命令，然后会提示输入当前用户的密码
- 按enter键，终端会提示输入新的密码并确认，此时的密码就是新的root密码
- 修改完毕以后，在执行su root命令，此时输入新的root密码即可

#### ubuntu开机后弹出System program problem detected的解决办法：
`sudo gedit /etc/default/apport`   将enabled=1改为enabled=0保存退出重启后就可以

#### 用xshell连接ubuntu系统时，在ubuntu中需要先安装openssh-server
命令为：`sudo apt-get install openssh-server`。
https://www.jianshu.com/p/1b1e56a2ec4f

#### 安装nodejs和npm

方法一(APT方式，即用Ubuntu的软件包管理工具安装)：
需要使用到apt包管理器，先刷新下本地包索引：`sudo apt-get update`
然后从存储库中安装nodejs：`sudo apt-get install nodejs`，检查版本：`node -v`，在写本文档时发现版本是`4.2.6`，想要更新nodejs版本，则安装更新版本的工具N，执行：`sudo npm install n -g`，然后执行更新nodejs版本的操作：`sudo n stable`，然后重启xShell，再执行版本检查，发现已经更新为`12.18.2`。同理，这时也把npm版本更新了，为`6.14.5`
安装npm：`sudo apt-get install npm`，检查版本：`npm -v`

方法二(二进制安装)：
```bash
# 一：下载想要的版本包
# 下载nodejs安装包
nitx@ubuntu:~$ wget https://nodejs.org/dist/v12.18.2/node-v12.18.2-linux-x64.tar.xz

# 解压安装包
nitx@ubuntu:~$ tar -xf node-v12.18.2-linux-x64.tar.xz

# 进入解压后nodejs目录中
nitx@ubuntu:~$ cd node-v12.18.2-linux-x64/

# 查看下载的nodejs版本
nitx@ubuntu:~/node-v12.18.2-linux-x64$ ./bin/node -v
v12.18.2

# 二：创建软连接 可以在任意路径下执行npm和node
# 注意：在创建软连接的时候要写 绝对路径,软连接到/usr/local/bin/
nitx@ubuntu:~$ sudo ln -s /home/nitx/node-v12.18.2-linux-x64/bin/node /usr/local/bin
nitx@ubuntu:~$ sudo ln -s /home/nitx/node-v12.18.2-linux-x64/bin/npm /usr/local/bin

# 这样就node和npm就可以全局使用了。
nitx@ubuntu:~$ node -v
v12.18.2
nitx@ubuntu:~$ npm -v
6.14.5

# 如果你在创建软连的时候，出现npm已经存在,node 已经存在
# 可以删除 /usr/local/bin/目录下的node，npm，然后再创建软链接就行了
nitx@ubuntu:~$ sudo rm -rf /usr/local/bin/node
nitx@ubuntu:~$ sudo rm -rf /usr/local/bin/npm


# 安装pm2 
nitx@ubuntu:~$ npm install pm2 -g

# 建立pm2软连接
nitx@ubuntu:~$ sudo ln -s /home/nitx/node-v12.18.2-linux-x64/bin/pm2 /usr/local/bin

# pm2启动nodejs项目
pm2 start app.js

# 在集群模式下启动4个应用实例，自动分配请求给每个实例，实现负载均衡
pm2 start app.js -i 4

# 列出所有已启动的进程（应用实例）
pm2 list/ls

# 显示所有应用实例的日志信息
pm2 logs

#  显示指定应用实例的日志信息
pm2 logs [app-name]

#  日志信息以JSON格式显示  (比较喜欢用这个形式显示日志)
pm2 logs --json

#  清除所有的l日志信息
pm2 flush

#  重载所有的日志信息
pm2 reloadLogs

# pm2 的日志文件在  /home/nitx/.pm2/logs 里面，分别在两个文件中 (app-error.log 和  app-out.log)
```

#### 安装mysql
```bash
sudo apt-get install mysql-server
sudo apt install mysql-client
sudo apt install libmysqlclient-dev

# 安装成功后可以通过下面的命令测试是否安装成功：
sudo netstat -tap | grep mysql

# 可以通过如下命令进入mysql服务：
mysql -uroot -p你的密码

# 现在设置mysql允许远程访问，首先编辑文件/etc/mysql/mysql.conf.d/mysqld.cnf：
sudo vi /etc/mysql/mysql.conf.d/mysqld.cnf
# 注释掉bind-address = 127.0.0.1
# 保存退出，然后进入mysql服务，执行授权命令
grant all on *.* to root@'%' identified by '你的密码' with grant option;
flush privileges;

# 然后执行quit命令退出mysql服务，执行如下命令重启mysql：
service mysql restart

# 现在在windows下可以使用navicat远程连接ubuntu下的mysql服务。
```



#### 在liunx中nodejs项目该放哪个目录
Linux 的软件安装目录是也是有讲究的，理解这一点，在对系统管理是有益的

/usr：系统级的目录，可以理解为C:/Windows/，/usr/lib理解为C:/Windows/System32。
/usr/local：用户级的程序目录，可以理解为C:/Progrem Files/。用户自己编译的软件默认会安装到这个目录下。
/opt：用户级的程序目录，可以理解为D:/Software，opt有可选的意思，这里可以用于放置第三方大型软件（或游戏），当你不需要时，直接rm -rf掉即可。在硬盘容量不够时，也可将/opt单独挂载到其他磁盘上使用。

源码放哪里？
/usr/src：系统级的源码目录。
/usr/local/src：用户级的源码目录。

/opt
这里主要存放那些可选的程序。你想尝试最新的firefox测试版吗?那就装到/opt目录下吧，这样，当你尝试完，想删掉firefox的时候，你就可 以直接删除它，而不影响系统其他任何设置。安装到/opt目录下的程序，它所有的数据、库文件等等都是放在同个目录下面。
举个例子：刚才装的测试版firefox，就可以装到/opt/firefox_beta目录下，/opt/firefox_beta目录下面就包含了运 行firefox所需要的所有文件、库、数据等等。要删除firefox的时候，你只需删除/opt/firefox_beta目录即可，非常简单。

/usr/local
这里主要存放那些手动安装的软件，即不是通过“新立得”或apt-get安装的软件。它和/usr目录具有相类似的目录结构。让软件包管理器来管理/usr目录，而把自定义的脚本(scripts)放到/usr/local目录下面，我想这应该是个不错的主意。

所以可以将自己写的nodejs服务端项目放在 /usr/local/src 中。

注意，当要将本地项目通过xftp上传到liunx的/usr/local/src目录中时，需要修改src文件夹权限才能上传成功。
```bash
root@ubuntu:/usr/local# chmod 777 src/
root@ubuntu:/usr/local# ll
# 此时的打印信息可以看到(其他略)
drwxrwxrwx  2 root root 4096 Apr 21  2016 src/
```

#### apt-get命令
apt-get 命令是 Ubuntu 系统中的包管理工具，可以用来安装、卸载包，也可以用来升级包，还可以用来把系统升级到新的版本。

测试环境为 Ubuntu 16.04

apt-get 默认的配置文件被分隔后放在 /etc/apt/apt.conf.d 目录下。

```bash
-h, --help              // 查看帮助文档
-v, --version           // 查看 apt-get 的版本
-y                      // 在需要确认的场景中回应 yes
-s, --dry-run           // 模拟执行并输出结果
-d, --download-only     // 把包下载到缓存中而不安装
--only-upgrade          // 更新当前版本的包而不是安装新的版本
--no-upgrade            // 在执行 install 命令时，不安装已安装包的更新
-q, --quiet             // 减少输出
--purge                 // 配合 remove 命令删除包的配置文件
--reinstall             // 重新安装已安装的包或其新版本
```

常用子命令：
- update  用于重新同步包索引文件，/etc/apt/sources.list 文件中的配置指定了包索引文件的来源。更新了包索引文件后就可以得到可用的包的更新信息和新的包信息。这样我们本地就有了这样的信息：有哪些软件的哪些版本可以从什么地方(源)安装。update 命令应该总是在安装或升级包之前执行。
- install 用来安装或者升级包，配置文件 /etc/apt/sources.list 中包含了用于获取包的源(服务器)。install 命令还可以用来更新指定的包。
- upgrade 用于从 /etc/apt/sources.list 中列出的源安装系统上当前安装的所有包的最新版本。在任何情况下，当前安装的软件包都不会被删除，尚未安装的软件包也不会被检索和安装。如果当前安装的包的新版本不能在不更改另一个包的安装状态的情况下升级，则将保留当前版本。必须提前执行 update 命令以便 apt-get 知道已安装的包是否有新版本可用。注意 update 与 upgrade 的区别：update 是更新软件列表，upgrade 是更新软件
- dist-upgrade 除执行升级功能外，dist-upgrade 还智能地处理与新版本包的依赖关系的变化。apt-get 有一个 "智能" 的冲突解决系统，如果有必要，它将尝试升级最重要的包，以牺牲不那么重要的包为代价。因此，distr -upgrade 命令可能会删除一些包。因此在更新系统中的包时，建议按顺序执行下面的命令：
  - $ apt-get update
  - $ apt-get upgrade -y
  - $ apt-get dis-upgrade -y
- remove  与 install 类似，不同之处是删除包而不是安装包。注意，使用 remove 命令删除一个包会将其配置文件留在系统上
- purge  与 remove 命令类似，purge 命令在删除包的同时也删除了包的配置文件
- autoremove  用于删除自动安装的软件包，这些软件包当初是为了满足其他软件包对它的依赖关系而安装的，而现在已经不再需要了
- download  把指定包的二进制文件下载到当前目录中。注意，是类似 *.deb 这样的包文件
- clean  清除在本地库中检索到的包。它从 /var/cache/apt/archives/ 和 /var/cache/apt/archives/partial/ 目录删除除锁文件之外的所有内容
- autoclean  与 clean 命令类似，autoclean 命令清除检索到的包文件的本地存储库。不同之处在于，它只删除不能再下载的软件包文件，而且这些文件在很大程度上是无用的。这允许长时间维护缓存，而不至于大小失控
- source  用于下载包的源代码。默认会下载最新可用版本的源代码到当前目录中
- changelog  尝试下载并显示包的更新日志

在需要确认的场景中回应 yes：多数包在安装前都需要与用户交互，在用户确认后才继续安装。而在自动化的任务中是没办法与用户交互的。-y 选项可以在这样的场景中发挥作用，其效果就像是用户确认了安装操作一样，例如：`$ sudo apt-get install -y nginx`

安装系统中有更新的包：
```bash
$ sudo apt-get update
$ sudo apt-get upgrade -y
$ sudo apt-get dis-upgrade -y
```

重新安装已安装的包：`$ sudo apt-get install --reinstall curl`,即为 install 命令添加 --reinstall 选项即可。如果已安装的包有了更新或新版本，也可以用这个方法把包升级到最新的版本。

更新指定的包：`$ sudo apt-get install vim`

检查某个包的版本，通过下面的命令可以查看已安装包或即将安装包的版本： `$ sudo apt-get -s install vim`

其他apt-get使用命令介绍可以看[这里](https://www.cnblogs.com/sparkdev/p/11339231.html)

### ubuntu系统版本18.04

虚拟机中安装ubuntu过程简单，略过不提。

进来后要安装东西，可以使用 `sudo apt-get update`  `sudo apt-get install net-tools`

### centos7系统

当本地windows中使用xSHell连接centose服务器提示失败时，检查CentOS7是否安装了openssh-server`yum list installed | grep openssh-server`

没有安装则执行：`yum install openssh-server`

如果已安装：找到/etc/ssh/目录下的sshd服务配置文件 sshd_config，用Vim编辑器打开
取消注释（去掉#）Post 22、PermitRootLogin（开启远程登陆） PasswordAuthentication（开启使用密码作为连接远征）
`vim /etc/ssh/sshd_config`

运行sshd服务
`service sshd start`

设置开机启动
`systemctl enable sshd.service`
