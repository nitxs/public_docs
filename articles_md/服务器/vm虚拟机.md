使用vm虚拟机安装liunx系统作为服务器

## 虚拟机中ubuntu安装使用

### ubuntu系统版本16.04

虚拟机中安装ubuntu过程简单，略过不提。

系统安装完后，需要将默认的ubuntu小界面改为自适应撑满虚拟机界面大小，需要进行如下配置：

- 1.在虚拟机软件工具栏中点击 “虚拟机(M) - 重新安装VMware Tools”，如果 “重新安装VMware Tools” 项是灰色无法点击，则 在“虚拟机(M) - 设置”中将CD/DVD、CD/DVD2和软盘均设为自动检测。
- 2.点击“重新安装VMware Tools”后，虚拟机会自动启动光驱下载 vmware tool工具包，把WMwareTools(tar包)拷贝到桌面–鼠标选中vmwaretools10.0.6-3595377.tar.gz,点鼠标右键,选”复制到”,鼠标右键点击”桌面”,则压缩包被复制到桌面.进入桌面鼠标选中压缩包,点鼠标右键命令”提取到这里”,即把压缩包解压到桌面。鼠标左键双击vmware-tools-distrib目录,点击鼠标右键命令” 在终端打开”。
- 3.`sudo ./vmware-install.pl`，安装过程选择默认安装直接回车或输入yes/no。安装完毕,重启虚拟机。

修改root密码：
- 输入 `sudo passwd` 命令，然后会提示输入当前用户的密码
- 按enter键，终端会提示输入新的密码并确认，此时的密码就是新的root密码
- 修改完毕以后，在执行su root命令，此时输入新的root密码即可

ubuntu开机后弹出System program problem detected的解决办法：
`sudo gedit /etc/default/apport`   将enabled=1改为enabled=0保存退出重启后就可以

用xshell连接ubuntu系统时，在ubuntu中需要先安装openssh-server，命令为：`sudo apt-get install openssh-server`。

安装nodejs和npm：
需要使用到apt包管理器，先刷新下本地包索引：`sudo apt-get update`
然后从存储库中安装nodejs：`sudo apt-get install nodejs`，检查版本：`node -v`，在写本文档时发现版本是`4.2.6`，想要更新nodejs版本，则安装更新版本的工具N，执行：`sudo npm install n -g`，然后执行更新nodejs版本的操作：`sudo n stable`，然后重启xShell，再执行版本检查，发现已经更新为`12.18.2`。同理，这时也把npm版本更新了，为`6.14.5`
安装npm：`sudo apt-get install npm`，检查版本：`npm -v`



### ubuntu系统版本18.04

虚拟机中安装ubuntu过程简单，略过不提。