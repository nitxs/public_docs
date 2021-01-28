
### 初始化maven java项目
1、eclipse创建maven项目

`File - New - Other - Maven - Maven Project - (默认配置)Next - maven-archetype-webapp 1.0 - (填写art id) - 自动生成`

标准的maven工程目录如下：
``` java
spring-web-mvc
├── pom.xml
└── src
    └── main
        ├── java    // 编写的java代码
        │   └── com
        │       └── itranswarp
        │           └── learnjava
        │               ├── AppConfig.java
        │               ├── DatabaseInitializer.java
        │               ├── entity  // java bean
        │               │   └── Index.java
        │               ├── service     // controller控制器类中需要实现的业务逻辑
        │               │   └── IndexService.java
        │               └── web     // 控制器
        │                   └── IndexController.java
        ├── resources    // 存放的是Java程序读取的classpath资源文件，除了JDBC的配置文件jdbc.properties
        │   ├── jdbc.properties
        │   └── logback.xml
        └── webapp  // 标准web目录
            ├── WEB-INF     // 专门存放web.xml 、编译的class 、 第三方jar 、不允许浏览器直接访问的 前端view模板 、前端静态文件夹
            │   ├── templates
            │   │   ├── index.html
            │   │   ├── login.html
            │   │   ├── register.html
            │   └── web.xmls
            └── static
                ├── css
                │   └── bootstrap.css
                └── js
                    └── jquery.js
```

2、pom中引入依赖

``` XML
<!-- spring -->
org.springframework:spring-context:5.2.0.RELEASE
org.springframework:spring-webmvc:5.2.0.RELEASE
org.springframework:spring-jdbc:5.2.0.RELEASE

<!-- 注解 -->
javax.annotation:javax.annotation-api:1.3.2

<!-- JDBC依赖 -->
com.zaxxer:HikariCP:3.4.2
org.hsqldb:hsqldb:2.5.0

<!-- 集成Pebble模板引擎 -->
io.pebbletemplates:pebble-spring5:3.1.2

<!-- 嵌入式Tomcat -->
org.apache.tomcat.embed:tomcat-embed-core:9.0.26
org.apache.tomcat.embed:tomcat-embed-jasper:9.0.26
```

3、配置`web.xml`

```XML
<?xml version="1.0" encoding="UTF-8"?>
<web-app version="2.4" xmlns="http://java.sun.com/xml/ns/j2ee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee
http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd">

    <display-name>Archetype Created Web Application</display-name>

    <!-- 部署 DispatcherServlet -->
    <servlet>
        <servlet-name>dispatcher</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <!-- 初始化参数contextClass指定使用注解配置的AnnotationConfigWebApplicationContext，配置文件的位置参数contextConfigLocation指向AppConfig的完整类名 -->
        <param-name>contextClass</param-name>
            <param-value>org.springframework.web.context.support.AnnotationConfigWebApplicationContext</param-value>
        </init-param>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>com.itranswarp.learnjava.AppConfig</param-value>
        </init-param>
        <!-- 表示Spring Ioc容器在启动时立即加载DispatcherServlet，而不是等到等到调用时再判断是调用DispatcherServlet还是Servlet -->
        <load-on-startup>1</load-on-startup>
    </servlet>

    <servlet-mapping>
        <servlet-name>dispatcher</servlet-name>
        <!-- 处理所有URL -->
        <url-pattern>/*</url-pattern>
    </servlet-mapping>
</web-app>
```

上述配置可以看作一个样板配置，有了这个配置，`Servlet`容器会首先初始化`Spring MVC`的`DispatcherServlet`，在`DispatcherServlet`启动时，它根据配置`AppConfig`创建了一个类型是`WebApplicationContext`的IoC容器，完成所有Bean的初始化，并将容器绑到`ServletContext`上。

因为`DispatcherServlet`持有IoC容器，能从IoC容器中获取所有`@Controller`的Bean，因此，`DispatcherServlet`接收到所有HTTP请求后，根据`Controller`方法配置的路径，就可以正确地把请求转发到指定方法，并根据返回的`ModelAndView`决定如何渲染页面。

最后，我们在AppConfig中通过main()方法启动嵌入式Tomcat

```java
package com.itranswarp.learnjava;

// 此处类import略

@Configuration
@ComponentScan
@EnableWebMvc // 启用Spring MVC
public class AppConfig {
	
	public static void main(String[] args) throws Exception {
		Tomcat tomcat = new Tomcat();
		tomcat.setPort(Integer.getInteger("port", 8089));
		tomcat.getConnector();
		Context ctx = tomcat.addWebapp("", new File("src/main/webapp").getAbsolutePath());
		WebResourceRoot resources = new StandardRoot(ctx);
		resources.addPreResources(
				new DirResourceSet(resources, "/WEB-INF/classes", new File("target/classes").getAbsolutePath(), "/"));
		ctx.setResources(resources);
		tomcat.start();
		tomcat.getServer().await();
	}
	
	// -- Mvc configuration ---------------------------------------------------

	@Bean
	WebMvcConfigurer createWebMvcConfigurer() {
		return new WebMvcConfigurer() {
			public void addResourceHandlers(ResourceHandlerRegistry registry) {
				registry.addResourceHandler("/static/**").addResourceLocations("/static/");
			}
		};
	}
	
	// -- pebble view configuration -------------------------------------------
	
	@Bean
	ViewResolver createViewResolver(@Autowired ServletContext servletContext) {
	    PebbleEngine engine = new PebbleEngine.Builder().autoEscaping(true)
	            .cacheActive(false)
	            .loader(new ServletLoader(servletContext))
	            .extension(new SpringExtension())
	            .build();
	    PebbleViewResolver viewResolver = new PebbleViewResolver();
	    viewResolver.setPrefix("/WEB-INF/templates/");
	    viewResolver.setSuffix("");
	    viewResolver.setPebbleEngine(engine);
	    return viewResolver;
	}
}
```

4、接下来就可以写Controller等业务代码。

