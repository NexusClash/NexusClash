module Intent
	class ActivateSelf < Action
		attr_accessor :entity
		attr_accessor :target
		attr_accessor :outcomes
		attr_accessor :name

		def initialize(entity, target, effect = nil)
			super entity, {encumbrance: true, status_tick: true}
			@target = target
			@outcomes = ThreadSafe::Array.new
			@name = ''
			unless effect === nil
				effect.activate_self_intent self
			end
		end

		def possible?
			possible = super
			@outcomes.each do |outcome|
				possible = possible && outcome.call(:possible?, self)
			end
			return possible
		end

		def apply_costs
			super
			@outcomes.each do |outcome|
				outcome.call :apply_costs, self
			end
		end

		def take_action
			@outcomes.each do |outcome|
				outcome.call :take_action, self
			end
		end

		def broadcast_results
			@outcomes.each do |outcome|
				outcome.call :broadcast_results, self
			end
		end
	end
end
