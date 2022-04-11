# Pytorch

## 查看显卡驱动

nvidia-smi（显卡驱动版本需要大于396.26）

## 一些安装包

> conda install nb_conda  //jupter 安装
>
> 官网命令行 //torch安装
>
> PIL图像处理类
>
> pip install tensorboard //数据可视化
>
> pip install opencv-python //读图片读成numpy类型


## 一些方法

```python
# 当前计算机gpu是否可以使用
torch.cuda.is_available()
```

### 数据读取

```python
# Dataset 获取数据和label
from torch.utils.data import Dataset

# eg
class Hymenoptera_dataset(Dataset):
    # 这边初始化所需要的目录等
    def __init__(self, root_path, dir_name, is_train = True):
        full_dir_path = ''
        if is_train:
            full_dir_path = os.path.join(root_path,'train',dir_name)
        else:
            full_dir_path = os.path.join(root_path,'val',dir_name)
        file_names = os.listdir(full_dir_path)
        self.images = [Image.open(os.path.join(full_dir_path,i)) for i in file_names]
        # 数据标签
        self.label_name = dir_name

    """
        从上面的解释中我们可以知道，这个方法必须被实现并且输入一个索引，然后根据当前索引构建对应数据集（官网可以看到FashionMNIST子类实现了Dataset，具体定义如下：
        Args:
            index (int): Index

        Returns:
            tuple: (image, target) where target is index of the target class.
        所以要返回一个元组键值对，键为image图像，值为它的label)
    """
    def __getitem__(self, index):
        return self.images[index],self.label_name

    # 从上面的解释中我们可以知道，这个方法必须被实现并且表示为当前数据集的长度
    def __len__(self):
        return len(self.images)
    
# 由于数据输入格式不完全相同，但是使用DataLoader打包数据时需要维度相同的数据，错误行torch.stack(batch, 0, out=out)，这个实现需要同维度数据进行对比，所以需要自己重写collate函数，不让它走默认的default_collate
def Hymenoptera_collate(batch):
    imgs = []
    labels = []
    for img, label in batch:
        imgs.append(img)
        labels.append(label)
    return imgs, labels




# Dataloader 为后面需求提供不同的数据形式
from torch.utils.data import DataLoader
# 常用参数 batch_size,shuffle,num_workers,drop_list
data_loader = DataLoader(dataset=ants_dataset, batch_size=10, num_workers=10, drop_last=True)
# 组合返回数据
for imgs, labels in data_loader:
    for index, _ in enumerate(imgs):
        print(imgs[index], labels[index])
```

### 可视化数据

```python
# Tensorboard工具
from torch.utils.tensorboard import SummaryWriter
# 写事件文件到logs中
writer = SummaryWriter("logs")

# 操作函数类型
x = range(100)
for i in x:
	# add_scalar方法传入标题，y轴以及x轴
    writer.add_scalar('y=2x', i * 2, i)

# 操作图片类型
img_HWC = cv2.imread(r'D:\imagenete\hymenoptera_data\train\ants\5650366_e22b7e1065.jpg')
cv2.cvtColor(img_HWC,cv2.COLOR_BGR2RGB,img_HWC)

writer = SummaryWriter('logs')
# 由于opencv读出来的数组为HWC图，所以要进行格式设定，默认为CHW,stage 0
writer.add_image('pic', img_HWC, 3, dataformats='HWC')

writer.close()

# 关闭文件流
writer.close()
# 读取事件文件
# conda环境命令行下 tensorboard --logdir={目录位置} --port={端口位置}
```

### CV2操作 

```python
import cv2
a = cv2.imread(r'D:\imagenete\hymenoptera_data\train\ants\5650366_e22b7e1065.jpg')
#显示在窗口中，要跟waitKey或者pollKey
cv2.imshow("test",a)
cv2.waitKey()
# 注意这边读出来的是BGR图片在其他工具使用时要进行转化
```

### 图片转化

```python
from torchvision import transforms
# 常用方法 Compose ToTensor PILToTensor 等，注意输入输出
a = cv2.imread(r'D:\imagenete\hymenoptera_data\train\ants\5650366_e22b7e1065.jpg')
b = transforms.ToTensor()(a)
writer.add_image("test_img",b,0)
# Compose 经过一系列transfer，类似于管道
# Normalize 归一化，通过输入一个tensor数据类型每个维度根据计算转化成对应的标准化数据
'''output[channel] = (input[channel] - mean[channel]) / std[channel]'''
# Resize 变化大小
# RandomCrop 随机裁剪
```

### 可视化数据集相关

```python
import torchvision
torchivision.datasets.CIFAR10(root="./dataset",train=True,download=True)
torchivision.datasets.CIFAR10(root="./dataset",train=False,download=True)
```

## 神经网络搭建

相关包

torch.nn

###  Container

所有神经网络的基类

https://pytorch.org/docs/stable/generated/torch.nn.Module.html

```python
# 基本骨架搭建
from torch import nn
import torch

class cnn(nn.Module):
    def __init__(self):
        super(cnn, self).__init__()
	# 输入为tensor类型的
    
    def forward(self, x):
        return x + 1

tensor = torch.tensor(1.0)
out = cnn()
print(out(tensor))
```

