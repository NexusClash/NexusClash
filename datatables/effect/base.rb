module Effect
	class Base

		def self.save_state_to_datatable(status, input)
			object = input.clone
			type = object.shift
			object.unshift(status)
			type = Effect.const_get type
			effect = type.new *object
			saved = effect.save_state_to_datatable
			saved[:status_id] = status.id
			saved[:description] = effect.describe
			return saved
			#puts saved.inspect

			#return self.datatable_row()
		end

		def self.save_state_from_datatable(status, input)
			type = Effect.const_get input[:type]
			return type.save_state_from_datatable(status, input)
		end

		def self.datatable_define(values)
			defined = Effect.const_get(values[:type]).datatable_define
			values2 = {}
			values.each_key { |k| values2[k] = values[k] if self.datatable_fields.include?(k.to_sym)}
			defined[:values] = values2
			return defined
		end

		def self.datatable_fields
			['select_1', 'text_1', 'select_2', 'text_2', 'select_3', 'text_3', 'select_4', 'text_4', 'select_5', 'text_5', 'text_6', 'text_7']
		end

		def self.datatable_row(input)
			self.datatable_fields.each do |field|
				input[field] = nil unless input.has_key? field
			end
		end

		def self.datatable_setup(input)
			hiddens = []
			shown = input[:show]
			self.datatable_fields.each do |field|
				hiddens << field unless shown.include? field
			end
			input[:hide] = hiddens
			input[:values] = {}
			return input
		end
	end
end