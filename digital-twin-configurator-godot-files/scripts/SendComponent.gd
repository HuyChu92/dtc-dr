extends GraphNode

@onready var Line = $Line
@onready var _componentName : Label = $Line/ComponentName

var ComponentMenuVisBool = false
var sender_node_name : String = ""
var NewSendNodeName : String = ""

# Called when the node enters the scene tree for the first time.
func _ready(): 
	SignalHub.connect("NewSendNodeName", Callable(self, "_onInitialiseNode"))

#De nieuwe send node wordt aangemaakt, de meegegeven naam wordt toegewezen en weergegeven.	
func _onInitialiseNode(NewSendNodeName):
	set_name(NewSendNodeName)
	sender_node_name = get_name()
	_componentName.text = sender_node_name
	


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
	self.ComponentMenuVisBool = true
	sender_node_name = get_name()
	SignalHub.emit_signal("ComponentMenuStatus", ComponentMenuVisBool, sender_node_name)
	SignalHub.emit_signal("NodeInformation", sender_node_name)
