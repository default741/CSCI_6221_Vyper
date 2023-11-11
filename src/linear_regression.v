module linear_regression

import utils

pub fn predict(x [][]f64, weights []f64, bias f64) []f64 {
	/*
	Predicts the target value based on the input variables, weights and bias.

	Args:
		x ([][]f64): Input Array.
		weights ([]f64): Slope of the Line for each feature.
		bias (f64): Intercept of the Line.

	Returns:
		f64: Predicted Array.
	*/

    mut y_pred := []f64{}

	for idx_i in 0..x[0].len {
		mut slope_x_sum := 0.0

		for idx_j in 0..x.len {
			slope_x_sum = slope_x_sum + (x[idx_j][idx_i] * weights[idx_j])
		}

		y_pred << utils.round(slope_x_sum + bias)
	}

    return y_pred
}

pub fn r_square(predicted_data []f64, actual_data []f64) f64 {
	/*
	Calculates the R-squared value which is a statistical measure of how close the data
	are to the fitted regression line.

	Args:
		predicted_data (f64): Predicted Data
		actual_data (int): Actual Data.

	Returns:
		f64: Rounded Floating Value.
	*/

	assert actual_data.len == predicted_data.len

	mut rss := []f64{}
	mut tss := []f64{}

	mean_y := utils.fmean(actual_data)

	for idx in 0..actual_data.len {
		rss << (actual_data[idx] - predicted_data[idx]) * (actual_data[idx] - predicted_data[idx])
		tss << (actual_data[idx] - mean_y) * (actual_data[idx] - mean_y)
	}

	return 1 - (utils.fsum(rss) / utils.fsum(tss))
}