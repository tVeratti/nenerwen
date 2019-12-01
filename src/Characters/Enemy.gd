extends Spatial

const ATTACK_COOLDOWN = 2
const COUNTER_TIMER = 1

var _health = 100
var _target
var _can_be_countered = false

# Meshes
onready var _mesh:MeshInstance = $MeshInstance
onready var _outline:MeshInstance = $OutlineMesh

# UI
onready var _ui:Control = $UI
onready var _label:Label = $UI/Label
onready var _health_bar = $UI/HealthBar

# Attack timers
onready var _receive_attack = $ReceiveAttack
onready var _attack_timer:Timer = $AttackTimer
onready var _counter_timer:Timer = $CounterTimer

func _ready():
    $MeshInstance/EnemyBody.set_enemy(self)
    _label.text = name


func _physics_process(delta):
    var camera = get_tree().get_root().get_camera()
    var screen_position = camera.unproject_position(translation)
    _ui.set_position(Vector2(screen_position.x , screen_position.y -20 ))


func target_me():
    _outline.show()


func untarget_me():
    _outline.hide()


func receive_attack(damage, type):
    print(type)
    var multiplier = 1
    if type == ATTACKS.COUNTER:
        multiplier = 2 if _can_be_countered else 0.5
            
    _health -= damage * multiplier
    print(multiplier)
    _health_bar.set_health(_health)
    _receive_attack.play()
    
    if _health <= 0:
        queue_free()


func attack():
    if is_instance_valid(_target):
        _can_be_countered = _target.receive_attack()
        _attack_timer.start(ATTACK_COOLDOWN)
        
        if _can_be_countered:
            _counter_timer.start(COUNTER_TIMER)


func start_attacking(player):
    _target = player
    _attack_timer.start(ATTACK_COOLDOWN)


func stop_attacking():
    _target = null


func _on_AttackTimer_timeout():
    attack()


func _on_CounterTimer_timeout():
    _can_be_countered = false
