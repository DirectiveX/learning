# 设计原则
## 6大设计原则
### 单一职责原则
一个类，接口，方法，尽量做到只有一个原因引起变化

### 里氏替换原则
所有父类出现的地方，都能用子类替换

### 依赖倒置原则
面向接口编程，实现类之间不发生直接依赖关系，通过抽象类或接口去建立依赖关系

### 开闭原则
对扩展开放，对修改关闭

### 迪米特法则
尽量减少一个类与外界的交互

### 接口隔离原则
不要暴露无意义的接口
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
所有的能够返回实例的类，都可以叫做工厂
### 简单工厂
```java
//产品A
public class AirConditioning {
    public void blow(){
        System.out.println("air condition blow");
    }
}
```
```java
//产品B
public class ElectricFan {
    public void blow(){
        System.out.println("Electric fan blow");
    }
}
```
```java
//简单工厂，扩展性差
public class BlowEquipmentFactory {
    public AirConditioning createAirConditioning(){
        return new AirConditioning();
    }
    public ElectricFan createElectricFan(){
        return new ElectricFan();
    }
}
```
### 静态工厂
单例

### 工厂方法
针对产品维度进行扩展，如果想新加一个产品，只要实现对应接口并写出对应工厂即可，无需修改源代码
```java
// 工厂
public class AirConditioningFactory {
    public Hairable create(){
        return new AirConditioning();
    }
}
public class ElectricFanFactory {
    public Hairable create(){
        return new ElectricFan();
    }
}
```
```java
//产品接口
public interface Hairable {
    public void blow();
}
```
```java
//产品
public class AirConditioning implements Hairable{
    public void blow(){
        System.out.println("Air condition blow");
    }
}
public class ElectricFan implements Hairable{
    public void blow(){
        System.out.println("Electric fan blow");
    }
}
```
```java
//使用
public static void main(String[] args) {
    Hairable hairable = new AirConditioningFactory().create();
    Hairable hairable1 = new ElectricFanFactory().create();
    hairable.blow();
    hairable1.blow();
}
```

### 抽象工厂
针对产品族维度进行扩展
```java
//抽象工厂
public abstract class HomeAbstractFactory {
    public abstract Bed createBed();
    public abstract Chair createChair();
    public abstract Desk createDesk();
}
```
```java
//具体工厂
public class WoodHomeFactory extends HomeAbstractFactory {
    @Override
    public Bed createBed() {
        return new WoodBed();
    }

    @Override
    public Chair createChair() {
        return new WoodChair();
    }

    @Override
    public Desk createDesk() {
        return new WoodDesk();
    }
}
```
```java
//抽象产品
public abstract class Bed {
    public abstract void sleep();
}
public abstract class Chair {
    public abstract void sit();
}
public abstract class Desk {
    public abstract void lie();
}
```
```java
//具体产品
public class WoodBed extends Bed{

    @Override
    public void sleep() {
        System.out.println("wood bed can sleep for 1s");
    }
}
public class WoodChair extends Chair{

    @Override
    public void sit() {
        System.out.println("wood chair can sit for 1s");
    }
}
public class WoodDesk extends Desk {
    @Override
    public void lie() {
        System.out.println("wood desk can lie for 1s");
    }
}
```