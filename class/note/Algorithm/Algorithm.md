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
            //插入,为了不打破稳定性，从后向前输入
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
### 二叉树递归套路
1.假设以X为头，假设左右两边树可以给我想要的信息
2.讨论我需要什么信息
3.构建信息类
4.把左树信息和右树信息求全集，就是任何一棵子树都需要返回的信息S
5.递归函数都返回S，每一棵子树都这么要求
6.写代码，在代码中考虑如何整合左树右树信息

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

2.把一段纸条竖着放在桌子上，从纸条的下边向上方对折一次，压出折痕后展开，此时折痕是凹下去的。如果从纸条的下边向上方连续对折两次，压出折痕后展开，此时有三条折痕，从上到下依次是凹折痕，凹折痕，凸折痕。
给定一个输入参数N，代表纸条都从下边向上方连续对折N次，从上到下打印所有折痕方向

解析：每一次折都会在上边生成一条凹折痕，下边生成一条凸折痕，是一个二叉树的中序遍历
```java
    private static void printFold(int n,int layer,boolean isDown){
        if(layer > n)return;
        printFold(n,layer + 1,true);
        System.out.print(isDown?"down ":"up ");
        printFold(n,layer + 1,false);
    }
```
3.给定一棵二叉树的头节点head，任何两个节点之间都存在距离，返回整棵二叉树的最大距离
```java
    static class Info{
        private int height;
        private int maxValue;

        public Info(int height, int maxValue) {
            this.height = height;
            this.maxValue = maxValue;
        }
    }

    private static Info findMaxDistance(Node head){
        if(head == null)return new Info(0,0);
        Info left = findMaxDistance(head.left);
        Info right = findMaxDistance(head.right);
        int maxValue = Math.max(left.height + right.height + 1,right.maxValue);
        maxValue = Math.max(maxValue,left.maxValue);
        int height = Math.max(left.height,right.height) + 1;
        return new Info(height,maxValue);
    }
```
4.给定一个二叉树头节点，返回这课二叉树最大二叉搜索子树的节点个数
```java
    static class Info{
        private int numbers;
        private boolean isBinarySearchTree;

        public Info(int numbers, boolean isBinarySearchTree) {
            this.numbers = numbers;
            this.isBinarySearchTree = isBinarySearchTree;
        }
    }

    private static Info findMaxBinarySearchTree(Node node){
        if(node == null)return new Info(0,true);
        Info left = findMaxBinarySearchTree(node.left);
        Info right = findMaxBinarySearchTree(node.right);
        int numbers = Math.max(left.numbers,right.numbers);
        boolean isBinarySearchTree = false;
        if(((node.left != null && node.val > node.left.val)||(node.left == null)) && ((node.right != null && node.val < node.right.val)||(node.right == null)) && left.isBinarySearchTree && right.isBinarySearchTree){
            numbers = left.numbers + right.numbers + 1;
            isBinarySearchTree = true;
        }
        return new Info(numbers,isBinarySearchTree);
    }
```


