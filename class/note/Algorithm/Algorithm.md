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

###  归并排序
**方式**
先让左和右有序，然后借助中间数组合起来，实质是把比较行为变为有序信息并传递

**代码**
```java
//递归
    public static void mergeSort(int [] arr,int l,int r){
        if(l == r)return;
        int mid = l + ((r - l) >> 1);
        mergeSort(arr,l,mid);
        mergeSort(arr,mid + 1,r);
        merge(arr,l,r);
    }

    public static void merge(int [] arr,int l,int r){
        int mid = l + ((r - l) >> 1);
        int p1 = l;
        int p2 = mid + 1;
        int [] temp = new int[r - l + 1];
        int index = 0;
        while (p1 <= mid && p2 <= r){
            temp[index ++] = arr[p1]<arr[p2]?arr[p1 ++]:arr[p2 ++];
        }
        while (p1 <= mid){
            temp[index ++] = arr[p1 ++];
        }
        while (p2 <= r){
            temp[index ++] = arr[p2 ++];
        }
        for(int i = 0;i < temp.length;i ++){
            arr[l + i] = temp[i];
        }
    }
//迭代
    public static void mergeSort(int [] arr){
        int mergeSize = 1;
        int n = arr.length;
        while (mergeSize < n){
            int l = 0;
            while (l < n){
                int mid = l + mergeSize - 1;
                if(mid >= n)break;
                int r = Math.min(mid + mergeSize,n - 1);
                merge(arr,l,r,mid);
                l = r + 1;
            }
            //防止越界
            if(mergeSize > n/2){
                break;
            }
            mergeSize <<= 1;
        }
        return sum;
    }

    public static void merge(int [] arr,int l,int r,int mid){
        int p1 = l;
        int p2 = mid + 1;
        int [] temp = new int[r - l + 1];
        int index = 0;
        while (p1 <= mid && p2 <= r){
            if(arr[p1] <= arr[p2]){
                temp[index ++] = arr[p1 ++];
            }else{
                temp[index ++] = arr[p2 ++];
            }
        }
        while (p1 <= mid){
            temp[index ++] = arr[p1 ++];
        }
        while (p2 <= r){
            temp[index ++] = arr[p2 ++];
        }
        for(int i = 0;i < temp.length;i ++){
            arr[l + i] = temp[i];
        }
        return sum;
    }
```
**复杂度**
时间复杂度：O($N\log{N}$)
空间复杂度：O(N)

#### 归并题目
1.一个数组中，一个数左边比它小的数的总和叫数的小和，所有小和加起来叫数组小和，求数组小和
```java
    public static int mergeSort(int [] arr){
        int mergeSize = 1;
        int n = arr.length;
        int sum = 0;
        while (mergeSize < n){
            int l = 0;
            while (l < n){
                int mid = l + mergeSize - 1;
                if(mid >= n)break;
                int r = Math.min(mid + mergeSize,n - 1);
                sum += merge(arr,l,r,mid);
                l = r + 1;
            }
            //防止越界
            if(mergeSize > n/2){
                break;
            }
            mergeSize <<= 1;
        }
        return sum;
    }

    public static int merge(int [] arr,int l,int r,int mid){
        int sum = 0;
        int p1 = l;
        int p2 = mid + 1;
        int [] temp = new int[r - l + 1];
        int index = 0;
        while (p1 <= mid && p2 <= r){
            if(arr[p1] <= arr[p2]){
                sum += arr[p1]*(r - p2 + 1);
                temp[index ++] = arr[p1 ++];
            }else{
                temp[index ++] = arr[p2 ++];
            }
        }
        while (p1 <= mid){
            temp[index ++] = arr[p1 ++];
        }
        while (p2 <= r){
            temp[index ++] = arr[p2 ++];
        }
        for(int i = 0;i < temp.length;i ++){
            arr[l + i] = temp[i];
        }
        return sum;
    }
```
2.求一个数组中所有的降序对个数
```java
    public static int mergeSort(int [] arr,int l,int r){
        if(l == r)return 0;
        int mid = l + ((r - l) >> 1);
        return mergeSort(arr,l,mid)+
        mergeSort(arr,mid + 1,r)+
        merge(arr,l,r);
    }

    public static int merge(int [] arr,int l,int r){
        int mid = l + ((r - l) >> 1);
        int p1 = l;
        int p2 = mid + 1;
        int [] temp = new int[r - l + 1];
        int index = 0;
        int res = 0;
        while (p1 <= mid && p2 <= r){
            if(arr[p1] > arr[p2]){
                res += (mid - p1 + 1);
                temp[index ++] = arr[p2 ++];
            }else{
                temp[index ++] = arr[p1 ++];
            }
        }
        while (p1 <= mid){
            temp[index ++] = arr[p1 ++];
        }
        while (p2 <= r){
            temp[index ++] = arr[p2 ++];
        }
        for(int i = 0;i < temp.length;i ++){
            arr[l + i] = temp[i];
        }
        return res;
    }
```

