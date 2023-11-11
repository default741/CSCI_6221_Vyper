module linear_regression

import utils


pub struct LinearRegression {
	/*
	LinearRegression is a struct representing a linear regression model.

	Attributes:
		- mut weights: A 1D array representing the weights of the model.
		- mut bias: A scalar representing the bias of the model.
		- mut learning_rate: A scalar representing the learning rate for gradient descent.
		- mut iterations: An integer representing the number of iterations for gradient descent.
		- mut zero_weight_bias: A boolean indicating whether to initialize weights and bias to zero.
		- mut num_features: An integer representing the number of features in the dataset.
		- mut r_square: A scalar representing the coefficient of determination (R²) for the model.
	*/
    mut:
        weights []f64
        bias f64
        learning_rate f64
        iterations int
        zero_weight_bias bool
        num_features int
        r_square f64
}


pub fn LinearRegression.init_model(learning_rate f64, iterations int, zero_weight_bias bool, num_features int) LinearRegression {
	/*
	init_model initializes a LinearRegression model with specified parameters.

	Parameters:
		- learning_rate: A scalar representing the learning rate for gradient descent.
		- iterations: An integer representing the number of iterations for gradient descent.
		- zero_weight_bias: A boolean indicating whether to initialize weights and bias to zero.
		- num_features: An integer representing the number of features in the dataset.

	Returns:
		- A LinearRegression model with the specified parameters.
	*/
    return LinearRegression {
        learning_rate: learning_rate
        iterations: iterations
        zero_weight_bias: zero_weight_bias
        num_features: num_features
    }
}

fn (mut lr_model LinearRegression) init_coef(x [][]f64, y []f64, zero_weight_bias bool, num_features int) ([]f64, f64) {
	/*
	init_coef initializes the weights and bias for a linear regression model.

	Parameters:
		- x: A 2D array representing the features of the dataset.
		- y: A 1D array representing the target values.
		- zero_weight_bias: A boolean indicating whether to initialize weights and bias to zero.
		- num_features: An integer representing the number of features.

	Returns:
		- init_weights: A 1D array representing the initialized weights.
		- init_bias: A scalar representing the initialized bias.
	*/

    // Initialize arrays for weights and bias
    mut init_weights := []f64{}
    mut init_bias := 0.0

    // Check if weights and bias should be initialized to zero
    if zero_weight_bias {
        for _ in 0..num_features {
            init_weights << 0.0 // Initialize weights to zero
        }

        init_bias = 0.0 // Initialize bias to zero
    } else {
        mut mx_sum := 0.0 // Initialize a variable to store the sum of products of weights and feature means

        // Calculate weights based on the covariance and variance of features
        for idx in 0..num_features {
            init_weights << utils.round(utils.fcovariance(x[idx], y) / utils.fvariance(x[idx]))
            mx_sum = mx_sum + (init_weights[idx] * utils.fmean(x[idx]))
        }

        // Calculate bias based on the mean of target values and the sum of weighted feature means
        init_bias = utils.round(utils.fmean(y) - mx_sum)
    }

    return init_weights, init_bias // Return the initialized weights and bias
}

pub fn (mut lr_model LinearRegression) fit_model(x [][]f64, y []f64) LinearRegression {
	/*
	fit_model fits the LinearRegression model to the provided dataset.

	Parameters:
		- x: A 2D array representing the features of the dataset.
		- y: A 1D array representing the target values.

	Returns:
		- The fitted LinearRegression model.
	*/

    // Initialize weights and bias using init_coef method
    mut init_weights, init_bias := lr_model.init_coef(x, y, lr_model.zero_weight_bias, lr_model.num_features)

    // Set the model's weights and bias to the initialized values
    lr_model.weights = init_weights
    lr_model.bias = init_bias

    // Initialize an array to store predicted values
    mut y_pred := []f64{}

    // Perform gradient descent for the specified number of iterations
    for _ in 0..lr_model.iterations {
        // Predict target values using the current weights and bias
        y_pred = lr_model.predict(x)

        // Calculate gradients for weights and bias
        dw, db := lr_model.calculate_gradients(x, y, y_pred)

        // Update weights using the learning rate and calculated gradients
        for idx in 0..lr_model.num_features {
            lr_model.weights[idx] = utils.round(lr_model.weights[idx] - (lr_model.learning_rate * dw[idx]))
        }

        // Update bias using the learning rate and calculated bias gradient
        lr_model.bias = utils.round(lr_model.bias - (lr_model.learning_rate * db))
    }

    // Calculate and store the R² score for the model
    lr_model.score(y_pred, y)

    // Return the fitted LinearRegression model
    return lr_model
}

