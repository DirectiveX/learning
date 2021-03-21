# 设计原则
## 六大设计原则（solid）
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
## 外观（门面）模式
一批对象对外提供接口去调度，而不是直接调度，说到底就是API
```java
//被调度的类
public class CPU {
    public void dispatch(){
        System.out.println("cpu dispatched thread xxx");
    }
}
public class HardDisk {
    public void save(){
        System.out.println("HardDisk save data");
    }
}
public class Memory {
    public void load(){
        System.out.println("Memory loading ...");
    }
}
```
```java
//门面
public class ComputerFacade {
    private CPU cpu;
    private HardDisk hardDisk;
    private Memory memory;

    public void startComputer(){
        cpu.dispatch();
        memory.load();
        hardDisk.save();
    }
}
```
## 调度者（中介者）模式
内部简化方法间的调用，用一个管家去管理，例如MQ,MVC,遵循迪米特法则，几个类之间能够互相影响
```java
//中介者
public class HouseKeeperMediator {
    private Staff maid;
    private Staff guard;
    private Staff gardener;
    private Staff privateDoctor;

    public HouseKeeperMediator(Staff maid,Staff guard,Staff gardener,Staff privateDoctor) {
        this.maid = maid;
        this.guard = guard;
        this.gardener = gardener;
        this.privateDoctor = privateDoctor;
    }

    public void addMaidSalary(int number){
        privateDoctor.salaryDown(number);
    }

    public void addGuardSalary(int number){
        gardener.salaryDown(number);
    }
}
```
```java
//抽象同事类
public abstract class Staff {
    protected HouseKeeperMediator houseKeeperMediator;
    public Staff(HouseKeeperMediator houseKeeperMediator){
        this.houseKeeperMediator = houseKeeperMediator;
    }
    public abstract void salaryUp(int number);
    public abstract void salaryDown(int number);
}
```
```java
//具体相互影响的类
public class Maid extends Staff {
    private int salary;

    public Maid(HouseKeeperMediator houseKeeperMediator) {
        super(houseKeeperMediator);
    }

    @Override
    public void salaryUp(int number) {
        salary += number;
        this.houseKeeperMediator.addMaidSalary(number);
    }

    @Override
    public void salaryDown(int number) {
        salary -= number;
    }
}

public class PrivateDoctor extends Staff {
    private int salary;

    public PrivateDoctor(HouseKeeperMediator houseKeeperMediator) {
        super(houseKeeperMediator);
    }

    @Override
    public void salaryUp(int number) {
        salary += number;
    }

    @Override
    public void salaryDown(int number) {
        salary -= number;
    }
}
public class Guard extends Staff {
    private int salary;

    public Guard(HouseKeeperMediator houseKeeperMediator) {
        super(houseKeeperMediator);
    }

    @Override
    public void salaryUp(int number) {
        salary += number;
        this.houseKeeperMediator.addGuardSalary(number);
    }

    @Override
    public void salaryDown(int number) {
        salary -= number;
    }
}
public class Gardener extends Staff {
    private int salary;

    public Gardener(HouseKeeperMediator houseKeeperMediator) {
        super(houseKeeperMediator);
    }

    @Override
    public void salaryUp(int number) {
        salary += number;
    }

    @Override
    public void salaryDown(int number) {
        salary -= number;
    }
}
```
## 装饰模式
常用于一键换肤，用组合替代继承
```java
//抽象被装饰的类
public abstract class Pet {
    public abstract void talk();
}
//抽象装饰类
public abstract class PetDecorator extends Pet{
    protected Pet pet;

    public PetDecorator(Pet pet){
        this.pet = pet;
    }
}
```
```java
//被装饰类实现
public class Cat extends Pet {
    @Override
    public void talk() {
        System.out.println("Cat mow");
    }
}
public class Dog extends Pet {
    @Override
    public void talk() {
        System.out.println("Dog wang");
    }
}
//装饰类实现
public class LowerPetDecorator extends PetDecorator{
    public LowerPetDecorator(Pet pet) {
        super(pet);
    }

    @Override
    public void talk() {
        pet.talk();
        talkLower();
    }

    private void talkLower(){
        System.out.println("more lower!!!!!");
    }
}
public class HigherPetDecorator extends PetDecorator{
    public HigherPetDecorator(Pet pet) {
        super(pet);
    }

    @Override
    public void talk() {
        pet.talk();
        talkHigher();
    }

    private void talkHigher(){
        System.out.println("more higher!!!!!");
    }
}
```
## 职责链模式

