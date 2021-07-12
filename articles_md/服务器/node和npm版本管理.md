
## 自用
自用项目的nodejs版本基本都是新的，所以无所谓。

## 买钢乐
mgl项目所用的nodejs版本是8.11.3，npm版本是5.6.0。

比如平时不需要安装mgl的source项目时，可以使用nodejs和npm的新版本。

如果要安装mgl的source项目时，需要将nodejs版本降到8.11.3，npm的版本降到5.6.0。
```
# 使用nvm切换node版本
nvm use 8.11.3 

# 重新安装npm版本
npm install -g npm@5.6.0
```

node.js和npm版本对应的官网参考：https://nodejs.org/zh-cn/download/releases/