5.派对最大快乐值,当员工被邀请，他的下属就无法被邀请，求最大值
员工定义信息如下
```java
    static class Employee{
        public int happy;
        List<Employee> subordinates;
    }
```
```java
static class Info{
        private int happyWithCurNode;
        private int happyWithOutCurNode;

        public Info(int happyWithCurNode, int happyWithOutCurNode) {
            this.happyWithCurNode = happyWithCurNode;
            this.happyWithOutCurNode = happyWithOutCurNode;
        }
    }

    private static int maxHappy(Employee node){
        if(node == null)return 0;
        return Math.max(findMaxHappy(node).happyWithCurNode,findMaxHappy(node).happyWithOutCurNode);
    }

    private static Info findMaxHappy(Employee node){
        if(node.subordinates == null)return new Info(node.happy,0);
        List<Info> list = new ArrayList<>();
        for(Employee employee:node.subordinates){
            list.add(findMaxHappy(employee));
        }
        int happyWithCurNode = node.happy;
        int happyWithOutCurNode = 0;
        for(Info info:list){
            happyWithCurNode += info.happyWithOutCurNode;
            happyWithOutCurNode += Math.max(info.happyWithCurNode,info.happyWithOutCurNode);
        }
        return new Info(happyWithCurNode,happyWithOutCurNode);
    }
```
6.求一棵树是否为满二叉树（非层序遍历实现）
定义信息为是否为满二叉树，完全二叉树和高度
```java
    public boolean isFullTree(TreeNode node){
        return isFull(node).isCBT;
    }

    private FullTreeInfo isFull(TreeNode node){
        if(node == null)return new FullTreeInfo(0,true,true);
        FullTreeInfo left = isFull(node.left);
        FullTreeInfo right = isFull(node.right);
        int height = Math.max(left.height,right.height) + 1;
        boolean isFull = false;
        boolean isCBT = false;
        if(left.isFull && right.isFull && left.height == right.height){
            isFull = true;
            isCBT = true;
        }else if(left.isCBT && right.isCBT){
            if(left.isCBT && right.isFull && left.height == right.height + 1){
                isCBT = true;
            }else if(left.isFull && right.isFull && left.height == right.height + 1){
                isCBT = true;
            }else if(left.isFull && right.isCBT && left.height == right.height){
                isCBT = true;
            }
        }
        return new FullTreeInfo(height,isFull,isCBT);
    }

    class FullTreeInfo{
        private int height;
        private boolean isFull;
        private boolean isCBT;

        public FullTreeInfo(int height, boolean isFull, boolean isCBT) {
            this.height = height;
            this.isFull = isFull;
            this.isCBT = isCBT;
        }
    }
```
7.给定一棵二叉树头结点，和另外两个结点a和b，返回a和b的最低公共祖先
```java
    //求二叉树的最低公共祖先
    public static TreeNode findPublicAncestor(TreeNode head,TreeNode a,TreeNode b){
        return publicAncestor(head,a,b).ancestor;
    }
    private static AncestorInfo publicAncestor(TreeNode node,TreeNode a,TreeNode b){
        if(node == null)return new AncestorInfo(false,false,null);
        AncestorInfo left = publicAncestor(node.left,a,b);
        AncestorInfo right = publicAncestor(node.right,a,b);
        TreeNode ancestor = null;
        if(left.ancestor != null || right.ancestor != null){
            ancestor = left.ancestor != null?left.ancestor:right.ancestor;
            return new AncestorInfo(true,true,ancestor);
        }
        boolean isHasA = (left.isHasA || right.isHasA)?true:false;
        boolean isHasB = (left.isHasB || right.isHasB)?true:false;
        if(node == a){
            isHasA = true;
        }else if(node == b){
            isHasB = true;
        }

        if(isHasA && isHasB){
            ancestor = node;
        }
        return new AncestorInfo(isHasA,isHasB,ancestor);
    }
    static class AncestorInfo{
        boolean isHasA;
        boolean isHasB;
        TreeNode ancestor;

        public AncestorInfo(boolean isHasA, boolean isHasB,TreeNode ancestor) {
            this.isHasA = isHasA;
            this.isHasB = isHasB;
            this.ancestor = ancestor;
        }
    }
```

## 贪心算法

**定义**
每一步都是最优解，并且最终都是最优解

### 经典贪心
给一个由字符串组成的数组strs，把所有的字符拼接起来，返回所有可能的拼接结果中，字典序最小的结果？

#### 思路
第一种贪心的思路是直接将字符数组按照字典序排序，并拼接，但是会发现这种策略是错误的，当出现数组中有dcb，d这种情况时，显然ddcb比dcbd字典序要大

由于第一种贪心思路的问题，我们找出了第二种贪心策略，即比较的时候用ddcb和dcbd来比较，这样子就处理了上面产生的问题

#### 证明
主要要证明A.B <= B.A的传递性，然后证明拼接后是最小值

#### 代码
```java
public String concatStr(String [] strs){
        Arrays.sort(strs,(obj1,obj2)-> (obj1+obj2).compareTo(obj2+obj1));
        return Arrays.stream(strs).reduce((x1,x2)-> x1 + x2).get();
    }
```
### 解题套路
1.实现一个不依靠贪心策略的解法
2.假设一个贪心策略的解法
3.用对数器去比较，看看是否得出正确答案
4.不要纠结贪心策略的证明，因为每一个贪心策略的题目的解法都不一样

