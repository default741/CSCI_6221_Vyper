module py_plot

import os

pub struct PlotGraph {
    pub mut:
        slope f64
        intercept f64
        feature_data []f64
        target_data []f64
}

fn (mut plot_params PlotGraph) get_params() (f64, f64, []f64, []f64) {
	return plot_params.slope, plot_params.intercept, plot_params.feature_data, plot_params.target_data
}

pub fn plot_graph(mut plot_params PlotGraph) {

	mut python_script_path := "./lr_plot.py"

	slope, intercept, feature_data, target_data := plot_params.get_params()

	mut slope_string := slope.str()
	mut intercept_string := intercept.str()
	mut feature_data_string := feature_data.str()
	mut target_data_string := target_data.str()
	mut feature_data_string_strip := feature_data_string.replace(',', '')
	feature_data_string_strip = feature_data_string_strip.replace('[', '')
	feature_data_string_strip = feature_data_string_strip.replace(']', '')
	mut target_data_string_strip := target_data_string.replace(',', '')
	target_data_string_strip = target_data_string_strip.replace('[', '')
	target_data_string_strip = target_data_string_strip.replace(']', '')

	mut data := feature_data_string_strip  + " " +target_data_string_strip

	// Construct the command string
	mut command_string := python_script_path + " --data " + data + " --slope " + slope_string + " --intercept " +  intercept_string
	//println(command_string)


	// Execute the Python script
	os.execvp("python", [command_string]) or {
	   println("Error executing Python script")
  }
  }