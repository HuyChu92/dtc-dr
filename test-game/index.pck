GDPC                @                                                                         T   res://.godot/exported/133200997/export-04a9bbb6f49b1e57b0f6d1d65617e2c7-raster.scn  0h      �      !�\���0D�~��J�~    \   res://.godot/exported/133200997/export-5240b8abcf0259038f1ff37fbb03ce77-component-send.scn  `A      �      ��6�Ś=�tr[    `   res://.godot/exported/133200997/export-eddee63b5ed24fe66c285038e2da16a0-component-receive.scn   `8      �      s�{�v�nX�� _�    \   res://.godot/exported/133200997/export-f2bea93d66c9817108bd7d42772dfe31-ComponentMenu.scn   @N      <      �"��\P�q��T��nw    ,   res://.godot/global_script_class_cache.cfg  �r             ��Р�8���8~$}P�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex�Z      �      �̛�*$q�*�́        res://.godot/uid_cache.bin  �v      �       ��b&�T�m�Kk+�N�        res://ComponentMenu.tscn.remap  �q      j       ��Eא8�Z鑹�b    $   res://component-receive.tscn.remap  �p      n       WK6������F�ؘ�        res://component-send.tscn.remap Pq      k       A5�AS�0��<(eFȻ�       res://icon.svg  �r      �      b�pW>���d���       res://icon.svg.import   `g      �       �T�+�A�W4���       res://project.binary0w      �      ���S�11������       res://raster.tscn.remap 0r      c       ��d��(�^ o�,        res://scripts/ComponentMenu.gd          �      ܳ��8�mM�]!����    $   res://scripts/ReceiveComponent.gd   �            F$8u�]����+��        res://scripts/SendComponent.gd  &      �      ��X���6T�Eߡ�=       res://scripts/SignalHub.gd  �5      p      l��!T�TFM��G       res://scripts/connections.gd�      9      n�s}��}ha�׾��0        res://scripts/nodeInformation.gd�      �      ��k��
��j)�`b       res://scripts/raster-main.gd`      �      �'���P)��� �q�                extends Control

@onready var _menu : Control = $Control
@onready var _componentNameLabel : Label = $Control/ComponentNameLabel
@onready var _ApiInputBox : LineEdit = $Control/ApiInput
@onready var http_request = $Control/setApiButton/HTTPRequest
@onready var apiErrorLabel : Label = $Control/apiErrorLabel
@onready var apiSuccesLabel : Label = $Control/apiSuccesLabel
@onready var ApiOutput = $Control/ApiOutput

