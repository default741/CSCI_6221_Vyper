# Machine Learning Data Analysis and Linear Regression

This project demonstrates how to read machine learning data from an Excel file, perform linear regression on the data, and visualize the results.

## Prerequisites

To run this code, you will need to have the following prerequisites installed:

* *Vlang*
* *PyPlot*
* *tabular*
* *read_xlsx_v*
* *visualize_table*
* *linear_regression*

## Usage

To run the code, follow these steps:

1. Install the required prerequisites.
2. Save the code as main.v.
3. Open a terminal window and navigate to the directory where you saved the code.
4. Run the following command:

Use code with caution. Learn more
v run main


## Example Usage

To run the code with the provided test data, follow these steps:

1. Download the test data file test_data_mv.xlsx and place it in a directory named data.
2. Run the following command:

v run main

Explanation of the Code
The code consists of two main modules: main and read_ml_data. The main module is the entry point for the program and performs the following tasks:

Reads machine learning data from an Excel file using the read_ml_data module.
Initializes a linear regression model using the linear_regression module.
Verilog
// Initialize a linear regression model
mut model := lr.LinearRegression.init_model(learning_rate, epochs, zero_weight_bias, num_of_features)
Use code with caution. Learn more
Trains the linear regression model using the input data.
Verilog
// Fit the model using the input data
model = model.fit_model(mut x, mut y)
Use code with caution. Learn more
Prints the trained model parameters.
Verilog
// Print the trained model parameters
println(model)
println('')
Use code with caution. Learn more
Prepares data for plotting using the py_plot module.
Verilog
// Prepare data for plotting
mut plot_data := py_plot.PlotGraph {
    slope: model.weights.data[0],
    intercept: model.bias,
    feature_data: x.data[0].data,
    target_data: y.data,
  }
Use code with caution. Learn more
Plots the graph using the PyPlot module.
Verilog
// Plot the graph using the PyPlot module
py_plot.plot_graph(mut plot_data)
Use code with caution. Learn more
The read_ml_data module reads machine learning data from an Excel file and returns a tuple containing a DataFrame representing feature data and a Series representing target data.

Output
The code will output the trained model parameters and a plot of the data points and the regression line.

Additional Notes
The code is written in Vlang, a high-performance, statically typed programming language.
The code uses the tabular module to work with tabular data.
The code uses the read_xlsx_v module to parse Excel files.
The code uses the visualize_table module to visualize tabular data.
The code uses the linear_regression module to perform linear regression.
The code uses the py_plot module to plot graphs.
Example Trained Model Parameters
Here is an example of the output of the trained model parameters:

inear_regression.LinearRegression{
  weights: tabular.Series{
    data: [9.914]
    shape: [1, 1]
    series_name: 'initial_weights'
  }
  bias: 3699.686
  learning_rate: 1.e-08
  iterations: 500
  zero_weight_bias: false
  num_features: 1
  r_square: 0.974
}
