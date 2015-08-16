module Entity
	class Status
		include Mongoid::Document

		embedded_in :stateful, polymorphic: true

		field :name, type: String
		field :link, type: Integer
		field :impacts, type: Array
		field :custom, type: Boolean

		field :family, type: Symbol

		attr_accessor :effects

		after_initialize do |document|
			document.effects = ThreadSafe::Array.new
		end

		before_save do |document|
			document.generate
		end

		# Handled by parent
		#after_find do |document|
			#document.regenerate
		#end

		def self.source_from(id)
			new_status = Entity::Status.new
			new_status.link = id
			new_status.custom = false
			new_status.regenerate
			return new_status
		end

		def describe(type = :line)
			case type
				when :line
					line = ''
					@effects.each do |effect|
						line << ' ' unless line == ''
						line << effect.describe
					end
				when :array
					line = []
					@effects.each do |effect|
						line << effect.describe
					end
				else
					line = ''
					@effects.each do |effect|
						line << ' ' unless line == ''
						line << effect.describe
					end
			end
			return line
		end

		def generate

			base_status = Entity::StatusType.find(link) unless link == nil

			if base_status == nil || base_status.locked == false
				state = Array.new
				effects.each do |effect|
					state << effect.save_state
				end

				if base_status.impacts == state then
					self.custom = false
					self.impacts = nil
				else
					self.custom = true
					self.impacts = state
				end

				self.name = base_status.name unless base_status == nil
				self.family = base_status.family unless base_status == nil

			else
				self.impacts = nil
				self.custom = false
				self.name = base_status.name
				self.family = base_status.family
			end

		end

		def regenerate
			new_effects = ThreadSafe::Array.new
			if self.custom
				self.impacts.each do |impact|
					new_effects << Effect::Base.regenerate(self, impact)
				end
				@effects = new_effects
			else
				base_status = Entity::StatusType.find(link)
				self.name = base_status.name
				self.family = base_status.family
				base_status.impacts.each do |impact|
					new_effects << Effect::Base.regenerate(self, impact)
				end
				@effects = new_effects
			end
		end

		def self.tick(char, interval)
			type = ('tick_' + interval.to_s).to_sym
			changed = BroadcastScope::NONE
			changed2 = BroadcastScope::NONE
			char.statuses.each do |status|
				status.effects.each do |effect|
					changed2 = effect.send(type, char) if effect.respond_to? type
					changed = changed2 > changed ? changed2 : changed
				end
			end
			return changed
		end

		#def self.generate(name)
		#	status = Entity::Status.new
		#	status.status_name = name.to_s
		#	case name
		#		when :Mortal
		#			status.impacts << Entity::Impact.link(Effect::Regen.new(status, :minute, :ap, 1))
		#	end
		#	return status
		#end



	end
end