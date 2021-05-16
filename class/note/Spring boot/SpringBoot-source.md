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