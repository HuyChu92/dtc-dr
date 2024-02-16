extends Node
var http_request = HTTPRequest.new()


# Called when the node enters the scene tree for the first time.
func _ready(): # Create an instance of HTTPRequest
	$Control/Panel/OptionDatasets.add_item("Select a dataset")
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	http_request.request("http://127.0.0.1:8000/fetchDatasets/")
	

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var files_array = json.files
	for file_name in files_array:
		print(file_name)
		$Control/Panel/OptionDatasets.add_item(file_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Declare http_request_corr at the class level
var http_request_corr: HTTPRequest

func _on_corr_btn_pressed():
	# Initialize the HTTPRequest node
	http_request_corr = HTTPRequest.new()
	add_child(http_request_corr)
	http_request_corr.request_completed.connect(_on_request_completed_corr_matrix)
	http_request_corr.request("http://127.0.0.1:8000/dataset_detail/movie/correlation_matrix.png")

#
#	var selectedDataset = $Control/Panel/OptionDatasets.get_item_text($Control/Panel/OptionDatasets.selected)
#	print(selectedDataset)
#	var dataset_splitted = selectedDataset.split(".")
#	var dataset = dataset_splitted[0]
#	print(dataset)
#	var url = "http://127.0.0.1:8000/dataset_detail/{0}/correlation_matrix.png".format({"0": dataset})
#	print(url)
#
#	# Open the URL in the default web browser
#	OS.shell_open(url)# Replace with function body.

func _on_request_completed_corr_matrix(result, response_code, headers, body):
	# Check if the request was successful (status code 200)
	if response_code == 200:
		# Load the image into the TextureRect
		print(body)
		var image_texture = Image.new()
		image_texture.load_png_from_buffer(body)
		var texture = ImageTexture.new()
		texture.create_from_image(image_texture)

#		# Create a new TextureRect and add it to the current node
#		var texture_rect = TextureRect.new()
#		add_child(texture_rect)

		# Configure the TextureRect
		$Control/Panel/TextureRect.texture = texture
#		$Control/Panel/TextureRect.rect_min_size = Vector2(1000, 1000)
#		$Control/Panel/TextureRect.rect_max_size = Vector2(1000, 1000)
#		$Control/Panel/TextureRect.expand = true

	
func _on_btn_upload_pressed():
	# Define the URL you want to open
	var url = "http://127.0.0.1:8000/uploadDataset/"

	# Open the URL in the default web browser
	OS.shell_open(url)# Replace with function body.
