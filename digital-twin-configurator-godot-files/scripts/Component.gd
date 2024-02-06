extends GraphNode

@onready var Line = $Line

@onready var newNameEdit = $Line2/HBoxContainer2/HBoxContainer/newNameEdit
@onready var _componentName : Label = $Line/ComponentName
#@onready var other_scene_instance = preload("res://raster.tscn").new()

#Icons
@onready var icon_button = $Line2/HBoxContainer2/ConfigureComponentIcon
@onready var icon_textureRect = $Line/TextureRect

#Paths van de icon bestanden
var icon_files = ["robo-arm", "warehouse-export", "warehouse-import", "warehouse"]

#HTTPRequest voor Datasets
@onready var http_request = $HTTPRequest


# Menu B
var ComponentMenuVisBool = false
var ComponentFeatureSelBool = false


var ComponentName : String = ""
var InitialComponentName : String = ""
var ComponentId
var content
var item
var data_received

# Called when the node enters the scene tree for the first time.
func _ready(): 
	newNameEdit.visible = 0
	_init_icons()
	SignalHub.connect("updateComponents", Callable(self, "_onInitialiseNode"))
	#SignalHub.connect("NodeInformation", Callable(self, "_editedName"))
	
	#HTTP
	http_request.request_completed.connect(_on_http_request_request_completed)
	http_request.request("http://127.0.0.1:8000/fetchDatasets/")
	
	handle_selected_dataset()
	
	
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
					print("Something has went wrong")
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
		
	self.ComponentMenuVisBool = true
	SignalHub.emit_signal("ComponentMenuStatus", ComponentMenuVisBool, ComponentName)
	SignalHub.emit_signal("NodeInformation", ComponentName)


func _on_configure_features_button_pressed():
	ComponentName = get_name()
	print("On Conf Feature pressed CompName = ", ComponentName)
	
	self.ComponentFeatureSelBool = true
	SignalHub.emit_signal("ComponentFeatureStatus", ComponentFeatureSelBool, ComponentName)
	#SignalHub.emit_signal("NodeInformation", ComponentName)
	


func _init_icons():
	for name in icon_files:
		icon_button.add_item(name)

func _on_configure_component_icon_item_selected(index):
	var texture_rect = $TextureRect
	var icon_path = "res://icons/" + icon_files[index] + "-negate.png"
	icon_textureRect.texture = load(icon_path)
	pass


func _on_change_name_button_pressed():
	newNameEdit.visible = 1
	_componentName.visible = 0
	pass # Replace with function body.


func _on_new_name_edit_text_submitted(new_text):
	_componentName.text = new_text
	var root = get_tree().root
	var getLocalNode = root.get_node("/root/Control/GraphEdit/" + ComponentName)
	getLocalNode.name = str(new_text)
	
	newNameEdit.visible = 0
	_componentName.visible = 1
	pass # Replace with function body.
	
	
	
	


func handle_selected_dataset():
	var selectedDataset = $Line2/DatasetSelBox/OptionDataset.get_item_text($Line2/DatasetSelBox/OptionDataset.selected)
	var dataset_splitted = selectedDataset.split(".")
	var dataset = dataset_splitted[0]
	return dataset


func _on_http_request_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var files_array = json.files
	for file_name in files_array:
		$Line2/DatasetSelBox/OptionDataset.add_item(file_name)
