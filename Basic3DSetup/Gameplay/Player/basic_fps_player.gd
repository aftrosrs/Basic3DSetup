@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("Basic FPS Player", "CharacterBody3D", preload("res://Gameplay/Player/basic_player_startup.gd"), preload("Assets/Basic FPS Player.svg"))

func _exit_tree() -> void:
	remove_custom_type("Basic FPS Player")
