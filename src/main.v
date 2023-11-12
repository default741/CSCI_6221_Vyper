module main

import tabular
import linear_regression as lr
import py_plot

import read_xlsx_v


pub fn read_ml_data(file_path string) !(tabular.DataFrame, tabular.Series) {
    /*
    read_ml_data reads machine learning data from an Excel file.

    Parameters:
        - file_path: The path to the Excel file.

    Returns:
        - A tuple containing a DataFrame representing feature data and a Series representing target data.
    */

    excel_data := read_xlsx_v.parse(file_path)! // Parse the Excel data using the read_xlsx_v module
    mut input_data := excel_data.clone() // Create a mutable copy of the parsed Excel data

    // Extract column names and remove them from the input data
    column_names := excel_data.first()
    input_data.delete(0)

    // Initialize containers for feature data and target data
    mut feature_data := [][]f64{len: input_data[0].len - 1, init: []f64{len: input_data.len}}
    mut target_data := []f64{}

    // Convert records to integers and extract target data
    for mut record in input_data {
        int_record := record.map(it.f64())
        target_data << int_record[input_data[0].len - 1]
    }

    // Populate the feature data matrix
    for idx_i in 0..input_data.len {
        for idx_j in 0..input_data[0].len - 1 {
            feature_data[idx_j][idx_i] = input_data[idx_i][idx_j].f64()
        }
    }

    // Create a DataFrame for feature data
    mut x := tabular.DataFrame.data_frame(feature_data, column_names[0..(column_names.len - 1)])

    // Create a Series for target data
    mut y := tabular.Series.series(target_data, column_names[column_names.len - 1])

    return x, y // Return the feature data and target data
}


fn main() {
    // Path to the Excel file containing test data
    file_path := './data/test_data.xlsx'

    // Configuration for linear regression model
    zero_weight_bias := false
    learning_rate := 0.00001
    epochs := 500

    // Read machine learning data from the Excel file
    mut x, mut y := read_ml_data(file_path)!

    // Get the number of records (samples)
    num_of_records := x.shape[1]

    // Initialize a linear regression model
    mut model := lr.LinearRegression.init_model(learning_rate, epochs, zero_weight_bias, num_of_records)

    // Fit the model using the input data
    model = model.fit_model(mut x, mut y)

    // Print the trained model parameters
    println(model)

    // Prepare data for plotting
    mut plot_data := py_plot.PlotGraph {
        slope: model.weights.data[0],
        intercept: model.bias,
        feature_data: x.data[0].data,
        target_data: y.data,
    }

    // Plot the graph using the PyPlot module
    py_plot.plot_graph(mut plot_data)
}
