import numpy as np
import plotly.graph_objects as go

from argparse import Namespace, ArgumentParser
from pydantic import BaseModel


class ML_Data(BaseModel):
    """A Pydantic model representing machine learning data with regression parameters.

    Attributes:
        feature_data (list): List of feature data points.
        target_data (list): List of corresponding target data points.

        slope (float): Slope value for the linear regression equation.
        intercept (float): Intercept value for the linear regression equation.

        x_regress (list): List of x-values for the regression line.
        y_regress (list): List of y-values for the regression line.
    """

    feature_data: list
    target_data: list

    slope: float
    intercept: float

    x_regress: list
    y_regress: list


def get_arguments() -> Namespace:
    """Parses command line arguments using argparse.

    Returns:
        argparse.Namespace: An object containing the parsed command line arguments.
    """

    # Create an ArgumentParser object
    parser = ArgumentParser()

    # Define command line arguments
    parser.add_argument('--data', type=str, nargs='*', required=True,
                        help='List of data points for analysis.')
    parser.add_argument('--slope', type=float, required=True,
                        help='Slope value for the linear equation.')
    parser.add_argument('--intercept', type=float, required=True,
                        help='Intercept value for the linear equation.')

    # Parse the command line arguments and return the result
    return parser.parse_args()


def process_data(args: Namespace) -> ML_Data:
    """
    Process command line arguments and generate ML_Data object.

    Args:
        args (Namespace): Parsed command line arguments.

    Returns:
        ML_Data: An ML_Data object containing processed data and regression parameters.
    """
    # Create an instance of the ML_Data class
    data_dict = ML_Data

    # Extract data from command line arguments
    data = args.data

    # Split the data into feature and target data
    data_dict.feature_data = list(map(float, data[:len(data) // 2]))
    data_dict.target_data = list(map(float, data[len(data) // 2:]))

    # Assign slope and intercept values
    data_dict.slope = args.slope
    data_dict.intercept = args.intercept

    # Generate x and y values for the regression line
    data_dict.x_regress = np.array(
        [min(data_dict.feature_data), max(data_dict.feature_data)])
    data_dict.y_regress = list(
        map(lambda x: data_dict.slope * x + data_dict.intercept, data_dict.x_regress))

    return data_dict


def plot_graph(data_dict: ML_Data) -> None:
    """Plot a graph using Plotly to visualize actual data, predicted data, and the regression line.

    Args:
        data_dict (ML_Data): An ML_Data object containing data and regression parameters.
    """

    # Create a Plotly Figure
    fig = go.Figure()

    # Add actual data as scatter plot
    fig.add_trace(go.Scatter(
        x=data_dict.feature_data, y=data_dict.target_data,
        mode='markers', name='Actual Data'
    ))

    # Calculate predicted values based on the regression parameters
    predicted_values_list = [
        (data_dict.slope * xi) + data_dict.intercept for xi in data_dict.feature_data]

    # Add predicted data as another scatter plot
    fig.add_trace(go.Scatter(
        x=data_dict.feature_data, y=predicted_values_list,
        mode='markers', name='Predicted Data'
    ))

    # Add the regression line as a line plot
    fig.add_trace(go.Scatter(
        x=data_dict.x_regress, y=data_dict.y_regress,
        mode='lines', name='Regression Line'
    ))

    # Update layout with axis titles
    fig.update_layout(xaxis_title='Feature_data', yaxis_title='Target Data')

    # Show the plot
    fig.show()

    # Save the plot as an image
    fig.write_image('./images/plot_image.jpeg',
                    format='jpeg', engine='kaleido')

    # Print a success message
    print("Plotting Successful!")


if __name__ == '__main__':
    # Parse command line arguments
    args = get_arguments()

    # Process the parsed arguments and generate an ML_Data object
    data_dict = process_data(args=args)

    # Plot a graph using the processed data
    plot_graph(data_dict=data_dict)
