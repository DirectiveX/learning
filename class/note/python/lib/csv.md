# CSV

```python
import csv

def read_csv():
    csv_file = csv.reader(open("xxx.csv", "r", encoding='utf-8'))
    print(csv_file)
    for line in csv_file:
        print(line)
```

