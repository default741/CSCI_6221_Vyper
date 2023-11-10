module utils

pub fn fsum(input_array []f64) (f64) {
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

pub fn fmean(input_array []f64) (f64) {
	/*
	Calculates the Mean of Array Values with floating point values.

	Args:
		input_array ([]f64): Input Array

	Returns:
		f64: Mean of the values in the Imput Array.
	*/
	return fsum(input_array) / input_array.len
}

pub fn fvariance(input_array []f64) (f64) {
	/*
	Calculates the Variance of Array Values with floating point values.

	Args:
		input_array ([]f64): Input Array

	Returns:
		f64: Variance of the values in the Imput Array.
	*/

	mut residual_array := []f64{}
	mean := fmean(input_array)

	for idx in 0..input_array.len {
		residual_array << (input_array[idx] - mean) * (input_array[idx] - mean)
	}

	return fsum(residual_array) / input_array.len
}

pub fn fcovariance(input_array_x []f64, input_array_y []f64) (f64) {
	/*
	Calculates the Variance of Array Values with floating point values.

	Args:
		input_array_x ([]f64): Input Array X
		input_array_y ([]f64): Input Array Y

	Returns:
		f64: Variance of the values in the Imput Array.
	*/

	assert input_array_x.len == input_array_y.len

	mut covariance := 0.0

	mean_x := fmean(input_array_x)
	mean_y := fmean(input_array_y)

	for idx in 0..input_array_x.len {
		covariance = covariance + ((input_array_x[idx] - mean_x) * (input_array_y[idx] - mean_y))
	}

	return covariance / input_array_x.len
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