**适用**
右（左）边有多少个数比某个数大（小）

### 快速排序
**荷兰国旗问题**
```java
    private static int[] process(int [] arr,int l,int r){
        int left = l - 1;
        int right = r;
        int index = l;
        while(index < right){
            if(arr[r] < arr[index]){
                swap(arr,-- right,index);
            }else if(arr[r] > arr[index]){
                swap(arr,++ left,index ++);
            }else{
                index ++;
            }
        }
        swap(arr,r,right);
        return new int[]{left + 1,right};
    }
```
**快速排序代码**

**方式**
用荷兰国旗问题求一组数的位置，然后递归求值，随机数导致结果的不确定性，根据数学期望求值，可以得出时间复杂度为O($N\log{N}$)

先分治，再荷兰国旗

**代码**
```java
//递归
    private static void quickSort(int [] arr,int l,int r){
        if(l >= r)return;
        int[] ranges = process(arr, l, r);
        quickSort(arr,l,ranges[0] - 1);
        quickSort(arr,ranges[1] + 1,r);
    }

    private static int[] process(int [] arr,int l,int r){
        if(r < l)return new int[]{-1,-1};
        if(r == l)return new int[]{l,l};
        int left = l - 1;
        int right = r + 1;
        int index = l;
        int aim = l + (int)(Math.random()*(r - l + 1));
        int tar = arr[aim];
        while(index < right){
            if(tar < arr[index]){
                swap(arr,-- right,index);
            }else if(tar > arr[index]){
                swap(arr,++ left,index ++);
            }else{
                index ++;
            }
        }
        return new int[]{left + 1,right - 1};
    }
```
**复杂度**
时间复杂度：O($N\log{N}$)
空间复杂度：O($\log{N}$)

### 堆排序
**方式**
用数组建堆，加入时加到末尾，向上调整，删除时用堆尾替换堆首，向下调整

**特点**
是一棵完全二叉树

**代码**
```java
    public static void heapSort(MyHeapSort myHeapSort){
        while(-- myHeapSort.heapSize >= 0){
            myHeapSort.swap(myHeapSort.heapSize,0);
            myHeapSort.heapify();
        }
    }

    private static class MyHeapSort{
        private int heapSize;
        private int maxSize;
        private int [] heap;

        public MyHeapSort(int maxSize){
            this.maxSize = maxSize;
            this.heap = new int[maxSize];
            this.heapSize = 0;
        }

        public void push(int value){
            if(heapSize == maxSize)return;
            heap[heapSize ++] = value;
            heapInsert();
        }

        //可优化
        private void heapInsert(){
            int index = heapSize - 1;
            int parent = (index - 1) >> 1;
            while(index != 0 && heap[index] > heap[parent]){
                swap(index,parent);
                index = parent;
                parent = (index - 1) >> 1;
            }
        }

        public Integer pop(){
            if(heapSize == 0)return null;
            int res = heap[0];
            swap(0,-- heapSize);
            heapify();
            return res;
        }

        private void heapify(){
            int index = 0;
            while (index < heapSize){
                int left = index * 2 + 1;
                if(left >= heapSize)break;
                int largest = (left + 1) >= heapSize?left:(heap[left] > heap[left + 1]?left:left + 1);
                largest = heap[largest] > heap[index]?largest:index;
                if(largest == index)break;
                swap(index,largest);
                index = largest;
            }
        }

        private void swap(int x,int y){
            int temp = heap[x];
            heap[x] = heap[y];
            heap[y] = temp;
        }
    }
```
```java
// O(N)方式建大根堆，从下往上建堆，根据数学计算收敛于O(N)，如果从上往下，达不到O(N)
    public static void createHeap(int [] arr){
        for(int i = (arr.length - 1)/2;i >= 0;i --){
            heapify(arr,i);
        }
    }

    private static void heapify(int [] heap,int index){
        int heapSize = heap.length;
        while (index < heapSize){
            int left = index * 2 + 1;
            if(left >= heapSize)break;
            int largest = (left + 1) >= heapSize?left:(heap[left] > heap[left + 1]?left:left + 1);
            largest = heap[largest] > heap[index]?largest:index;
            if(largest == index)break;
            swap(heap,index,largest);
            index = largest;
        }
    }
```

