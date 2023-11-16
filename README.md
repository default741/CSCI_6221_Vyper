# V-Regress 
## Linear Regression with Gradient Descent

V-Regress is combination of modules that reads machine learning data from an Excel file, perform linear regression on the data, and visualize/plot the results.

## Pre-requistes

<li> This is done on V programming language, so we recommend to install that from https://github.com/vlang/v </li>
<li> Clone the V-Regress repo </li>

## Modules

To run this code, you will need to have the following prerequisites installed:

* [read_xlsx_v](https://github.com/default741/CSCI_6221_V/blob/main/src/read_xlsx_v.v) : Reads Excel file and returns data in the form of lists of lists. 
* [xml](https://github.com/default741/CSCI_6221_V/blob/main/src/xml.v) : Helper module for read_xlsx_v module. 
* [visualize_table](https://github.com/default741/CSCI_6221_V/blob/main/src/visualize_table.v) : As read_xlsx_v module returns the data in lists of lists format, this module helps in preinting the entire data or few rows in the tabular format in terminal.
* [linear_regression](https://github.com/default741/CSCI_6221_V/blob/main/src/linear_regression.v) : Has function which perform initialization and training of model with all the features and one target variable, and also consists predict function that can be used for prediction on future/test data. 
* [tabular](https://github.com/default741/CSCI_6221_V/blob/main/src/tabular.v) : Its a helper module for linear regression consists various functions like variance, covariance that are used for initializing the weights. 
* [utils](https://github.com/default741/CSCI_6221_V/blob/main/src/utils.v) : This is also a helper module, it has functiions like list_sum, list_mean, round, sqrt which help in basic calculations. 
* [py_plot](https://github.com/default741/CSCI_6221_V/blob/main/src/py_plot.v) : This module executes the python script which plots our regression line with actual data( one feature and one target) by passing the necessary information like weights, slop, intercept, data and other things.
* [lr_plot](https://github.com/default741/CSCI_6221_V/blob/main/src/lr_plot.py) : This is the python scripts which plots the grapgh with one feature data, one target data and regression line.

## Usage

To run the code, follow these steps:

1. Install the required prerequisites.
2. Save the code as main.v.
3. Open a terminal window and navigate to the directory where you saved the code.
4. Run the following command:
   ```
   v run .
   ```
   The above code will automatically search the **main.v** file and execute the **main()** function present in it.


## Example Usage

To run the code with the provided test data and main.v, follow these steps:

### Simple Linear Regression

1. Download the test data file test_data.xlsx and place it in a directory named data.
2. Make the required changes in the main.v file like changing the data path in main().
3. Run the following command:
```
v run .
```

### Multi-Feature Linear Regression

1. Download the test data file test_data_mv.xlsx and place it in a directory named data.
2. Make the required changes in the main.v file like changing the data path in main().
3. Run the following command:
```
v run .
```

## Additionall Notes

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
