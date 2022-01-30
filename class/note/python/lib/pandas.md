# Pandas

## 读取文件

 ```python
 df = pd.read_excel("same_doi_different_journals.xlsx")
 ```

## DataFrame

### 遍历

```python
for _, row in df.iterrows():
    print(row['container_title'])
    print(row['journal'])
    break
```

### 存文件

```python

```

