## Installatie

-   python -m venv env
-   env\scripts\activate.bat
-   pip install -r requirements.txt

## Starten applicatie

-   Open cmd
-   navigeer naar projectfolder
-   voer de volgende command uit: runcommand.bat

## Django API doc's

1. Train model (POST request)
   **description** : Regressie model trainen. Keuze uit: Decision Trees, Linear Regression, Random Forest & Neural Network
   **url** : [http://127.0.0.1:8000/trainModel](http://127.0.0.1:8000/trainModel)
   **example post-body**: {
   "dataset": "D:\\dtc-dr\\digitaltwins\\api\\datasets\\continuous_factory_process\\continuous_factory_process.csv",
   "features": ["Machine1.RawMaterial.Property2"],
   "y": "Machine1.RawMaterial.Property3",
   "model": "Linear Regression",
   "scaler": false,
   "save_model": true,
   "parameters": []
   }
   **example response**: {
   "evaluation": {
   "model_name": "LinearRegression_20240216113645",
   "created_at": "2024-02-16 11:36:45",
   "dataset": "D:\\dtc-dr\\digitaltwins\\api\\datasets\\continuous_factory_process\\continuous_factory_process.csv",
   "model_parameters": {
   "copy_X": true,
   "fit_intercept": true,
   "n_jobs": null,
   "positive": false
   },
   "X": [
   "Movie_length",
   "Director_rating",
   "Critic_rating"
   ],
   "y": "Budget",
   "evaluation": {
   "train": {
   "R-squared": 0.8168442039487912,
   "Mean Squared Error": 2934.70170992428,
   "Root Mean Squared Error": 54.1728872216008,
   "Scatter-train": "http://127.0.0.1:8000/fetchScatterplot/continuous_factory_process/LinearRegression_20240216113645/scatterplot-train.png"
   },
   "test": {
   "R-squared": 0.8003748070955019,
   "Mean Squared Error": 3217.292776631658,
   "Root Mean Squared Error": 56.72118454891133,
   "Scatter-test": "http://127.0.0.1:8000/fetchScatterplot/continuous_factory_process/LinearRegression_20240216113645/scatterplot-test.png"
   }
   }
   }
   }
2. Dataset details (GET Request)
   **description** : Duplicates, NaN & kolomnamen opvragen voor een dataset.
   **url** : [http://127.0.0.1:8000/dataset_detail/movie.xlsx](http://127.0.0.1:8000/dataset_detail/movie.xlsx)
   **example response**:
   {
   "NaN": 12,
   "duplicate*count": 0,
   "columns": [
   "Marketing expense",
   "Production expense",
   "Multiplex coverage",
   "Budget",
   "Movie_length",
   "Lead* Actor_Rating",
   "Lead_Actress_rating",
   "Director_rating",
   "Producer_rating",
   "Critic_rating",
   "Trailer_views",
   "3D_available",
   "Time_taken",
   "Twitter_hastags",
   "Genre",
   "Avg_age_actors",
   "Num_multiplex",
   "Collection"
   ]
   }
3. Dataset correlatie afbeelding (GET Request)
   **description** : Correlatie afbeelding opvragen van een dataset (LET OP: WERKT ALLEEN ALS ALLE KOLOMMEN NUMERIEK ZIJN).
   **url** : [http://127.0.0.1:8000/dataset_detail/movie.xlsx/correlation_matrix.png](http://127.0.0.1:8000/dataset_detail/movie.xlsx/correlation_matrix.png)
   **example response**: ![movie.xlsx/correlation_matrix.png](http://127.0.0.1:8000/dataset_detail/movie.xlsx/correlation_matrix.png)
4. Fetch Models (GET Request)
   **description** : Haalt alle namen van de datasets op in de huidige lokale projectomgeving(digitaltwins\api\datasets).
   **url** : [http://127.0.0.1:8000/fetchDatasets](http://127.0.0.1:8000/fetchDatasets)
   **example response**: {
   "files": [
   "continuous_factory_process.csv",
   "Movie.xlsx",
   "ToyotaCorolla.xlsx"
   ]
   }
5. Fetch scatterplot (GET Request)
   **description** : Train of test scatterplot ophalen van getrainde model.
   **url** : [http://127.0.0.1:8000/fetchScatterplot/ToyotaCorolla/LinearRegression_20240206154923/scatterplot-test.png](http://127.0.0.1:8000/fetchScatterplot/ToyotaCorolla/LinearRegression_20240206154923/scatterplot-test.png)
   **example response**: ![ToyotaCorolla/LinearRegression_20240206154923/scatterplot-test.png](http://127.0.0.1:8000/fetchScatterplot/ToyotaCorolla/LinearRegression_20240206154923/scatterplot-test.png)
6. Upload dataset 
   **description** : Dataset uploaden via een interface.
   **url** : [http://127.0.0.1:8000/uploadDataset](http://127.0.0.1:8000/uploadDataset)
  