给定一个职责链的开始，然后对于某个用户的请求只要通过一级一级进行处理，直到请求处理完毕，每级都会记住下一级是谁，典型实现是javax.servlet包中的Filter和FilterChain，还有类加载器

即当收到一个用户请求，会根据链条逐步处理，每步都会做一些操作，直到完全解决请求，然后逐步返回

```java
//职责链接口
public interface Filter {
    public void doFilter(Request request,Response response,FilterChain filterChain);
}
//职责链管理
public class FilterChain implements Filter{
    private List<Filter> list = new ArrayList<>();
    private int index = 0;

    public FilterChain addFilter(Filter filter){
        list.add(filter);
        return this;
    }

    @Override
    public void doFilter(Request request, Response response,FilterChain filterChain) {
        if(index == list.size())return;
        Filter filter = list.get(index);
        index ++;
        filter.doFilter(request,response,filterChain);
    }
}
```

```java
//职责链实现
public class SmileFilter implements Filter {
    @Override
    public void doFilter(Request request, Response response, FilterChain filterChain) {
        request.setMsg(request.getMsg().replace(":)","TAT"));
        filterChain.doFilter(request,response,filterChain);
        response.setMsg(response.getMsg() + "smile response");
    }
}

public class NumberFilter implements Filter {
    @Override
    public void doFilter(Request request, Response response, FilterChain filterChain) {
        request.setMsg(request.getMsg().replace("\\d","t"));
        filterChain.doFilter(request,response,filterChain);
        response.setMsg(response.getMsg() + "NumberFilter response");
    }
}

```

```java
//简单参数类
public class Response {
    String msg;

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }
}
public class Request {
    String msg;

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }
}
```

## 观察者模式
观察者模式通常与职责链模式穿插使用，我们平时看到的Observer,Listener,Hook,Callback都是观察者模式的实践

观察者模式主要用于观察源目标的状态，当源目标触发事件时，观察者就会立即做出反应

```java
//源目标类
public class Source {
    List<Observer> observers = new ArrayList<>();

    private void addObserver(Observer observer){
        observers.add(observer);
    }

    public void action(){
        Event event = new Event(this);
        for(Observer observer:observers){
            observer.ObserveEvent(event);
        }
    }
}
```
```java
//观察者接口
public interface Observer {
    public void ObserveEvent(Event event);
}
//观察者类
public class Observer1 implements Observer {
    @Override
    public void ObserveEvent(Event event) {
        System.out.println("Observer1 catch event");
    }
}
public class Observer2 implements Observer {
    @Override
    public void ObserveEvent(Event event) {
        System.out.println("Observer2 catch event");
    }
}
```
```java
//事件
public class Event {
    private Source source;

    public Event(Source source){
        this.source = source;
    }
}
```

## 组合（树状）模式
处理树状结构，组合成部分-整体层次结构
```java
public class Node {
    List<Node> nodes = new ArrayList<>();

    public void addNode(Node node){
        nodes.add(node);
    }
}
```

