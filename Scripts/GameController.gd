#TODO:
#add touch
#add saving highscore
#add leaderboard
#add dark mode
#add gold snakeball for >100 score
#add plus stuff

extends Node3D

@export var controlBall : Node3D
@export var head : Node3D
@export var apple : Node3D
@export var turnSpeed : float
@export var moveSpeed : float
@export var boost : float
@export var ballRadius : float
@export var headRadius : float
@export var appleRadius : float
@export var bodyRadius : float
@export var initialBodyParts : int
@export var applePartBonus : int
@export var maxAppleTries : int
@export var bodyPrefab : PackedScene
@export var nodePrefab : PackedScene
@export var scoreText : Label
@export var highscoreText : Label
@export var pausedText : Label

var score : int = 0
var highscore : int = 0
var headVelocity : Vector2
var headRotation : float
var bodyParts : Array[Node3D] = []
var gameOver = false
var paused = false

func _ready():
	addBodyPart(initialBodyParts)
	pausedText.visible = false

func _physics_process(delta):
	if gameOver:
		if Input.is_action_just_pressed("continue"):
			for part in bodyParts.size():
				bodyParts[part].queue_free()
			
			bodyParts.clear()
			
			addBodyPart(initialBodyParts)
			
			score = 0
			scoreText.text = str(score)
			highscoreText.text = str(highscore)
			
			gameOver = false
	else:
		if paused:
			if Input.is_action_just_pressed("pause"):
				paused = false
				pausedText.visible = false
		else:
			if Input.is_action_just_pressed("pause"):
				paused = true
				pausedText.visible = true
				
			if (sphereCollision(head, headRadius, apple, appleRadius)):
				addBodyPart(applePartBonus)
				moveApple()
				
				var appleTries = 0
				
				while (sphereCollision(head, headRadius * 2, apple, appleRadius) || bodyCollision(apple, appleRadius)):
					moveApple()
					
					if appleTries >= maxAppleTries:
						break
						
					appleTries += 1
				
				score += 1
				scoreText.text = str(score)
				
				if score > highscore:
					highscore = score
			
			moveBodyParts()
			
			var rotateLeft = Input.is_key_pressed(KEY_LEFT)
			var rotateRight = Input.is_key_pressed(KEY_RIGHT)
			
			var currentMoveSpeed = moveSpeed
			
			if rotateLeft && rotateRight:
				currentMoveSpeed = moveSpeed + boost
			else:
				if rotateLeft:
					headRotation -= turnSpeed * delta
				elif rotateRight:
					headRotation += turnSpeed * delta
					
			headVelocity.x = sin(headRotation) * currentMoveSpeed
			headVelocity.y = cos(headRotation) * currentMoveSpeed
			
			controlBall.rotate_object_local(Vector3(1,0,0), deg_to_rad(headVelocity.x) * delta)
			controlBall.rotate_object_local(Vector3(0,1,0), deg_to_rad(headVelocity.y) * delta)
			
			if (bodyCollision(head, headRadius) && score > 0):
				gameOver = true
		
func addBodyPart(count : int = 1):
	for part in range(0, count):
		var newPart : Node3D
		
		if ((bodyParts.size() + 1) % 3 != 0):
			newPart = nodePrefab.instantiate()
		else:
			newPart = bodyPrefab.instantiate()
			
		bodyParts.append(newPart)
		add_child(newPart)
		
func moveBodyParts():
	for part in range(1, bodyParts.size()):
		var reversePart = bodyParts.size() - part
		var lastPart : Node3D = bodyParts[reversePart - 1]
		bodyParts[reversePart].global_position = lastPart.global_position
	
	bodyParts[0].global_position = head.global_position

func moveApple():
	apple.global_position = Vector3(randf_range(-1,1), randf_range(-1,1), randf_range(-1,1)).normalized() * ballRadius

func sphereCollision(a : Node3D, ar : float, b : Node3D, br : float):
	var distance = a.global_position.distance_to(b.global_position)
	
	#if center of one sphere is within other sphere's radius then collide
	if (distance < (ar + br)):
		return true
	else:
		return false

func bodyCollision(collider : Node3D, collisionRadius : float):
	for part in range(5, bodyParts.size() - 1):
		if ((part + 1) % 3 != 0):
			if (sphereCollision(bodyParts[part], bodyRadius, collider, collisionRadius)):
				return true

	return false
