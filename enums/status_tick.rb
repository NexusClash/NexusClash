module StatusTick

	# Scope Character
	AP = :ap
	MINUTE = :minute
	STATUS = :status
	DAMAGE_TAKEN = :damage_taken # expects (you), damage, type, source (optional) to be passed as additional arguments
	DEATH = :death # expects source (optional) to be passed as additional arguments

	# Scope: Item
	ITEM_ACTIVATED = :item_activation

	# Scope: Status
	ACTIVATED = :activation
	ACTIVATED_TARGET = :activation_target # When calling these triggers the target must be passed as an additional argument
	ACTIVATED_SOURCE = :activation_source # When calling these triggers the target must be passed as an additional argument
	STATUS_CREATED = :status_created


	LIST = [ACTIVATED, STATUS_CREATED, ACTIVATED_SOURCE, ACTIVATED_TARGET, AP, DAMAGE_TAKEN, ITEM_ACTIVATED, MINUTE, STATUS]

	def type_list
		LIST
	end
end