ps：贪心策略是经验优先的，不要死扣证明

### 题目
1.一些项目要占用一个会议室宣讲，会议室不能同时容纳两个项目的宣讲。给你每一个项目开始的时间和结束的时间，你来安排宣讲的日程，要求会议室进行的宣讲的场次最多。返回最多的宣讲场次。
贪心策略：按照结束时间去排序，然后比较开始时间是否符合要求

2.给一个字符数组，'X'表示墙，'.'表示房子，一个房子可以放一个灯，一个灯可以照亮自己房子和旁边的房子，要求求出至少需要多少灯能照亮所有人家
贪心策略：找到一个结点i，i中为X时跳过，i中为.时去看i+1位置，如果是X就加灯并去i+2执行，如果是.就加灯去i + 3 执行
```java
public int calculateLights(String s){
        char[] chars = s.toCharArray();
        int len = chars.length;
        int index = 0;
        int lights = 0;
        while (index < len){
            char ch = chars[index];
            if(ch == 'X'){
                index ++;
            }else{
                lights ++;
                if(index + 1 < len){
                    if(chars[index + 1] == 'X'){
                        index = index + 2;
                    }else {
                        index = index + 3;
                    }
                }else{
                    break;
                }
            }
        }
        return lights;
    }
```

3.一块金条切成两半，是需要花费和长度数值一样的铜板的
比如长度为20的金条，不管怎么切，都需要花费20个铜板，一群人想要分整块金条，怎么分最省铜板
例如，给定数组{10，20，30}，代表一共三个人，整块金条长度为60，金条要分成10，20，30三个部分。
如果先把长度60的金条分成10和50，花费60，再把长度50的分成20和30，花费50，一共花110，但如果先把60分成30和30，再分成10和20，花费90
输入一个数组，返回分割的最小代价
贪心策略：先从小到大排序，再相加后拿新的最小两两相加，最后一定花费最小（用小根堆相加）（哈夫曼树）

```java
    public int calculateCost(int [] splits){
        PriorityQueue<Integer> priorityQueue = new PriorityQueue<>();
        Arrays.stream(splits).forEach((x)->priorityQueue.offer(x));
        int sum = 0;
        while (priorityQueue.size() != 1){
            Integer i1 = priorityQueue.poll();
            Integer i2 = priorityQueue.poll();
            int cur = i1 + i2;
            sum += cur;
            priorityQueue.add(cur);
        }
        return sum;
    }
```
4.你有一些项目给定了花费(int [] spend)和利润(int [] salary)，你有初始资金w和最多能做k个项目，求k个项目做完后自己涨到多少了
贪心策略：找出当前利润最高的并且费用符合的项目进行执行（大根堆存解锁的项目）（小根堆按照花费存储项目）
```java
    public int findMaxMoney(int [] spend,int [] salary,int w,int k){
        PriorityQueue<Program> waitQueue = new PriorityQueue<>((x1,x2)->x1.spend-x2.spend);
        PriorityQueue<Program> unlockQueue = new PriorityQueue<>((x1,x2)->x2.salary-x1.salary);

        for(int i = 0;i < spend.length;i ++){
            waitQueue.offer(new Program(spend[i],salary[i]));
        }

        int res = 0;
        for(int i = 0;i < k;i ++){
            while (!waitQueue.isEmpty()){
                Program peek = waitQueue.peek();
                if(peek.spend <= w){
                    unlockQueue.offer(waitQueue.poll());
                }else{
                    break;
                }
            }
            if(unlockQueue.isEmpty())break;
            Program task = unlockQueue.poll();
            res += task.salary;
            w += task.salary;
        }

        return res;
    }
```

## 并查集

### 定义
1.有若干个样本a,b,c,d类型都是V
2.在并查集中一开始认为每个样本都在独立的集合里
3.用户可以在任何时候调用如下两个方法
boolean isSameSet(V x,V y):查询x和y是否处于一个集合
void union(V x,V y):把x和y各自所在的集合的所有样本合并成一个集合
4.isSameSet和union方法代价尽可能低

