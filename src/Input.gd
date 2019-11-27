extends Node

const ACTION_MAP = 'action'
const HOLD_TIMER = 300
const CHAIN_TIMER = 300

enum TYPES { HOLD, TAP }

var _press_start_time = 0
var _press_end_time = 0
var _press_chain = false
var _pressing = false
var _holding = false

var _chain = []

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

    # Elapsed time from last action released.
    var elapsed_time = _press_end_time - _press_start_time

    # When this press completes, it should either be chained with the
    # previous command, or it should start a new chain.
    _press_chain = elapsed_time <= CHAIN_TIMER

    print('START')
    

func _update_press():
    var now = OS.get_ticks_msec()
    var elapsed_time = now - _press_start_time
    print(elapsed_time)
    if elapsed_time >= HOLD_TIMER:
        # TODO: Signal that the character is HOLDING
        _holding = true
        print('HOLDING')


func _end_press():
    _pressing = false
    _holding = false
    _press_end_time = OS.get_ticks_msec()

    # Elapsed time that action has been pressed to determine
    # whether the action is a hold or tap.
    var elapsed_time = _press_end_time - _press_start_time
    var input_type = TYPES.HOLD if elapsed_time >= HOLD_TIMER else TYPES.TAP

    if _press_chain:
        _chain.append(input_type)
    else:
        # TODO: Send the current chain for processing & reset
        _chain = [input_type]

    printt('END:', _chain)
