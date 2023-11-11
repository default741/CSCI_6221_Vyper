module tabular

pub struct DataFrame {
	mut:
		data [][]f64
		shape []int
}

pub struct Series {
	mut:
		data []f64
		shape []int
}

pub fn DataFrame.data_frame (data [][]f64) DataFrame {
	return DataFrame{
		data: data
		shape: [data[0].len, data.len]
	}
}

pub fn Series.series (data []f64) Series {
	return Series{
		data: data
		shape: [data.len, 1]
	}
}

pub fn (mut series Series) fsum () f64 {
	mut final_sum := 0.0

	for idx in 0..series.shape[0] {
        final_sum = final_sum + series.data[idx]
	}

	return final_sum
}