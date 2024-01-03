extends Node

var components : Array = []
var ComponentName
var ComponentId

func _ready():
	# Create some sample components
	SignalHub.connect("updateComponents", Callable(self, "_json_ready"))
#	ComponentId, ComponentName


func _json_ready(ComponentId, ComponentName):
	# Create a dictionary for the current component
	var component_dict : Dictionary = {
		"ComponentId": ComponentId,
		"component": {
			"id": ComponentId,
			"name": ComponentName
		}
	}

	# Append the dictionary to the list
	components.append(component_dict)

	# Save the list to a JSON file
	save_to_json()

func save_to_json():
	# Save JSON data to a file
	var file = FileAccess.open("res://components.json", FileAccess.WRITE)
	var line = JSON.stringify(components)
	file.store_line(line)
	file.close()
	
	#SignalHub_emit
