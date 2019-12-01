extends KinematicBody

const SPEED = 200

enum STATES {  WAIT, MOVE, BLOCK, ATTACK }
var _state = STATES.WAIT

var _damage = 40

var _path = []
var _path_ind = 0

const TARGET_RESET_TIME = 3
var _target_index = 0
var _current_target:Node
var _targets_within_range = []

onready var _nav:Navigation = get_parent()
onready var _input = $Input
onready var _target_timer:Timer = $TargetTimer

func _ready():
    _input.connect("hold_start", self, "_on_hold_start")
    _input.connect("press_end", self, "_on_press_end")


func _physics_process(delta):
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
    

func change_target():
    var targets = _get_targets()
    if targets.size() == 0: return
    
    for target in targets:
        target.untarget_me()
    
    var nearest_target = targets[0]
    var previous_index = _target_index
    
    # Cycle through targets if they are already moving...
    var target_valid = false
    var index = _target_index
    while not target_valid:
        index += 1
        index = index if targets.size() > index else 0
        nearest_target = targets[index]
        if nearest_target != _current_target or targets.size() == 1:
            _target_index = index
            target_valid = true

    set_current_target(nearest_target)
    
    _path = _nav.get_simple_path(translation, nearest_target.translation)
    _path_ind = 0
    
    _target_timer.start(TARGET_RESET_TIME)

    set_state(STATES.MOVE)


func set_current_target(target):
    if is_instance_valid(target):
        _current_target = target
        _current_target.target_me()


func attack(type):
    set_state(STATES.ATTACK)
    
    if not _targets_within_range.has(_current_target) and _targets_within_range.size() > 0:
        set_current_target(_targets_within_range[0])
    
    if is_instance_valid(_current_target):
        _current_target.receive_attack(_damage, type)


func receive_attack():
    if _state == STATES.BLOCK:
        print('blocked')
        return true
    
    print('hit')
    return false


func set_state(new_state):
    _state = new_state
    match(new_state):
        STATES.BLOCK: pass

    
func _sort_targets(a:Spatial, b:Spatial):
    var a_distance = a.translation.distance_to(translation)
    var b_distance = b.translation.distance_to(translation)
    return a_distance < b_distance


func _get_targets():
    var targets = get_tree().get_nodes_in_group("enemy")
    targets.sort_custom(self, "_sort_targets")
    return targets


func _on_hold_start():
    set_state(STATES.BLOCK)


func _on_press_end(command):
    match(command):
        '1': change_target()
        '0': set_state(STATES.WAIT)
        ATTACKS.BASIC, ATTACKS.COUNTER:
            attack(command)


func _on_attack_range_entered(body):
    if body.name == 'EnemyBody':
        var enemy = body.get_enemy()
        _targets_within_range.append(enemy)
        enemy.start_attacking(self)


func _on_attack_range_exited(body):
    var enemy = body.get_enemy()
    var index = _targets_within_range.find(enemy)
    _targets_within_range.remove(index)
    enemy.stop_attacking()


func _on_TargetTimer_timeout():
    _target_index = 0
