import json
import numpy as np

# Load the results from the regression model
with open(r'D:\dtc-dr\models\feature-selection\test_regression_results.json', 'r') as regression_file:
    regression_results = json.load(regression_file)

# Load the results from the decision tree model
with open(r'D:\dtc-dr\models\feature-selection\test_decision_tree_results.json', 'r') as decision_tree_file:
    decision_tree_results = json.load(decision_tree_file)

# Load the results from the MLP model
with open(r'D:\dtc-dr\test_regression_MLP_results.json', 'r') as mlp_results_json:
    mlp_results = json.load(mlp_results_json)

# Create a new dictionary to store combined results
combined_results = {}

# Iterate over the target variables
for col in regression_results.keys():
    regression_scores_train = regression_results[col]["r2_scores_train"]
    regression_scores_test = regression_results[col]["r2_scores_test"]

    decision_tree_scores_train = decision_tree_results[col]["r2_scores_train"]
    decision_tree_scores_test = decision_tree_results[col]["r2_scores_test"]

    mlp_scores_train = mlp_results[col]["r2_scores_train"]
    mlp_scores_test = mlp_results[col]["r2_scores_test"]

    # Find the index of the max R-squared value for all models
    max_r2_regression_train_index = np.argmax(regression_scores_train)
    max_r2_regression_test_index = np.argmax(regression_scores_test)

    max_r2_decision_tree_train_index = np.argmax(decision_tree_scores_train)
    max_r2_decision_tree_test_index = np.argmax(decision_tree_scores_test)

    max_r2_mlp_train_index = np.argmax(mlp_scores_train)
    max_r2_mlp_test_index = np.argmax(mlp_scores_test)

    # Extract the selected features for all models
    selected_features_regression = regression_results[col]["selected_feature_indices"][max_r2_regression_train_index]
    selected_features_decision_tree = decision_tree_results[col]["selected_feature_indices"][max_r2_decision_tree_train_index]
    selected_features_mlp = mlp_results[col]["selected_feature_indices"][max_r2_mlp_train_index]

    # Combine the information into a dictionary
    combined_results[col] = {
        "regression": (
            regression_scores_train[max_r2_regression_train_index],
            regression_scores_test[max_r2_regression_test_index],
            selected_features_regression
        ),
        "decision_tree": (
            decision_tree_scores_train[max_r2_decision_tree_train_index],
            decision_tree_scores_test[max_r2_decision_tree_test_index],
            selected_features_decision_tree
        ),
        "mlp": (
            mlp_scores_train[max_r2_mlp_train_index],
            mlp_scores_test[max_r2_mlp_test_index],
            selected_features_mlp
        )
    }

# Save the combined results to a new JSON file
with open('combined_results_23012024.json', 'w') as combined_file:
    json.dump(combined_results, combined_file, indent=4)

print("Combined results saved to combined_results.json")