**复杂度**
时间复杂度：O($N\log{N}$)
空间复杂度：O(1)

#### 语言提供的堆排序PriorityQueue与自己写的

1、给一个几乎有序的数组（排完序后数组位置移动不超过k,k相对于n很小），进行排序

```java
    private static void sort(int [] arr,int k){
        PriorityQueue<Integer> priorityQueue = new PriorityQueue();
        for(int i = 0;i <= k;i ++) {
            priorityQueue.add(arr[i]);
        }
        for(int i = k + 1;i < arr.length;i ++){
            Integer poll = priorityQueue.poll();
            arr[i - k - 1] = poll;
            priorityQueue.add(arr[i]);
        }
        int index = arr.length - k - 1;
        while (!priorityQueue.isEmpty()){
            arr[index ++] = priorityQueue.poll();
        }
    }
```

2.给定一个对象数组，在数据进入堆之后，对象数组的内容会进行改变，此时无法使用系统给定的堆，要自己写

```java
public class MyHeapSort<T> {
    private ArrayList<T> arr = new ArrayList<>();
    private Comparator<? super T> comparator;
    private Map<T,Integer> map = new HashMap<>();

    public MyHeapSort(Comparator<? super T> comparator) {
        this.comparator = comparator;
    }

    public void push(T value){
        arr.add(value);
        map.put(value,arr.size() - 1);
        heapInsert(arr.size() - 1);
    }

    public T pop(){
        T res = arr.get(0);
        swap(0,arr.size() - 1);
        map.remove(res);
        arr.remove(arr.size() - 1);
        heapify(0);
        return res;
    }

    private void heapInsert(int index){
        int parentIndex = (index - 1)/2;
        T value = arr.get(index);
        T parent = arr.get(parentIndex);
        while (comparator.compare(value,parent) > 0){
            swap(index,parentIndex);
            index = parentIndex;
            parentIndex = (index - 1)/2;
            value = arr.get(index);
            parent = arr.get(parentIndex);
        }
    }

    public void resign(T value){
        Integer integer = map.get(value);
        heapify(integer);
        heapInsert(integer);
    }

    private void heapify(int index){
        int left = index * 2 + 1;
        while(left < arr.size()){
            int largest = left + 1 < arr.size() && comparator.compare(arr.get(left + 1),arr.get(left)) > 0?left + 1:left;
            largest = comparator.compare(arr.get(index),arr.get(largest)) > 0?index:largest;
            if(largest == index)break;
            swap(largest,index);
            index = largest;
            left = index * 2 + 1;
        }
    }

    private void swap(int x,int y){
        T t1 = arr.get(x);
        T t2 = arr.get(y);
        arr.set(y,t1);
        arr.set(x,t2);
        map.put(t1,y);
        map.put(t2,x);
    }
}
```

## 

### 桶排序（不基于比较的排序）
**方式**
用空间换时间，限制较大，要满足特定情况才能使用

**复杂度**
时间复杂度：O(N)
空间复杂度：O(M)

#### 计数排序
当数据量比较小时，可以用一个范围建桶进行排序
```java
    public int [] counterSort(int [] arr){
        if(arr == null || arr.length < 2)return arr;
        //1.计算当前最大值
        int max = calculateMax(arr);
        //2.建桶放入数据
        int [] bucket = new int[max + 1];
        for(int i = 0;i < arr.length;i ++){
            bucket[arr[i]] ++;
        }
        //3.排序
        int [] res  = new int[arr.length];
        int index = 0;
        for(int i = 1;i < bucket.length;i ++){
            while (bucket[i] > 0){
                res[index ++] = i;
                bucket[i] --;
            }
        }
        return res;
    }

    private int calculateMax(int [] arr){
        int max = -1;
        for(int i = 0;i < arr.length;i ++){
            max = Math.max(max, arr[i]);
        }
        return max;
    }
```

