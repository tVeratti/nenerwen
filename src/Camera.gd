extends Camera

const MIN_ZOOM = 1.0
const MAX_ZOOM = 3.0
const DEFAULT_ZOOM = 15
const CINEMATIC_ZOOM = 20

const Y_OFFSET = 10


# Target
onready var _target:Spatial
var _player:KinematicBody
var _speed:float = 5.0
var _manual_speed:float = 15.0
var _tolerance:float = 0.1

# Zoom
onready var _zoom_target = DEFAULT_ZOOM
var _zoom_speed:float = 8.0
var _zoom_step:float = 1.0
var _zoom_tolerance:float = 0.1

# Cinematic
var _playing_cinematic:bool = false
var _prev_zoom_target = _zoom_target
var _input_target_active:bool = false
var _input_zoom_active:bool = false
var _canceled_by_target:bool = false
var _canceled_by_zoom:bool = false

var _camera_locked:bool = false

onready var _timer:Timer = $Timer


func _ready():
    _player = get_tree().get_nodes_in_group("player")[0]
    set_target(_player)


func _physics_process(delta):
    
    # Move the camera to the target tile (x, y)
    var target = _target.translation
    look_at(target, Vector3.UP)
    var distance = translation.distance_to(target)
    if distance >= _tolerance:
        translation = Vector3(\
        lerp(translation.x, target.x, _speed * delta),\
        lerp(translation.y, target.y + Y_OFFSET, _speed * delta),
        lerp(translation.z, target.z + _zoom_target, _zoom_speed * delta))
    

func _input(event):
    if not _camera_locked:
        _input_zoom_active = false
        if event is InputEventMouse and event.is_pressed():
            if event.button_index == BUTTON_WHEEL_UP:
                adjust_zoom(-1)
                cancel_cinematic()
            elif event.button_index == BUTTON_WHEEL_DOWN:
                adjust_zoom(1)
                cancel_cinematic()
    

func set_target(target):
    if not _camera_locked:
        _target = target


func adjust_zoom(factor:float):
    _zoom_target += (_zoom_step * factor)
    _input_zoom_active = true


func set_zoom_target(target):
    _zoom_target = target


func start_cinematic_target(target):
    _playing_cinematic = true
    _prev_zoom_target = _zoom_target
    set_target(target)
    set_zoom_target(CINEMATIC_ZOOM)
    _timer.start(1)


func end_cinematic_target():
    _playing_cinematic = false
    _camera_locked = false
    set_target(_player)
    set_zoom_target(DEFAULT_ZOOM)


func cancel_cinematic():
    _canceled_by_target = _input_target_active
    _canceled_by_zoom = _input_zoom_active


func lock():
    _camera_locked = true


func unlock():
    _camera_locked = false


func _on_Timer_timeout():
    end_cinematic_target()