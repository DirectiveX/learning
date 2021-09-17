# Python

## 基础

**变量**

属性：id，type，value

数据类型：int，float，bool，str

输入数字：二进制0bxxxx,八进制0oxxxxx，十六进制0xXXX

**注释**

```python
# coding:UTF-8
# 设置python文件格式
# this is a comment
'''
这样算是多行注释
'''
```

**运算符**

```python
# + - * /（除） //(整除) %（取余） **幂运算
# /的时候一正一负向下取整,取余的时候遵循公式
```

**系列解包赋值**

```python
# 会一一对应复制
a,b,c=20,30,40
```

**比较对象的标识（id）**

```python
a=b=1
print(a is b)
print(a is not b)

list1=[11,22,33]
list2=[11,22,33]
print(list1 is list2)
```

**布尔运算符**

```python
and #与运算符
or #或运算符
not #取反运算符
in  #存在
not in #不存在
```

**运算符优先级**

算术运算符（幂运算 -》乘除取模 -》加减） -》位运算（左移右移） -》比较运算符（大于小于相等） -》布尔运算符（与运算 -》或运算）-》赋值运算符

ps：有括号先算括号

**分支结构**

```python
money = 1200
a = int(input("please enter your money "))
if money > a:
    print("balance is " + str(money - a))
else:
    print("error ")
    
# 多分支结构
grade = int(input("please enter your grade "))
if grade >= 90:
    print("A")
elif grade >= 80:
    print("B")
elif grade >= 60:
    print("C")
else:
    print("D")
    
# 条件表达式
number1,number2 = int(input("number1")),int(input("number2"))
print(str(number1) + " 大于等于 " + str(number2) if number1 >= number2 else str(number1) + " 小于 " + str(number2))
```

**pass（类似于标一下以后做，类似于todo）**

**循环**

```python
# while循环
a = 2
sum = 0
while a <= 100:
    sum += a
    a += 2
print(sum)
# for-in循环，迭代器，后置对象为可迭代对象
for item in 'Python':
    print(item)
#  占位符
for _ in 'Python':
    print(item)
# 流程控制语句 continue和break，continue忽略下部分代码重新回到之前位置进行执行，break跳出循环
# else配合while和for，当未遇到break时，循环执行完毕执行else中的语句
# 九九乘法表
for i in range(1,10):
    for j in range(1,10):
        if j <= i:
            print(str(j) + "*" + str(i) + "=" + str(i * j),end='\t')
    print()
```

**列表[]**

```python
lis1 = ["hhh",12,True,"hhh"]
lis2 = list((1,2))
for item in lis2:
    print(type(item))
    
print(lis1[2])
# 列表index方法
print(lis1.index('hhh'))
# 在指定范围内查找
print(lis1.index('hhh',1))
print(lis1.index('hhh',1,4))
# 读列表副本
lis2 = lis1[0:5]
# 使用in和not in进行列表元素存在性判断
print('hhh' in lis1)
# 添加操作
# append 尾部添加元素
tt = list((1,2))
tt.append(6)
print(tt)
# extend 尾部至少添加一个元素
tt1 = list((1,2))
tt.extend(tt1)
print(tt)
# insert 在链表任意位置上添加元素
tt.insert(1,50)
# 替换切片
tt = [1,4,6,7,23,7,5]
tt1 = [1,4,6,7,5]
tt[4:]=tt1
print(tt)
# 删除操作
# remove()移除碰到的第一个元素
# pop()删除指定索引的元素，不指定参数删除最后一个
print(tt.pop(2))
print(tt)
# 切片替换
tt[1:3] = []
# clear清空列表
# del删除列表对象指针
# 修改
tt[1]=4
tt[1:3]=[6,5,2]
# 排序（原列表排序）
tt.sort(reverse=True)
# 排序（产生新对象,原排序不变）
tt1 = sorted(tt)
print(tt1)
# 利用range生成列表
tt = list(range(1,8))
# 列表生成式
tt = [i+1 for i in range(1,8)]
print(tt)
```

**字典{}**

```python
# 创建方式
dict1 = dict(name='fa',age=51)
# key不存在报None
print(dict1.get('name'))
dict2 = {'name':'fa1','age':51}
# key不存在报错
print(dict2['name'])
# key不存在提供默认值，不提供也不报错，返回None
print(dict2.get('name',99))
# key的判断
print('fa' in dict1)
print('fa' not in dict1)
# clear清空字典
# 获取字典视图
dict1.keys()
dict1.values()
dict1.items() # 转换之后的列表由元组组成
# zip函数打包字典生成式，zip以元素短的那个
item=['apple','banana','berry']
key=[1,2,4]
dicts = {key:item for (item,key) in zip(item,key)}
print(dicts)
# 删除
del dicts[1]
# 添加、更新
dicts[1] = 'appleplus'
```

**元组()不可变序列**

```python
# 创建方式 ps：只包含一个元组的元素需要用逗号和小括号
t = (1,2,4,6)
print(t)
t = 1,2,4,6
print(t)
t = tuple((8,9,4,6))
print(t)
t = ('at',)
print(t)
# 迭代器遍历元组
```

