package main

import "fmt"

/*
	https://leetcode.com/problems/rotate-array/description/?envType=study-plan-v2&envId=top-interview-150
*/

func rotate(nums []int, k int) {
	l := len(nums) - 1
	t := nums
	for c := 0; c < k; c++ {
		t = append(t[l:], t[:l]...)
	}
	copy(nums, t)
}

func main() {
	nums := []int{1, 2, 3, 4, 5, 6, 7}
	k := 3
	rotate(nums, k)
	fmt.Printf("%v", nums)
}
