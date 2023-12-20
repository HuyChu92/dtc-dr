from sklearn.linear_model import LinearRegression
from sklearn.tree import DecisionTreeRegressor
from sklearn.model_selection import train_test_split
import pandas as pd
from sklearn.metrics import r2_score, mean_squared_error
import numpy as np
from sklearn.preprocessing import StandardScaler


class ModelSelector:
    def __init__(self, dataset: str, features: list, y: str, model: str, scaler: bool):
        self.dataset = dataset
        self.scaler = StandardScaler()
        self.df = (
            pd.read_csv(dataset) if "csv" in self.dataset else pd.read_excel(dataset)
        )
        self.df = self.scaler.fit_transform(self.df) if scaler is True else self.df
        self.X = self.df[features]
        self.Y = self.df[y]
        self.model = (
            DecisionTreeRegressor() if model == "DecisionTree" else LinearRegression()
        )
        self.X_train, self.X_test, self.y_train, self.y_test = train_test_split(
            self.X, self.Y, test_size=0.2, random_state=42
        )
        self.model.fit(self.X_train, self.y_train)

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
            'train': {
                'R-squared': train_r2_score,
                'Mean Squared Error': train_mse,
                'Root Mean Squared Error': train_rmse
            },
            'test' : {
                'R-squared': r2_score,
                'Mean Squared Error': mse,
                'Root Mean Squared Error': rmse
            },
        }

        return evaluate_results


dataset = r'D:\dtc-dr\digitaltwins\api\datasets\House_Price.csv'
features = ['room_num', 'teachers', 'poor_prop']
y = 'price'
model = 'regression'
scaler = False

# test = ModelSelector(
#     dataset,
#     features,
#     y,
#     model,
#     scaler
# )

# print(test.evaluateModel())