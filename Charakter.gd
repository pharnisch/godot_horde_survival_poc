extends CharacterBody2D

#@export var Bullet : PackedScene
var Bullet = load("res://bullet.tscn")
var Zombie = load("res://zombie.tscn")

var move_speed = 200

var shoot_timer = 0
var shoot_cooldown = 0.5
var shoot_timer2 = 0
var shoot_cooldown2 = 1.7
var spawn_timer = 0
var spawn_cooldown = 5

var move_direction = Vector2(1,1)

var angle = 0

const DEG2RAD = PI / 180.0

var hp = 100
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.move(delta)
	self.base_attack(delta)
	self.base_attack2(delta)
	self.spawn(delta)
	self.collision_damage(delta)
	
func collision_damage(delta):
	var overlapping_mobs = %Hurtbox.get_overlapping_bodies()
	self.get_damage(delta * 5 * overlapping_mobs.size())
	
func spawn(delta):
	self.spawn_timer += delta
	if self.spawn_timer >= self.spawn_cooldown:
		self.spawn_timer -= self.spawn_cooldown
		for i in range(10):
			var z = Zombie.instantiate()
			z.transform = Transform2D(Vector2(1,0), Vector2(0,1), self.global_transform.origin + Vector2(500-i*100,500))
			owner.add_child(z)
			z = Zombie.instantiate()
			z.transform = Transform2D(Vector2(1,0), Vector2(0,1), self.global_transform.origin + Vector2(500-i*100,-500))
			owner.add_child(z)
			z = Zombie.instantiate()
			z.transform = Transform2D(Vector2(1,0), Vector2(0,1), self.global_transform.origin + Vector2(500,500-i*100))
			owner.add_child(z)
			z = Zombie.instantiate()
			z.transform = Transform2D(Vector2(1,0), Vector2(0,1), self.global_transform.origin + Vector2(-500,500-i*100))
			owner.add_child(z)
			

func move(delta):
	var move_direction = Vector2()
	move_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	move_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	move_direction = move_direction.normalized()
	if move_direction.x != 0 or move_direction.y != 0:
		self.move_direction = move_direction

	self.move_and_collide(move_direction * delta * self.move_speed)
	
func base_attack(delta):
	self.shoot_timer += delta
	if self.shoot_timer >= self.shoot_cooldown:
		self.shoot_timer -= self.shoot_cooldown
		
		
		var b = Bullet.instantiate()
		owner.add_child(b)
		b.transform = self.global_transform
		
		var velocity = Vector2(cos(self.angle), sin(self.angle))
		
		# Apply force to move the bullet
		b.apply_central_impulse(velocity * 500) 
	
		self.angle += 1
		
func base_attack2(delta):
	self.shoot_timer2 += delta
	if self.shoot_timer2 >= self.shoot_cooldown2:
		self.shoot_timer2 -= self.shoot_cooldown2
		
		
		var b = Bullet.instantiate()
		var b2 = Bullet.instantiate()
		var b3 = Bullet.instantiate()
		owner.add_child(b)
		owner.add_child(b2)
		owner.add_child(b3)
		
		b.transform = self.global_transform
		b2.transform = self.global_transform
		b3.transform = self.global_transform
		
		var velocity = self.move_direction
		
		# Apply force to move the bullet
		var cos = cos(20 * DEG2RAD)
		var sin = sin(20 * DEG2RAD)

		var vel1 = Vector2(velocity.x*cos, velocity.y*sin).normalized()
		var vel3 = Vector2(velocity.x*sin, velocity.y*cos).normalized()
		b.apply_central_impulse(vel1 * 500) 
		b2.apply_central_impulse(velocity * 500) 
		b3.apply_central_impulse(vel3 * 500) 

func get_damage(dmg):
	self.hp -= dmg
