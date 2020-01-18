extends Character

onready var _input = $Input
onready var _target_timer:Timer = $TargetTimer
onready var _held_mesh:MeshInstance = $MeshInstance/Held/HeldMesh

onready var _resources:ResourcePreloader = $ResourcePreloader

func _ready():
    _input.connect("hold_start", self, "_on_hold_start")
    _input.connect("press_end", self, "_on_press_end")
    
    _resources.add_resource('shield', load("res://Assets/Equipment/shield.tres"))
    

func change_target():
    var targets = _get_targets()
    if targets.size() == 0: return
    
    for target in targets:
        target.untarget_me()
    
    var nearest_target = targets[0]
    if _state == STATES.MOVE:
        # Cycle through targets if they are already moving...
        var previous_index = _target_index
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


func set_state(new_state):
    _state = new_state
    match(new_state):
        STATES.BLOCK:
            _held_mesh.mesh = _resources.get_resource("shield")
            _held_mesh.visible = true
        _: _held_mesh.visible = false


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
