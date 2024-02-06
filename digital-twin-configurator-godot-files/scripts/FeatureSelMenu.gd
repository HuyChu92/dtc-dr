extends GraphNode

@onready var menuGraphNode = self


@onready var _componentNameLabel : Label = $HBoxContainer/ComponentNameLabel
@onready var model_option : OptionButton = $train_dataset_container/OptionButton
@onready var vertical_container = $featureControl

var ComponentFeatureSelBool = false
var ComponentName

#Popup
@onready var resultsPopup = $PopupPanel
##Var voor openen Plot
var urlscattertrain
var urlscattertest
##Button voor popup na trainen
@onready var results_button = $ResultsButton


#Features
# Assuming you have a list of features
var features = [
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

var selectedXFeatures = []
var selectedYFeatures : String = ""

var selected_model_option

# Get the reference to the VerticalBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	menuGraphNode.visible = ComponentFeatureSelBool
	SignalHub.connect("ComponentFeatureStatus", Callable(self, "_on_configure_features_button_pressed"))
	_init_model_options()
	_generate_features()
	

func _init_model_options():
	model_option.add_item("Linear Regression")
	model_option.add_item("Neural Network")
	model_option.add_item("Random Forests")
	model_option.add_item("DecisionTree")
	

	
func _generate_features():
	for feature in features:
		var horizontal_container = HBoxContainer.new()
	
		vertical_container.add_child(horizontal_container)
	
		var id_label = Label.new()
		id_label.text = str(features.find(feature))
		horizontal_container.add_child(id_label)
		id_label.size_flags_horizontal = 0
		id_label.size_flags_vertical = 4
	
		var name_label = Label.new()
		name_label.text = feature
		horizontal_container.add_child(name_label)
		name_label.size_flags_horizontal = 3
		name_label.size_flags_vertical = 4
	
		var Xcheckbutton = CheckButton.new()
		var Ycheckbutton = CheckButton.new()
		
		var callX = Callable(self, "_on_checkbutton_X_toggled")
		callX = callX.bind(feature)
		Xcheckbutton.connect("toggled", callX)
		horizontal_container.add_child(Xcheckbutton)
		Xcheckbutton.size_flags_horizontal = 3
		Xcheckbutton.size_flags_vertical = 4


		var callY = Callable(self, "_on_checkbutton_Y_toggled")
		callY = callY.bind(feature)
		Ycheckbutton.connect("toggled", callY)
		horizontal_container.add_child(Ycheckbutton)
		Ycheckbutton.size_flags_horizontal = 8
		Ycheckbutton.size_flags_vertical = 1


func _on_checkbutton_X_toggled(checked, feature):
	if checked and feature not in selectedYFeatures:
		selectedXFeatures.append(feature)
		pass
	else:
		selectedXFeatures.erase(feature)
		pass
	
func _on_checkbutton_Y_toggled(checked, feature):
	if checked and feature not in selectedXFeatures:
		selectedYFeatures = feature
		pass
	else:
		#selectedYFeatures.erase(feature)
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_configure_features_button_pressed(ComponentFeatureSelBool, ComponentName):
	menuGraphNode.visible = ComponentFeatureSelBool
	_componentNameLabel.text = ComponentName

func _on_close_button_pressed():
	self.ComponentFeatureSelBool = false
	menuGraphNode.visible = ComponentFeatureSelBool

func _on_start_train_button_pressed():
	#selectedYFeatures = str(selectedYFeatures)
	var selectedModel = model_option.get_item_text(model_option.selected)
	print(model_option.get_item_text(model_option.selected),selectedXFeatures,selectedYFeatures)
	
	var postBody : Dictionary = {
	  "dataset": "C:\\Users\\scrae\\Desktop\\dtc-dr\\digitaltwins\\api\\datasets\\continuous_factory_process\\continuous_factory_process.csv",
	  "features": selectedXFeatures,
	  "y": selectedYFeatures,
	  "model": selectedModel,
	  "scaler": false,
	  "save_model": true
	}
	
	var url = "http://127.0.0.1:8000/trainModel/"
	var headers = ["Content-Type: application/json"]
	

	$HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(postBody))


func _on_http_request_request_completed(result, response_code, headers, body):
	results_button.visible = true
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	#Train
	var evaluation_train = json["evaluation"]["evaluation"]["train"]
	var r2_train = evaluation_train["R-squared"]
	var mse_train = evaluation_train["Mean Squared Error"]
	var rmse_train = evaluation_train["Root Mean Squared Error"]
	
	
	#Test
	var evaluation_test = json["evaluation"]["evaluation"]["test"]
	var r2_test = evaluation_test["R-squared"]
	var mse_test = evaluation_test["Mean Squared Error"]
	var rmse_test = evaluation_test["Root Mean Squared Error"]
	
	#Global
	self.urlscattertrain = evaluation_train["Scatter-train"]
	self.urlscattertest = evaluation_test["Scatter-test"]

	
	$PopupPanel/HBoxContainer/Testbox/R2_testbox/R2_test_label.text = str(r2_test)
	$PopupPanel/HBoxContainer/Testbox/MSE_testbox/MSE_test_label.text = str(mse_test)
	$PopupPanel/HBoxContainer/Testbox/RMSE_testbox/RMSE_test_label.text = str(rmse_test)
	
	$PopupPanel/HBoxContainer/Trainbox/R2_trainbox/R2_train_label.text = str(r2_train)
	$PopupPanel/HBoxContainer/Trainbox/MSE_trainbox/MSE_train_label.text = str(mse_train)
	$PopupPanel/HBoxContainer/Trainbox/RMSE_trainbox/RMSE_train_label.text = str(rmse_train)
	
	resultsPopup.visible = true


func _on_open_train_plot_pressed():
	OS.shell_open(urlscattertrain)
	pass


func _on_open_test_plot_pressed():
	OS.shell_open(urlscattertest)
	pass


func _on_results_button_pressed():
	resultsPopup.visible = true
	pass
