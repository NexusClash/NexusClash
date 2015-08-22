module Entity
	class Status
		include Mongoid::Document

		embedded_in :stateful, polymorphic: true

		field :link, type: Integer

		#field :name, type: String
		#field :impacts, type: Array
		#field :custom, type: Boolean
		#field :family, type: Symbol

		def name
			self.type.name
		end

		def family
			self.type.family
		end

		def type
			@type ||= Entity::StatusType.find self.link
		end

		def link=(link_id)
			self[:link] = link_id
			self.unserialize
		end

		attr_accessor :effects

		after_initialize do |document|

		end

		before_save do |document|
			document.serialize
		end

		# Handled by parent
		#after_find do |document|
		#document.unserialize
		#end

		def self.source_from(link_id)
			new_status = Entity::Status.new
			new_status.link = link_id
			new_status.unserialize
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

		def serialize
			#TODO: Come up with new state saving method (for any custom data effects need to save)
		end

		def unserialize
			@type = Entity::StatusType.find(self.link.to_i)
			new_effects = ThreadSafe::Array.new
			@type.impacts.each do |impact|
				new_effects << Effect::Base.unserialize(self, impact)
			end
			@effects = new_effects
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



	end
end