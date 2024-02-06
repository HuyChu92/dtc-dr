extends Node


var connectionDict = {}

var from
var from_slot
var to
var to_slot

var from_to_swap

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalHub.connect("ConnectionLine", Callable(self, "_updateConnections"))

	
func _updateConnections(from, from_slot, to, to_slot):
	print("from = ", from, " from_slot = ", from_slot, " to = ", to, " to_slot = ", to_slot)
	self.from = from
	self.from_slot = from_slot
	self.to = to
	self.to_slot = to_slot
	
	
	
	#Omdat de volgorde van connections maken afhankelijk is van de locatie van de component,
	#dient de sendcomponent altijd voor te staan.
	#als de sendcomponent niet bij de 'from=' is (of in dit geval de receive bij de 'To=')
	#dan worden from en to omgewisseld, from_to_swap is een tijdelijke variabele
	if to.contains ("ReceiveComponent"):
		connectionDict[to] = {"from=": from, "from_slot=": from_slot, "To=": to, "to_slot=": to_slot}
		print("ConnectionDict: ", connectionDict)
		SignalHub.emit_signal("connectionDict", connectionDict)
	else:
		from_to_swap = from
		from = to
		to = from_to_swap
		
		connectionDict[to] = {"from=": from, "from_slot=": from_slot, "To=": to, "to_slot=": to_slot}
		print("ConnectionDict: ", connectionDict)
		SignalHub.emit_signal("connectionDict", connectionDict)