var ComponentMenuVisBool = false
var node_name : String = ""
var ApiInput : String = ""
var rawApiData 
var nodeInformationDict : Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	_menu.visible = ComponentMenuVisBool
	# Haalt de ComponentMenuStatus op van ComponentMenuStatus.gd wanneer op 'configure' wordt gedrukt in de node/component
	SignalHub.connect("ComponentMenuStatus", Callable(self, "_on_configure_button_pressed"))
	SignalHub.connect("nodeInformationDict", Callable(self, "_displayRawApi"))
	SignalHub.connect("nodeInformationDict", Callable(self, "_on_configure_button_pressed"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _resetCompMenu():
	apiSuccesLabel.visible = false
	apiErrorLabel.visible = false
	
	

#Dit verzorgd de naam van de geselecteerde component in het menu
func _on_configure_button_pressed(ComponentMenuVisBool, node_name):

	_menu.visible = ComponentMenuVisBool
	_componentNameLabel.text = node_name
	_resetCompMenu()
	
	if nodeInformationDict.has (node_name):
		#print("nodeInformationDict", nodeInformationDict)
		var accesApiData = nodeInformationDict[node_name]["Api Data= "]
		ApiOutput.text = str(accesApiData)
		
		var accesApiUrl = nodeInformationDict[node_name]["Api Url= "]
		_ApiInputBox.text = str(accesApiUrl)
		
	else:
		ApiOutput.text = ""

#Verberg het ComponentMenu wanneer op X wordt gedrukt.
func _on_close_button_pressed():
	self.ComponentMenuVisBool = false
	_menu.visible = ComponentMenuVisBool


#Wanneer op de API ('set') knop wordt gedrukt
func _on_set_api_button_pressed():
	self.ApiInput = _ApiInputBox.text
	self.node_name = _componentNameLabel.text
	
	var error = http_request.request(ApiInput)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		apiSuccesLabel.visible = false
		apiErrorLabel.visible = true
		ApiOutput.text = ""
	
#Wanneer de request van de API is voltooid wordt rawApiData toegewezen en weergegeven in _addToNodeInformation
func _on_http_request_request_completed(result, response_code, headers, body):
	print("response code = ", response_code)
	apiErrorLabel.visible = false
	apiSuccesLabel.visible = true
	self.rawApiData = JSON.parse_string(body.get_string_from_utf8())
	_addToNodeInformation(node_name, ApiInput, rawApiData)

		
func _addToNodeInformation(node_name, ApiInput, rawApiData):
	ApiInput = _ApiInputBox.text
	node_name = _componentNameLabel.text
	
	SignalHub.emit_signal("NodeInformation", node_name, ApiInput, rawApiData)
	
#deze functie behandelt het weergeven van de ruwe api in de ComponentMenu scene
func _displayRawApi(nodeInformationDict):
	self.nodeInformationDict = nodeInformationDict
	
	if node_name in self.nodeInformationDict:
		var api_data = self.nodeInformationDict[node_name]["Api Data= "]
		ApiOutput.text = str(api_data)
		
	else:
		print("Node name not found in nodeInformationDict")
		return null
    extends Node


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
       extends Node

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
            extends Control


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



     extends GraphNode

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
   extends GraphNode

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
extends Node


#Signaal dat in raster-main wordt meegegeven aan een nieuwe graph-node
signal NewSendNodeName(NewSendNodeName)
signal NewReceiveNodeName(NewReceiveNodeName)

#Signaal dat de boolean van het ComponentMenu behandelt.
signal ComponentMenuStatus(ComponentMenuVisBool, sender_node_name)

#NodeInformatie 
signal NodeInformation(sender_node_name, ApiInput, rawApiData)

#dict van de nodeinformation
signal nodeInformationDict(nodeInformationDict)

#Connection Line registratie
signal ConnectionLine(from, from_slot, to, to_slot)

#dict van alle connecties
signal connectionDict(connectionDict)
RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script "   res://scripts/ReceiveComponent.gd ��������      local://PackedScene_6uu1n          PackedScene          	         names "   4   
   GraphNode    anchor_left    anchor_top    anchor_right    anchor_bottom    offset_left    offset_top    offset_right    offset_bottom    grow_horizontal    grow_vertical    scale    mouse_filter    show_close 
   resizable    slot/0/left_enabled    slot/0/left_type    slot/0/left_color    slot/0/left_icon    slot/0/right_enabled    slot/0/right_type    slot/0/right_color    slot/0/right_icon    slot/0/draw_stylebox    slot/1/left_enabled    slot/1/left_type    slot/1/left_color    slot/1/left_icon    slot/1/right_enabled    slot/1/right_type    slot/1/right_color    slot/1/right_icon    slot/1/draw_stylebox    script    Line    custom_minimum_size    layout_mode    VBoxContainer    ComponentName    Label    FlaskOutput1    RichTextLabel    FlaskOutput    Line2 	   HTTPPost    HTTPRequest    _on_close_request    close_request    _on_resize_request    resize_request     _on_http_post_request_completed    request_completed    	   variants             ?     ��     0�     �B     �B      
   c&}?  �?                        �?  �?  �?  �?                 
         �A
         �B      node_count             nodes     �   ��������        ����!                                                       	      
                                       	      
                  	      
                        	      
                  	      
                !                  %   "   ����   #      $                 '   &   ����   $                 )   (   ����   $                 '   *   ����   $                  %   +   ����   #      $                  -   ,   ����              conn_count             conns                /   .                      1   0                     3   2                    node_paths              editable_instances              version             RSRC              RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://scripts/SendComponent.gd ��������      local://PackedScene_ufiv8          PackedScene          	         names "   H   
   GraphNode    anchor_left    anchor_top    anchor_right    anchor_bottom    offset_left    offset_top    offset_right    offset_bottom    grow_horizontal    grow_vertical    scale    mouse_filter    show_close 
   resizable    slot/0/left_enabled    slot/0/left_type    slot/0/left_color    slot/0/left_icon    slot/0/right_enabled    slot/0/right_type    slot/0/right_color    slot/0/right_icon    slot/0/draw_stylebox    slot/1/left_enabled    slot/1/left_type    slot/1/left_color    slot/1/left_icon    slot/1/right_enabled    slot/1/right_type    slot/1/right_color    slot/1/right_icon    slot/1/draw_stylebox    slot/2/left_enabled    slot/2/left_type    slot/2/left_color    slot/2/left_icon    slot/2/right_enabled    slot/2/right_type    slot/2/right_color    slot/2/right_icon    slot/2/draw_stylebox    script    Line    custom_minimum_size    layout_mode    VBoxContainer    ComponentName    Label    ConfigureButton    size_flags_horizontal    tooltip_text    text    Button    Line2    Timer 
   alignment    Button2 	   TextEdit    Label2 
   TextEdit2    HTTPRequest    _on_close_request    close_request    _on_resize_request    resize_request    _on_configure_button_pressed    pressed    _on_button_pressed    _on_button_2_pressed #   _on_http_request_request_completed    request_completed    	   variants             ?     ��     @�     �B     HB      
   c&}?  �?                        �?  �?  �?  �?                        
         �A      Configure this component    
   Configure 
         �B
         B      Start       End       Machine1.Temperature       Machine1.Pressure       node_count             nodes     �   ��������        ����*                                                       	      
                                       	      
                  	      
                        	      
                  	      
                !      "   	   #   
   $      %      &   	   '   
   (      )      *                  .   +   ����   ,      -                 0   /   ����   -                  5   1   ����   -      2   	   3      4                  .   6   ����   ,      -                 7   7   ����               5   5   ����   ,      -      4      8   	              5   9   ����   -      4      8   	              0   0   ����   -      4                 :   :   ����   ,      -                 0   ;   ����   -      4                 :   <   ����   ,      -                  =   =   ����              conn_count             conns     *           ?   >                      A   @                     C   B                     C   D                     C   E                     G   F                    node_paths              editable_instances              version             RSRC   RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    line_spacing    font 
   font_size    font_color    outline_size    outline_color    shadow_size    shadow_color    shadow_offset    script 	   _bundled       Script    res://scripts/ComponentMenu.gd ��������      local://LabelSettings_fv5sy �         local://LabelSettings_2i5vm          local://PackedScene_jiv7f G         LabelSettings                      LabelSettings                      PackedScene          	         names "   $      ComponentMenu    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    Control    offset_left    offset_right    offset_bottom    Panel    offset_top 	   ApiInput    pivot_offset 	   LineEdit    Label    text    closeButton    Button    ComponentNameLabel    label_settings    setApiButton    HTTPRequest    verwijderButton    visible    apiErrorLabel    apiSuccesLabel 
   ApiOutput    RichTextLabel    _on_close_button_pressed    pressed    _on_set_api_button_pressed #   _on_http_request_request_completed    request_completed    	   variants    4                    �?                            �A     `B      B    �SD     �B    ��D    �BD     YD     ,C    ��D     KC
     �A   �      �     hB     ��      API Key     ��D     �B    ��D     C      X
      �B     pD     C      Placeholder               ��D    ��D      Set             qD     5D    �<D      Verwijderen      WC     nC      Invalid API key               �C    �gD     �C
    ��C  �C      API Information    #   API allocation has been successful     ��C    �D      node_count             nodes        ��������       ����                                                                ����         	      
                             ����         	   	      
   
                             ����         	            
                                   ����               
                                   ����         	            
                                   ����         	            
                                         ����         	             
   !            "                    ����                     ����      #         	   $      %   
   !      &      '                    ����         	         (   
         )      *      +                    ����         	         ,   
   -      .      /      0                    ����         	         (   
         )      1      +                    ����         	         2   
   !      3             conn_count             conns                                            !                     #   "                    node_paths              editable_instances              version             RSRC    GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