```python
# 关于卷积操作
import torch
import torch.nn.functional as F
import numpy as np

# 被卷积的数据
input_tensor = torch.tensor(np.arange(25).reshape(5, 5))
# 卷积核
input_kernel = torch.tensor(np.arange(9).reshape(3, 3))
# 由于尺寸要求为4维，所以进行升维,input_tensor要转换为 ({minibatch} , {in_channels} , iH , iW)(minibatch,in_channels,iH,iW)
input_tensor = torch.reshape(input_tensor, (1, 1, 5, 5))
# 由于尺寸要求为4维，所以进行升维,input_kernel要转换为({out_channels} , {{in_channels}}{{groups}} , kH , kW)(out_channels,groups/in_channels,kH,kW)
input_kernel = torch.reshape(input_kernel, (1, 1, 3, 3))
# 卷积操作 2维使用conv2d,stride参数默认为1，为卷积核一次走的长度（步长），padding为补充原数据的尺寸，bias偏置，给结果加数值，padding_mode为填充形式，dilation表示空洞卷积，表示卷积核对应到的位置间隔
output = F.conv2d(input_tensor, input_kernel)
print(output)
```

```python
# 卷积层的基本使用
import torch
from torch import nn
from torch.utils.data import DataLoader
from torch.utils.tensorboard import SummaryWriter
from torchvision import datasets
import torchvision.transforms as tf

train_data = datasets.CIFAR10("./datasets", train=True, download=True, transform=tf.ToTensor())

train_loader = DataLoader(train_data, batch_size=64)


class cnn(nn.Module):
    def __init__(self):
        super(cnn, self).__init__()
        # 这边的kernel_size表示卷积核,每次都会生成不同的卷积核进行卷积
        self.conv = nn.Conv2d(in_channels=3, out_channels=15, kernel_size=3, padding=1, stride=1)

    def forward(self, x):
        return self.conv(x)


writer = SummaryWriter("logs")
step = 0
cn = cnn()
for imgs, label in train_loader:
    writer.add_images("test_con_input", imgs, step)
    outputs = cn(imgs)
    outputs = torch.reshape(outputs,(-1,3,32,32))
    writer.add_images("test_conv_output", outputs, step)
    step += 1
    
writer.close()
```

```python
# 池化层，主要看池化核，最大池化表示取池化核部分的最大值，注意ceil_mode的使用，它表示了即使池化核对应的值缺失，是否需要进行池化
# 主要为了减小数据量，减少文件大小，这样训练速度可以加快
from torch import nn
from torch.utils.tensorboard import SummaryWriter
from torchvision import datasets, transforms
from torch.utils.data import DataLoader

train_dataset = datasets.CIFAR10(root="./datasets", train=True, transform=transforms.ToTensor(), download=True)

train_loader = DataLoader(train_dataset, batch_size=64)


class cnn(nn.Module):
    def __init__(self):
        super(cnn, self).__init__()
        self.pool = nn.MaxPool2d(3)

    def forward(self, x):
        return self.pool(x)


cn = cnn()

writer = SummaryWriter("logs")

step = 0
for imgs, labels in train_loader:
    writer.add_images("pool_test_input", imgs, step)
    output = cn(imgs)
    writer.add_images("pool_test_output", output, step)
    step += 1
    
writer.close()
```

```python
# padding层，用于填充数据
```

```python
# 非线性激活层Non-linear Activations，常用ReLU，Sigmoid
# ReLU有inplace，表示是否取代原输入
```

**ReLU**

$f(x)=\max (0, x)$

**CONV2D**

$\operatorname{out}\left(N_{i}, C_{\text {out }_{j}}\right)=\operatorname{bias}\left(C_{\text {out }_{j}}\right)+\sum_{k=0}^{C_{\text {in }}-1} \operatorname{weight}\left(C_{\text {out }_{j}}, k\right) \star \operatorname{input}\left(N_{i}, k\right)$

*shape计算*

- Input: $\left(N, C_{i n}, H_{i n}, W_{i n}\right)$ or $\left(C_{i n}, H_{i n}, W_{i n}\right)$

- Output: $\left(N, C_{\text {out }}, H_{\text {out }}, W_{\text {out }}\right)$ or $\left(C_{\text {out }}, H_{\text {out }}, W_{\text {out }}\right)$, where

  $\begin{aligned} H_{\text {out }} &=\left\lfloor\frac{H_{\text {in }}+2 \times \text { padding }[0]-\text { dilation }[0] \times(\text { kernel\_size }[0]-1)-1}{\text { stride }[0]}+1\right\rfloor \\ W_{\text {out }} &=\left\lfloor\frac{W_{\text {in }}+2 \times \text { padding }[1]-\text { dilation }[1] \times(\text { kernel\_size }[1]-1)-1}{\operatorname{stride}[1]}+1\right\rfloor \end{aligned}$

## 使用GPU

GPU能使用在三类数据上

- 数据集 imgs 和 labels
- 模型
- 损失函数

```python
device = device = torch.device('cuda:0') if torch.cuda.is_available() else torch.device('cpu')
xxx.to(device)
```

## 常用套路

1. 实现数据集子类，方便对数据集的操作
2. 计算训练数据集的方差均值，去掉公共部分
3. 用DataLoader进行数据集加载
4. 建立神经网络模型
5. 选择损失函数，优化器，步长优化器
6. 放到GPU上进行训练
7. 根据训练的时候的精确率或损失函数，取出最佳模型状态并保存
8. 下次使用的时候对状态进行读取使用

## 实战

 [classification train.ipynb](classification train.ipynb) 

## 一些手段

**bz2的使用**

bz2文件是conda python的安装包，放到anaconda的下载目录下的pkgs

安装的时候使用conda install --use-local + name

## 为什么需要Tensor

目的是为了创造更高维度的矩阵和张量，包装了神经网络需要的参数