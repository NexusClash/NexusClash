require 'autoinc'
module Entity
	class Character
		include Mongoid::Document
		include Unobservable::Support
		include Entity::ObservedFields
		include Mongoid::Autoinc
		include Pronouns

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
		field :plane, type: Integer, default: 1

		field :gender, type: Integer, default: Gender::PLURAL

		field :last_tick, type:Time, default: ->{Time.now}

		attr_reader :location

		def shard
			@shard ||= Firmament::Plane.fetch self.plane
		end

		index({:name => 1}, :unique => true)

		#observe_fields :name, :hp, :ap, :mp, :xp, :level, :mo, :cp

		belongs_to :account

		embeds_many :statuses, as: :stateful, cascade_callbacks: true

		embeds_many :items, as: :carrier, cascade_callbacks: true, after_add: :add_weight, after_remove: :remove_weight

		def weight
			@weight ||= self.items.inject(0){ |sum, an_item| sum + an_item.weight }
		end

		def weight_max
			50
		end

		def add_weight(item)
			@weight += item.weight if @weight
		end

		def remove_weight(item)
			@weight -= item.weight if @weight
		end

		before_save do |document|
			self.last_tick = Time.now

			#document.statuses.each do |status|
			#	status.generate
			#end
		end

		after_find do |document|

			document.statuses.each do |status|
				status.unserialize
			end

			minutes_elapsed = ((Time.now - document.last_tick) / 60).floor

			ticks_before = (15 - document.last_tick.min % 15).floor
			ap_ticks = ((minutes_elapsed - (15 - document.last_tick.min % 15) - (Time.now.min % 15)) / 15).floor
			ticks_after = (Time.now.min % 15).floor

			(1..ticks_before).each do |tick|
				minutes_elapsed -= 1
				Status.tick(self, :minute) unless minutes_elapsed < 0
			end
			(1..ap_ticks).each do |tick|
				Status.tick self, :ap
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
			[50, level + 40].max
		end

		def mp_max
			level > 0 ? level + 19 : 20
		end

		def dead?
			self.hp <= 0
		end

		def nexus_class
			statuses.each do |status|
				return status.name if status.family == :class
			end
			return 'Unknown'
		end

		def has_nexus_class?(class_name)
			class_name = class_name.to_s
			statuses.each do |status|
				return true if status.family == :class && status.name == class_name
			end
			return false
		end

		def hp_fuzzy
			return 'full' if hp >= hp_max
			return 'high' if hp > hp_max * 0.5
			return 'mid' if hp > hp_max * 0.25
			return 'low'
		end

		def name_link
			"<span data-char-link='#{self.id}'>#{self.name}</span>"
		end

		def to_hash
			{id: id, name: name, hp: hp, hp_fuzzy: hp_fuzzy, ap: ap, mp: mp, xp: xp, level: level, mo: mo, cp: cp, x: x, y: y, z: z, plane: plane, nexus_class: nexus_class}
		end
	end
end