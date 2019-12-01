extends Spatial

onready var _animation:AnimationPlayer = $AnimationPlayer

func play():
    _animation.play("Hit")