## 享元模式
重复利用对象（共享元数据），ThreadPool，String
```java
//抽象类
public abstract class Shape {
    public abstract void draw();
}
//实现类
public class Circle extends Shape {
    @Override
    public void draw() {
        System.out.println("circle draw");
    }
}
public class Square extends Shape {
    @Override
    public void draw() {
        System.out.println("square draw");
    }
}
public class CircleOnSquare extends Shape {
    private List<Shape> list = new ArrayList<>();

    public void addShape(Shape shape){
        list.add(shape);
    }

    @Override
    public void draw() {
        for(Shape shape:list){
            shape.draw();
        }
    }
}
```
```java
//保存元数据类
public class ShapePool {
    private List<Shape> list = new ArrayList<>();

    {
        list.add(new Square());
        list.add(new Circle());
        list.add(new CircleOnSquare());
    }

    public void addShape(Shape shape){
        list.add(shape);
    }

    public Shape getShape(int index){
        return list.get(index);
    }
}
```

## 代理模式
代理模式就是在执行某个类的方法时，通过代理类去执行它，而不是直接执行它，这样能够通过代理类对执行的方法进行一些额外的操作

典型实现：Spring AOP，Spring AOP的代理混合了jdk动态代理和cglib，当有接口实现的时候用jdk动态代理，而无接口时用cglib

### cglib和jdk dynamic proxy
两者都是都是实现代理的api，底层都通过asm去修改字节码文件，生成动态代理对象。要注意的是，jdk动态代理只能代理实现了接口的对象，因为他是通过接口去知道要代理哪些方法的，而cglib代理没有这个限制，cglib的限制在于不能代理final类，因为cglib的代理是通过创建继承代理类去实现的，里面有做异常处理

jdk的动态代理还同时代理了toString,hashCode,equals方法

### 代码实现（静态代理）
```java
//代理接口
public interface Manager {
    public void issueOrder();
}
```
```java
//被代理类
public class Master implements Manager{

    @Override
    public void issueOrder() {
        System.out.println(" start issue an order");
    }
}

```
```java
//代理类
public class MasterProxy implements Manager{
    private Master master;

    public MasterProxy(Master master){
        this.master = master;
    }
    @Override
    public void issueOrder() {
        System.out.println("do something before");
        master.issueOrder();
        System.out.println("do something after");
    }
}
```

## 迭代器模式
主要提供一个接口去统一实现容器的遍历
主要指代java.util.iterator
```java
//实现linkedlist
public class LinkedList_<T>  {
    private Node head = new Node(0);
    private Node tail = head;
    private int length = 0;

    public void add(T t){
        tail.next = new Node(t);
        tail = tail.next;
        length ++;
    }

    public int size(){
        return length;
    }

    public Iterator iterator(){
        return new itr();
    }

    private class itr<T> implements Iterator<T>{
        private Node node = head;
        @Override
        public boolean hasNext() {
            return node.hasNext();
        }

        @Override
        public T next() {
            node = node.next;
            return (T) node.value;
        }
    }

    private class Node<T>{
        private Node next;
        private T value;

        public Node(T t){
            value = t;
        }

        private boolean hasNext(){
            return next != null;
        }
    }
}
```

## 访问者模式
编译器语法分析的时候会用到这种模式，对于结构固定的类的访问，可以使用visitor模式

```java
//被访问者抽象组件
public abstract class IntervieweeComp {
    abstract void accept(Visitor visitor);
}
//被访问者具体组件
public class IntervieweeComp1 extends IntervieweeComp{
    void accept(Visitor visitor){
        visitor.visitorComp1();
    }
}
public class IntervieweeComp2 extends IntervieweeComp{
    void accept(Visitor visitor){
        visitor.visitorComp2();
    }
}
//被访问者
public class Interviewee {
    private IntervieweeComp intervieweeComp1;
    private IntervieweeComp intervieweeComp2;

    public Interviewee(IntervieweeComp intervieweeComp1, IntervieweeComp intervieweeComp2) {
        this.intervieweeComp1 = intervieweeComp1;
        this.intervieweeComp2 = intervieweeComp2;
    }

    public void accepted(Visitor visitor){
        intervieweeComp1.accept(visitor);
        intervieweeComp2.accept(visitor);
    }
}
```

