import argparse
import numpy as np
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px

# Create an ArgumentParser object
parser = argparse.ArgumentParser()

# Add an argument for the feature data and target data
parser.add_argument('--data', type=str, nargs='*', required=True)

# Add an argument for the slope
parser.add_argument('--slope', type=float, required=True)

# Add an argument for the intercept
parser.add_argument('--intercept', type=float, required=True)

# Add an argument to save the plot as an image
parser.add_argument('--save_image', action='store_true')

# Parse the command-line arguments
args = parser.parse_args()

# Get the feature data and target data
data = args.data

# Split the data list into feature data and target data lists
feature_data = data[:len(data) // 2]
target_data = data[len(data) // 2:]

# Convert the feature data to numerics
feature_data = list(map(float, feature_data))
target_data = list(map(float, target_data))
print(feature_data)

# Get the slope and intercept
slope = args.slope
intercept = args.intercept

# df = pd.DataFrame({'X': feature_data, 'Y': target_data})

# fig = px.scatter(df, x='X', y='Y')


x = np.array([min(feature_data), max(feature_data)])
y = list(map(lambda x: slope * x + intercept, x))

# fig.add_trace(px.scatter(x=x, y=f(x)))

# Create a Figure object
fig = go.Figure()

# Add the scatter plot trace
fig.add_trace(go.Scatter(
    x=feature_data,
    y=target_data,
    mode='markers',
    name='Scatter Plot'
))


predicted_values_list = []
# Calculate the predicted values
for i in feature_data:
    predicted_values = (slope * i) + intercept
    predicted_values_list.append(predicted_values)
print(predicted_values_list)

fig.add_trace(go.Scatter(
    x=feature_data,
    y=predicted_values_list,
    mode='markers',
    name='Scatter Plot'
))

# Add the regression line trace
fig.add_trace(go.Scatter(
    x=x,
    y=y,
    mode='lines',
    name='Regression Line'
))

# Set the labels for the x and y axes
fig.update_layout(xaxis_title='Target', yaxis_title='Feature')

# Show the plot
fig.show()
print("plotting successfull")
fig.write_image('./plot_image.jpeg')

# Save the plot as an image
# if args.save_image:
#     fig.write_image('plot.png')
