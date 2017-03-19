require 'autoinc'
module Entity
	class Character
		include Mongoid::Document
		include Unobservable::Support
		include Entity::ObservedFields
		include Mongoid::Autoinc
		include Mongoid::Attributes::Dynamic

		attr_accessor :socket

		field :id, type: Integer
		field :name, type: String
		field :hp, type: Integer, default: 50
		field :ap, type: Integer, default: 100
		field :mp, type: Integer, default: 20
		field :xp, type: Integer, default: 0
		field :level, type: Integer, default: 1
		field :mo, type: Integer, default: 0
		field :cp, type: Integer, default: 10
		field :x, type: Integer, default: 1
		field :y, type: Integer, default: 1
		field :z, type: Integer, default: 0
		field :plane, type: Integer, default: ->{Instance.plane}

		field :visibility, type: Integer, default: Visibility::VISIBLE

		field :gender, type: Integer, default: Gender::PLURAL

		field :last_tick, type:Time, default: ->{Time.now}

		attr_reader :location
		attr_accessor :sense_health
		attr_accessor :cast_spells
		attr_accessor :casts_at_normal_damage
		attr_accessor :sense_magic
		attr_accessor :sense_morality
		attr_accessor :weight_max
		attr_accessor :hp_max_mod


		attr_accessor :transient_tags

		def transient_tags
			@transient_tags ||= ThreadSafe::Cache.new
		end

		@revealed_to = ThreadSafe::Array.new

		def shard
			@shard ||= Firmament::Plane.fetch self.plane
		end

		index({:name => 1}, :unique => true)

		#observe_fields :name, :hp, :ap, :mp, :xp, :level, :mo, :cp

		belongs_to :account

		embeds_many :statuses, as: :stateful, cascade_callbacks: true

		embeds_many :items, as: :carrier, cascade_callbacks: true, after_add: :add_weight, after_remove: :remove_weight

		def get_tag(tag)
			read_attribute tag
		end

		def set_tag(tag, value)
			write_attribute tag, value
		end

		def weight
			self.items.inject(0){ |sum, an_item| sum + an_item.weight }
		end

		def weight_max
			@weight_max ||= 50
		end

		def hp_max_mod
			@hp_max_mod ||= 0
		end

		def add_weight(item)
			if item.is_a? Entity::Item
				@weight += item.weight if @weight
			else
				@weight += item if @weight
			end
		end

		def remove_weight(item)
			if item.is_a? Entity::Item
				@weight -= item.weight if @weight
			else
				@weight -= item if @weight
			end
		end

		def mo_max
			if ['Paladin', 'Divine Herald', 'Holy Champion', 'Seraph', 'Shepherd', 'Lightspeaker', 'Archon', 'Advocate'].include? nexus_class
				500
			else
				400
			end
		end

		def mo_min
			if ['Pariah', 'Infernal Behemoth', 'Doom Howler', 'Void Walker', 'Defiler', 'Dark Oppressor', 'Corruptor', 'Wyrm Master'].include? nexus_class
				-500
			else
				-400
			end
		end

		def reveal_to!(char)
			@revealed_to << char.id
			packet = {packets: [{type: 'character', character: self.to_hash(BroadcastScope::TILE)}]}.to_json
			char.socket.send(packet) unless char.socket === nil
		end

		def visible_to?(char)
			char == self || self.visibility == Visibility::VISIBLE || @revealed_to.include?(char.id)
		end

		def visibility=(val)
			if val != self.visibility
				could_see = []
				self.location.characters.each do |char|
					could_see << char if self.visible_to?(char)
				end
				self[:visibility] = val
				@revealed_to.clear
				# Hide from characters who can't see anymore
				rmpacket = {packets:[type:'remove_character', char_id: self.id]}.to_json
				could_see.each do |char|
					char.socket.send(rmpacket) unless char.socket === nil || self.visible_to?(char)
				end
				# Display to characters now capable of seeing
				self.broadcast_self(BroadcastScope::TILE)
			end
		end

		before_save do |document|
			self.last_tick = Time.now

			#document.statuses.each do |status|
			#	status.generate
			#end
		end

		after_find do |document|

			@revealed_to = ThreadSafe::Array.new

			document.statuses.each do |status|
				status.unserialize
				status.parent = self
			end

			document.statuses.each do |status|
				status.effects.each do |effect|
					effect.unserialise if effect.respond_to? :unserialise
				end
			end

			minutes_elapsed = ((Time.now - document.last_tick) / 60).floor

			ticks_before = (15 - document.last_tick.min % 15).floor
			ap_ticks = ((minutes_elapsed - (15 - document.last_tick.min % 15) - (Time.now.min % 15)) / 15).floor
			ticks_after = (Time.now.min % 15).floor

			ap_ticks = 100 if ap_ticks > 100 #cap the amount of computation on inactive dead characters

			(1..ticks_before).each do |tick|
				minutes_elapsed -= 1
				Status.tick(self, :minute) unless minutes_elapsed < 0
			end
			(1..ap_ticks).each do |tick|
				Status.tick self, :ap
				Status.tick self, :status
				unless tick == ap_ticks || minutes_elapsed < 0 then
					(1..15).each do |tick2|
						minutes_elapsed -= 1
						Status.tick(self, :minute) unless minutes_elapsed < 0
					end
				end
			end
			(1..ticks_after).each do |tick|
				minutes_elapsed -= 1
				Status.tick(self, :minute) unless minutes_elapsed < 0
			end

			self.last_tick = Time.now

		end

		increments :id

		#belongs_to :tile

		def ap_max
			[50, level + 40].max
		end

		def hp_max
			[50, level + 40].max + hp_max_mod
		end

		def mp_max
			level > 0 ? level + 19 : 20
		end

		def dead?
			self.hp <= 0
		end

		def nexus_class
			nclass = 'Mortal'
			statuses.each do |status|
				nclass = status.name if status.family == :class
			end
			nclass
		end

		def has_nexus_class?(class_name)
			class_name = class_name.to_s
			statuses.each do |status|
				return true if status.family == :class && status.name == class_name
			end
			return false
		end

		def nexus_classes
			classes = []
			statuses.each do |status|
				classes << status if status.family == :class
			end
			return classes
		end

		def alignment
			return :good if mo >= 200
			return :evil if mo <= -200
			return :neutral
		end

		def hp_fuzzy
			return 'full' if hp >= hp_max
			return 'high' if hp > hp_max * 0.5
			return 'mid' if hp > hp_max * 0.25
			return 'low'
		end

		def name_link
			"<a href='/character/#{self.id}' data-char-link='#{self.id}'>#{self.name}</a>"
		end

		def to_hash(scope = BroadcastScope::NONE)

			hash = {id: id, name: name, hp: hp, hp_fuzzy: hp_fuzzy, hp_max: hp_max, ap: ap, mp: mp, mp_max: mp_max, xp: xp, level: level, mo: mo, cp: cp, x: x, y: y, z: z, plane: plane, nexus_class: nexus_class, sense_hp: sense_health, sense_mp: sense_magic, sense_mo: sense_morality, alignment: alignment}

			if scope == BroadcastScope::SELF
				visible_statuses = Array.new
				visible_statuses << {name: 'Hidden', description: 'You are hiding'} if self.visibility & Visibility::HIDING > 0
				self.statuses.each do |status|
					visible_statuses << {name: status.name, description: status.describe} if status.family == :magical || status.family == :mundane
				end

				abilities = Array.new
				uses = self.activated_uses
				uses.each do |k, val|
					abilities << {name: val.name, status_id: k}
				end

				hash[:visible_statuses] = visible_statuses
				hash[:abilities] = abilities
			end

			hash
		end
	end
end
