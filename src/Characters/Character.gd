extends KinematicBody

class_name Character

var _health = 100
var _damage = 40

# STATE
enum STATES {  WAIT, MOVE, BLOCK, ATTACK }
var _state = STATES.WAIT

# PATHING
const SPEED = 200
var _path = []
var _path_ind = 0

#TARGETING
const TARGET_RESET_TIME = 3
var _target
var _target_index = 0
var _current_target:Node
var _targets_within_range = []

# MESHES
onready var _mesh:MeshInstance = $MeshInstance
onready var _outline:MeshInstance = $OutlineMesh

# UI
onready var _ui:Control = $UI
onready var _label:Label = $UI/Label
onready var _health_bar = $UI/HealthBar

# ATTACK TIMERS
const ATTACK_COOLDOWN = 2
const COUNTER_TIMER = 1
var _can_attack = true
var _can_be_countered = false

onready var _receive_attack = $ReceiveAttack
onready var _attack_timer:Timer = $AttackTimer
onready var _counter_timer:Timer = $CounterTimer

# NAVIGATION
onready var _nav:Navigation = get_parent()


func _ready():
    #$MeshInstance/EnemyBody.set_enemy(self)
    _label.text = name


func _physics_process(delta):
    # Render the ui according to the 3d translation.
    var camera = get_tree().get_root().get_camera()
    var screen_position = camera.unproject_position(translation)
    _ui.set_position(Vector2(screen_position.x , screen_position.y -20 ))

    if _state == STATES.MOVE:
        if _path_ind < _path.size():
            var next_point = _path[_path_ind]
            var distance = translation.distance_to(next_point)
            if distance < 1:
                _path_ind += 1
            else:
                if is_instance_valid(_current_target):
                    look_at(_current_target.translation, Vector3.UP)
                
                if not _targets_within_range.has(_current_target):
                    var next_position = translation.linear_interpolate(next_point, (SPEED * delta))
                    var direction = (next_point - translation).normalized();
                    
                    #direction.normalized()
                    #direction.y -= 9.8
                    move_and_slide(direction * SPEED * delta, Vector3.UP)


func set_state(new_state):
    _state = new_state
   # match(new_state):
        #STATES.BLOCK:
            #_held_mesh.mesh = _resources.get_resource("shield")
            #_held_mesh.visible = true
        #_: _held_mesh.visible = false


func set_current_target(target):
    if is_instance_valid(target):
        _current_target = target
        _current_target.target_me()


func target_me():
    _outline.show()


func untarget_me():
    _outline.hide()


func is_defending():
    return _state == STATES.BLOCK


func receive_attack(damage, type):
    var multiplier = 1
    if type == ATTACKS.COUNTER:
        multiplier = 2 if _can_be_countered else 0.5
            
    _health -= damage * multiplier
    _health_bar.set_health(_health)
    _receive_attack.play()
    
    if _health <= 0:
        queue_free()


func attack(type = ATTACKS.BASIC):
    set_state(STATES.ATTACK)
    if not _can_attack: return
    
    _attack_timer.start(ATTACK_COOLDOWN)
    _can_attack = false
    
    if not _targets_within_range.has(_current_target) and _targets_within_range.size() > 0:
        set_current_target(_targets_within_range[0])
        
    if is_instance_valid(_current_target):
        _current_target.receive_attack(_damage, type)
        _can_be_countered = _current_target.is_defending()
        if _can_be_countered:
            _counter_timer.start(COUNTER_TIMER)


#func start_attacking(target):
    #_target = target
    #_attack_timer.start(ATTACK_COOLDOWN)


#func stop_attacking():
    #_target = null


func _sort_targets(a:Spatial, b:Spatial):
    var a_distance = a.translation.distance_to(translation)
    var b_distance = b.translation.distance_to(translation)
    return a_distance < b_distance


func _get_targets():
    var targets = get_tree().get_nodes_in_group("enemy")
    targets.sort_custom(self, "_sort_targets")
    return targets
  

func _on_AttackTimer_timeout():
    _can_attack = true


func _on_CounterTimer_timeout():
    _can_be_countered = false

