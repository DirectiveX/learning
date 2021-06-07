Spring boot version 2.4.5

# static  content

[static](https://docs.spring.io/spring-boot/docs/current/reference/html/spring-boot-features.html#boot-features-spring-mvc-static-content)

1.通过官网知道如果要修改的话需要实现WebMvcConfigurer接口并且实现addResourceHandlers方法

2.找到WebMvcConfigurer的addResourceHandlers方法

3.找具体实现类WebMvcAutoConfiguration.WebMvcAutoConfigurationAdapter的addResourceHandlers方法

4.代码如下

```java
@Override
protected void addResourceHandlers(ResourceHandlerRegistry registry) {
			super.addResourceHandlers(registry);
			if (!this.resourceProperties.isAddMappings()) {
				logger.debug("Default resource handling disabled");
				return;
			}
			ServletContext servletContext = getServletContext();
    		//当加载/webjars/**的路径时，默认扫描classpath:/META-INF/resources/webjars/下的内容
			addResourceHandler(registry, "/webjars/**", "classpath:/META-INF/resources/webjars/");
			addResourceHandler(registry, this.mvcProperties.getStaticPathPattern(), (registration) -> {
				registration.addResourceLocations(this.resourceProperties.getStaticLocations());
				if (servletContext != null) {
					registration.addResourceLocations(new ServletContextResource(servletContext, SERVLET_LOCATION));
				}
			});
		}
```

5.逐行分析

```java
			if (!this.resourceProperties.isAddMappings()) {
				logger.debug("Default resource handling disabled");
				return;
			}
```

先判断是否不需要启动默认配置

```java
/**
 * Whether to enable default resource handling.
 */
private boolean addMappings = true
```

具体配置在

```java
@ConfigurationProperties(prefix = "spring.resources", ignoreUnknownFields = false)
public class ResourceProperties extends Resources {
	@Override
	@DeprecatedConfigurationProperty(replacement = "spring.web.resources.add-mappings")
	public boolean isAddMappings() {
		return super.isAddMappings();
	}
}
```

6.this.mvcProperties.getStaticPathPattern()可以看到关键是通过这句去找对应的匹配项，看看里面具体是什么

```java
/**
 * Path pattern used for static resources.
 */
private String staticPathPattern = "/**";
```

可以知道如果加载的静态资源路径除了上面的情况，其余都会匹配到当前情况，而第三个参数就是具体的物理路径，点进去看一下，主要语句为

```java
registration.addResourceLocations(this.resourceProperties.getStaticLocations());
```

7.this.resourceProperties.getStaticLocations()查看具体的值

```java
private static final String[] CLASSPATH_RESOURCE_LOCATIONS = { "classpath:/META-INF/resources/",
      "classpath:/resources/", "classpath:/static/", "classpath:/public/" };

/**
 * Locations of static resources. Defaults to classpath:[/META-INF/resources/,
 * /resources/, /static/, /public/].
 */
private String[] staticLocations = CLASSPATH_RESOURCE_LOCATIONS;
```

可以看到是从类路径下/META-INF/resources/,/resources/, /static/, /public/取的，同名优先级从高到低

# welcome page
[welcome page](https://docs.spring.io/spring-boot/docs/current/reference/html/spring-boot-features.html#boot-features-spring-mvc-welcome-page)
会去静态目录下找index模板

WebMvcAutoConfiguration 下面具体实现

```java
//加了一个handlerMapping
		@Bean
		public WelcomePageHandlerMapping welcomePageHandlerMapping(ApplicationContext applicationContext,
				FormattingConversionService mvcConversionService, ResourceUrlProvider mvcResourceUrlProvider) {
			WelcomePageHandlerMapping welcomePageHandlerMapping = new WelcomePageHandlerMapping(
					new TemplateAvailabilityProviders(applicationContext), applicationContext, getWelcomePage(),
					this.mvcProperties.getStaticPathPattern());
			welcomePageHandlerMapping.setInterceptors(getInterceptors(mvcConversionService, mvcResourceUrlProvider));
			welcomePageHandlerMapping.setCorsConfigurations(getCorsConfigurations());
			return welcomePageHandlerMapping;
		}
//去静态目录下找index模板
private Resource getWelcomePage() {
   for (String location : this.resourceProperties.getStaticLocations()) {
      Resource indexHtml = getIndexHtml(location);
      if (indexHtml != null) {
         return indexHtml;
      }
   }
   ServletContext servletContext = getServletContext();
   if (servletContext != null) {
      return getIndexHtml(new ServletContextResource(servletContext, SERVLET_LOCATION));
   }
   return null;
}
//真正找的方法
		private Resource getIndexHtml(String location) {
			return getIndexHtml(this.resourceLoader.getResource(location));
		}

		private Resource getIndexHtml(Resource location) {
			try {
				Resource resource = location.createRelative("index.html");
				if (resource.exists() && (resource.getURL() != null)) {
					return resource;
				}
			}
			catch (Exception ex) {
			}
			return null;
		}
```
WelcomePageHandlerMapping的具体实现，将/请求转发到index.html上
```java
WelcomePageHandlerMapping(TemplateAvailabilityProviders templateAvailabilityProviders,
      ApplicationContext applicationContext, Resource welcomePage, String staticPathPattern) {
   if (welcomePage != null && "/**".equals(staticPathPattern)) {
      logger.info("Adding welcome page: " + welcomePage);
      setRootViewName("forward:index.html");
   }
   else if (welcomeTemplateExists(templateAvailabilityProviders, applicationContext)) {
      logger.info("Adding welcome page template: index");
      setRootViewName("index");
   }
}
```

# 注解学习

**@DeprecatedConfigurationProperty**
标明在@ConfigurationProperties注解中的getter方法已经弃用，这个注释对实际的绑定过程没有影响，必须注释在getter方法上，但是在使用配置类时会有提示功能

```yaml
spring:
  resources:
    add-mappings: false（这里会有删除线的效果）
  web:
    resources:
      add-mappings: false
```

# Spring Boot 启动流程

1.开始的时候先new了一个SpringApplication对象，new对象的时候做了一些操作

①根据当前类判断当前应用类型

②从spring.factories文件中根据类全名key获取引导注册初始化器实例

③从spring.factories文件中根据类全名key获取初始化器实例

④从spring.factories文件中根据类全名key获取监听器实例

⑤将当前主类名存入到Application对象中

2.new完对象之后运行对象的run方法

3.创建一个计时器，开始计时

4.使用引导注册初始化器创建引导上下文

5.从spring.factories文件中根据类全名key获取运行时监听器PublishEventRunListener并执行starting方法，通过doWithListeners向所有监听器广播starting事件

6.将传入的命令行参数根据--key=value的形式进行解析封装成ApplicationArguments对象

7.准备环境对象，里面做了一些步骤

①根据当前应用类型创建或获取环境

②配置环境

③触发PublishEventRunListener的广播方法，广播环境创建的事件

8.打印banner，从对应目录下找是否有banner.png,banner.gif,banner.jpg的文件，如果有，就进行该文件的打印，如果没有，继续找是否有banner.txt的文件，如果有，打印，最后如果都找不到，打印默认的

9.根据当前应用类型创建上下文，创建的时候创建了两个用来扫描注解的对象reader和scanner，然后父类还创建了DefaultListableBeanFactory对象

10.准备上下文

①执行初始化器的初始化方法

②触发PublishEventRunListener的广播方法，广播环境准备上下文的事件

③关闭引导上下文

④load方法将当前主类加载放到context中

⑤触发PublishEventRunListener的广播方法，广播上下文加载完毕的事件

11.刷新上下文，里面执行了spring中的刷新方法，并且嵌入了tomcat的创建和启动流程，还嵌入了自动装配的流程

12.afterRefresh，空实现，扩展方法

13.停止计时器，进行用时的打印

14.触发PublishEventRunListener的广播方法，广播started的事件

15.触发PublishEventRunListener的广播方法，广播running的事件

# Spring boot自动装配

1.先进行new SpringApplication，执行它的run方法

2.run方法中会调用createContext方法，里面创建的时候context中有个属性叫BeanDefinationMap，会向里面放一个ConfigureClassPostProcessor对象，在后续的自动装配的时候会使用到

3.run方法中会调用preContext方法，会在BeanDefinationMap里面放一个当前主类对象，在后续的自动装配的时候会使用到

4.会调用refreshContext方法，在这个方法里真正完成了自动装配

5.refreshContext方法会调用父类的refresh方法，里面会调用到invokeBeanFactoryPostProcessor方法，然后再调用invokeBeanDefinationPostProcessor方法，在这个方法里，会取出ConfigurationClassPostProcessor对当前应用的主类进行解析

6.主要的解析过程是解析主类头上的注解，进行一个递归解析，找到里面的@import注解标识的类，最终会找到一个名为AutoConfigurationImportSelector的一个类，调用getImports方法会调用到这个类中的getCandidates方法，会去spring.factories下面找一个key为EnableConfiguration的一组数据，找到了一组类全名，依次判断这些类全名是否满足自动装配的条件，判断依据是这些类上面的Conditional注解和当前主类排除了一些具体的类，最后将留下的类依次实例化，完成自动装配

# Spring boot 内置tomcat启动

1.先进行new SpringApplication，执行它的run方法

2.会调用refreshContext方法，在这个方法里完成了内置tomcat启动

3.refreshContext方法会调用父类的rerfresh方法,在父类onRefresh方法中进行了内置tomcat的创建

①createWebServer方法创建

②创建时候按照tomcat的组件依次创建

ps：组件为service，connector，engine，host，context

③调用getTomcatWebServer方法进行初始化，通过嵌套调用initInternal()走过一小轮生命周期，直到所有组件到达INITIALIZED这个状态，然后嵌套调用startInternal()直到所有组件变成STARTED状态

ps：状态迁移 NEW->INITIALIZING->INITIALIZED，然后STARTING_PREP->STARTING->STARTED

ps：LifecycleMBeanBase子类：StandardServer，StandardService，StandardEngine（会获取server.xml的配置文件），MapperListener，Connector

4.refreshContext方法会调用父类的rerfresh方法,在父类finishRefresh方法中进行了内置tomcat的启动，调用了lifeCycleProcessor的doStart方法，最终会调到TomcatWebServer的start方法进行启动

