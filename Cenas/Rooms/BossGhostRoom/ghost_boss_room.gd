extends Room

@export var boss: GhostBoss

func switch_process(mode: bool):
	super.switch_process(mode)
	if mode: boss.setup()
