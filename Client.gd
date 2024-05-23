extends Control

@export var CountDown = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	var args = Array(OS.get_cmdline_args())
	if args.has("-s") || DisplayServer.get_name() == "headless":
		call_deferred("StartServer")
	else:
		if args.has("-i"):
			call_deferred("StartIntegrated")
		else:
			call_deferred("StartClient")

func ChangeMap(scene: PackedScene):
	var map = $Map
	# Clean out everything
	for child in map.get_children():
		map.remove_child(child)
		child.queue_free()
	map.add_child(scene.instantiate())

# setup the client part of a network peer
func PrepareClient(peer):
	print("Preparing Client")
	
	peer.create_client("127.0.0.1", 10000)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return false
		
	print(peer.get_connection_status())
	return true

# setup the serer part of a peer
func PrepareServer(peer):
	print("Preparing Server")
	peer.create_server(10000, 10)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to Start Server.")
	
	return true

# launch a standalone client
func StartClient():
	var peer = ENetMultiplayerPeer.new()
	if not PrepareClient(peer):
		return
	
	StartGame(peer)

# launch a standalone server
func StartServer():
	var peer = ENetMultiplayerPeer.new()
	if not PrepareServer(peer):
		return
		
	StartGame(peer)

# launch a client and a server at the same time
func StartIntegrated():
	var peer = ENetMultiplayerPeer.new()
	if not PrepareServer(peer):
		return
		
	if not PrepareClient(peer):
		return
		
	StartGame(peer)

# actually start the game logic
func StartGame(peer):
	print("Starting Game")
	multiplayer.multiplayer_peer = peer
	$ConnectionUI.hide()
	get_tree().paused = false;
	if multiplayer.is_server():
		ChangeMap.call_deferred(load("res://Maps/DebugMap.tscn"))
		
func _input(event):
	if event.is_action_released("ui_page_up"):
		var ext = "bat"
		if(OS.get_name() != "Windows"):
			ext = "sh"
		OS.shell_open(ProjectSettings.globalize_path("res://") + "./run.")