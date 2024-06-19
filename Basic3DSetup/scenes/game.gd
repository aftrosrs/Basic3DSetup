extends Node2D
class_name Game


@export var ui: UI

var world = World
enum INPUT_SCHEMES { KEYBOARD_AND_MOUSE, GAMEPAD, TOUCH_SCREEN }
static var INPUT_SCHEME: INPUT_SCHEMES = INPUT_SCHEMES.KEYBOARD_AND_MOUSE

func start_game():
	get_tree().change_scene_to_file("res://Gameplay/Levels/main.tscn")
	get_tree().paused = false



func _on_ui_start_game():
	start_game()


func _on_ui_quit_to_menu():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	get_tree().paused = false



func _on_ui_menu_closed():
	get_tree().paused = false


func _on_ui_menu_opened():
	get_tree().paused = true 
