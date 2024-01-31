extends Control

@onready var _menu : Control = $Control
@onready var _componentNameLabel : Label = $Control/ComponentNameLabel
@onready var model_option : OptionButton = $Control/OptionButton

var ComponentFeatureSelBool = false
var ComponentName


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

var selectedFeatures = []
var selected_model_option

# Get the reference to the VerticalBoxContainer
@onready var vertical_container = $Control/featureControl/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	_menu.visible = ComponentFeatureSelBool
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
	
		var name_label = Label.new()
		name_label.text = feature
		horizontal_container.add_child(name_label)
	
		var checkbutton = CheckButton.new()
		var callable = Callable(self, "_on_checkbutton_toggled")
		callable = callable.bind(feature)
		checkbutton.connect("toggled", callable)
		horizontal_container.add_child(checkbutton)


func _on_checkbutton_toggled(checked, feature):
	if checked:
		selectedFeatures.append(feature)
		pass
	else:
		selectedFeatures.erase(feature)
		pass
	print(selectedFeatures)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_configure_features_button_pressed(ComponentFeatureSelBool, ComponentName):
	_menu.visible = ComponentFeatureSelBool
	_componentNameLabel.text = ComponentName

func _on_close_button_pressed():
	self.ComponentFeatureSelBool = false
	_menu.visible = ComponentFeatureSelBool

func _on_start_train_button_pressed():
	var selectedModel = model_option.get_item_text(model_option.selected)
	print(model_option.get_item_text(model_option.selected),selectedFeatures)
	
	var postBody : Dictionary = {
	  "dataset": "C:\\Users\\scrae\\Documents\\Zuyd\\2023-2024\\dtc-dr\\data-analyse\\continuous_factory_process.csv",
	  "features": selectedFeatures,
	  "y": "Stage1.Output.Measurement11.U.Actual",
	  "model": selectedModel,
	  "scaler": false,
	  "save_model": true
	}
	
	var url = "http://127.0.0.1:8000/trainModel/"
	var headers = ["Content-Type: application/json"]
	

	$HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(postBody))
