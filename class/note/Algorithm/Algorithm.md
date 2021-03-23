# 算法
## 排序算法
### 选择排序
**方式**
在剩余未排序的数组中选择一个最小（大）值与第i个数交换

**代码**
```java
    public static void main(String[] args) {
        int [] a = new int[]{8,6,1,9,3,4};

        for(int i = 0;i < a.length;i ++){
            int minIndex = i;
            int minValue = a[minIndex];
            for(int j = i + 1;j < a.length; j ++){
                if(minValue > a[j]){
                    minIndex = j;
                    minValue = a[j];
                }
            }
            swap(a,i,minIndex);
        }
    }

    private static void swap(int [] a,int x,int y){
        int temp = a[x];
        a[x] = a[y];
        a[y] = temp;
    }
```

**复杂度**

时间复杂度：O($N{^2}$)
空间复杂度：O(1)

### 冒泡排序
**方式**

相邻数比较，每次遍历都将最大（小）值确定在最后位置

**代码**

```java
    public static void main(String[] args) {
        int [] a = new int[]{8,6,1,9,3,4};

        for(int i = 0;i < a.length;i ++){
            for(int j = i + 1;j < a.length; j ++){
                if(a[i] < a[j])swap(a,i,j);
            }
        }

        System.out.println(Arrays.toString(a));
    }

    private static void swap(int [] a,int x,int y){
        int temp = a[x];
        a[x] = a[y];
        a[y] = temp;
    }
```

**复杂度**

时间复杂度：O($N{^2}$)
空间复杂度：O(1)

### 插入排序
**方式**

选择第i个数，与前面排好序的相比较，插入到合适位置

**代码**

```java
    public static void main(String[] args) {
        int [] a = new int[]{8,6,1,9,3,4};

        for(int i = 1;i < a.length;i ++){
            for(int j = i - 1;j >= 0; j --){
                if(a[j] > a[i]){
                    swap(a,i,j);
                    break;
                }
            }
        }

        System.out.println(Arrays.toString(a));
    }

    private static void swap(int [] a,int x,int y){
        int temp = a[x];
        a[x] = a[y];
        a[y] = temp;
    }
```

**复杂度**

时间复杂度：O($N{^2}$)
（额外）空间复杂度：O(1)

## 对数器
### 制作对数器
1.想测的方法a
2.实现复杂度不好但是容易实现的方法b
3.实现随机样本产生器
4.对比结果

## 二分法
### 用处
1.找有序数组中的一个值
2.找有序数组中大于等于某个值的最左位置
3.找有序数组中小于等于某个值的最右位置
4.找局部最小值问题（某一段中找到最小）

**写法1**

```java
//找有序数组中的一个值
    public static void main(String[] args) {
        int [] a = new int[]{1, 3, 4, 6, 8, 9};
        System.out.println(findIndex(a,3));
    }

    public static int findIndex(int [] a,int target){
        int l = 0;
        int r = a.length - 1;

        while(l <= r){
            int mid = r + ((l - r) >> 1);
            if(a[mid] > target){
                r = mid - 1;
            }else if(a[mid] < target){
                l = mid + 1;
            }else{
                return mid;
            }
        }
        return -1;
    }
```
**写法2**

```java
//找有序数组中大于等于某个值的最左位置
    public static void main(String[] args) {
        int [] a = new int[]{1, 3, 4 ,4, 6, 8, 9};
        System.out.println(findIndex(a,4));
    }

    public static int findIndex(int [] a,int target){
        int l = 0;
        int r = a.length - 1;
        int index = -1;
        while(l <= r){
            int mid = r + ((l - r) >> 1);
            if(a[mid] < target) {
                l = mid + 1;
            }
            else{
                index = mid;
                r = mid - 1;
            }
        }
        return index;
    }
```
**写法3**

```java
    //找有序数组中小于等于某个值的最右位置
    public static void main(String[] args) {
        int [] a = new int[]{1, 3, 4 ,4, 6, 8, 9};
        System.out.println(findIndex(a,4));
    }

    public static int findIndex(int [] a,int target){
        int l = 0;
        int r = a.length - 1;
        int index = -1;
        while(l <= r){
            int mid = r + ((l - r) >> 1);
            if(a[mid] > target) {
                r = mid - 1;
            }
            else{
                index = mid;
                l = mid + 1;
            }
        }
        return index;
    }
```
**写法4**

```java
    //找局部最小值
    public static void main(String[] args) {
        int [] a = new int[]{3, 1, 5 ,4, 3, 8, 9};
        System.out.println(findIndex(a));
    }

    public static int findIndex(int [] a){
        int l = 0;
        int r = a.length - 1;
        if(a[l] < a[l + 1])return l;
        if(a[r] < a[r - 1])return r;
        int index = -1;
        while(l <= r){
            int mid = l + ((r - l) >> 1);
            if(a[mid - 1] < a[mid]){
                r = mid;
            }else if (a[mid + 1] < a[mid]){
                l = mid;
            }else {
                return mid;
            }
        }
        return index;
    }
```

