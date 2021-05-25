## RestTemplate

### 依赖注入

```
	@Bean
	// 开启负载均衡
	@LoadBalanced
	RestTemplate restTemplate() {
		return new RestTemplate();
	}
```

接下来便可以使用资源地址调用服务

```
String url ="http://provider/getHi";
String respStr = restTemplate.getForObject(url, String.class);
		
```

### get 请求处理

#### getForEntity

getForEntity方法的返回值是一个ResponseEntity，ResponseEntity是Spring对HTTP请求响应的封装，包括了几个重要的元素，如响应码、contentType、contentLength、响应消息体等。

```
<200,Hi,[Content-Type:"text/plain;charset=UTF-8", Content-Length:"8", Date:"Fri, 10 Apr 2020 09:58:44 GMT", Keep-Alive:"timeout=60", Connection:"keep-alive"]>
```

#### 返回一个Map

**调用方**

```
		String url ="http://provider/getMap";
		   
		ResponseEntity<Map> entity = restTemplate.getForEntity(url, Map.class);
		   
		System.out.println("respStr: "  + entity.getBody() );
```

**生产方**

```
	@GetMapping("/getMap")
	public Map<String, String> getMap() {
		
		HashMap<String, String> map = new HashMap<>();
		map.put("name", "500");
		return map; 
	}
```

#### 返回对象

**调用方**

```
		ResponseEntity<Person> entity = restTemplate.getForEntity(url, Person.class);
		   
		System.out.println("respStr: "  + ToStringBuilder.reflectionToString(entity.getBody() ));
```

**生产方**

```
	@GetMapping("/getObj")
	public Person getObj() {


		Person person = new Person();
		person.setId(100);
		person.setName("xiaoming");
		return person; 
	}
```

**Person类**

```
	private int id;
	private String name;
```

#### 传参调用

**使用占位符**

```
	String url ="http://provider/getObjParam?name={1}";
	   
	ResponseEntity<Person> entity = restTemplate.getForEntity(url, Person.class,"hehehe...");
```

**使用map**

```
		String url ="http://provider/getObjParam?name={name}";
		   
		Map<String, String> map = Collections.singletonMap("name", " memeda");
		ResponseEntity<Person> entity = restTemplate.getForEntity(url, Person.class,map);
```

#### 返回对象

```
Person person = restTemplate.getForObject(url, Person.class,map);
```

### post 请求处理

**调用方**

```
		String url ="http://provider/postParam";
		   
		Map<String, String> map = Collections.singletonMap("name", " memeda");
		 ResponseEntity<Person> entity = restTemplate.postForEntity(url, map, Person.class);
```

**生产方**

```
	@PostMapping("/postParam")
	public Person postParam(@RequestBody String name) {

		System.out.println("name:" + name);

		Person person = new Person();
		person.setId(100);
		person.setName("xiaoming" + name);
		return person; 
	}
```

### postForLocation

**调用方**

```
		String url ="http://provider/postParam";
		   
		Map<String, String> map = Collections.singletonMap("name", " memeda");
		URI location = restTemplate.postForLocation(url, map, Person.class);
		
		System.out.println(location);
```

**生产方**

需要设置头信息，不然返回的是null

```
	public URI postParam(@RequestBody Person person,HttpServletResponse response) throws Exception {

	URI uri = new URI("https://www.baidu.com/s?wd="+person.getName());
	response.addHeader("Location", uri.toString());
```

### exchange

可以自定义http请求的头信息，同时保护get和post方法

### 拦截器

需要实现`ClientHttpRequestInterceptor`接口

**拦截器**

```
public class LoggingClientHttpRequestInterceptor implements ClientHttpRequestInterceptor {

	@Override
	public ClientHttpResponse intercept(HttpRequest request, byte[] body, ClientHttpRequestExecution execution)
			throws IOException {

		System.out.println("拦截啦！！！");
		System.out.println(request.getURI());

		ClientHttpResponse response = execution.execute(request, body);

		System.out.println(response.getHeaders());
		return response;
	}
```

添加到resttemplate中

```
	@Bean
	@LoadBalanced
	RestTemplate restTemplate() {
		RestTemplate restTemplate = new RestTemplate();
		restTemplate.getInterceptors().add(new LoggingClientHttpRequestInterceptor());
		return restTemplate;
	}
```