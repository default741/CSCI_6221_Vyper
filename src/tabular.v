module tabular

pub struct Series {
	pub mut:
		data []f64
		shape []int
		series_name string
}

pub struct DataFrame {
	pub mut:
		data []Series
		shape []int
		column_names []string
}

pub fn DataFrame.data_frame (data [][]f64, column_names []string) DataFrame {
	mut series_data := []Series{}

	for idx in 0..data.len {
		series_data << Series.series(data[idx], column_names[idx])
	}

	return DataFrame{
		data: series_data
		shape: [data[0].len, data.len]
		column_names: column_names
	}
}

pub fn (mut df DataFrame) get (column_name string) Series {
	mut result := Series.series([], 'empty_series')

	for record in df.data{
		if column_name == record.series_name {
			result = record
		}
	}

	return result
}

pub fn (mut df DataFrame) fsum (column_name string) f64 {
	mut record := df.get(column_name)

	return record.fsum()
}

pub fn (mut df DataFrame) fmean (column_name string) f64 {
	mut record := df.get(column_name)

	return record.fmean()
}

pub fn (mut df DataFrame) fvariance (column_name string) f64 {
	mut record := df.get(column_name)

	return record.fvariance()
}

pub fn (mut df DataFrame) fcovariance (column_name_a string, column_name_b string) f64 {
	mut record_a := df.get(column_name_a)
	mut record_b := df.get(column_name_b)

	return record_a.fcovariance(mut record_b)
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