#### 基数排序
当数据非负时，可以使用
```java
    public void radixSort(int [] arr){
        int radix = 10;
        int length = String.valueOf(calculateMax(arr)).length();
        for(int i = 0;i < length;i ++){
            int [] bucket = new int[radix];
            for(int j = 0;j < arr.length;j ++){
                int indexValue = getIndexValue(arr[j], i, radix);
                bucket[indexValue]++;
            }
            //转换bucket
            for(int j = 0;j < bucket.length - 1;j ++){
                bucket[j + 1] += bucket[j];
            }
            //插入
            int [] res = new int[arr.length];
            for(int j = arr.length - 1;j >= 0;j --){
                int indexValue = getIndexValue(arr[j], i, radix);
                res[-- bucket[indexValue]] = arr[j];
            }
            arr = res;
        }
    }

    private int getIndexValue(int num,int index,int radix){
        for(int i = 0;i < index;i ++){
            num = num / radix;
        }
        return num % radix;
    }
    
    private int calculateMax(int [] arr){
        int max = -1;
        for(int i = 0;i < arr.length;i ++){
            max = Math.max(max, arr[i]);
        }
        return max;
    }
```

### 稳定性
选择排序：不稳定
冒泡排序：稳定
插入排序：稳定
归并排序：稳定
快速排序：不稳定，速度最快
堆排序：不稳定，空间最小
计数排序：稳定
基数排序：稳定

### 常见坑
1.归并排序空间复杂度可以变成O(1)，但是会丢失稳定性（归并排序内部缓存法）
2.原地归并排序垃圾算法，时间复杂度为O($N^{2}$)
3.快排可以变稳定，（01 stable sort），但是这样对数据要求很高，不如使用桶排序
4.在整型数组中，将奇数部分放左边，将偶数部分放右边，要求时间复杂度O(N)，空间复杂度O(1)并且具有稳定性?
不可能完成，因为这种情况是partition的算法，如果能做到的话，快速排序怎么没法做到稳定

### 总结

|          | 时间复杂度 | 空间复杂度 | 稳定性 |
| -------- | ---------- | ---------- | ------ |
| 选择排序 | O($N^2$)        | O(1) | 不稳定 |
| 冒泡排序 | O($N^2$) | O(1) | 稳定 |
| 插入排序 | O($N^2$) | O(1) | 稳定 |
| 归并排序 | O($N\log{N}$) | O(N) | 稳定 |
| 堆排序 | O($N\log{N}$) | O(1) | 不稳定 |
| 快速排序 | O($N\log{N}$) | O($\log{N}$) | 不稳定 |
| 计数排序 | O(max(N)) | O(1) | 稳定 |
| 基数排序 | O($\log_{radix}{max(N)}$) | O(1) | 稳定 |

### 工程上对排序的改进
1.基于稳定性考虑
2.基于O($N\log{N}$)与O(N^2)算法的优势考虑


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

### 链表题目
1.输入链表头节点，奇数长度返回中点，偶数长度返回上中点
```java
    private static Node getMiddle(Node head){
        if(head == null || head.getNext() == null || head.getNext().getNext() == null)return head;
        Node slow = head.getNext();
        Node fast = head.getNext().getNext();
        while(fast.getNext() != null && fast.getNext().getNext() != null){
            slow = slow.getNext();
            fast = fast.getNext().getNext();
        }
        return slow;
    }
```

2.输入链表头节点，奇数长度返回中点，偶数长度返回下中点
```java
    private static Node getUnderMiddle(Node head){
        if(head == null || head.getNext() == null)return head;
        Node slow = head.getNext();
        Node fast = head.getNext();
        while(fast.getNext() != null && fast.getNext().getNext() != null){
            slow = slow.getNext();
            fast = fast.getNext().getNext();
        }
        return slow;
    }
```

3.输入链表头节点，奇数长度返回中点前一个，偶数长度返回上中点前一个
```java
    private static Node getPreUnderMiddle(Node head){
        if(head == null || head.getNext() == null)return head;
        Node slow = head.getNext();
        Node fast = head.getNext();
        while(fast.getNext() != null && fast.getNext().getNext() != null){
            slow = slow.getNext();
            fast = fast.getNext().getNext();
        }
        return slow;
    }
```

4.输入链表头节点，奇数长度返回中点前一个，偶数长度返回下中点前一个
```java
    private static Node getPreUnderMiddle(Node head){
        if(head == null || head.getNext() == null)return head;
        Node slow = head;
        Node fast = head.getNext();
        while(fast.getNext() != null && fast.getNext().getNext() != null){
            slow = slow.getNext();
            fast = fast.getNext().getNext();
        }
        return slow;
    }
```

