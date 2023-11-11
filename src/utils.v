module utils

pub fn list_sum(input_array []f64) (f64) {
	/*
	Calculates the Sum of Array Values with floating point values.

	Args:
		input_array ([]f64): Input Array

	Returns:
		f64: Sum of all the values in the Imput Array.
	*/

	mut final_sum := 0.0

	for idx in 0..input_array.len {
        final_sum = final_sum + input_array[idx]
	}

	return final_sum
}

pub fn list_mean(input_array []f64) (f64) {
	/*
	Calculates the Mean of Array Values with floating point values.

	Args:
		input_array ([]f64): Input Array

	Returns:
		f64: Mean of the values in the Imput Array.
	*/
	return list_sum(input_array) / input_array.len
}

pub fn round(input_data f64) f64 {
	/*
	Rounds the floating point value to the specified decimal points.

	Args:
		input_data (f64): Input Array
		decimal_points (int): Number of decimal points.

	Returns:
		f64: Rounded Floating Value.
	*/
	return '${input_data:.3f}'.f64()
}