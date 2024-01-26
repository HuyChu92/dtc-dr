extends GraphNode

@onready var Line = $Line
@onready var _componentName : Label = $Line/ComponentName
#@onready var other_scene_instance = preload("res://raster.tscn").new()


var ComponentMenuVisBool = false
var ComponentName : String = ""
var InitialComponentName : String = ""
var ComponentId
var content
var item
var data_received

# Called when the node enters the scene tree for the first time.
func _ready(): 
	SignalHub.connect("updateComponents", Callable(self, "_onInitialiseNode"))
	SignalHub.connect("NodeInformation", Callable(self, "_editedName"))

#De nieuwe send node wordt aangemaakt, de meegegeven naam wordt toegewezen en weergegeven.	

#https://docs.godotengine.org/en/stable/classes/class_fileaccess.html#description
func _onInitialiseNode(ComponentId, InitialComponentName):
	var jsonfile = FileAccess.open("res://components.json", FileAccess.READ)
	content = jsonfile.get_as_text()
	jsonfile.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			print("JSON Array", data_received) #Array
		else:
			print("Unexpected data")

	for item in data_received:
		if item["ComponentId"] == ComponentId:
			ComponentName = item["component"]["name"]
			print("The component name for Id: ", ComponentId, " is: ", ComponentName)



			#_componentName.text = ComponentName
			#$IdLabel.text = str(ComponentId)


			
			var root = get_tree().get_root()
			var getLocalNode = root.get_node("/root/Control/GraphEdit/" + ComponentName)
			if getLocalNode:
				var localNodeName = getLocalNode.get_name()
				print("root:", root, " getNode:", ComponentName)
				if str(localNodeName) == ComponentName:
					var getLocalNodeId = root.get_node("/root/Control/GraphEdit/" + ComponentName + "/IdLabel")
					var getLocalNodeLabel = root.get_node("/root/Control/GraphEdit/" + ComponentName + "/Line/ComponentName")
					getLocalNodeLabel.text = ComponentName
					ComponentName = self.ComponentName
					getLocalNodeId.text = str(ComponentId)
				else:
					print("het is over")
			else:
				print("Node not found.")
			
			#Node path:GraphEdit/component_0
			break
		else:
			print("No matching component found for ComponentId: " , ComponentId )
	
#	var root_node = get_node("GraphEdit")
#	print("root_node ", root)
			
			
	
func _editedName(ComponentName):
	pass
	#self.ComponentName = ComponentName
	#_componentName.text = ComponentName
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

## Controls
#Resize
func _on_resize_request(new_minsize):
	self.size = new_minsize

#Close	
func _on_close_request():
	self.queue_free()


func _on_configure_button_pressed():
	ComponentName = get_name()
	print("Current Node Name: ", ComponentName)
		
	self.ComponentMenuVisBool = true
	SignalHub.emit_signal("ComponentMenuStatus", ComponentMenuVisBool, ComponentName)
	SignalHub.emit_signal("NodeInformation", ComponentName)


func _on_configure_features_button_pressed():
	pass # Replace with function body.
