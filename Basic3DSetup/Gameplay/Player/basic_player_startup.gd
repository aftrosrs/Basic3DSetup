@tool
extends CharacterBody3D

var BasicFPSPlayerScene: PackedScene = preload("basic_player_head.tscn")
var addedHead: bool = false
@onready var game_menu: Control = $GameMenu



func _enter_tree() -> void:
	if find_child("Head"):
		addedHead = true
	if Engine.is_editor_hint() && !addedHead:
		var s = BasicFPSPlayerScene.instantiate()
		add_child(s)
		s.owner = get_tree().edited_scene_root
		addedHead = true


@export_category("Mouse Capture")
@export var CAPTURE_ON_START: bool = true

@export_category("Movement")
@export_subgroup("Settings")
@export var SPEED: float = 5.0
@export var ACCEL: float = 50.0
@export var IN_AIR_SPEED: float = 3.0
@export var IN_AIR_ACCEL: float = 5.0
@export var JUMP_VELOCITY: float = 4.5
@export_subgroup("Head Bob")
@export var HEAD_BOB: bool = false
@export var HEAD_BOB_FREQUENCY: float = 0.3
@export var HEAD_BOB_AMPLITUDE: float = 0.01
@export_subgroup("Clamp Head Rotation")
@export var CLAMP_HEAD_ROTATION: bool = true
@export var CLAMP_HEAD_ROTATION_MIN: float = -90.0
@export var CLAMP_HEAD_ROTATION_MAX: float = 90.0

@export_category("Key Binds")
@export_subgroup("Mouse")
@export var MOUSE_ACCEL : bool = true
@export var KEY_BIND_MOUSE_SENS: float = 0.005
@export var KEY_BIND_MOUSE_ACCEL: float = 50

@export_category("Advanced")
@export var UPDATE_PLAYER_ON_PHYS_STEP : bool = true	# When check player is moved and rotated in _physics_process (fixed fps)
												# Otherwise player is updated in _process (uncapped)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# To keep track of current speed and acceleration
var speed: float = SPEED
var accel: float = ACCEL

# Used when lerping rotation to reduce stuttering when moving the mouse
var rotation_target_player: float
var rotation_target_head: float

# Used when bobing head
var head_start_pos: Vector3

# Current player tick, used in head bob calculation
var tick: float = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	# Capture mouse if set to true
	if CAPTURE_ON_START:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	head_start_pos = $Head.position

func _physics_process(delta) -> void:
	if Engine.is_editor_hint():
		return
	
	# Increment player tick, used in head bob motion
	tick += 1
	
	if UPDATE_PLAYER_ON_PHYS_STEP:
		move_player(delta)
		rotate_player(delta)
	
	if HEAD_BOB:
		# Only move head when on the floor and moving
		if velocity && is_on_floor():
			head_bob_motion()
		reset_head_bob(delta)


func _process(delta) -> void:
	if Engine.is_editor_hint():
		return

	if !UPDATE_PLAYER_ON_PHYS_STEP:
		move_player(delta)
		rotate_player(delta)

func pause():
	game_menu.show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	# Listen for mouse movement and check if mouse is captured
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		set_rotation_target(event.relative)
	if event.is_action_pressed("pause") and get_tree().paused == false:
		pause()



func set_rotation_target(mouse_motion : Vector2) -> void:
	# Add player target to the mouse -x input
	rotation_target_player += -mouse_motion.x * KEY_BIND_MOUSE_SENS
	# Add head target to the mouse -y input
	rotation_target_head += -mouse_motion.y * KEY_BIND_MOUSE_SENS
	# Clamp rotation
	if CLAMP_HEAD_ROTATION:
		rotation_target_head = clamp(rotation_target_head, deg_to_rad(CLAMP_HEAD_ROTATION_MIN), deg_to_rad(CLAMP_HEAD_ROTATION_MAX))


func rotate_player(delta) -> void:
	if MOUSE_ACCEL:
		# Shperical lerp between player rotation and target
		quaternion = quaternion.slerp(Quaternion(Vector3.UP, rotation_target_player), KEY_BIND_MOUSE_ACCEL * delta)
		# Same again for head
		$Head.quaternion = $Head.quaternion.slerp(Quaternion(Vector3.RIGHT, rotation_target_head), KEY_BIND_MOUSE_ACCEL * delta)
	else:
		# If mouse accel is turned off, simply set to target
		quaternion = Quaternion(Vector3.UP, rotation_target_player)
		$Head.quaternion = Quaternion(Vector3.RIGHT, rotation_target_head)


func move_player(delta) -> void:
	# Check if not on floor
	if not is_on_floor():
		# Reduce speed and accel
		speed = IN_AIR_SPEED
		accel = IN_AIR_ACCEL
		# Add the gravity
		velocity.y -= gravity * delta
	else:
		# Set speed and accel to defualt
		speed = SPEED
		accel = ACCEL
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, accel * delta)
	move_and_slide()


func head_bob_motion() -> void:
	var pos = Vector3.ZERO
	pos.y += sin(tick * HEAD_BOB_FREQUENCY) * HEAD_BOB_AMPLITUDE
	pos.x += cos(tick * HEAD_BOB_FREQUENCY/2) * HEAD_BOB_AMPLITUDE * 2
	$Head.position += pos

func reset_head_bob(delta) -> void:
	# Lerp back to the staring position
	if $Head.position == head_start_pos:
		pass
	$Head.position = lerp($Head.position, head_start_pos, 2 * (1/HEAD_BOB_FREQUENCY) * delta)