```java
//访问者接口
public interface Visitor {
    void visitorComp1();
    void visitorComp2();
}
//访问者实现
public class Visitor1 implements Visitor {
    @Override
    public void visitorComp1() {
        System.out.println("visitor1:I'm coming to visit component 1 ");
    }

    @Override
    public void visitorComp2() {
        System.out.println("visitor1:I'm coming to visit component 2 ");
    }
}
public class Visitor2 implements Visitor {
    @Override
    public void visitorComp1() {
        System.out.println("visitor2:I'm coming to visit component 1 ");
    }

    @Override
    public void visitorComp2() {
        System.out.println("visitor2:I'm coming to visit component 2 ");
    }
}
```

## 构建者模式
分离复杂对象，分部构建小对象
```java
//抽象类
public abstract class Builder {
    protected Product product = new Product();
    public abstract Builder builderA();
    public abstract Builder builderB();
    public abstract Builder builderC();
    public abstract Builder builderD();
    public abstract Builder builderE();
    public Product build(){
        return product;
    }
}
//实现类
public class ComplexBuilder extends Builder {

    @Override
    public Builder builderA() {
        super.product.setA(51);
        return this;
    }

    @Override
    public Builder builderB() {
        super.product.setB("161");
        return this;
    }

    @Override
    public Builder builderC() {
        super.product.setC(1.0);
        return this;
    }

    @Override
    public Builder builderD() {
        super.product.setD(10.0f);
        return this;
    }

    @Override
    public Builder builderE() {
        super.product.setE(new E());
        return this;
    }
}
public class SimpleBuilder extends Builder {

    @Override
    public Builder builderA() {
        super.product.setA(1);
        return this;
    }

    @Override
    public Builder builderB() {
        super.product.setB("1");
        return this;
    }

    @Override
    public Builder builderC() {
        super.product.setC(10.0);
        return this;
    }

    @Override
    public Builder builderD() {
        super.product.setD(10.0f);
        return this;
    }

    @Override
    public Builder builderE() {
        super.product.setE(new E());
        return this;
    }
}
//用到的其他类
public class E {
}
```
```java
//产品类
public class Product {
    private int a;
    private String b;
    private double c;
    private float d;
    private E e;

    public int getA() {
        return a;
    }

    public void setA(int a) {
        this.a = a;
    }

    public String getB() {
        return b;
    }

    public void setB(String b) {
        this.b = b;
    }

    public double getC() {
        return c;
    }

    public void setC(double c) {
        this.c = c;
    }

    public float getD() {
        return d;
    }

    public void setD(float d) {
        this.d = d;
    }

    public E getE() {
        return e;
    }

    public void setE(E e) {
        this.e = e;
    }
}
```

## 适配器模式
将一个类的接口转换成用户希望的另一个接口，需要做一个适配器，让两个接口适配使用，java中的实现就是InputStreamReader，OutputStreamWriter

常见的Adapter不是Adapter模式，只是为了方便编程，做了空实现
```java
//要被转换的类
public class Adaptee{

    public void willUse() {

    }
}
//目标接口
public interface Target {
    public void wantUse();
}
//适配器
public class Bridge extends Adaptee implements Target{

    @Override
    public void wantUse() {
        super.willUse();
    }
}
```
## 桥接模式
抽象具体两个维度同时发展，互不影响，防止出现类爆炸，使用组合替代继承

```java
//抽象维度
public class PetImpl {

}
public class Unruly extends PetImpl {
}
public class Cold extends PetImpl {
}
//具体维度
public class Pet {
    protected PetImpl petImpl;

    public Pet(PetImpl petImpl) {
        this.petImpl = petImpl;
    }
}
public class Cat extends Pet {
    public Cat(PetImpl petImpl) {
        super(petImpl);
    }
}
public class Dog extends Pet {
    public Dog(PetImpl petImpl) {
        super(petImpl);
    }
}
```

## 命令模式
主要用来封装命令
可以配合职责链模式达到undo功能
可以配合备忘录模式达到回滚功能
可以配合组合模式达到宏命令

