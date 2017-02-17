##
# This class represents an action being taken by an entity (usually a character or pet)

module Intent
	class Action

		attr_reader :entity

		def initialize(entity, options = {encumbrance: true, status_tick: true, unhide: true, alive:true})
			@entity = entity
			@costs = Hash.new{|hash, key| 0}
			@debug_log = Array.new

			# Built-in default triggers for actions
			add_cost(:alive_check_callback, self.method(:alive_check_callback)) if !options.has_key?(:alive) || options[:alive]
			add_cost(:encumbrance_check_callback, self.method(:encumbrance_check_callback)) if !options.has_key?(:encumbrance) || options[:encumbrance]
			add_cost(:status_tick_callback, self.method(:status_tick_callback)) if !options.has_key?(:status_tick) || options[:status_tick]
			add_cost(:unhide_callback, self.method(:unhide_callback)) if !options.has_key?(:unhide) || options[:unhide]
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
		# Remove a cost from the intended action
		def remove_cost(cost)
			@costs.delete cost.to_sym
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

						if cost == :ap # AP costs work provided user has at least 1 AP
							return false if value < 1
						else
							return false if value < delta
						end
					end
				end
			end
			return true
		end

		def alive_check_callback(action, intent)
			true unless intent.entity.dead?
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
				debug 'Status Tick as part of action...'
				Entity::Status.tick(intent.entity, StatusTick::STATUS)
			end
			true if action == :possible?
		end

		def unhide_callback(action, intent)
			if action == :apply_costs
				debug 'Unhiding character as part of action...'
				intent.entity.visibility = Visibility::VISIBLE #if intent.entity.respond_to? :visibility=
			end
			true if action == :possible?
		end

		def realise
			unless possible?
				debug_broadcast entity
				return false
			end
			apply_costs
			take_action if respond_to? :take_action
			debug_broadcast entity
			broadcast_results if respond_to? :broadcast_results
			return true
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
			target = target.id if target.is_a? Entity::Character
			target = [target] unless target.is_a? Array
			@debug_log.reverse_each do |msg|
				Entity::Message.send_transient(target,msg, MessageType::DEBUG)
			end
		end

		alias :realize :realise
	end
end