**集合{}**

```python
t = {124,4,1,2,2,5,4}
t = set(range(1,6))
print(t)
# in或者not in判断存在性
# 添加
t.add(7)
t.update((7,8.2,13))
print(t)
# 删除（不存在抛出异常）
t.remove(4)
# 删除（不存在不抛出异常）
t.discard(4)
# 删除任意元素
t.pop
# 集合运算符
# 相等
print(s1==s2)
print(s1!=s2)
# 子集
print(s1.issubset(s2))
print(s2.issubset(s1))
# 超集
print(s1.issuperset(s2))
print(s2.issuperset(s1))
# 是否没有交集
print(s1.isdisjoint(s2))
# 求交集
print(s1.intersection(s2))
print(s1 & s2)
# 求并集
print(s1.union(s2))
print(s1 | s2)
# 求差集
print(s1 - s2)
print(s1.difference(s2))
print(s2 - s1)
print(s2.difference(s1))
# 对称差集
print(s1 ^ s2)
print(s1.symmetric_difference(s2))
# 集合生成式
t = {item**item for item in range(4)}
```

**string**

```python
# index 查找字符串位置，左起 找不到报错
# find 查找字符串位置，左起 找不到返回-1
# rindex 查找字符串位置，右起 找不到报错
# rfind 查找字符串位置，右起 找不到返回-1
# upper 所有字符转大写
# lower 所有字符转小写
# swapcase 交换大小写
# captalize 首字符大写，其余换小写
# title 一句中每个单词第一字符转大写

# 字符串对齐
print(ss.center(20,' ')) #居中对齐
print(ss.ljust(20,' ')) #左对齐
print(ss.rjust(20,' ')) #右对齐
ss = '-123'
print(ss.zfill(20)) #右对齐，0填充，-0000000000000000123
# split 字符串分割 左起
# rsplit 字符串分割 右起
```

```python
# 字符串判断
# 是否为合法标识符字符串
print(ss.isidentifier())
# 是否为空
print(" ".isspace())
# 是否为字符
print(ss.isalpha())
# 是否为十进制数字
print("123".isdecimal())
print("123四".isdecimal()) # False
# 是否全部由数字组成
print("123".isnumeric())
print("123四".isnumeric()) # True
# 是否只有数字和字母组成
print("123四".isalnum()) # True
# 替换
ss = 'time is not enough enough!'
print(ss.replace('enough','en',1))
# 连接
t=("2","56",'1','6')
print(''.join(t))
print(' '.join(t))

# 比较运算符 > ==
# 切片
s = 'hello python'
print(s[:5] + '-' + s[6:])

# 格式化字符串
# % .format f
print("我叫%s，今年%d岁"%(name,age))
print("我叫{0}，今年{1}岁".format(name,str(age)))
print(f"我叫{name}，今年{age}岁")
# 宽度+取小数点后n位
print("%10.1f"%83.1)
print("{0:10.1f}".format(25.66))
print(f"我叫{name}，今年{age:10d}岁")

# 编码解码
print("我的一天".encode(encoding="GBK"))
print("我的一天".encode(encoding="UTF-8"))
# byte的decode，str的encode
s = "我的一天".encode(encoding="GBK")
print(s.decode("GBK"))
```



## 交互模式-字符串驻留机制

字符串长度为0或1时
符合标识符（字母数字下划线）的字符串
字符串只在编译时进行驻留，非运行时
[-5,256]之间的整数

PyCharm对字符串进行了优化处理

```python
import sys
ss = sys.intern(ss1) #强制驻留
```

ps：多个字符串相加使用join方法，不使用+，效率较高，因为join先计算字符串长度，只产生一个对象进行拷贝，而+会产生多个对象

## 函数编程

def 函数名(输入参数):
	函数体
	[return 返回值]

```python
def add(a,b):
    return a+b

print(add(1,2))
# 关键字参数传参
print(add(b=1,a=2))
```

python为值传递

# 一般内置函数

**print**

用于输出

**open**

用于打开文件，文件不存在创建，存在追加

```python
f = open("D://text.txt","a+")
print("hellow",file=f)
f.close()
```

**ord**

获取unicode

**chr**

强转char

**input**

输入函数

 ```python
 # eg
 a = int(input("please enter a"))
 b = int(input("please enter b"))
 print("sum is " + str(a + b) )
 ```

**bool**

获取对象的布尔值

```python
print(bool(False))
print(bool(0))
print(bool(0.0))
print(bool(None))
print(bool(''))
print(bool(""))
print(bool([]))
print(bool(list()))
print(bool(()))
print(bool(tuple()))
print(bool({}))
print(bool(dict()))
print(bool(set()))
# ------------ 除了上面，其他都为True
```

**range()**

```python
# 数组内部0-n
r = range(10)
print(list(r))
# 数组内部n1-n2
r = range(3,11)
print(list(r))
# 数组内部n1-n2步长为n3
r = range(3,11,2)
print(list(r))
print(9 in list(r)) # True
print(10 in list(r)) # False
#懒加载（lazy evaluation）
r = range(-1,-10,-1)
print(list(r))
```
