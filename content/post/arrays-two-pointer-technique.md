---
title: "Arrays: Two Pointer Technique"
date: "2023-02-02"
categories: ["Technical","Algorithm"]
author: "Ugur Elveren"
tags: ["two pointer", "arrays", "algorithm"]
description: "Discover how the Two Pointer Technique can optimize solutions for array problems, including Two Sum and array intersection."
---

The two-pointer technique is an easy method used to solve some array-related problems. It involves using two pointers, one starting from the beginning of the array and the other from the end, to traverse the array and find a solution. This technique is helpful because it reduces the time complexity of the algorithm and increases its efficiency.

The two-pointer technique is used in various solutions such as finding the sum of two numbers in an array that equals a given target, finding the length of the longest subarray with a given sum, and finding the shortest subarray with a given sum. The basic idea behind this technique is to start from the two ends of the array and move the pointers towards each other until a solution is found or it becomes clear that a solution does not exist.

### Two Sum Problem

**Two Sum**, one of the famous interview questions, can be solved using the two-pointer technique.

**Problem:** Given an array of integers `nums` and an integer `target`, return indices of the two numbers such that they add up to the target. You may assume that each input would have exactly one solution, and you may not use the same element twice.

#### Solution of Two Sum Problem using Two Pointers Technique

We initialize two pointers, `left` and `right`, to the start and end of the array, respectively. We calculate the sum of the numbers at `left` and `right` and compare it with the target. If the sum is equal to the target, we have found two numbers that add up to the target, so we return their indices. If the sum is less than the target, we increment the `left` pointer. If the sum is greater than the target, we decrement the `right` pointer.

```csharp
public int[] TwoSum(int[] nums, int target) 
{
    int left = 0, right = nums.Length - 1;
    while (left < right) 
    {
        int sum = nums[left] + nums[right];
        if (sum == target) 
        {
            return new int[] { left, right };
        } 
        else if (sum < target) 
        {
            left++;
        } 
        else 
        {
            right--;
        }
    }
    throw new ArgumentException("No two sum solution");
}
```

## Two-pointer technique for problems involving two arrays

The two-pointer technique can also be applied to problems involving two arrays. In this scenario, the two pointers are used to traverse the two arrays simultaneously, with one pointer moving through each array. The goal is to find a solution that satisfies a given condition, such as finding a pair of elements with a given sum or finding the common elements between two arrays.

### The Intersection Problem

**Problem:** Find the common elements between two sorted arrays.

#### Solution of Intersection Problem using Two Pointers Technique

```csharp
public List<int> Intersection(int[] nums1, int[] nums2)
{
    int i = 0, j = 0;
    List<int> result = new List<int>();
    while (i < nums1.Length && j < nums2.Length)
    {
        if (nums1[i] == nums2[j])
        {
            result.Add(nums1[i]);
            i++;
            j++;
        }
        else if (nums1[i] < nums2[j])
        {
            i++;
        }
        else
        {
            j++;
        }
    }
    return result;
}
```

**Explanation:**
- Initialize two-pointers `i` and `j`: They are initialized to zero to traverse arrays `nums1` and `nums2`, respectively.
- Create a result list `result`: A list is created to store the common elements of both arrays.
- Start a `while` loop: The loop runs as long as both `i` and `j` are less than the length of their respective arrays.
- Compare the elements: If the elements pointed to by `i` and `j` are equal, it is added to the result, and both pointers are incremented. If `nums1[i]` is smaller, `i` is incremented, otherwise `j` is incremented.
- Return the result: The list of common elements is returned.

### Conclusion

In conclusion, the two-pointer technique is a highly effective algorithm for solving a variety of problems in computer science. It involves using two pointers that traverse a data structure, such as an array or list, in opposite directions to search for a solution. By utilizing this technique, developers can efficiently find solutions to problems with linear time complexity, making it an ideal method for optimizing performance. With its versatility and ease of use, the two-pointer technique is an indispensable tool for developers, allowing them to quickly tackle complex challenges.
