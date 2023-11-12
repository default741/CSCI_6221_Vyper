module tabular

import utils


pub struct Series {
	/*
	Series is a struct representing a one-dimensional array of floating-point numbers.

	Attributes:
		- pub mut data: A mutable 1D array of floating-point numbers.
		- pub mut shape: A mutable array representing the shape of the series.
		- pub mut series_name: A mutable string representing the name of the series.
	*/
    pub mut:
        data []f64
        shape []int
        series_name string
}

pub struct DataFrame {
	/*
	DataFrame is a struct representing a two-dimensional data structure with labeled axes (rows and columns).

	Attributes:
		- pub mut data: A mutable array of Series, where each Series represents a column in the DataFrame.
		- pub mut shape: A mutable array representing the shape of the DataFrame.
		- pub mut column_names: A mutable array of strings representing the names of the columns in the DataFrame.
	*/
    pub mut:
        data []Series
        shape []int
        column_names []string
}


pub fn DataFrame.data_frame (data [][]f64, column_names []string) DataFrame {
	/*
	data_frame creates a DataFrame from a 2D array of floating-point numbers and column names.

	Parameters:
		- data: A 2D array representing the data for the DataFrame.
		- column_names: An array of strings representing the names of the columns in the DataFrame.

	Returns:
		- A DataFrame constructed from the provided data and column names.
	*/

    mut series_data := []Series{} // Initialize an array to store Series objects

    // Iterate through each row in the data
    for idx in 0..data.len {

        // Create a Series for each column using the Series.series constructor
        series_data << Series.series(data[idx], column_names[idx])
    }

    // Return a new DataFrame with the constructed Series objects, shape, and column names
    return DataFrame{
        data: series_data
        shape: [data[0].len, data.len]
        column_names: column_names
    }
}

pub fn (mut df DataFrame) get(column_name string) Series {
	/*
	get retrieves a Series from the DataFrame based on the specified column name.

	Parameters:
		- column_name: A string representing the name of the column to retrieve.

	Returns:
		- A Series object representing the specified column. Returns an empty Series if the column is not found.
	*/

    mut result := Series.series([], 'empty_series') // Initialize a default empty Series

    // Iterate through each Series in the DataFrame's data
    for record in df.data {

        // Check if the current Series matches the specified column name
        if column_name == record.series_name {
            result = record // Update the result with the matched Series
        }
    }

    // Return the Series representing the specified column
    return result
}

pub fn (mut df DataFrame) fsum(column_name string) f64 {
	/*
	fsum calculates the sum of values in the specified column of the DataFrame.

	Parameters:
		- column_name: A string representing the name of the column for which the sum is calculated.

	Returns:
		- The sum of values in the specified column as a floating-point number.
	*/

    mut record := df.get(column_name) // Retrieve the Series representing the specified column using the get method

    return record.fsum() // Call the fsum method on the retrieved Series to calculate the sum
}

pub fn (mut df DataFrame) fmean(column_name string) f64 {
	/*
	fmean calculates the mean (average) of values in the specified column of the DataFrame.

	Parameters:
		- column_name: A string representing the name of the column for which the mean is calculated.

	Returns:
		- The mean of values in the specified column as a floating-point number.
	*/

    mut record := df.get(column_name) // Retrieve the Series representing the specified column using the get method

    return record.fmean() // Call the fmean method on the retrieved Series to calculate the mean
}

pub fn (mut df DataFrame) fvariance(column_name string) f64 {
	/*
	fvariance calculates the variance of values in the specified column of the DataFrame.

	Parameters:
		- column_name: A string representing the name of the column for which the variance is calculated.

	Returns:
		- The variance of values in the specified column as a floating-point number.
	*/

    mut record := df.get(column_name) // Retrieve the Series representing the specified column using the get method

    return record.fvariance() // Call the fvariance method on the retrieved Series to calculate the variance
}

