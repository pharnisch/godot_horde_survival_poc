extends CharacterBody2D

#@export var Bullet : PackedScene
var Bullet = load("res://bullet.tscn")
var Zombie = load("res://zombie.tscn")
var WeirdCrawler = load("res://weird_crawler.tscn")

var move_speed = 200

var shoot_timer = 0
var shoot_cooldown = 0.5
var shoot_timer2 = 0
var shoot_cooldown2 = 1.7
var shoot_timer3 = 0
var shoot_cooldown3 = 0.2
var spawn_timer = 0
var spawn_cooldown = 5

var move_direction = Vector2(1,1)

var angle = 0

const DEG2RAD = PI / 180.0

var hp = 100
var score = 0
var hp_regen_per_second = 3

var rng = null

# Called when the node enters the scene tree for the first time.
func _ready():
	self.rng = RandomNumberGenerator.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.regen(delta)
	self.move(delta)
	
	# ATTACKS
	#self.base_attack(delta)
	#self.base_attack2(delta)
	self.base_attack3(delta)
	
	# SPAWN NEW MOBS
	self.spawn(delta)
	
	# HANDLE ENEMY COLLISIONS (currently same damage for every "Hurtbox"-collision (collision layer mask: 3 - enemy))
	self.collision_damage(delta)

	
func regen(delta):
	self.hp += delta * self.hp_regen_per_second
	if self.hp > 100:
		self.hp = 100
	
func collision_damage(delta):
	var overlapping_mobs = %Hurtbox.get_overlapping_bodies()
	#var collision_dmg = 5 * overlapping_mobs.size()
	var collision_dmg = 0
	for mob in overlapping_mobs:
		collision_dmg += mob.get_collision_dmg()
	self.get_damage(delta * collision_dmg)
	
func spawn(delta):
	self.spawn_timer += delta
	if self.spawn_timer >= self.spawn_cooldown:
		self.spawn_timer -= self.spawn_cooldown
		
		var spawn_patterns = [self.spawn_pattern_1, self.spawn_pattern_2]
		var pattern_idx = self.rng.randi_range(0, len(spawn_patterns)-1)
		var enemy_types = [self.Zombie, self.WeirdCrawler]
		var enemy_type_idx = self.rng.randi_range(0, len(enemy_types)-1)
		spawn_patterns[pattern_idx].call(enemy_types[enemy_type_idx])
		#self.spawn_pattern_1()
		
		
func spawn_pattern_1(enemy_type):
	var amount = int(self.hp / 10)
	for i in range(amount):
		var z = enemy_type.instantiate()
		z.transform = Transform2D(Vector2(1,0), Vector2(0,1), self.global_transform.origin + Vector2(500-i*100,500))
		owner.add_child(z)
		z = enemy_type.instantiate()
		z.transform = Transform2D(Vector2(1,0), Vector2(0,1), self.global_transform.origin + Vector2(500-i*100,-500))
		owner.add_child(z)
		z = enemy_type.instantiate()
		z.transform = Transform2D(Vector2(1,0), Vector2(0,1), self.global_transform.origin + Vector2(500,500-i*100))
		owner.add_child(z)
		z = enemy_type.instantiate()
		z.transform = Transform2D(Vector2(1,0), Vector2(0,1), self.global_transform.origin + Vector2(-500,500-i*100))
		owner.add_child(z)
			
func spawn_pattern_2(enemy_type):
	var amount = int(self.hp / 10)
	for i in range(amount):
		var z = enemy_type.instantiate()
		z.transform = Transform2D(Vector2(1,0), Vector2(0,1), self.global_transform.origin + Vector2(500-i*100,500))
		owner.add_child(z)
		z = enemy_type.instantiate()
		z.transform = Transform2D(Vector2(1,0), Vector2(0,1), self.global_transform.origin + Vector2(500-i*100,-500))
		owner.add_child(z)
		z = enemy_type.instantiate()
		z.transform = Transform2D(Vector2(1,0), Vector2(0,1), self.global_transform.origin + Vector2(550-i*100,600))
		owner.add_child(z)
		z = enemy_type.instantiate()
		z.transform = Transform2D(Vector2(1,0), Vector2(0,1), self.global_transform.origin + Vector2(550-i*100,-600))
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
		
func base_attack3(delta):
	self.shoot_timer3 += delta
	if self.shoot_timer3 >= self.shoot_cooldown3:
		self.shoot_timer3 -= self.shoot_cooldown3
		
		# detect nearest enemy within certain range
		var closest_enemy = null
		var closest_distance = 9999999
		for enemy in %AttackRange.get_overlapping_bodies():
			var distance = self.global_position.distance_to(enemy.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_enemy = enemy
				
		# only shoot when there is at least one enemy within attack range
		if closest_enemy != null:
			var b = Bullet.instantiate()
			owner.add_child(b)
			b.transform = self.global_transform
			var direction = self.global_position.direction_to(closest_enemy.global_position)
			b.apply_central_impulse(direction * 500) 


func get_damage(dmg):
	self.hp -= dmg
	if self.hp < 0:
		self.hp = 0

func add_score(score):
	self.score += score