5.给定一个单链表的头，判断是否为回文链表
①全部节点入栈，然后出栈一一比较
②快慢指针找中点，逆序比较
```java
    private static boolean isPalindromic(Node head){
        if(head == null || head.getNext() == null)return true;
        boolean res = true;
        Node slow = head;
        Node fast = head;
        while(fast.getNext() != null && fast.getNext().getNext() != null){
            slow = slow.getNext();
            fast = fast.getNext().getNext();
        }
        Node right = reverseLinklist(slow);
        Node left = head;
        Node tail = right;
        while (left != null && left.getVal() == right.getVal()){
            left = left.getNext();
            right = right.getNext();
        }
        if(left != null){
            res = false;
        }
        reverseLinklist(tail);
        return res;
    }

    private static Node reverseLinklist(Node head){
        Node pre = null;
        while (head != null){
            Node next = head.getNext();
            head.setNext(pre);
            pre = head;
            head = next;
        }
        return pre;
    }
```
6.将单链表按某值分为左小中等右大的形式
```java
//六指针完成
    private static Node partitionLink(Node head,int target){
        if(head == null || head.getNext() == null)return head;
        Node lH = null;
        Node lT = null;
        Node mH = null;
        Node mT = null;
        Node rH = null;
        Node rT = null;
        while(head != null){
            Node next = head.getNext();
            head.setNext(null);
            if(head.getVal() < target){
                if(lH == null){
                    lH = head;
                }else{
                    lT.setNext(head);
                }
                lT = head;
            }else if(head.getVal() == target){
                if(mH == null){
                    mH = head;
                }else{
                    mT.setNext(head);
                }
                mT = head;
            }else{
                if(rH == null){
                    rH = head;
                }else{
                    rT.setNext(head);
                }
                rT = head;
            }
            head = next;
        }
        Node res = null;
        if(lH != null){
            res = lH;
            if(mH == null){
                lT.setNext(rH);
            }else{
                lT.setNext(mH);
                mT.setNext(rH);
            }
        }else if(mH != null){
            res = mH;
            mT.setNext(rH);
        }else{
            res = rH;
        }
        return res;
    }
```
7.rand指针时单链表节点结构中新增的指针，rand可能指向链表中的任意一个节点，也可能指向null，给定一个由Node节点类型组成的无环单链表的头节点head，请实现一个函数完成这个链表的复制，并返回复制的新链表的头结点
要求：时间复杂度O(N),额外空间复杂度O(1)
```java
    private static Node copyLinkedList(Node head){
        if(head == null)return null;
        //节点增值
        Node temp = head;
        while(temp != null){
            Node next = temp.getNext();
            Node node = new Node(temp.getVal());
            temp.setNext(node);
            node.setNext(next);
            temp = next;
        }
        //节点复制
        temp = head;
        while (temp != null){
            Node copyNode = temp.getNext();
            Node next = copyNode.getNext();
            copyNode.setRand(temp.getRand()==null?null:temp.getRand().getNext());
            temp = next;
        }
        //断链恢复节点
        Node res = head.getNext();
        temp = head;
        while (temp != null){
            Node copyNode = temp.getNext();
            Node next = copyNode.getNext();
            if(next != null){
                temp.setNext(next);
                copyNode.setNext(next.getNext());
            }
            temp = next;
        }
        return res;
    }
```
8.给定两个可能有环也可能无环的单链表，头节点head1和head2.实现一个函数，如果两个链表相交，返回相交的第一个节点，如果不相交，返回null
两个链表长度之和为N，时间复杂度达到O(N),空间复杂度达到O(1)

