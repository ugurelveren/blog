---
title: "Arrays: Sliding Windows Technique"
date: "2023-02-16"
author: "Ugur Elveren"
categories: ["Technical","Algorithm"]
tags: ["sliding window", "algorithm", "arrays"]
description: "Learn how to solve array problems efficiently using the Sliding Windows technique with examples."
---

Window Sliding Technique is a strategy that aims to reduce nested loops for solving problems where you need to analyze a sequence of elements, like an array or a string. The technique reduces the use of a nested loop and replaces it with a single loop, reducing the time complexity.

The sliding window technique is efficient because it avoids unnecessary computations. By moving the window only one step at a time, you avoid repeating calculations already done for the previous window. This can save a lot of time and make the algorithm more efficient.

This approach is useful in solving problems that involve finding a subarray or substring that meets a certain condition, such as the maximum sum of a subarray or the longest substring without repeating characters. By sliding the window over the input sequence, the algorithm can efficiently explore all possible subarrays or substrings and identify the ones that meet the given condition.

## Problem: The longest sub-array having a sum is less than k.

Given an array of positive integers `nums` and an integer `k`, find the length of the longest subarray whose sum is less than or equal to `k`.

**Example:**
Input: `arr[] = { 3, 1, 2, 4, 5, 9 }`, `k = 10`
Output: `4`
Explanation: The sub-array is `{3, 1, 2, 4}`.

### Solution

Create a window of elements by moving the right pointer to the right until the desired size or condition is met. If the sum of the elements in the window exceeds the given integer `k`, we need to adjust the window to the right. We do this by moving the left end of the window one step to the right and subtracting the element that was previously at the left end of the window from current. We repeat this process as many times as needed until the sum of the elements in the window is less than or equal to `k`.

At each iteration, we update the `answer` variable with the maximum length of the subarray seen so far. We calculate this as the difference between the current right index and the left index. We continue iterating over the array until we reach the end.

```csharp
public int FindLengthOfLongestSubarray(int[] nums, int k) {
    int left = 0;
    int current = 0;
    int answer = 0;

    for (int right = 0; right < nums.Length; right++) {
        current += nums[right];
        while (current > k) {
            current -= nums[left];
            left++;
        }
        answer = Math.Max(answer, right - left + 1);
    }
    return answer;
}
```

## Fixed Size Sliding Window

The fixed sliding window problem is a specific type of problem that requires finding a solution within a fixed-size window of elements in an array or sequence. This means that the size of the window remains constant throughout the problem.

**Problem: The maximum sum of any subarray of size k**

Given an array of integers and a fixed window size of `k`, find the maximum sum of any subarray of size `k`.

### Solution

To solve this problem using the sliding window technique, we would start by initializing two pointers, left and right, to the beginning of the array. We would then create a window of elements by moving the right pointer to the right by the size of the window.

Next, we would calculate the sum of the elements in the window. We would then store this sum in a variable, say `max_sum`.

We would then slide the window to the right by incrementing the left and right pointers by one, subtracting the element at the left end of the old window from the sum and adding the element at the right end of the new window to the sum. We would then update the `max_sum` as necessary by comparing it to the sum of the new window:

```csharp
public int MaxSumSubarray(int[] arr, int k)
{
    int left = 0;
    int right = k - 1;
    int maxSum = 0;
    int currSum = 0;

    // Calculate the sum of the first window
    for (int i = 0; i <= right; i++)
    {
        currSum += arr[i];
    }
    maxSum = currSum;

    // Slide the window and update the maximum sum as necessary
    while (right < arr.Length - 1)
    {
        currSum -= arr[left];
        left++;
        right++;
        currSum += arr[right];

        if (currSum > maxSum)
        {
            maxSum = currSum;
        }
    }

    return maxSum;
}
```

## Conclusion

In conclusion, the sliding window technique is a useful algorithmic pattern that can be applied to a wide range of problems in which we need to find a subarray or substring of a given array or string that satisfies certain constraints.

The technique involves creating a “window” of a fixed size or a variable size that slides through the input data, with the goal of finding the optimal solution or the longest/shortest subarray/substring that satisfies a specific condition.

Fixed-size sliding window problems are easier to solve as we only need to maintain a window of a fixed size, while variable-size sliding window problems require us to adjust the window size dynamically based on the problem constraints.

Overall, the sliding window technique provides a simple and efficient way to solve a variety of problems, particularly those that involve searching for a continuous subset of data that meets specific criteria.