pub fn (mut df DataFrame) fcovariance(column_name_a string, column_name_b string) f64 {
	/*
	fcovariance calculates the covariance between two columns in the DataFrame.

	Parameters:
		- column_name_a: A string representing the name of the first column.
		- column_name_b: A string representing the name of the second column.

	Returns:
		- The covariance between the values in the specified columns as a floating-point number.
	*/

    mut record_a := df.get(column_name_a) // Retrieve the Series representing the first specified column using the get method
    mut record_b := df.get(column_name_b) // Retrieve the Series representing the second specified column using the get method

    return record_a.fcovariance(mut record_b) // Call the fcovariance method on the first Series with the second Series as an argument
}

/* ############################################ Series Functions ######################################################## */

pub fn Series.series(data []f64, series_name string) Series {
	/*
	series constructs a Series from a 1D array of floating-point numbers and a series name.

	Parameters:
		- data: A 1D array representing the data for the Series.
		- series_name: A string representing the name of the Series.

	Returns:
		- A Series constructed from the provided data and series name.
	*/

    // Return a new Series with the provided data, shape, and series name
    return Series{
        data: data
        shape: [data.len, 1]
        series_name: series_name
    }
}

pub fn (mut series Series) update_series() Series {
	/*
	update_series updates the shape of the Series based on its current data length.

	Returns:
		- The Series with the updated shape.
	*/

    series.shape = [series.data.len, 1] // Update the shape of the Series based on its current data length

    return series // Return the updated Series
}

pub fn (mut series Series) fsum() f64 {
	/*
	fsum calculates the sum of values in the Series.

	Returns:
		- The sum of values in the Series as a floating-point number.
	*/

    mut final_sum := 0.0 // Initialize the sum variable

    // Iterate through each element in the Series data
    for idx in 0..series.shape[0] {

        // Add the current element to the sum
        final_sum = final_sum + series.data[idx]
    }

    return final_sum // Return the calculated sum
}

pub fn (mut series Series) fmean() f64 {
	/*
	fmean calculates the mean (average) of values in the Series.

	Returns:
		- The mean of values in the Series as a floating-point number.
	*/

    return series.fsum() / series.shape[0] // Calculate the mean by dividing the sum by the number of elements
}

pub fn (mut series Series) fvariance() f64 {
	/*
	fvariance calculates the variance of values in the Series.

	Returns:
		- The variance of values in the Series as a floating-point number.
	*/

    mut residual_array := Series.series([], 'residual_array') // Initialize a Series for storing residuals
    mean := series.fmean() // Calculate the mean of the Series

    // Iterate through each element in the Series data
    for idx in 0..series.shape[0] {

        // Calculate the squared residual and add it to the residual array
        residual_array.data << (series.data[idx] - mean) * (series.data[idx] - mean)
        residual_array.update_series()
    }

    // Calculate the sum of squared residuals and divide by the number of elements
    return residual_array.fsum() / series.shape[0]
}

pub fn (mut series Series) fstd() f64 {
	/*
	fstd calculates the standard deviation of values in the Series.

	Returns:
		- The standard deviation of values in the Series as a floating-point number.
	*/

    mut variance := series.fvariance() // Calculate the variance of the Series using the fvariance method

    return utils.sqrt(variance) // Calculate the standard deviation by taking the square root of the variance
}

pub fn (mut series Series) fcovariance(mut input_series Series) f64 {
	/*
	fcovariance calculates the covariance between two Series.

	Parameters:
		- input_series: The Series for which covariance is calculated.

	Returns:
		- The covariance between the two Series as a floating-point number.
	*/

    assert series.shape == input_series.shape // Ensure that the shapes of both Series are the same
    mut covariance := 0.0 // Initialize the covariance variable

    // Calculate the mean of the current Series and the input Series
    mean_x := series.fmean()
    mean_y := input_series.fmean()

    // Iterate through each element in the Series data
    for idx in 0..series.shape[0] {

        // Calculate the product of the differences from the means and add it to the covariance
        covariance = covariance + ((series.data[idx] - mean_x) * (input_series.data[idx] - mean_y))
    }

    // Calculate the covariance by dividing the sum by the number of elements
    return covariance / series.shape[0]
}
