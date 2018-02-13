extends KinematicBody2D

export var max_speed = 10000

var speed = 0
var velocity = Vector2()
var direction = Vector2()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	direction = Vector2()
	
	if Input.is_action_pressed("ui_up"):
		direction.y = -1
	elif Input.is_action_pressed("ui_down"):
		direction.y = 1
		
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	elif Input.is_action_pressed("ui_right"):
		direction.x = 1

	if direction != Vector2():
		speed = max_speed
	else:
		speed = 0
	
	velocity = speed * direction.normalized() * delta
	
	move_and_slide(velocity)
