extends CharacterBody3D

# first person movement controls with mouse and joystick support.

# global variables.
var speed: float = 5.0
var jump_velocity: float = 4.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# node for tracking camera direction minus the up and down tilt.
var pivot_node: Node3D = Node3D.new()
var camera: Camera3D
var camera_rotation_y: Vector3 = Vector3.ZERO
var player_direction: Vector3 = Vector3.ZERO
var keyboard_direction: Vector2 = Vector2.ZERO
var using_keyboard: bool = false
var joystick_direction: Vector2 = Vector2.ZERO
var using_joystick: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_tree().root.find_child("camera", true, false)

# process player movement in the physics update so we can collide with objects.
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	# get input from the joystick.
	joystick_direction = Input.get_vector("left_stick_left", "left_stick_right", "left_stick_up", "left_stick_down")
	using_joystick = joystick_direction != Vector2.ZERO
	# get input from the keyboard.
	keyboard_direction = Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	using_keyboard = keyboard_direction != Vector2.ZERO
	# reset rotation tracker.
	camera_rotation_y = Vector3.ZERO
	camera_rotation_y.y = camera.rotation.y
	pivot_node.rotation = camera_rotation_y
	# reset player direction.
	player_direction = Vector3.ZERO
	# joystick takes priority.
	if using_joystick:
		# move player based on camera direction which is tracked with the pivot node.
		player_direction = (pivot_node.basis * Vector3(joystick_direction.x, 0, joystick_direction.y)).normalized()
	elif using_keyboard:
		# move player based on camera direction which is tracked with the pivot node.
		player_direction = (pivot_node.basis * Vector3(keyboard_direction.x, 0, keyboard_direction.y)).normalized()
	# if player direction is not zero then move player.
	if player_direction:
		velocity.x = player_direction.x * speed
		velocity.z = player_direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
