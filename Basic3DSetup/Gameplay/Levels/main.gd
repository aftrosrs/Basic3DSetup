extends Node3D
class_name World


static var _instance: World = null

func _ready():
	_instance = self if _instance == null else _instance
	get_tree().paused = false
	
