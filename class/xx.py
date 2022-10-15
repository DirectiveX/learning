def movingCount(m, n, k):
    """
    :type m: int
    :type n: int
    :type k: int
    :rtype: int
    """
    # 动态规划
    # 原始 列和行为 0~9，全部可以求出
    dp = [[0 for _ in range(n)] for _ in range(m)]
    min_m = min(m, 10)
    min_n = min(n, 10)
    count = 0
    for i in range(min_m):
        for j in range(min_n):
            dp[i][j] = i + j
            if dp[i][j] <= k:
                count += 1
    for i in range(m):
        for j in range(n):
            if i >= 10 and j >= 10:
                dp[i][j] = dp[i - 10][j - 10] + 2
                if dp[i][j] <= k:
                    count += 1
            elif i >= 10:
                dp[i][j] = dp[i - 10][j] + 1
                if dp[i][j] <= k:
                    count += 1
            elif j >= 10:
                dp[i][j] = dp[i][j - 10] + 1
                if dp[i][j] <= k:
                    count += 1
    return count

movingCount(16
,8
,4)