module Intent
	# Learn a new Skill or Class
	class Learn < Action

		attr_reader :learning

		def initialize(entity, learn)
			super entity, {encumbrance: false, status_tick: false}
			@learning = learn
			@learning = Entity::Status.source_from(@learning.id) if @learning.is_a? Entity::StatusType
			calculate_prerequisites
		end

		def take_action
			@learning.stateful = @entity
		end

		def broadcast_results
			@entity.broadcast_self BroadcastScope::SELF
			text = "You have learnt #{@learning.name}."
			text = "You have become #{@learning.a_or_an} #{@learning.name}." if @learning.family == :class
			message_ent = Entity::Message.new({characters: [@entity.id], message: text, type: MessageType::SKILL_LEARNT})
			message_ent.save
		end

		private

		def calculate_prerequisites
			@cp_cost = 0
			i = 0
			@learning.effects.each do |effect|
				if effect.respond_to? :learn_intent_callback
					debug effect
					add_cost "learn_#{i}", effect.method(:learn_intent_callback)
					i += 1
				end
				# CP costs need to be totalled when learning skills
				@cp_cost += effect.cp_cost if effect.is_a? Effect::SkillPurchasable
			end
			debug "Total CP cost: #{@cp_cost}"
			add_cost :cp, @cp_cost
			debug_broadcast @entity.id
		end

	end
end