extends Control

@onready var _menu : Control = $Control
@onready var _componentNameLabel : Label = $Control/ComponentNameLabel
@onready var _ApiInputBox : LineEdit = $Control/ApiInput
@onready var http_request = $Control/setApiButton/HTTPRequest
@onready var apiErrorLabel : Label = $Control/apiErrorLabel
@onready var apiSuccesLabel : Label = $Control/apiSuccesLabel
@onready var ApiOutput = $Control/ApiOutput

var ComponentMenuVisBool = false
var ComponentName : String = ""
var ApiInput : String = ""
var rawApiData 
var nodeInformationDict : Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	_menu.visible = ComponentMenuVisBool
	# Haalt de ComponentMenuStatus op van ComponentMenuStatus.gd wanneer op 'configure' wordt gedrukt in de node/component
	SignalHub.connect("ComponentMenuStatus", Callable(self, "_on_configure_button_pressed"))
	SignalHub.connect("nodeInformationDict", Callable(self, "_displayRawApi"))
	SignalHub.connect("nodeInformationDict", Callable(self, "_on_configure_button_pressed"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _resetCompMenu():
	apiSuccesLabel.visible = false
	apiErrorLabel.visible = false
	

#Dit verzorgd de naam van de geselecteerde component in het menu
func _on_configure_button_pressed(ComponentMenuVisBool, ComponentName):

	_menu.visible = ComponentMenuVisBool
	_componentNameLabel.text = ComponentName
	_resetCompMenu()
	
	if nodeInformationDict.has (ComponentName):
		#print("nodeInformationDict", nodeInformationDict)
		var accesApiData = nodeInformationDict[ComponentName]["Api Data= "]
		ApiOutput.text = str(accesApiData)
		
		var accesApiUrl = nodeInformationDict[ComponentName]["Api Url= "]
		_ApiInputBox.text = str(accesApiUrl)
		
	else:
		ApiOutput.text = ""

#Verberg het ComponentMenu wanneer op X wordt gedrukt.
func _on_close_button_pressed():
	self.ComponentMenuVisBool = false
	_menu.visible = ComponentMenuVisBool


#Wanneer op de API ('set') knop wordt gedrukt
func _on_set_api_button_pressed():
	self.ApiInput = _ApiInputBox.text
	self.ComponentName = _componentNameLabel.text
	
	var error = http_request.request(ApiInput)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		apiSuccesLabel.visible = false
		apiErrorLabel.visible = true
		ApiOutput.text = ""
	
#Wanneer de request van de API is voltooid wordt rawApiData toegewezen en weergegeven in _addToNodeInformation
func _on_http_request_request_completed(result, response_code, headers, body):
	print("response code = ", response_code)
	apiErrorLabel.visible = false
	apiSuccesLabel.visible = true
	self.rawApiData = JSON.parse_string(body.get_string_from_utf8())
	_addToNodeInformation(ComponentName, ApiInput, rawApiData)

		
func _addToNodeInformation(ComponentName, ApiInput, rawApiData):
	ApiInput = _ApiInputBox.text
	ComponentName = _componentNameLabel.text
	
	SignalHub.emit_signal("NodeInformation", ComponentName, ApiInput, rawApiData)
	
#deze functie behandelt het weergeven van de ruwe api in de ComponentMenu scene
func _displayRawApi(nodeInformationDict):
	self.nodeInformationDict = nodeInformationDict
	
	if ComponentName in self.nodeInformationDict:
		var api_data = self.nodeInformationDict[ComponentName]["Api Data= "]
		ApiOutput.text = str(api_data)
		
	else:
		print("Node name not found in nodeInformationDict")
		return null


#func _on_invis_name_change_button_button_down():
	#_componentNameLabel.visible = 0
	#$Control/NewNameInput.visible = 1
	#$Control/InvisNameChangeButton.visible = 0
#
#
#func _on_new_name_input_text_submitted(new_text):
	#self.ComponentName = $Control/NewNameInput.text
	#$Control/NewNameInput.visible = 0
	#_componentNameLabel.text = ComponentName
	#_componentNameLabel.visible = 1
	#$Control/InvisNameChangeButton.visible = 1
	#SignalHub.emit_signal("NodeInformation", ComponentName)