ScI_L �;����In#Y��0�p~��Z��m[��N����R,��#"� )���d��mG�������ڶ�$�ʹ���۶�=���mϬm۶mc�9��z��T��7�m+�}�����v��ح�m�m������$$P�����එ#���=�]��SnA�VhE��*JG�
&����^x��&�+���2ε�L2�@��		��S�2A�/E���d"?���Dh�+Z�@:�Gk�FbWd�\�C�Ӷg�g�k��Vo��<c{��4�;M�,5��ٜ2�Ζ�yO�S����qZ0��s���r?I��ѷE{�4�Ζ�i� xK�U��F�Z�y�SL�)���旵�V[�-�1Z�-�1���z�Q�>�tH�0��:[RGň6�=KVv�X�6�L;�N\���J���/0u���_��U��]���ǫ)�9��������!�&�?W�VfY�2���༏��2kSi����1!��z+�F�j=�R�O�{�
ۇ�P-�������\����y;�[ ���lm�F2K�ޱ|��S��d)é�r�BTZ)e�� ��֩A�2�����X�X'�e1߬���p��-�-f�E�ˊU	^�����T�ZT�m�*a|	׫�:V���G�r+�/�T��@U�N׼�h�+	*�*sN1e�,e���nbJL<����"g=O��AL�WO!��߈Q���,ɉ'���lzJ���Q����t��9�F���A��g�B-����G�f|��x��5�'+��O��y��������F��2�����R�q�):VtI���/ʎ�UfěĲr'�g�g����5�t�ۛ�F���S�j1p�)�JD̻�ZR���Pq�r/jt�/sO�C�u����i�y�K�(Q��7őA�2���R�ͥ+lgzJ~��,eA��.���k�eQ�,l'Ɨ�2�,eaS��S�ԟe)��x��ood�d)����h��ZZ��`z�պ��;�Cr�rpi&��՜�Pf��+���:w��b�DUeZ��ڡ��iA>IN>���܋�b�O<�A���)�R�4��8+��k�Jpey��.���7ryc�!��M�a���v_��/�����'��t5`=��~	`�����p\�u����*>:|ٻ@�G�����wƝ�����K5�NZal������LH�]I'�^���+@q(�q2q+�g�}�o�����S߈:�R�݉C������?�1�.��
�ڈL�Fb%ħA ����Q���2�͍J]_�� A��Fb�����ݏ�4o��'2��F�  ڹ���W�L |����YK5�-�E�n�K�|�ɭvD=��p!V3gS��`�p|r�l	F�4�1{�V'&����|pj� ߫'ş�pdT�7`&�
�1g�����@D�˅ �x?)~83+	p �3W�w��j"�� '�J��CM�+ �Ĝ��"���4� ����nΟ	�0C���q'�&5.��z@�S1l5Z��]�~L�L"�"�VS��8w.����H�B|���K(�}
r%Vk$f�����8�ڹ���R�dϝx/@�_�k'�8���E���r��D���K�z3�^���Vw��ZEl%~�Vc���R� �Xk[�3��B��Ğ�Y��A`_��fa��D{������ @ ��dg�������Mƚ�R�`���s����>x=�����	`��s���H���/ū�R�U�g�r���/����n�;�SSup`�S��6��u���⟦;Z�AN3�|�oh�9f�Pg�����^��g�t����x��)Oq�Q�My55jF����t9����,�z�Z�����2��#�)���"�u���}'�*�>�����ǯ[����82һ�n���0�<v�ݑa}.+n��'����W:4TY�����P�ר���Cȫۿ�Ϗ��?����Ӣ�K�|y�@suyo�<�����{��x}~�����~�AN]�q�9ޝ�GG�����[�L}~�`�f%4�R!1�no���������v!�G����Qw��m���"F!9�vٿü�|j�����*��{Ew[Á��������u.+�<���awͮ�ӓ�Q �:�Vd�5*��p�ioaE��,�LjP��	a�/�˰!{g:���3`=`]�2��y`�"��N�N�p���� ��3�Z��䏔��9"�ʞ l�zP�G�ߙj��V�>���n�/��׷�G��[���\��T��Ͷh���ag?1��O��6{s{����!�1�Y�����91Qry��=����y=�ٮh;�����[�tDV5�chȃ��v�G ��T/'XX���~Q�7��+[�e��Ti@j��)��9��J�hJV�#�jk�A�1�^6���=<ԧg�B�*o�߯.��/�>W[M���I�o?V���s��|yu�xt��]�].��Yyx�w���`��C���pH��tu�w�J��#Ef�Y݆v�f5�e��8��=�٢�e��W��M9J�u�}]釧7k���:�o�����Ç����ս�r3W���7k���e�������ϛk��Ϳ�_��lu�۹�g�w��~�ߗ�/��ݩ�-�->�I�͒���A�	���ߥζ,�}�3�UbY?�Ӓ�7q�Db����>~8�]
� ^n׹�[�o���Z-�ǫ�N;U���E4=eȢ�vk��Z�Y�j���k�j1�/eȢK��J�9|�,UX65]W����lQ-�"`�C�.~8ek�{Xy���d��<��Gf�ō�E�Ӗ�T� �g��Y�*��.͊e��"�]�d������h��ڠ����c�qV�ǷN��6�z���kD�6�L;�N\���Y�����
�O�ʨ1*]a�SN�=	fH�JN�9%'�S<C:��:`�s��~��jKEU�#i����$�K�TQD���G0H�=�� �d�-Q�H�4�5��L�r?����}��B+��,Q�yO�H�jD�4d�����0*�]�	~�ӎ�.�"����%
��d$"5zxA:�U��H���H%jس{���kW��)�	8J��v�}�rK�F�@�t)FXu����G'.X�8�KH;���[             [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://bponvx6er434i"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
                RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    script/source 	   _bundled    script       Script    res://scripts/raster-main.gd ��������   PackedScene    res://ComponentMenu.tscn ����K�5      local://GDScript_sl01v ~         local://PackedScene_e6dvq       	   GDScript          p  extends GraphEdit