## 认识异或运算
异或就是无进位相加

### 性质
1.0^N=N
2.N^N=0
3.满足交换律和结合律

### 无中间量相加
a = a^b
b = a^b
a = a^b
**不适用ab指向同一个空间的情况**

### 问题

*1.一个数组中有一种数出现奇数次，其他出现偶数次，怎么找出并打印?*
全部异或一遍，因为偶数的异或结果为0，所以剩下的就是要求的数

*2.把整型数提取最后一个1?*
a&(~a+1)

*3.一个数组中有两种数出现奇数次，其他出现偶数次，怎么找出并打印?*
全部异或一遍，找出两种数的异或值eor
提取最后一个1
将两部分分开
求一部分的全部异或，就为其中一个值a，将a与eor异或，就是b

## 链表
**反转链表**
用next保存下一个值，用pre保存初始值
```java
// 迭代
    private static Node reverseList(Node head){
        Node pre = null;
        Node next = null;
        while (head != null){
            next = head.next;
            head.next = pre;
            pre = head;
            head = next;
        }
        return pre;
    }
//递归
    private static Node reverseList(Node node){
        if(node == null || node.next == null)return node;
        Node head = reverseList(node.next);
        node.next.next = node;
        node.next = null;
        return head;
    }
```
**链表删值**
先删前面，然后后面寻找
```java
//迭代
    private static Node reverseList(Node node,int value){
        Node head = null;
        while (node != null && node.val == value){
            node = node.next;
        }
        head = node;
        Node pre = head;

        while(node != null){
            if(node.val == value){
                pre.next = node.next;
            }else{
                pre = node;
            }
            node = node.next;
        }
        return head;
    }
```

## 栈和队列常见题
1.用数组实现队列

思路：循环队列
代码：
```java
class MyQueue{
        private int [] arr;
        private int size;
        private int limit;
        private int head;
        private int tail;

        public MyQueue(int size){
            arr = new int[size];
            head = 0;
            tail = 0;
            this.size = 0;
            limit = size;
        }

        public int poll(){
            if(size == 0){
                throw new RuntimeException("gun");
            }
            size --;
            int value = arr[head];
            head = getNextIndex(head);
            return value;
        }

        public void offer(int value){
            if(size == limit){
                throw new RuntimeException("gun");
            }
            size ++;
            arr[tail] = value;
            tail = getNextIndex(tail);
        }

        private int getNextIndex(int index){
            return (index + 1)%limit;
        }
    }
```

2.实现特殊栈，在基本功能基础上，增加返回栈中最小元素的功能

思路：双栈
代码：
```java
class SpecificStack{
        Stack<Integer> mainStack = new Stack<>();
        Stack<Integer> helperStack = new Stack<>();

        public void push(int value){
            mainStack.push(value);
            if(helperStack.isEmpty()){
                helperStack.push(value);
            }else{
                Integer peek = helperStack.peek();
                if(value < peek){
                    helperStack.push(value);
                }else{
                    helperStack.push(peek);
                }
            }
        }

        public Integer minElement(){
            if(helperStack.isEmpty())return null;
            return helperStack.peek();
        }

        public Integer poll(){
            if(mainStack.isEmpty()){
                return null;
            }else{
                Integer value = mainStack.pop();
                helperStack.pop();
                return value;
            }
        }
    }
```

3.栈实现队列
双栈实现
```java
class MyQueue{
        Stack<Integer> mainStack = new Stack<>();
        Stack<Integer> helperStack = new Stack<>();

        public void offer(int value){
            mainStack.push(value);
            mainToHelp();
        }

        public Integer poll(){
            mainToHelp();
            if(helperStack.isEmpty())return null;
            return helperStack.pop();
        }

        private void mainToHelp(){
            if(!mainStack.isEmpty()){
                if(helperStack.isEmpty()){
                    while (!mainStack.isEmpty()){
                        helperStack.push(mainStack.pop());
                    }
                }
            }
        }
    }
```

4.队列实现栈
双队列实现，保持一个队列为空，每次取到最后一个值
```java
 class MyStack{
        Queue<Integer> mainQueue = new LinkedList<>();
        Queue<Integer> helperQueue = new LinkedList<>();

        public void push(int value){
            setEmptyQueue();
            mainQueue.offer(value);
        }

        public Integer pop(){
            setEmptyQueue();
            Integer res = null;
            int i = 0;
            int size = mainQueue.size();
            while(!mainQueue.isEmpty()){
                res = mainQueue.poll();
                if(i < size - 1) {
                    helperQueue.offer(res);
                }
                i ++;
            }
            return res;
        }

        private void setEmptyQueue(){
            mainQueue = mainQueue.isEmpty()?helperQueue:mainQueue;
            helperQueue = new LinkedList<>();
        }
    }
```

## 递归
递归的时间复杂度
T(N) = aT(N/B)+O($N^d$)
子问题的规模X次数+O(N)