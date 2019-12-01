extends Node

const ACTION_MAP = 'action'
const HOLD_TIMER:float = 300.0
const CHAIN_TIMER:float = 300.0

signal press_start()
signal press_end(command)
signal hold_start()

enum TYPES { HOLD, TAP }

var _press_start_time = 0
var _press_end_time = 0
var _press_chain = false
var _pressing = false
var _holding = false

var _chain = []

onready var _end_timer:Timer = $ChainTimer
onready var _audio:AudioStreamPlayer = $AudioStreamPlayer

func _ready():
    _end_timer.connect("timeout", self, "_on_end_timeout")
    _end_timer.one_shot = true
    add_child(_end_timer)


func _input(event):
    if event.is_action_pressed(ACTION_MAP):
        if not _pressing:
            _start_press()
    if event.is_action_released(ACTION_MAP):
        _end_press()
        

func _process(delta):
    if _pressing and not _holding:
        _update_press()


func _start_press():
    _pressing = true
    _press_start_time = OS.get_ticks_msec()

    _play_tap()
    emit_signal("press_start")
    

func _update_press():
    var now = OS.get_ticks_msec()
    var elapsed_time = now - _press_start_time
    if elapsed_time >= HOLD_TIMER:
        _holding = true
        _play_hold()
        emit_signal("hold_start")


func _end_press():
    _pressing = false
    _holding = false
    _press_end_time = OS.get_ticks_msec()

    # Elapsed time that action has been pressed to determine
    # whether the action is a hold or tap.
    var elapsed_time = _press_end_time - _press_start_time
    var input_type = TYPES.HOLD if elapsed_time >= HOLD_TIMER else TYPES.TAP
    _chain.append(input_type)
    
    _end_timer.start(CHAIN_TIMER / 1000)


func _on_end_timeout():     
    var now = OS.get_ticks_msec()
    var elapsed_time = now - _press_start_time
    if elapsed_time > CHAIN_TIMER:
        var command = ""
        for input in _chain:
            command += String(input)
        
        emit_signal("press_end", command)
        _chain = []
    

func _play_tap():
    _audio.pitch_scale = 5
    _audio.play()


func _play_hold():
    _audio.pitch_scale = 4
    _audio.play()
    