extends RigidBody2D

var player = null

var move_speed = 100

var hp = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	self.player = get_node("/root/World/Charakter")
	self.body_entered.connect(_on_body_entered)
	self.set_contact_monitor(true)
	self.set_max_contacts_reported(11)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = self.global_position.direction_to(self.player.global_position)
	move_and_collide(velocity * self.move_speed * delta)

func _test(body):
	print(body)

func _on_body_entered(body):
	#if body.name == "Charakter":
	#	self.hp -= 100 # dmg from player collision and bullet collision
	#	self.player.get_damage(10)
	if "Bullet" in body.name: # Bullet1, Bullet2, Bullet3 ...
		self.hp -= 100
		body.queue_free() # destroy bullet after this collision
		
	if self.hp <= 0:
		self.queue_free() # destroy this zombie
	
func get_damage(dmg):
	self.hp -= dmg