```java
//抽象命令
public abstract class Command {
    public abstract void execute();
    public abstract void undo();
}
//指令实现
public class CopyCommand extends Command {
    private Content content;

    public CopyCommand(Content content) {

        this.content = content;
    }

    @Override
    public void execute() {
        content.setContent(content.getContent() + content.getContent());
    }

    @Override
    public void undo() {
        content.setContent(content.getContent().substring(0,content.getContent().length()/2));
    }
}
public class InsertCommand extends Command {
    private Content content;
    private final static String INSERTED_STRING = " hello ";

    public InsertCommand(Content content) {
        this.content = content;
    }

    @Override
    public void execute() {
        content.setContent(content.getContent() + INSERTED_STRING);
    }

    @Override
    public void undo() {
        content.setContent(content.getContent().substring(0,content.getContent().length() - INSERTED_STRING.length()));
    }
}
```
```java
//职责链
public class CommandChain {
    List<Command> commands = new ArrayList<>();
    int index = 0;

    public CommandChain addCommand(Command command){
        commands.add(command);
        return this;
    }

    public void execute(){
        if(index >= commands.size())return;
        Command command = commands.get(index);
        command.execute();
        index ++;
    }

    public void undo(){
        if(index <= 0)return;
        index --;
        Command command = commands.get(index);
        command.undo();
    }
}
```
```java
//包装类
public class Content {
    private String content;

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
```

## 原型模式
以原型实例为模板，创建新的对象，对象属性和原来一样
实现Cloneable接口，重写clone方法

```java
public class NeedClone implements Cloneable {
    @Override
    protected Object clone() throws CloneNotSupportedException {
        return super.clone();
    }
}
```

## 备忘录模式
记录快照，存盘，暂停

```java
//备忘录类
public class Memento {
    public void save(Data data){
        File f = new File("C:\\Users\\28267\\Desktop\\data");
        try(ObjectOutputStream objectOutputStream = new ObjectOutputStream(new FileOutputStream(f))){
            objectOutputStream.writeObject(data);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    public Data load(){
        File f = new File("C:\\Users\\28267\\Desktop\\data");
        try(ObjectInputStream objectOutputStream = new ObjectInputStream(new FileInputStream(f))){
            return  (Data)objectOutputStream.readObject();
        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }
}
```
```java
//被记录类
public class Data implements Serializable {
    private int age;
    private String name;

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String toString() {
        return "Data{" +
                "age=" + age +
                ", name='" + name + '\'' +
                '}';
    }
}
```

## 模板方法
父类方法会调用一些将来会被子类实现的方法，子类通过实现那些方法来控制父类方法

回调函数,钩子函数

```java
//父类
public abstract class Template {
    public void method(){
        method1();
        method2();
    }

    public abstract void method1();
    public abstract void method2();
}
//子类
public class Realize extends Template {
    @Override
    public void method1() {
        System.out.println(" m1 ");
    }

    @Override
    public void method2() {
        System.out.println(" m2 ");
    }
}
```

## 状态模式
类中根据不同状态有不同反应,就可以用state模式
和visitor类似,不过这边是根据状态的不同

```java
//主类
public class User {
    private State state;

    public User(State state) {
        this.state = state;
    }

    public void say() {
        state.say();
    }

    public void talk() {
        state.talk();
    }
}
```
```java
//状态接口
public interface State {
    void say();
    void talk();
}
//状态实现
public class SadState implements State {
    @Override
    public void say() {

    }

    @Override
    public void talk() {

    }
}
public class HappyState implements State {
    @Override
    public void say() {

    }

    @Override
    public void talk() {

    }
}
```

## 解释器模式
解释脚本语言

# 分层
## 创建型模式
单例模式
工厂方法
抽象工厂
构建者模式
原型模式

## 结构型模式
适配器模式
门面模式
装饰者模式
代理模式
桥接模式
享元模式
组合模式

## 行为型模式
策略模式
中介者模式
迭代器模式
职责链模式
备忘录模式
观察者模式
解释器模式
访问者模式
状态模式
命令模式
模板方法模式