#Deze signal nodes regelen het 'plakken' van de lijnen
func _on_connection_request(from, from_slot, to, to_slot):
	connect_node(from, from_slot, to, to_slot)
	SignalHub.emit_signal("ConnectionLine", from, from_slot, to, to_slot)

func _on_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)
    PackedScene          	         names "         Control    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script 
   GraphEdit    offset_right    offset_bottom    ComponentMenu    offset_left    offset_top    Button-send    text    Button    Button-receive    _on_connection_request    connection_request    _on_disconnection_request    disconnection_request !   _on_add_send_comp_button_pressed    pressed $   _on_add_receive_comp_button_pressed    	   variants                        �?                           ��D     uD                             �'D     �     �C     A    ��C     $B      Add send
      �C    �	D      Add receive       node_count             nodes     [   ��������        ����                                                                ����         	      
                       ���   	         
               	      
                        ����                     	      
                              ����                     	      
                      conn_count             conns                                                                                                            node_paths              editable_instances              version             RSRC            [remap]

path="res://.godot/exported/133200997/export-eddee63b5ed24fe66c285038e2da16a0-component-receive.scn"
  [remap]

path="res://.godot/exported/133200997/export-5240b8abcf0259038f1ff37fbb03ce77-component-send.scn"
     [remap]

path="res://.godot/exported/133200997/export-f2bea93d66c9817108bd7d42772dfe31-ComponentMenu.scn"
      [remap]

path="res://.godot/exported/133200997/export-04a9bbb6f49b1e57b0f6d1d65617e2c7-raster.scn"
             list=Array[Dictionary]([])
     <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
            �۔��_;   res://component-receive.tscnO{Ã6Y�   res://component-send.tscn����K�5   res://ComponentMenu.tscn�'dM$0   res://icon.svg�B#q�9   res://raster.tscn    ECFG      application/config/name         Godot-control      application/run/main_scene         res://raster.tscn      application/config/features$   "         4.1    Forward Plus       application/config/icon         res://icon.svg     autoload/SignalHub$         *res://scripts/SignalHub.gd    autoload/NodeInformation,      !   *res://scripts/nodeInformation.gd      autoload/Connections(         *res://scripts/connections.gd          