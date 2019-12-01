extends Control

onready var _tween = $Tween
onready var _background = $Background
onready var _progress = $Progress
onready var _timer = $ShowTimer
onready var _flash_timer = $FlashTimer

var health:int = 100
var prev_health:int = 100
var is_animating:bool = false


func try_hide():
    if is_animating: return
    hide()


func set_health(new_health):
    is_animating = true
    _progress.value = health
    _background.value = health
    
    show()
    _tween.interpolate_property(_progress, "value", health, new_health, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
    _tween.start()
    
    _flash_timer.start(0.8)

    prev_health = health
    health = new_health


func set_background():
    _tween.interpolate_property(_background, "value", prev_health, health, .5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    _tween.start()
    
    _timer.start(1)


func _on_FlashTimer_timeout():
    set_background()
    
    
func _on_ShowTimer_timeout():
    is_animating = false
    #hide()