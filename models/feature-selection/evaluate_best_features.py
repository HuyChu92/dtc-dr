import json

with open(r'models\feature-selection\decision_tree_results.json', 'r') as decision_tree_results_json:
    decision_tree_results = json.load(decision_tree_results_json)

with open(r'models\feature-selection\regression_results.json', 'r') as regression_results_json:
    regression_results = json.load(regression_results_json)

result = {}
for key, dt_value in decision_tree_results.items():
    max_dt_index = dt_value["r2_scores"].index(max(dt_value["r2_scores"]))

    rg_value = regression_results.get(key, {"r2_scores": [], "selected_feature_indices": []})
    max_rg_index = rg_value["r2_scores"].index(max(rg_value["r2_scores"]))

    result[key] = {
        "decision_tree": (max(dt_value["r2_scores"]), dt_value["selected_feature_indices"][max_dt_index]),
        "regression": (max(rg_value["r2_scores"]), rg_value["selected_feature_indices"][max_rg_index]),
    }

# Save the results to a JSON file
with open('model_evaluation.json', 'w') as json_file:
    json.dump(result, json_file, indent=4)

