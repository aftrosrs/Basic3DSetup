extends CanvasLayer
class_name UI

signal start_game()
signal menu_opened()
signal menu_closed()
signal quit_to_menu()

@onready var game_menu: Control = %GameMenu
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var main_menu = %MainMenu
@onready var transition = %Transition

static var _instance: UI = null

var letterbox_open := false
	
func _ready():
	_instance = self if _instance == null else _instance


static func open_letterbox() -> void:
	if !_instance.letterbox_open:
		_instance.animation_player.play("open_letterbox")
		_instance.letterbox_open = true
		
		
static func close_letterbox() -> void:
	if _instance.letterbox_open:
		_instance.animation_player.play_backwards("open_letterbox")
		_instance.letterbox_open = false


func _on_main_menu_start_game() -> void:
	start_game.emit()
	transition.show()
	animation_player.play("screen_transition")
	await animation_player.animation_finished
	transition.hide()


func _on_menu_main_menu():
	if animation_player.is_playing():
		await animation_player.animation_finished
	game_menu.hide()
	transition.show()
	animation_player.play_backwards("screen_transition")
	await animation_player.animation_finished
	transition.hide()
	quit_to_menu.emit()
	main_menu.show()


func _on_menu_return_to_game():
	if animation_player.is_playing():
		await animation_player.animation_finished
	game_menu.hide()
	menu_closed.emit()
