from sklearn.linear_model import LinearRegression
from sklearn.tree import DecisionTreeRegressor
from sklearn.model_selection import train_test_split
import pandas as pd
from sklearn.metrics import r2_score, mean_squared_error
from sklearn.feature_selection import SelectKBest, f_regression
import numpy as np
from sklearn.preprocessing import StandardScaler
import seaborn as sns
import matplotlib.pyplot as plt
import os
from pathlib import Path


class ModelSelector:
    def __init__(self, dataset: str, features: list, y: str, model: str, scaler: bool):
        self.dataset = dataset
        self.scaler = StandardScaler()
        self.df = (
            pd.read_csv(dataset) if "csv" in self.dataset else pd.read_excel(dataset)
        )
        self.columns = self.df.columns.tolist().remove(y)
        self.df = self.scaler.fit_transform(self.df) if scaler is True else self.df
        self.X = self.df[features]
        self.Y = self.df[y]
        self.model = (
            DecisionTreeRegressor() if model == "Decision Trees" else LinearRegression()
        )
        self.X_train, self.X_test, self.y_train, self.y_test = train_test_split(
            self.X, self.Y, test_size=0.2, random_state=42
        )
        self.model.fit(self.X_train, self.y_train)
        self.corr_df = None

    def evaluateModel(self):
        # Print results from the training set
        train_r2_score = self.model.score(self.X_train, self.y_train)
        train_mse = mean_squared_error(self.y_train, self.model.predict(self.X_train))
        train_rmse = np.sqrt(train_mse)

        # print(f"Training set - R-squared: {round(train_r2_score, 2)}")
        # print(f"Training set - Mean Squared Error: {round(train_mse, 2)}")
        # print(f"Training set - Root Mean Squared Error: {round(train_rmse, 2)}")

        # Make predictions on the test set
        y_pred = self.model.predict(self.X_test)

        # Evaluate the model's performance on the test set
        r2_score = self.model.score(self.X_test, self.y_test)
        mse = mean_squared_error(self.y_test, y_pred)
        rmse = np.sqrt(mse)

        # print(f"\nTest set - R-squared: {round(r2_score, 2)}")
        # print(f"Test set - Mean Squared Error: {round(mse, 2)}")
        # print(f"Test set - Root Mean Squared Error: {round(rmse, 2)}")

        evaluate_results = {
            "train": {
                "R-squared": train_r2_score,
                "Mean Squared Error": train_mse,
                "Root Mean Squared Error": train_rmse,
            },
            "test": {
                "R-squared": r2_score,
                "Mean Squared Error": mse,
                "Root Mean Squared Error": rmse,
            },
        }

        return evaluate_results


class DatasetEvaluator:
    def __init__(self, dataset: str, dataset_dir: str):
        print(dataset)
        self.dataset_dir = dataset_dir
        self.dataset = dataset
        self.df = (
            pd.read_csv(self.dataset)
            if "csv" in str(self.dataset)
            else pd.read_excel(self.dataset)
        )
        self.createHeatmap()

    def createHeatmap(self):
        # Check correlation
        corr_df = pd.get_dummies(data=self.df, drop_first=False)
        corr_df
        correlation_matrix = corr_df.corr()

        # Step 2: Visualize the correlation matrix using a heatmap
        fig, ax = plt.subplots(figsize=(10, 10))  # Adjust the figure size as needed
        sns.heatmap(
            correlation_matrix,
            annot=True,
            cmap="coolwarm",
            fmt=".2f",
            annot_kws={"size": 8},
            ax=ax,
        )
        plt.title("Correlation Matrix")

        # Save the plot as an image file (e.g., PNG)
        plt.savefig(str(self.dataset_dir) + "/plots" + "/correlation_matrix.png")
        self.corr_df = correlation_matrix

    # def calculate_best_regression_model(self):
    #     for k in range(len(self.X.columns) + 1):
    #         # Instantiate SelectKBest with f_regression scoring function
    #         selector = SelectKBest(score_func=f_regression, k=k)  # Choose the appropriate k value

    #         # Fit and transform the data
    #         X_new = selector.fit_transform(X, y)

    #         # Get selected features
    #         selected_features = selector.get_support()

    #         # Transform original data to keep only selected features
    #         X_selected = selector.transform(X)

    #     return None


# dataset = r'D:\dtc-dr\digitaltwins\api\datasets\House_Price.csv'
# features = ['room_num', 'teachers', 'poor_prop']
# y = 'price'
# model = 'regression'
# scaler = False

# test = ModelSelector(
#     dataset,
#     features,
#     y,
#     model,
#     scaler
# )

# print(test.calculate_best_regression_model())
