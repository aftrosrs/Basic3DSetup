extends Control


@onready var buttons_v_box = %ButtonsVBox
signal start_game()

func _ready() -> void:
	focus_button()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_start_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Gameplay/Levels/main.tscn") #Goes to the main world scene.
	hide()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func focus_button() -> void:
	if buttons_v_box:
		var button: Button = buttons_v_box.get_child(0)
		if button is Button:
			button.grab_focus()


func _on_visibility_changed():
	if visible:
		focus_button()


