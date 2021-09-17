# Scala

## for循环

https://www.runoob.com/scala/scala-for-loop.html

**yield**

```scala
val x : List[Char] = List('a','v')
var b = '''
var res = for {b <- x
    if b > 'a' && b < 'z'
}yield b

for (c <- res){
  println(c);
}
```

## 方法

https://www.runoob.com/scala/scala-functions.html