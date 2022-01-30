# 机器学习

## 应用场景

1.医用治疗

2.推荐系统

3.AI

## 思路

数据+算法=模型

数据量决定了模型的高度，算法只是逼近这个高度

大数据是机器学习的根基

## 算法

### 线性回归

$y = w_0 + w_1x$

**目的**

空间的点到直线的距离，找拟合曲线

**解决方案**

量化空间的点到直线的y距离，量化公式(误差函数，损失函数，目标函数)为：

![image-20220123195527742](./picture/1642939000(1).jpg)



含义：将每个点的x轴对应线上的y值求出，减去它当前的y值，然后再取平方和的平均数，除以2是为了方便求导

其中，$h_θ(x^{(i)})$为要求的线，假设有两个列向量$W=(w_0,w_1)$,X=(1,x),则$h_θ(x^{(i)})$也可以表示为$W^T*X$

即原式子表示为$J(θ)=\frac{1}{2m}∑(W^T*X-y^i)^2$

因为极小值表示为三维曲面的凹函数，需要求a和b的偏导，让其等于0

**在多维情况下，x不止为一个，所以无法使用求偏导的情况求出对应的a和b等，所以无法反推，需要进行尝试**

#### 步骤

##### 训练模型

1.人为设置容忍值capacity，随机产生w参数

2.调整$w_0,w_1...$<a href="#tiaocan">如何调整</a>

3.将数据集带入方程

4.不断迭代2-4到误差函数的值小于容忍值capacity或者到达迭代上限n（取最好的w参数）

##### 测试模型

##### 问题

1.为什么损失函数不求点到直线的垂直距离，而求的是y的差？

因为y为要求的值，我们更加关注的是y的差距最小，我们希望y更准确，而不是点到直线的距离最小

#### <a id="tiaocan">调整w参数</a>

##### 方法

**梯度下降法**

$w_0=w_0-α\frac{∂J(θ)}{∂w_0}$

$w_{0}=w_{0}-\alpha \frac{1}{m} \sum_{i=0}^{m}\left(w_{0}+w_{1} x^{(i)}-y^{(i)}\right)$

$w_{1}=w_{1}-\alpha \frac{\partial J(\theta)}{\partial w_{1}}$

$w_{1}=w_{1}-\alpha \frac{1}{m} \sum_{j=0}^{m}\left(w_{0}+w_{1} x^{(i)}-y^{(i)}\right) x^{(i)}$

其中α表示学习率，导数正负决定w参数调整方向，α决定了每次w调整的步长

*含义*

梯度永远向上，我们调参是为了让梯度下降，所以叫梯度下降法

**偏导计算**

$\frac{\partial J(\theta)}{\partial w_{0}}=\frac{1}{m} \sum_{i=0}^{m}\left(h_{\theta}\left(x^{(i)}\right)-y^{(i)}\right) \frac{\partial\left(h_{\theta}\left(x^{(i)}\right)-y^{(i)}\right)}{\partial w_{0}}$

$=\frac{1}{m} \sum_{i=0}^{m}\left(w_{0}+w_{1} x^{(i)}-y^{(i)}\right) \frac{\partial\left(w_{0}+w_{1} x^{(i)}-y^{(i)}\right)}{\partial w_{0}}$

$=\frac{1}{m} \sum_{i=0}^{m}\left(w_{0}+w_{1} x^{(i)}-y^{(i)}\right)(1)$

$=\frac{1}{m} \sum_{i=0}^{m}\left(w_{0}+w_{1} x^{(i)}-y^{(i)}\right)$

$\frac{\partial J(\theta)}{\partial w_{1}}=\frac{1}{m} \sum_{i=0}^{m}\left(h_{\theta}\left(x^{(i)}\right)-y^{(i)}\right) \frac{\partial\left(h_{\theta}\left(x^{(i)}\right)-y^{(i)}\right)}{\partial w_{1}}$
$=\frac{1}{m} \sum_{i=0}^{m}\left(w_{0}+w_{1} x^{(i)}-y^{(i)}\right) \frac{\partial\left(w_{0}+w_{1} x^{(i)}-y^{(i)}\right)}{\partial w_{1}}$

$=\frac{1}{m} \sum_{i=0}^{m}\left(w_{0}+w_{1} x^{(i)}-y^{(i)}\right)\left(x^{(i)}\right)$
$=\frac{1}{m} \sum_{i=0}^{m}\left(w_{0}+w_{1} x^{(i)}-y^{(i)}\right) x^{(i)}$

##### 面试题

1.α调整带来的后果？

过大，损失函数值螺旋上升，只有小的α才能使用梯度下降法

2.为什么损失函数要用平方？

对于取绝对值，因为平方可以放大远距离的误差，综合考虑多点的结果，获得更好的目标函数

对于多次方，提高计算复杂度

#### 数据集分配

验证集10%（辅助选择训练模型）

训练集90%

总80%（通过训练集和验证集找到最好的model，最好的model<a href="#xunzhaofangshi">寻找方式</a>）

测试集（不参与训练）

总20%

**<a id="xunzhaofangshi">寻找方式</a>**

1.训练集训练出模型model1

2.通过验证集去测试当前的error1

3.训练集训练出模型model2

4.通过验证集去测试当前的error2

5.当error(n) > error(n - 1)时,可能产生过拟合，可以取当前error(n - 1)来进行测试，不然就循环3-4

### K-means

演示网站https://www.naftaliharris.com/blog/visualizing-k-means-clustering/

#### 问题

1.k值的选择？选几个？

> 思考: 聚类效果好不好？怎么衡量？标准？
>
> 类与类之间的差异很大，但是内部相似度很高

肘部法（选择肘点）：

![1643028170(1)](picture/1643028170(1).png)

类内部的相似性和类之间的差异用距离表示

**三种选择方法**
Elbow，Silhouhette ，Gap statistic
