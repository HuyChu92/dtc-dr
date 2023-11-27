extends GraphNode

@onready var Line = $Line
@onready var _componentName : Label = $Line/ComponentName

var ComponentMenuVisBool = false
var sender_node_name : String = ""
var NewSendNodeName : String = ""
var interval_enabled = false
var interval_timer : Timer

# Called when the node enters the scene tree for the first time.
# Called when the node enters the scene tree for the first time.
func _ready(): 
	SignalHub.connect("NewSendNodeName", Callable(self, "_onInitialiseNode"))
	interval_timer = $Line2/Timer  # Replace with the actual path to your Timer node
	interval_timer.connect("timeout", Callable(self, "_on_IntervalTimer_timeout"))


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


func _on_button_pressed():
	_start_interval()
	pass # Replace with function body.


func _on_button_2_pressed():
	_stop_interval()
	pass # Replace with function body.

# Function to start the interval
func _start_interval():
	interval_enabled = true
	interval_timer.start()

# Function to stop the interval
func _stop_interval():
	interval_enabled = false
	interval_timer.stop()

# Function called by the timer every 1 second
func _on_IntervalTimer_timeout():
	if interval_enabled:
		# Update TextEdit.text every second
		var machineValue1 = str(_retrieve_random_values("Machine1.RawMaterial.Property1"))
		var machineValue2 = str(_retrieve_random_values("Machine1.RawMaterial.Property2"))
		$Line2/TextEdit.text = machineValue1
		$Line2/TextEdit2.text = machineValue2
		makePostRequest(machineValue1, machineValue2)

func makePostRequest(machine1: String, machine2: String):
	# Set the target URL
	var url = "http://127.0.0.1:8000/saveMeasurement/"

	# Get the current timestamp
	var timestamp = Time.get_datetime_string_from_system()

	# Set the request data
	var post_data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"Machine1.RawMaterial.Property1": str(machine1),
		"Machine1.RawMaterial.Property2": str(machine2)
	}
	print(post_data)

	# Convert the dictionary to JSON format
	var json_data = JSON.stringify(post_data)

	# Create an HTTPRequest object
	var request = HTTPRequest.new()

	# Connect the request_completed signal to the _on_request_completed method
	#request.connect("request_completed", Callable(self, "_on_request_completed"))
	$HTTPRequest.request_completed.connect(_on_request_completed)

	# Set the request parameters
	$HTTPRequest.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, json_data)

func _on_request_completed(result, response_code, headers, body):
	# Handle the response here
	if response_code == 200:
		print("Request successful!")
		print("Response Body:", body)
		# Add your logic for a successful response
	else:
		print("Request failed. Response Code:", response_code)
		print("Response Body:", body)
		# Add your logic for handling a failed response



func _on_end_button_pressed():
	_stop_interval()

func _on_start_button_pressed():
	_start_interval()
	

# Helper function to retrieve random values
func _retrieve_random_values(machine: String):
	var machine_dict = {
		"Machine1.RawMaterial.Property1": {
			"max": 11.54,
			"min": 12.9
		},
		"Machine1.RawMaterial.Property2": {
			"max": 11.54,
			"min": 12.9
		},
	}
	var random_float_in_range = randf() * (machine_dict[machine]["max"] - machine_dict[machine]["min"]) + machine_dict[machine]["min"]
	return round(random_float_in_range * 100) / 100
