extends CharacterBody2D

@onready var velocity_component = $VelocityComponent
@onready var hurtbox_component = $HurtboxComponent
@onready var visuals = $Visuals

var damage = 2

func _ready():
	hurtbox_component.hit.connect(on_hit)


func _process(_delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)

func on_hit():
	$HitRandomAudioPlayerComponent.play_random()
