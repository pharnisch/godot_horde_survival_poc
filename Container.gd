extends ColorRect

var player = null
var attackRangeCollisionBox = null

# Called when the node enters the scene tree for the first time.
func _ready():
	self.player = get_node("/root/World/Charakter")
	for child in self.player.get_children():
		if child.name == "AttackRange":
			attackRangeCollisionBox = child.get_child(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_talent_1_pressed():
	attackRangeCollisionBox.shape.radius *= 1.1
	self.visible = false


func _on_talent_2_pressed():
	self.player.shoot_cooldown3 *= 0.9
	self.visible = false


func _on_talent_3_pressed():
	self.player.base_damage *= 1.1
	self.visible = false
