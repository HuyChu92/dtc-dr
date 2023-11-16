extends Control


#Gemaakte Scene importeren. Deze scene(s) zijn verschillende GraphNodes 
@onready var component_send = load("res://component-send.tscn")

@onready var component_receive = load("res://component-receive.tscn")

@onready var Graph = $GraphEdit

var NewSendNodeName : String = ""
var NewReceiveNodeName : String = ""
var umpteenthNewSendNode  = 0
var umpteenthNewReceiveNode  = 0


func add_node(type):
	Graph.add_child(type.instantiate())

#(Add component knop)
func _on_add_send_comp_button_pressed():
	NewSendNodeName = "SendComponent" + "_" + str(umpteenthNewSendNode)
	add_node(component_send)
	SignalHub.emit_signal("NewSendNodeName", NewSendNodeName)
	
func _on_add_receive_comp_button_pressed():
	NewReceiveNodeName = "ReceiveComponent" + "_" + str(umpteenthNewReceiveNode)
	add_node(component_receive)
	SignalHub.emit_signal("NewReceiveNodeName", NewReceiveNodeName)




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



