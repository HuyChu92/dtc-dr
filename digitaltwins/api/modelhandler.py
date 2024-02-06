from sklearn.linear_model import LinearRegression
from sklearn.tree import DecisionTreeRegressor
from sklearn.neural_network import MLPRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
import pandas as pd
from sklearn.metrics import r2_score, mean_squared_error
from sklearn.feature_selection import SelectKBest, f_regression
import numpy as np
from sklearn.preprocessing import StandardScaler
import seaborn as sns
import matplotlib

matplotlib.use("agg")
import matplotlib.pyplot as plt
import os
from pathlib import Path
import pickle
from datetime import datetime
import json
from django.conf import settings


class ModelSelector:
    def __init__(
        self,
        dataset: str,
        features: list,
        y: str,
        model: str,
        scaler: bool,
    ):
        self.created = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.dataset = dataset
        self.model_path = ""
        self.scaler = StandardScaler()
        self.df = (
            pd.read_csv(dataset) if "csv" in self.dataset else pd.read_excel(dataset)
        )
        self.columns = self.df.columns.tolist().remove(y)
        self.df = self.scaler.fit_transform(self.df) if scaler is True else self.df
        self.X = self.df[features]
        self.Y = self.df[y]
        if model == "Decision Trees":
            self.model = DecisionTreeRegressor()
        elif model == "Linear Regression":
            self.model = LinearRegression()
        elif model == "Random Forest":
            self.model = RandomForestRegressor(n_estimators=100)
        elif model == "Neural Network":
            self.model = MLPRegressor()

        self.X_train, self.X_test, self.y_train, self.y_test = train_test_split(
            self.X, self.Y, test_size=0.2, random_state=42
        )
        self.model.fit(self.X_train, self.y_train)
        self.corr_df = None
        self.trained_parameters = self.model.get_params()
        self.meta_info = None
        self.scatter_train = ""
        self.scatter_test = ""
        self.saveModel()

    def evaluateModel(self):
        # Print results from the training set
        train_r2_score = self.model.score(self.X_train, self.y_train)
        train_mse = mean_squared_error(self.y_train, self.model.predict(self.X_train))
        train_rmse = np.sqrt(train_mse)

        # Make predictions on the test set
        y_pred = self.model.predict(self.X_test)

        # Evaluate the model's performance on the test set
        r2_score = self.model.score(self.X_test, self.y_test)
        mse = mean_squared_error(self.y_test, y_pred)
        rmse = np.sqrt(mse)

        evaluate_results = {
            "train": {
                "R-squared": train_r2_score,
                "Mean Squared Error": train_mse,
                "Root Mean Squared Error": train_rmse,
                "Scatter-train": self.scatter_train,
            },
            "test": {
                "R-squared": r2_score,
                "Mean Squared Error": mse,
                "Root Mean Squared Error": rmse,
                "Scatter-test": self.scatter_test,
            },
        }

        return evaluate_results

    def createScatterPlot(self, subdirectory_path):
        y_train_predicted = self.model.predict(self.X_train)
        plt.scatter(self.y_train, y_train_predicted, color="blue", alpha=0.5)
        plt.title("Actual vs. Predicted Values (Training Set)")
        plt.xlabel("Actual Values")
        plt.ylabel("Predicted Values")
        scatter_train = f"scatterplot-train.png"
        dataset = self.dataset.split('\\')[-1].split('.')[0]
        self.scatter_train = f"http://127.0.0.1:8000/fetchScatterplot/{dataset}/{self.model_path}/scatterplot-train.png"
        file_path_scatter_train = os.path.join(subdirectory_path, scatter_train)
        plt.savefig(file_path_scatter_train)  # Save the plot as an image

        y_test_predicted = self.model.predict(self.X_test)
        # Create scatter plot for test set
        plt.scatter(self.y_test, y_test_predicted, color="green", alpha=0.5)
        plt.title("Actual vs. Predicted Values (Test Set)")
        plt.xlabel("Actual Values")
        plt.ylabel("Predicted Values")
        scatter_test = f"scatterplot-test.png"
        self.scatter_train = f"http://127.0.0.1:8000/fetchScatterplot/{dataset}/{self.model_path}/scatterplot-test.png"
        file_path_scatter_test = os.path.join(subdirectory_path, scatter_test)
        plt.savefig(file_path_scatter_test)  # Save the plot as an image

    def saveModel(self):
        model_name = self.model.__class__.__name__
        current_date_time = datetime.now()
        date_string = current_date_time.strftime("%Y%m%d%H%M%S")

        model_path = model_name + "_" + date_string

        # base_directory = r"D:\dtc-dr\digitaltwins\api\datasets\Movie\models"
        base_directory = os.path.join(
            settings.BASE_DIR, "api/datasets", self.dataset.split("\\")[-2], "models"
        )
        print(base_directory)
        # base_directory = os.path.dirname(os.path.abspath(__file__))
        subdirectory_path = os.path.join(base_directory, model_path)

        os.makedirs(subdirectory_path, exist_ok=True)

        file_path = os.path.join(subdirectory_path, model_path + ".pkl")

        with open(file_path, "wb") as model_file:
            pickle.dump(self.model, model_file)

        # Specify the metadata file name
        meta_file_name = f"{model_name}_{date_string}_meta.json"
        file_path_meta_info = os.path.join(subdirectory_path, meta_file_name)

        self.model_path = model_path
        self.createScatterPlot(subdirectory_path)
        
        meta_info = {
            "model_name": model_path,
            "created_at": self.created,
            "dataset": self.dataset,
            "model_parameters": self.trained_parameters,
            "X": features,
            "y": y,
            "evaluation": self.evaluateModel(),
        }

        with open(file_path_meta_info, "w") as meta_file:
            json.dump(meta_info, meta_file, indent=4)
        
        self.meta_info = meta_info

        return f"{model_name}_{date_string} succesfully created at {date_string}"


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
        columns = corr_df.columns.tolist()
        # Step 2: Visualize the correlation matrix using a heatmap
        fig, ax = plt.subplots(
            figsize=(columns, columns)
        )  # Adjust the figure size as needed
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


dataset = r"D:\dtc-dr\digitaltwins\api\datasets\Movie\Movie.xlsx"
features = ["Movie_length", "Director_rating", "Critic_rating"]
y = "Budget"
model = "Neural Network"
scaler = False
parameters = []

# test = ModelSelector(
#     dataset,
#     features,
#     y,
#     model,
#     scaler,
#     parameters=parameters,
# )

# print(test.evaluateModel())

# print(test.calculate_best_regression_model())
