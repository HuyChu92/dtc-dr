import numpy as np
from sklearn.datasets import make_regression
from sklearn.model_selection import train_test_split
from sklearn.feature_selection import SelectKBest, f_regression
from sklearn.linear_model import LinearRegression
from sklearn.neural_network import MLPRegressor
from sklearn.metrics import mean_squared_error, r2_score
import pandas as pd
import json

df = pd.read_csv(
    r"D:\dtc-dr\data-analyse\continuous_factory_process.csv", delimiter=","
)

prefixes_to_match = ["Machine1", "Machine2", "Machine3", "time_stamp"]

# Use list comprehension to filter columns based on prefixes
filtered_columns = [
    col
    for col in df.columns
    if any(col.startswith(prefix) for prefix in prefixes_to_match)
]

X = df[filtered_columns]
X = X.drop("time_stamp", axis=1)

y_columns = [
    "Stage1.Output.Measurement0.U.Actual",
    "Stage1.Output.Measurement1.U.Actual",
    "Stage1.Output.Measurement2.U.Actual",
    "Stage1.Output.Measurement3.U.Actual",
    "Stage1.Output.Measurement4.U.Actual",
    "Stage1.Output.Measurement5.U.Actual",
    "Stage1.Output.Measurement6.U.Actual",
    "Stage1.Output.Measurement7.U.Actual",
    "Stage1.Output.Measurement8.U.Actual",
    "Stage1.Output.Measurement9.U.Actual",
    "Stage1.Output.Measurement10.U.Actual",
    "Stage1.Output.Measurement11.U.Actual",
    "Stage1.Output.Measurement12.U.Actual",
    "Stage1.Output.Measurement13.U.Actual",
    "Stage1.Output.Measurement14.U.Actual",
    "FirstStage.CombinerOperation.Temperature1.U.Actual",
    "FirstStage.CombinerOperation.Temperature2.U.Actual",
    "FirstStage.CombinerOperation.Temperature3.C.Actual",
]

y = df[y_columns]

# Split the dataset into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

def calculate_best_regression_model():
    results_dict = {}

    for col in y.columns:
        col_results = {"r2_scores_train": [], "r2_scores_test": [], "selected_feature_indices": []}

        for index in range(1, len(X.columns) + 1):
            # Use SelectKBest to select the top features based on f_regression
            k_best = SelectKBest(score_func=f_regression, k=index)
            
            # Transform both the training and test sets
            X_train_selected = k_best.fit_transform(X_train, y_train[col])
            X_test_selected = k_best.transform(X_test)

            # Create and train a multilinear regression model
            model = MLPRegressor(hidden_layer_sizes=(100,), max_iter=1000, random_state=42)
            model.fit(X_train_selected, y_train[col])

            # Make predictions on both the training and test sets
            y_train_pred = model.predict(X_train_selected)
            y_test_pred = model.predict(X_test_selected)

            # Evaluate the model using R-squared for both sets
            r2_train = r2_score(y_train[col], y_train_pred)
            r2_test = r2_score(y_test[col], y_test_pred)

            col_results["r2_scores_train"].append(r2_train)
            col_results["r2_scores_test"].append(r2_test)

            # Print the selected features
            selected_feature_indices = np.where(k_best.get_support())[0]
            col_results["selected_feature_indices"].append(selected_feature_indices.tolist())

        results_dict[col] = col_results
    return results_dict

results = calculate_best_regression_model()

# Save the results to a JSON file
with open('test_regression_MLP_results.json', 'w') as json_file:
    json.dump(results, json_file, indent=4)

print("Results saved to regression_results.json")

