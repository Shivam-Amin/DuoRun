extends CharacterBody3D


@export var jump_height: float = 0.6
@export var jump_time_to_peak: float = 0.4
@export var jump_time_to_descent: float = 0.3
@export var max_speed = 2
@export var acceleration = 0.047

## these two variables takes care of jump conditons for next 15 frames.
@export var cayote_frames = 15
@export var jump_buffer_frames = 15


const SPEED: float = 2.0
#const JUMP_VELOCITY = 3.2
#const MAX_JUMP_VELOCITY = 10
@onready var jump_velocity: float = (2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity: float = (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var cayote_counter: int = 0
var jump_buffer_counter: int = 0
var jump_counter: int = 0


func _physics_process(delta):
	velocity.y += get_gravity() * delta
	#print(velocity)
	
	if is_on_floor():
		cayote_counter = cayote_frames
	
	if not is_on_floor():
		if cayote_counter > 0:
			cayote_counter -= 1
			jump_counter = 0
		
		if jump_buffer_counter > 0 and jump_counter < 1:
			cayote_counter = 1
			jump_counter += 1
	
	# Add the gravity.
	#if not is_on_floor():
		#velocity.y -= get_gravity() * delta
	
	# smooth movement.
	smooth_movement()
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#if Input.is_action_just_pressed("jump"):
		#jump()
	
	## These 3 conditions takes care of jump
	if Input.is_action_just_pressed("ui_select"):
		jump_buffer_counter = jump_buffer_frames

	if jump_buffer_counter > 0:
		jump_buffer_counter -= 1

	if jump_buffer_counter > 0 and cayote_counter > 0:
		jump()
		jump_buffer_counter = 0
	
	
	move_and_slide()

func get_gravity():
	return jump_gravity if velocity.y > 0.0 else fall_gravity

func smooth_movement():
	# add acceleration to start moving slowly and achive max speed
	velocity.z -= acceleration
	
	if velocity.z < -max_speed:
		velocity.z = -max_speed


func jump():
	velocity.y = jump_velocity
