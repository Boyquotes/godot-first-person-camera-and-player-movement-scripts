extends Camera3D

# first person camera controls with mouse and joystick support.

# global variables.
var mouse_acceleration: float = 0.1
var joystick_acceleration: float = 3
var x_rotation_limit: float = 1.5 # how far can the camera rotate on the X axis. in radians.
var offset: Vector3 = Vector3(0, 0.75, 0) # how far the camera is offset from player.
# internal variables.
var camera_rotation: Vector3 = Vector3.ZERO
var mouse_direction: Vector2 = Vector2.ZERO
var using_mouse: bool = false
var joystick_direction: Vector2 = Vector2.ZERO
var using_joystick: bool = false
var player: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().root.find_child("player", true, false)
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	joystick_direction = Input.get_vector("right_stick_left", "right_stick_right", "right_stick_up", "right_stick_down")
	using_joystick = joystick_direction != Vector2.ZERO
	# joystick takes priority over mouse
	if (using_joystick):
		camera_rotation.x += (-joystick_direction.y * joystick_acceleration) * delta # up and down.
		camera_rotation.y += (-joystick_direction.x * joystick_acceleration) * delta # left and right.
	elif (using_mouse):
		camera_rotation.x += (-mouse_direction.y * mouse_acceleration) * delta # up and down.
		camera_rotation.y += (-mouse_direction.x * mouse_acceleration) * delta # left and right.
	camera_rotation.x = clamp(camera_rotation.x, -x_rotation_limit, x_rotation_limit);
	camera_rotation.y = loop_value(camera_rotation.y, PI)
	rotation = camera_rotation
	position = player.position + offset
	# reset mouse tracker
	using_mouse = false

# get mouse motion.
func _input(event):
	if event is InputEventMouseMotion:
		using_mouse = true
		mouse_direction = event.relative

# continously loops my_value between the max_value. my_value must be a positive number.
# used to keep the rotation between PI so there is no float overflow.
func loop_value(my_value: float, max_value: float) -> float:
	if my_value > max_value:
		return -max_value + (my_value - max_value)
	elif my_value < -max_value:
		return max_value - (-max_value - my_value)
	return my_value
