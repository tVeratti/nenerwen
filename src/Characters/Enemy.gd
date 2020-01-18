extends Character

func start_attacking():
    attack()
    _attack_timer.start(ATTACK_COOLDOWN)


#func stop_attacking():
    #_target = null
  

func _on_AttackTimer_timeout():
    _can_attack = true
    start_attacking()


func _on_CounterTimer_timeout():
    _can_be_countered = false

