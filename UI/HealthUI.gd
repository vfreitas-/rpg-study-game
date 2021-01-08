extends Control

var playerStats = PlayerStats

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var uiFull = $Full
onready var uiEmpty = $Empty

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if uiFull != null:
		uiFull.rect_size.x = hearts * 15

func set_max_hearts(value):
	max_hearts = max(value, 1)
	if uiEmpty != null:
		uiEmpty.rect_size.x = max_hearts * 15
	
func _ready():
	self.max_hearts = playerStats.max_health
	self.hearts = playerStats.health
	playerStats.connect("health_changed", self, "set_hearts")
	playerStats.connect("max_health_changed", self, "set_max_hearts")
