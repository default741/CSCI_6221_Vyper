module utils

pub fn list_sum(input_array []f64) f64 {
	/*
	list_sum calculates the sum of elements in a floating-point array.

	Parameters:
		- input_array: The array for which the sum is calculated.

	Returns:
		- The sum of elements in the input array as a floating-point number.
	*/

    mut final_sum := 0.0 // Initialize the sum variable

    // Iterate through each element in the array and accumulate the sum
    for idx in 0..input_array.len {
        final_sum = final_sum + input_array[idx]
    }

    return final_sum // Return the calculated sum
}

pub fn list_mean(input_array []f64) f64 {
	/*
	list_mean calculates the mean (average) of elements in a floating-point array.

	Parameters:
		- input_array: The array for which the mean is calculated.

	Returns:
		- The mean of elements in the input array as a floating-point number.
	*/

    sum := list_sum(input_array) // Calculate the sum of elements using the list_sum function

    return sum / input_array.len // Calculate the mean by dividing the sum by the number of elements
}

pub fn round(input_data f64) f64 {
	/*
	round rounds a floating-point number to three decimal places.

	Parameters:
		- input_data: The floating-point number to be rounded.

	Returns:
		- The rounded floating-point number.
	*/
    return '${input_data:.3f}'.f64() // Use string formatting to round the number to three decimal places
}

pub fn sqrt(number f64) f64 {
	/*
	sqrt calculates the square root of a floating-point number using the Newton-Raphson method.

	Parameters:
		- number: The number for which the square root is calculated.

	Returns:
		- The square root of the input number as a floating-point number.
	*/

    // Initialize variables for iterations
    mut y := number
    mut z := (y + (number / y)) / 2

    // Initialize variable for absolute value
    mut abs_value := 0.0

    // Iterate until convergence (absolute difference less than 0.001)
    for true {

        // Calculate the absolute difference
        if (y - z) > 0 {abs_value = (y - z)}
		else {abs_value = (z - y)}

        // Check for convergence
        if abs_value < 0.001 {break}

        // Update variables for the next iteration
        y = z
        z = (y + (number / y)) / 2
    }

    return round(z) // Round the result and return the square root
}