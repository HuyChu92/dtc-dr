extends Node
var http_request = HTTPRequest.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request("http://127.0.0.1:8000/fetchDatasets/")
	
		# Handle selected dataset after fetching datasets
	handle_selected_dataset()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed_models)
	http_request.request("http://127.0.0.1:8000/fetchModels/movie")
	for num in range(1,10):
		print(num)
		var checkBox = CheckBox.new()
		checkBox.name = str(num)
		$Panel/ScrollFeature.add_child(checkBox)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var files_array = json.files
	for file_name in files_array:
		$Panel/OptionsDataset.add_item(file_name)

func _on_request_completed_models(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var files_array = json.files
	for file_name in files_array:
		$Panel/OptionsModel.add_item(file_name)

func handle_selected_dataset():
	var selectedDataset = $Panel/OptionsDataset.get_item_text($Panel/OptionsDataset.selected)
	var dataset_splitted = selectedDataset.split(".")
	var dataset = dataset_splitted[0]
	return dataset
	# Use the 'dataset' variable as needed
func _process(delta):
	pass

func _on_options_dataset_item_selected(index):
	$Panel/OptionsModel.clear()
	print(handle_selected_dataset())
	var url = "http://127.0.0.1:8000/fetchModels/{dataset}".format({"dataset": handle_selected_dataset()})
	print(url)
	http_request.request(url)
