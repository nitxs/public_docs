Nginx发音为“ engine x”，是一种免费的开源高性能HTTP和反向代理服务器，负责处理Internet上一些最大站点的负载。

Nginx可以用作独立的Web服务器，也可以用作 Apache 和其他Web服务器的反向代理。

与Apache相比，Nginx可以处理大量并发连接，并且每个连接的内存占用量较小。

本教程将概述在Ubuntu 18.04计算机上安装Nginx所需的步骤。

## 先决条件
在开始学习本教程之前，请确保您以位具有sudo特权的用户身份登录，并且没有在端口80或443上运行Apache或任何其他Web服务器。

## 安装Nginx
Nginx软件包在默认的Ubuntu存储库中可用。安装非常简单。

我们将首先更新软件包列表，然后安装Nginx：
```
sudo apt update
sudo apt install nginx
```

安装完成后，Nginx服务将自动启动。您可以使用以下命令检查服务的状态：
`sudo systemctl status nginx`
输出将如下所示：
```
● nginx.service - A high performance web server and a reverse proxy server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2018-04-29 06:43:26 UTC; 8s ago
     Docs: man:nginx(8)
  Process: 3091 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
  Process: 3080 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
 Main PID: 3095 (nginx)
    Tasks: 2 (limit: 507)
   CGroup: /system.slice/nginx.service
           ├─3095 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
           └─3097 nginx: worker process
```

## 配置防火墙
假设您正在使用 UFW 管理防火墙，则需要打开HTTP（80）和HTTPS（443）端口。为此，您可以启用“ Nginx Full”配置文件，其中包括两个端口的规则：

`sudo ufw allow 'Nginx Full'`

要验证状态类型：

`sudo ufw status`

输出将类似于以下内容：

```
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
Nginx Full                 ALLOW       Anywhere
22/tcp (v6)                ALLOW       Anywhere (v6)
Nginx Full (v6)            ALLOW       Anywhere (v6)
```

## 测试安装
您可以在选择的浏览器中测试打开的新Nginx安装http://YOUR_IP，然后会看到默认的Nginx登陆页面，如下图所示：

## 管理Nginx服务
您可以以与其他任何systemd服务相同的方式管理Nginx服务。

要停止Nginx服务，请运行：
`sudo systemctl stop nginx`

要重新启动，请键入：
`sudo systemctl start nginx`

重新启动Nginx服务：
`sudo systemctl restart nginx`

进行一些配置更改后，重新加载Nginx服务：
`sudo systemctl reload nginx`

默认情况下，Nginx服务将在启动时启动。如果要禁用Nginx服务以在启动时启动：
`sudo systemctl disable nginx`

并重新启用：
`sudo systemctl enable nginx`

Nginx配置文件的结构和最佳做法

- 所有Nginx配置文件都位于/etc/nginx目录中。
- 主要的Nginx配置文件为/etc/nginx/nginx.conf。
- 为使Nginx配置更易于维护，建议为每个域创建一个单独的配置文件。您可以根据需要拥有任意数量的服务器块文件。
- Nginx服务器块文件存储在/etc/nginx/sites-available目录中。除非它们链接到/etc/nginx/sites-enabled目录，否则Nginx不会使用此目录中找到的配置文件。
- 要激活服务器块，您需要从以下目录中的配置文件站点创建符号链接（指针）将sites-available目录移到sites-enabled目录。
- 建议遵循标准命名约定，例如，如果您的域名是mydomain.com，则您的配置文件应命名为/etc/nginx/sites-available/mydomain.com.conf  ]
- /etc/nginx/snippets目录包含可包含在服务器块文件中的配置片段。如果使用可重复的配置段，则可以将这些段重构为片段，并将片段文件包括到服务器块中。
- Nginx日志文件（access.log和error.log）位于/var/log/nginx目录中。建议每个服务器块使用不同的access和error日志文件。
- 您可以将域文档根目录设置为所需的任何位置。 Webroot的最常见位置包括：
- `/home/<user_name>/<site_name>`
- `/var/www/<site_name>`
- `/var/www/html/<site_name>`
- `/opt/<site_name>`

[参考](https://www.myfreax.com/how-to-install-nginx-on-ubuntu-18-04/)