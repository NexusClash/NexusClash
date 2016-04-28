##
# This class represents an action being taken by an entity (usually a character or pet)

module Intent
	class Action

		attr_reader :entity

		def initialize(entity, options = {encumbrance: true, status_tick: true})
			@entity = entity
			@costs = Hash.new{|hash, key| 0}
			@debug_log = Array.new

			# Built-in default triggers for actions
			add_cost(:encumbrance_check_callback, self.method(:encumbrance_check_callback)) if options.has_key?(:encumbrance) && options[:encumbrance]
			add_cost(:status_tick_callback, self.method(:status_tick_callback)) if options.has_key?(:status_tick) && options[:status_tick]
		end

		##
		# Add a cost to the intended action
		def add_cost(cost, amount)
			if amount.is_a? Method
				@costs[cost.to_sym] = amount
			else
				@costs[cost.to_sym] += amount
			end

		end

		##
		# Apply the costs of this intended action
		def apply_costs
			@costs.each do |cost, delta|
				if delta.is_a? Method
					delta.call :apply_costs, self
				else
					if delta != 0 && @entity.respond_to?(cost)
						cost_set = (cost.to_s + '=').to_sym
						value = @entity.send cost
						value -= delta
						@entity.send cost_set, value
					end
				end

			end
		end

		##
		# Determine if the costs of intended action can be met
		# Note that costs can be negative to represent gains (negative morality costs will function correctly)
		def possible?
			@costs.each do |cost, delta|
				if delta.is_a? Method # This cost requires a callback to evaluate
					return false unless delta.call :possible?, self
				else # We're dealing with a regular numeric cost
					# Skip bounds checking for costs with no associated change
					if delta != 0 && @entity.respond_to?(cost)
						value = @entity.send cost
						minimum = (cost.to_s + '_min').to_sym
						maximum = (cost.to_s + '_max').to_sym
						if delta > 0 && @entity.respond_to?(minimum)
							return false if value - delta < @entity.send(minimum)
						end
						if delta < 0 && @entity.respond_to?(maximum)

							return false if value - delta > @entity.send(maximum)
						end

						return false if value < delta
					end
				end
			end
			return true
		end

		def encumbrance_check_callback(action, intent)
			if action == :possible?
				if intent.entity.respond_to?(:weight) && intent.entity.respond_to?(:weight_max) &&  intent.entity.weight > intent.entity.weight_max
					Entity::Message.send_transient([intent.entity.id],'You are carrying too much weight to do this!', MessageType::FAILED)
					return false
				end
			end
			return true
		end

		def status_tick_callback(action, intent)
			if action == :apply_costs
				Entity::Status.tick(intent.entity, StatusTick::STATUS)
			end
			true if action == :possible?
		end

		def realise
			if possible?
				apply_costs
				take_action if respond_to? :take_action
				broadcast_results if respond_to? :broadcast_results
				return true
			end
			return false
		end

		def debug(log)
			return unless Instance.debug
			@debug_log = Array.new if @debug_log === nil
			if log.is_a? String
				@debug_log << log
			else
				if log.respond_to? :parent
					@debug_log << "<b>#{log.parent.name}</b> #{log.describe}"
				else
					@debug_log << log.describe
				end
			end
		end

		def debug_broadcast(target)
			return unless Instance.debug
			@debug_log = Array.new if @debug_log === nil
			target = [target] unless target.is_a? Array
			@debug_log.reverse_each do |msg|
				Entity::Message.send_transient(target,msg, MessageType::DEBUG)
			end
		end

		alias :realize :realise
	end
end