### 复杂度
调用频繁的情况下单次O(1)

### 结构
```java
public class UnionSet<V> {
    public HashMap<V,Node<V>> nodes = new HashMap<>();
    public HashMap<Node<V>,Node<V>> parents = new HashMap<>();
    public HashMap<Node<V>,Integer> sizeMap = new HashMap<>();

    public UnionSet(List<V> values){
        for(V v:values){
            Node<V> node = new Node<>(v);
            nodes.put(v,node);
            parents.put(node,node);
            sizeMap.put(node,1);
        }
    }

    public Node<V> findParent(Node<V> node){
        ArrayDeque<Node<V>> stack = new ArrayDeque();
        while (node != parents.get(node)){
            stack.push(node);
            node = parents.get(node);
        }
        while (!stack.isEmpty()){
            parents.put(stack.pop(),node);
        }
        return node;
    }

    public boolean isSameSet(V x,V y){
        if(!nodes.containsKey(x) || !nodes.containsKey(y))return false;
        return parents.get(nodes.get(x)) == parents.get(nodes.get(y));
    }

    public void union(V x,V y){
        if(!nodes.containsKey(x) || !nodes.containsKey(y))return;
        Node<V> xNode = nodes.get(x);
        Node<V> yNode = nodes.get(y);

        Node<V> xParent = findParent(xNode);
        Node<V> yParent = findParent(yNode);
        if(xParent != yParent) {
            Node<V> small = sizeMap.get(xParent) < sizeMap.get(yParent) ? xParent : yParent;
            Node<V> big = sizeMap.get(xParent) < sizeMap.get(yParent) ? yParent : xParent;
            parents.put(small, big);
            sizeMap.put(big,sizeMap.get(small) + sizeMap.get(big));
            sizeMap.remove(small);
        }
    }

    class Node<V>{
        V value;

        public Node(V value) {
            this.value = value;
        }
    }
}
```

##  图
图的表示方式有很多，不只是邻接表法和邻接矩阵法

### 结构
Node
```java
public class Node{
	public int value;
	public int in;
	public int out;
	public ArrayList<Node> nexts;
	public ArrayList<Edge> edges; //从该点出发的所有边
}
```
Edge
```java
public class Edge{
	public int weight;
	public Node from;
	public Node to;
}
```
Graph
```java
public class Graph{
	public HashMap<Integer,Node> nodes;
	public HashSet<Edge> edges;
}
```
### 遍历
**宽度优先遍历**
和树一样，不过要加入一个HashSet来防止环形成的无限循环问题

**深度优先遍历**
维护一个stack来模拟递归过程，加入一个HashSet来防止环形成的无限循环问题
```java
    public void dfs(Node node){
        ArrayDeque<Node> stack = new ArrayDeque();
        HashSet<Node> set = new HashSet<>();
        stack.push(node);
        System.out.println(node.value);
        while (!stack.isEmpty()){
            Node curNode = stack.pop();
            if(curNode.nexts != null){
                for(int i = 0;i < curNode.nexts.size();i ++){
                    if(!set.contains(curNode.nexts.get(i))){
                        stack.push(curNode);
                        stack.push(curNode.nexts.get(i));
                        set.add(curNode.nexts.get(i));
                        System.out.println(node.value);
                        break;
                    }
                }
            }
        }
    }
```

### 拓扑排序
一个有向无环图，做一个拓扑排序
1.先计算各个结点的入度
2.入度为0的先排序，然后将其对应的子节点入度减一，无限循环步骤2直到没有结点

### 最小生成树
不破坏连通性的情况下删除权重大的边

**克鲁斯卡尔Kruskal算法**
流程：
1.将所有边根据权值由小到大排序
2.使用并查集依次插入直到并查集sizeMap大小为1

**普里姆Prim算法**
随便从一个点出发，找出当前解锁的所有边中最小的，选择那条边，如果边的两边点有一个未解锁，就要那个边，如果都解锁了，就不要那个边