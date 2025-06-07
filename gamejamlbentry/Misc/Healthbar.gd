extends ProgressBar

@onready var progress_bar = $ProgressBar
@onready var timer = $Timer

var health = 0 : set = _set_health

func _set_health(new_health):
	var previous_health = health
	health = clamp(new_health, 0, max_value)
	value = health
	
	if health <= 0:
		value = 0
		# Don't queue_free, just hide if needed
		hide()

	if health < previous_health:
		timer.start()
	else:
		progress_bar.value = health

func init_health(_health):
	health = _health
	max_value = _health
	value = _health
	progress_bar.max_value = _health
	progress_bar.value = _health
	show()

func _on_timer_timeout():
	progress_bar.value = health
