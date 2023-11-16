extends GraphNode

@onready var Line = $Line
@onready var _componentName : Label = $Line/ComponentName
@onready var flaskOutput = $Line/FlaskOutput

var ComponentMenuVisBool = false
var receiver_node_name : String = ""
var NewReceiveNodeName : String = ""
var connectionDict = {}
var SendComponent
var json_result


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalHub.connect("NewReceiveNodeName", Callable(self, "_onInitialiseNode"))
	SignalHub.connect("connectionDict", Callable(self, "_isConnected"))
	

#De nieuwe receive node wordt aangemaakt, de meegegeven naam wordt toegewezen en weergegeven.
func _onInitialiseNode(NewReceiveNodeName):
	set_name(NewReceiveNodeName)
	receiver_node_name = get_name()
	_componentName.text = receiver_node_name

#Er wordt gekeken of de huidige node (receiver_node_name) aanwezig is in connectionDict (waarin alle connections gedefineerd zijn)
#Vervolgens wordt de sendnode geassocieerd met de receivenode achterhaald. 
#De functie _accesRawApiData wordt aangeroepen. De API inhoud van de achterhaalde sendnode wordt geraadpleegd
func _isConnected(connectionDict):
	print("receiver_node_name: ", receiver_node_name)
	
	if receiver_node_name not in connectionDict:
		print("an error has occured. Please try to lay the connection an other way")
	else:
		self.SendComponent = connectionDict[receiver_node_name]["from="]
		SignalHub.connect("nodeInformationDict", Callable(self, "_accesRawApiData"))

#Voor verwerking in de flask server wordt de array in aparte integers omgezet in een dictionary.
func _accesRawApiData(nodeInformationDict):
	self.json_result = nodeInformationDict[SendComponent]["Api Data= "]
	_convert_string_to_dict(json_result)
	
	
#Voor verwerking in de flask server wordt de array in aparte integers omgezet in een dictionary.
func _convert_string_to_dict(json_result: Array) -> Dictionary:
	var data = {}

	for i in range(json_result.size()):
		data["int" + str(i + 1)] = json_result[i]

	_flaskRequest(data)
	return data

#De dictionary wordt naar de flask server gepost (Ip adres aanpassen aan de flask server!!!).	
func _flaskRequest(data):
	var json = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]
	#Ip adres aanpassen aan het IP waar flask wordt gehost.
	$HTTPPost.request("http://0.0.0.0/sum", headers, HTTPClient.METHOD_POST, json)

#Het gerturnede resultaat wordt weergegeven in de scrollbox flaskOutput
func _on_http_post_request_completed(result, response_code, headers, body):
	var json_post_result = JSON.parse_string(body.get_string_from_utf8())
	flaskOutput.text = str(json_post_result)

## Controls
#Resize
func _on_resize_request(new_minsize):
	self.size = new_minsize

#Close    
func _on_close_request():
	self.queue_free()


func _on_configure_button_pressed():
	self.ComponentMenuVisBool = true
	receiver_node_name = get_name()
	SignalHub.emit_signal("ComponentMenuStatus", ComponentMenuVisBool, receiver_node_name)
	SignalHub.emit_signal("NodeInformation", receiver_node_name)
