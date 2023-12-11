import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score 
from sklearn.preprocessing import StandardScaler
import pickle

# Assuming df is your DataFrame
df = pd.read_csv(r"D:\projects\dtc-dr\data-analyse\continuous_factory_process.csv", delimiter=",")
# X represents input features (sensor readings from Machines 1 to 3)
# y represents the target variable (measurements of the 15 features after the first stage)
# Specify the list of prefixes you want to filter
prefixes_to_match = ['Machine1', 'Machine2' , 'Machine3', 'time_stamp']

# Use list comprehension to filter columns based on prefixes
filtered_columns = [col for col in df.columns if any(col.startswith(prefix) for prefix in prefixes_to_match)]


X = df[filtered_columns]
X = X.drop('time_stamp', axis=1) 
print(X.columns.tolist())

y = df[['Stage1.Output.Measurement0.U.Actual', 'Stage1.Output.Measurement1.U.Actual',
        'Stage1.Output.Measurement2.U.Actual', 'Stage1.Output.Measurement3.U.Actual',
        'Stage1.Output.Measurement4.U.Actual', 'Stage1.Output.Measurement5.U.Actual',
        'Stage1.Output.Measurement6.U.Actual', 'Stage1.Output.Measurement7.U.Actual',
        'Stage1.Output.Measurement8.U.Actual', 'Stage1.Output.Measurement9.U.Actual',
        'Stage1.Output.Measurement10.U.Actual', 'Stage1.Output.Measurement11.U.Actual',
        'Stage1.Output.Measurement12.U.Actual', 'Stage1.Output.Measurement13.U.Actual',
        'Stage1.Output.Measurement14.U.Actual']]

# Split the data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Standardize the features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Create a multilinear regression model
model = LinearRegression()


# Train the model
model.fit(X_train_scaled, y_train)

with open('linear_regression_model.pkl', 'wb') as model_file:
    pickle.dump(model, model_file)

# Make predictions on the test set
y_pred = model.predict(X_test_scaled)

# Evaluate the model
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

print(f'Mean Squared Error: {mse}')
print(f'R-squared: {r2}')