```java
    private static Node findIntersect(Node head1,Node head2){
        if(head1 == null || head2 == null)return null;
        Node loop1 = getLoop(head1);
        Node loop2 = getLoop(head2);
        if(loop1 == null && loop2 == null){
            return getUnCircleNode(head1,head2);
        }else if(loop1 != null && loop2 != null){
            return getCircleNode(head1,head2,loop1,loop2);
        }
        return null;
    }

    private static Node getUnCircleNode(Node head1,Node head2){
        int len1 = 0,len2 = 0;
        Node tail1 = head1;
        while (tail1.getNext() != null){
            tail1 = tail1.getNext();
            len1 ++;
        }
        Node tail2 = head2;
        while (tail2.getNext() != null){
            tail2 = tail2.getNext();
            len2 ++;
        }
        if(tail1 != tail2)return null;
        int largest = Math.max(len1,len2);
        if(len1 > len2){
            for(int i = 0;i < largest - len2;i ++){
                head1 = head1.getNext();
            }
        }else{
            for(int i = 0;i < largest - len1;i ++){
                head2 = head2.getNext();
            }
        }
        while (head1 != head2){
            head1 = head1.getNext();
            head2 = head2.getNext();
        }
        return head1;
    }

    private static Node getCircleNode(Node head1,Node head2,Node loop1,Node loop2){
        if(loop1 == loop2){
            int len1 = 0,len2 = 0;
            Node tail1 = head1;
            while (tail1.getNext() != loop1){
                tail1 = tail1.getNext();
                len1 ++;
            }
            Node tail2 = head2;
            while (tail2.getNext() != loop2){
                tail2 = tail2.getNext();
                len2 ++;
            }
            int largest = Math.max(len1,len2);
            if(len1 > len2){
                for(int i = 0;i < largest - len2;i ++){
                    head1 = head1.getNext();
                }
            }else{
                for(int i = 0;i < largest - len1;i ++){
                    head2 = head2.getNext();
                }
            }
            while (head1 != head2){
                head1 = head1.getNext();
                head2 = head2.getNext();
            }
            return head1;
        }else{
            Node temp = loop1;
            loop1 = loop1.getNext();
            while (loop1 != loop2 && loop1 != temp){
                loop1 = loop1.getNext();
            }
            return loop1==loop2?loop1:null;
        }
    }

    private static Node getLoop(Node head){
        if(head == null)return null;
        Node slow = head;
        Node fast = head;
        while (fast.getNext() != null && fast.getNext().getNext() != null){
            slow = slow.getNext();
            fast = fast.getNext().getNext();
            if(slow == fast)break;
        }
        if(slow != fast){
            return null;
        }
        fast = head;
        while (slow != fast){
            slow = slow.getNext();
            fast = fast.getNext();
        }
        return slow;
    }
```
10.能不能不给头结点，删除想要删除的节点
不行，会有问题，唯一的一种做法是将后面节点的内容移到当前节点，再将当前节点指向下一个节点的下一个节点，实现一个伪装，但是这么做有缺点，一个是删除尾部节点的时候会有问题，无法删除，还一个是如果删除的是服务器，正在对外界提供服务，移到新节点上后仍然无法直接删除后面那个节点


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
T(N) = aT($\frac{N}{b}$)+O($N^d$)
子问题的规模X次数+O(N),a,b,d为常数

求时间复杂度的Master
1.当 $\log_{b}{a}$ < d ,复杂度为O($N^d$)
2.当 $\log_{b}{a}$ > d ,复杂度为O($N^{\log_{b}{a}}$)
3.当 $\log_{b}{a}$ == d ,复杂度为O($N^d$ $\log{N}$)

## 常用容器的复杂度
**HashMap**
增删改查全为O(1)

**TreeMap**
增删改查全为O($\log{N}$)

## 前缀树
**代码**
```java

public class Trie {
    private Node root;
    public Trie(){
        root = new Node();
    }

    public void insert(String string){
        if(string == null || string == "")return;
        char[] str = string.toCharArray();
        Node node = root;
        node.pass ++;
        for(char ch : str){
            if(!node.nexts.containsKey(ch)){
                node.nexts.put(ch,new Node());
            }
            node = node.nexts.get(ch);
            node.pass ++;
        }
        node.end ++;
    }

    public int search(String string){
        if(string == null || string == "")return 0;
        char[] str = string.toCharArray();
        Node node = root;
        for(char ch : str){
            if(!node.nexts.containsKey(ch)){
                return 0;
            }
            node = node.nexts.get(ch);
        }
        return node.end;
    }

    public int searchPrefix(String string){
        if(string == null || string == "")return 0;
        char[] str = string.toCharArray();
        Node node = root;
        for(char ch : str){
            if(!node.nexts.containsKey(ch))return 0;
            node = node.nexts.get(ch);
        }
        return node.pass;
    }



    public void delete(String string){
        if(string == null || string == "")return;
        if(search(string) > 0){
            char[] str = string.toCharArray();
            Node node = root;
            node.pass --;
            for(char ch : str){
                if(-- node.pass == 0){
                    node.nexts = new HashMap<>();
                    return;
                }
                node = node.nexts.get(ch);
            }
            node.end --;
        }
    }

    class Node{
        private Map<Character,Node> nexts = new HashMap<>();
        private int pass;
        private int end;

        public Node(){
            pass = 0;
            end = 0;
        }
    }
}
```

