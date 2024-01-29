extends Control

@onready var _menu : Control = $Control
@onready var _componentNameLabel : Label = $Control/ComponentNameLabel
@onready var model_option : OptionButton = $Control/OptionButton

var ComponentFeatureSelBool = false
var ComponentName


#Features
# Assuming you have a list of features
var features = ["Measurement1.Actual", "Measurement2.Actual", "Measurement3.Actual"]

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
	model_option.add_item("Decision Trees")
	#model_option.selected = 0


	
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
		pass
	else:
		pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_configure_features_button_pressed(ComponentFeatureSelBool, ComponentName):
	_menu.visible = ComponentFeatureSelBool
	_componentNameLabel.text = ComponentName
	#_resetCompMenu()
	#
	#if nodeInformationDict.has (ComponentName):
		##print("nodeInformationDict", nodeInformationDict)
		#var accesApiData = nodeInformationDict[ComponentName]["Api Data= "]
		#ApiOutput.text = str(accesApiData)
		#
		#var accesApiUrl = nodeInformationDict[ComponentName]["Api Url= "]
		#_ApiInputBox.text = str(accesApiUrl)
		#
	#else:
		#ApiOutput.text = ""


func _on_close_button_pressed():
	self.ComponentFeatureSelBool = false
	_menu.visible = ComponentFeatureSelBool
