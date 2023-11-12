module py_plot

import os

pub struct PlotGraph {
	/*
	PlotGraph represents data for plotting a linear regression graph.

	Fields:
		- slope: The slope of the linear regression line.
		- intercept: The y-intercept of the linear regression line.
		- feature_data: The feature data points for plotting.
		- target_data: The target data points for plotting.
	*/
    pub mut:
        slope f64
        intercept f64
        feature_data []f64
        target_data []f64
}

pub fn (mut plot_params PlotGraph) get_params() (string, string, string, string) {
	/*
	get_params retrieves the parameters of a PlotGraph instance as strings.

	Parameters:
		- plot_params: The PlotGraph instance for which parameters are retrieved.

	Returns:
		- A tuple of strings containing the slope, intercept, feature data, and target data.
	*/
    return plot_params.slope.str(), plot_params.intercept.str(), plot_params.feature_data.str(), plot_params.target_data.str()
}

pub fn plot_graph(mut plot_params PlotGraph) {
	/*
	plot_graph generates a command-line string and executes a Python script for plotting a linear regression graph.

	Parameters:
		- plot_params: The PlotGraph instance containing parameters for the graph.

	Note: This function assumes the existence of a Python script named "lr_plot.py" in the current directory.

	Example Usage:
		plot_params := PlotGraph{ slope: 0.5, intercept: 2.0, feature_data: [1.0, 2.0, 3.0], target_data: [3.0, 5.0, 7.0] }
		plot_graph(plot_params)
	*/

    mut python_script_path := "lr_plot.py" // Define the path to the Python script

    // Retrieve parameters as strings
    mut slope, mut intercept, mut feature_data, mut target_data := plot_params.get_params()

    // Format feature_data and target_data strings
    feature_data = feature_data.replace(',', '').replace('[', '').replace(']', '')
    target_data = target_data.replace(',', '').replace('[', '').replace(']', '')

    // Combine feature_data and target_data
    mut data := feature_data + " " + target_data

    // Build the command-line string
    mut cli_string := "python " + python_script_path + " --slope " + slope + " --intercept " + intercept + " --data " + data

	// Execute the CLI Command to run the python Script
	println(os.execute(cli_string))
}
