extends Node

var nodeInformationDict = {}

var node_name : String = ""
var ApiInput : String = ""
var rawApiData

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalHub.connect("NodeInformation", Callable(self, "_updateNodeDict"))
		
func _updateNodeDict(node_name, ApiInput, rawApiData):
	self.node_name = node_name
	self.ApiInput = ApiInput
	self.rawApiData = rawApiData
	nodeInformationDict[node_name] = {"Node Name= ": node_name, "Api Url= ": ApiInput, "Api Data= ": rawApiData}
	print("Dict: ", nodeInformationDict)
	SignalHub.emit_signal("nodeInformationDict", nodeInformationDict)