**复杂度**
时间复杂度：O(N)

## 二叉树
### 先序中序后序的迭代写法
```java
public class Node {
    public int val;
    public Node left;
    public Node right;
}
//先序
    private static void preOrder(TreeNode head){
        if(head == null)return;
        Deque<TreeNode> stack = new ArrayDeque<>();
        stack.push(head);
        while (!stack.isEmpty()){
            TreeNode node = stack.poll();
            System.out.println(node.val);
            if(node.right != null){
                stack.push(node.right);
            }
            if(node.left != null){
                stack.push(node.left);
            }
        }
    }
//后序
    private static void postOrder(TreeNode head){
        Deque<TreeNode> stack = new ArrayDeque<>();
        Deque<TreeNode> helper = new ArrayDeque<>();
        stack.push(head);
        while (!stack.isEmpty()){
            TreeNode node = stack.poll();
            helper.push(node);
            if(node.left != null){
                stack.push(node.left);
            }
            if(node.right != null){
                stack.push(node.right);
            }
        }
        while (!helper.isEmpty()){
            System.out.println(helper.poll().val);
        }
    }
//中序
    private static void inOrder(TreeNode head){
        Deque<TreeNode> stack = new ArrayDeque<>();
        while (!stack.isEmpty() || head != null){
            if(head != null){
                stack.push(head);
                head = head.left;
            }else{
                head = stack.pop();
                System.out.println(head.val);
                head = head.right;
            }
        }
    }
//非翻转后序
    private static void postOrderNotReverse(TreeNode head){
        Deque<TreeNode> stack = new ArrayDeque<>();
        stack.push(head);
        TreeNode curNode = head;
        while (!stack.isEmpty()){
            if(curNode.left != null && curNode.left != head && curNode.right != head){
                stack.push(curNode.left);
                curNode = curNode.left;
            }else if(curNode.right != null && curNode.right != head){
                stack.push(curNode.right);
                curNode = curNode.right;
            }else{
                curNode = stack.pop();
                System.out.println(curNode.val);
                head = curNode;
                curNode = stack.peek();
            }
        }
    }
```

### 二叉树题目

1.二叉树的序列化和反序列化
使用null记录子节点
```java
//先序方式
    private static void serialize(TreeNode head, Queue<String> queue){
        if(head == null){
            queue.offer(null);
            return;
        }
        queue.offer(String.valueOf(head.val));
        serialize(head.left,queue);
        serialize(head.right,queue);
    }

    private static TreeNode analysis(Queue<String> queue){
        String poll = queue.poll();
        if(poll == null){
            return null;
        }
        TreeNode node = new TreeNode(Integer.valueOf(poll));
        node.left = analysis(queue);
        node.right = analysis(queue);
        return node;
    }
//层序方式
    private static void levelTraversalSerialize(TreeNode head, Queue<String> queue){
        Queue<TreeNode> helper = new LinkedList<>();
        helper.offer(head);
        while (!helper.isEmpty()){
            TreeNode poll = helper.poll();
            if(poll != null){
                queue.offer(String.valueOf(poll.val));
                helper.offer(poll.left);
                helper.offer(poll.right);
            }else{
                queue.offer(null);
            }
        }
    }

    private static TreeNode levelTraversalAnalysis(Queue<String> queue){
        if(queue.isEmpty())return null;
        TreeNode head = new TreeNode(Integer.valueOf(queue.poll()));
        Queue<TreeNode> helper = new LinkedList<>();
        helper.offer(head);
        while (!helper.isEmpty()) {
            TreeNode poll = helper.poll();
            String leftVal = queue.poll();
            String rightVal = queue.poll();
            TreeNode left = null;
            TreeNode right = null;
            if(leftVal != null){
                left = new TreeNode(Integer.valueOf(leftVal));
                helper.add(left);
            }
            if(rightVal != null){
                right = new TreeNode(Integer.valueOf(rightVal));
                helper.add(right);
            }
            poll.left = left;
            poll.right = right;
        }
        return head;
    }
```
