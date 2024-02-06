extends Control


#Gemaakte Scene importeren. Deze scene(s) zijn verschillende GraphNodes 
@onready var new_component = load("res://component.tscn")

@onready var Graph = $GraphEdit

var InitialComponentName : String = ""
var umpteenthNewComponent  = 0


#Menu Booleans
var ComponentMenuVisBool = false
var ComponentFeatureSelBool = false


var ComponentName : String = ""
var ComponentId
var content
var item
var data_received


func add_node(type):
	var new_component = type.instantiate()
	Graph.add_child(new_component)
	
	## Voegt een naam toe zodat de Node later teruggevonden kan worden.
	var new_component_id = umpteenthNewComponent
	new_component.name = "component_" + str(new_component_id)
	
	#Graph.add_child(type.instantiate())

#(Add component knop)
func _on_add_send_comp_button_pressed():
	InitialComponentName = "component" + "_" + str(umpteenthNewComponent)
	add_node(new_component)
	var ComponentName = InitialComponentName
	var ComponentId = umpteenthNewComponent
	#SignalHub.emit_signal("InitialComponentName", ComponentId, InitialComponentName)
	SignalHub.emit_signal("updateComponents", ComponentId, ComponentName)
	_onInitialiseNode(ComponentId, InitialComponentName)
	self.umpteenthNewComponent = umpteenthNewComponent + 1
	
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

	# Naam bij Id zoeken
	for item in data_received:
		if item["ComponentId"] == ComponentId:
			ComponentName = item["component"]["name"]
			print("The component name for Id: ", ComponentId, " is: ", ComponentName)
			
			# Haalt de naam huidige child uit de boom
			var child = Graph.get_node("component_" + str(ComponentId))
			print("child: ", child.name)
			#ComponentName
			#$IdLabel.text = str(ComponentId)
			break
		else:
			print("No matching component found for ComponentId: " , ComponentId )



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
