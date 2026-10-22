class_name Hurtbox
extends Area2D

# Receives hits from Hitboxes. The owner connects to `hit` and decides what
# a hit means (damage, knockback, state change).

signal hit(hitbox: Hitbox)

# Set false to ignore hits (e.g. while stunned or dead). A Hitbox that
# overlapped while disabled won't land when re-enabled; it must reactivate.
var enabled: bool = true

func _ready() -> void:
	# Hurtboxes detect Hitboxes, not the other way round.
	monitorable = false
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	var hitbox := area as Hitbox
	if hitbox == null or not enabled:
		return
	if hitbox.register_hit(self):
		hit.emit(hitbox)
