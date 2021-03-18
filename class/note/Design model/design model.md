# 设计模式
## 单例模式
永远只有一个实例
1.先把构造方法做成私有
2.提供getInstance方法

### 饿汉式
无论是否使用都会在类加载时把实例对象放入内存，占用一点空间
```java
public class Hungry{
    private static final Hungry hungry = new Hungry();

    private Hungry(){};

    public static Hungry getInstance() {
        return hungry;
    }
}
```
### 懒汉式
多线程访问有影响，可能new多个实例，需要加锁，双重检查,volatile防止JIT重排序造成的影响
```java
public class Lazy {
    private static volatile Lazy lazy;

    private Lazy(){};

    public static Lazy getInstance(){
        if(lazy == null){
            synchronized (Lazy.class){
                if(lazy == null){
                    lazy = new Lazy();
                }
            }
        }

        return lazy;
    }
}
```
### 完美写法
#### 静态内部类
由于虚拟机加载类永远只会加载一次，所以内部类总是被加载一次，内部类的常量也就只会有一个
```java
public class InnerClass {
    private static InnerClass innerClass;

    private static class A{
        private static final InnerClass innerClass = new InnerClass();
    }

    private InnerClass(){};


    public static InnerClass getInstance(){
        return A.innerClass;
    }
}
```
#### enum
真正完美，可以防止反射创建对象，因为反射无法找到enum的构造函数
```java
public enum Single {
    SINGLE;

    public static Single getInstance(){
        return SINGLE;
    }
}
```

## 策略模式
封装一个方法不同的执行方式，类似于Comparator
一个类的方法行为可以在类运行时更改
分离算法，选择实现

```java
//策略接口
public interface Strategy {
    public void work(Person person);
}
```
```java
//策略实现
public class BankStrategy implements Strategy {
    @Override
    public void work(Person person) {
        System.out.println("bank staff work");
    }
}
public class TaxiDriverStrategy implements Strategy {
    @Override
    public void work(Person person) {
        System.out.println("taxi driver work");
    }
}
```
### context不持有策略对象
```java
//上下文
public class Person {
    private int age;
    private String name;
    private Job job;

    public void work(Strategy strategy){
        strategy.work(this);
    }
}
```
```java
//使用
public static void main(String[] args) throws Exception{
    Person p1 = new Person();
    Person p2 = new Person();
    p1.work(new TaxiDriverStrategy());
    p2.work(new BankStrategy());
}
```
### context持有策略对象
```java
//上下文
public class Person {
    private int age;
    private String name;
    private Job job;
    private Strategy strategy;
    
    public void work(){
        strategy.work(this);
    }
}
```
```java
//使用
public static void main(String[] args) throws Exception{
    Person p1 = new Person(new TaxiDriverStrategy());
    Person p2 = new Person(new BankStrategy());
    p1.work();
    p2.work();
}
```

## 工厂模式
### 简单工厂