pub fn (mut lr_model LinearRegression) predict(x [][]f64) []f64 {
	/*
	predict generates predictions using the LinearRegression model.

	Parameters:
		- x: A 2D array representing the features for which predictions are to be generated.

	Returns:
		- A 1D array containing the predicted target values.
	*/

    // Initialize an array to store predicted values
    mut y_pred := []f64{}

    // Iterate through each record in the feature matrix
    for idx_i in 0..x[0].len {
        // Initialize a variable to store the sum of products of features and weights
        mut slope_x_sum := 0.0

        // Iterate through each feature and calculate the product of feature value and corresponding weight
        for idx_j in 0..x.len {
            slope_x_sum = slope_x_sum + (x[idx_j][idx_i] * lr_model.weights[idx_j])
        }

        // Calculate the predicted target value by adding the sum of products and the bias
        y_pred << utils.round(slope_x_sum + lr_model.bias)
    }

    // Return the array containing the predicted target values
    return y_pred
}

fn (mut lr_model LinearRegression) calculate_gradients(x [][]f64, y []f64, y_pred []f64) ([]f64, f64) {
	/*
	calculate_gradients calculates the gradients for the weights (dw) and the bias (db) in a linear regression model.

	Parameters:
		- x: A 2D array representing the features of the dataset.
		- y: A 1D array representing the target values.
		- y_pred: A 1D array representing the predicted values.

	Returns:
		- dw: A 1D array representing the gradients for the weights.
		- db: A scalar representing the gradient for the bias.
	*/

    // Get the number of records and features
    num_records := x[0].len
    num_features := x.len

    mut loss := []f64{} // Initialize an array to store the differences between true values and predicted values

    // Calculate the loss for each record
    for idx_i in 0..num_records {
        loss << y[idx_i] - y_pred[idx_i]
    }

    // Initialize arrays to store gradients and intermediate values
    mut dw := []f64{}
    mut cost_func := []f64{}

    // Calculate gradients for weights (dw)
    for idx_j in 0..num_features {
        for idx_i in 0..num_records {
            cost_func << x[idx_j][idx_i] * loss[idx_i] // Compute the product of the feature and the corresponding loss
        }

        dw << -2 * utils.fsum(cost_func) / num_records // Compute the mean of the product and multiply by a constant factor
    }

    mut db := -2 * utils.fsum(loss) / num_records // Calculate the gradient for the bias (db)

    return dw, db // Return the computed gradients
}

pub fn (mut lr_model LinearRegression) score(predicted_data []f64, actual_data []f64) {
	/*
	score calculates the coefficient of determination (R²) for the LinearRegression model.

	Parameters:
		- predicted_data: A 1D array containing the predicted target values.
		- actual_data: A 1D array containing the actual target values.

	Returns:
		- None (modifies the R² attribute of the LinearRegression model).
	*/

    // Assert that the lengths of actual_data and predicted_data are equal
    assert actual_data.len == predicted_data.len

    // Initialize arrays to store residuals and total sum of squares
    mut rss := []f64{}
    mut tss := []f64{}

    // Calculate the mean of actual_data
    mean_y := utils.fmean(actual_data)

    // Iterate through each data point and calculate residuals and total sum of squares
    for idx in 0..actual_data.len {
        rss << (actual_data[idx] - predicted_data[idx]) * (actual_data[idx] - predicted_data[idx])
        tss << (actual_data[idx] - mean_y) * (actual_data[idx] - mean_y)
    }

    // Calculate R² and round the result
    lr_model.r_square = utils.round(1 - (utils.fsum(rss) / utils.fsum(tss)))
}

pub fn (mut lr_model LinearRegression) summary() {
}