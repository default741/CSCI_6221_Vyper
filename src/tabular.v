module tabular

pub struct DataFrame {
	mut:
		data [][]f64
		shape []int
		column_names []string
}

pub struct Series {
	mut:
		data []f64
		shape []int
		series_name string
}

pub fn DataFrame.data_frame (data [][]f64, column_names []string) DataFrame {
	return DataFrame{
		data: data
		shape: [data[0].len, data.len]
		column_names: column_names
	}
}

pub fn (mut df DataFrame) get (column_name string) Series {
	mut feature_index := 0

	for idx in 0.. df.shape[1]{
		if column_name == df.column_names[idx] {
			feature_index = idx
			break
		}
	}

	mut feature_vector := Series.series(df.data[feature_index], column_name)

	return feature_vector
}

pub fn (mut df DataFrame) fsum (column_name string) f64 {
	mut feature_index := 0

	for idx in 0.. df.shape[1]{
		if column_name == df.column_names[idx] {
			feature_index = idx
			break
		}
	}

	mut feature_vector := Series.series(df.data[feature_index], column_name)

	return feature_vector.fsum()
}

pub fn (mut df DataFrame) fmean (column_name string) f64 {
	mut feature_index := 0

	for idx in 0.. df.shape[1]{
		if column_name == df.column_names[idx] {
			feature_index = idx
			break
		}
	}

	mut feature_vector := Series.series(df.data[feature_index], column_name)

	return feature_vector.fmean()
}

pub fn (mut df DataFrame) fvariance (column_name string) f64 {
	mut feature_index := 0

	for idx in 0.. df.shape[1]{
		if column_name == df.column_names[idx] {
			feature_index = idx
			break
		}
	}

	mut feature_vector := Series.series(df.data[feature_index], column_name)

	return feature_vector.fvariance()
}

pub fn (mut df DataFrame) fcovariance (column_name_a string, column_name_b string) f64 {
	mut feature_index_a := 0
	mut feature_index_b := 0

	for idx in 0.. df.shape[1]{
		if column_name_a == df.column_names[idx] {
			feature_index_a = idx
			break
		}
	}

	for idx in 0.. df.shape[1]{
		if column_name_b == df.column_names[idx] {
			feature_index_b = idx
			break
		}
	}

	mut feature_vector_a := Series.series(df.data[feature_index_a], column_name_a)
	mut feature_vector_b := Series.series(df.data[feature_index_b], column_name_b)

	return feature_vector_a.fcovariance(mut feature_vector_b)
}

/* ############################################ Series Functions ######################################################## */

pub fn Series.series (data []f64, series_name string) Series {
	return Series{
		data: data
		shape: [data.len, 1]
		series_name: series_name
	}
}

pub fn (mut series Series) update_series() Series {
	series.shape = [series.data.len, 1]

	return series
}

pub fn (mut series Series) fsum() f64 {
	mut final_sum := 0.0

	for idx in 0..series.shape[0] {
        final_sum = final_sum + series.data[idx]
	}

	return final_sum
}

pub fn (mut series Series) fmean() f64 {
	return series.fsum() / series.shape[0]
}

pub fn (mut series Series) fvariance() (f64) {
	mut residual_array := Series.series([], 'residual_array')
	mean := series.fmean()

	for idx in 0..series.shape[0] {
		residual_array.data << (series.data[idx] - mean) * (series.data[idx] - mean)
		residual_array.update_series()
	}

	return residual_array.fsum() / series.shape[0]
}

pub fn (mut series Series) fcovariance(mut input_series Series) (f64) {
	assert series.shape == input_series.shape

	mut covariance := 0.0

	mean_x := series.fmean()
	mean_y := input_series.fmean()

	for idx in 0..series.shape[0] {
		covariance = covariance + ((series.data[idx] - mean_x) * (input_series.data[idx] - mean_y))
	}

	return covariance / series.shape[0]
}