module Effect
	class Armour

		def save_state_to_datatable

			soak_string = ''

			@soaks.each do |key, val|
				soak_string = "#{soak_string} #{key.to_s}=#{val.to_s},"
			end

			resistances_string = ''

			@resistances.each do |key, val|
				resistances_string = "#{resistances_string} #{key.to_s}=#{val.to_s},"
			end

			{type: 'Armour', text_1: @name, select_1: @type, text_2: soak_string.chomp(','), text_3: resistances_string.chomp(','), text_4: @avoidance[DefenceType::GENERIC_COMBAT_AVOIDANCE], text_5: @avoidance[DefenceType::CLOSE_COMBAT_AVOIDANCE], text_6: @avoidance[DefenceType::RANGED_COMBAT_AVOIDANCE]}
		end

		def self.save_state_from_datatable(parent, table)

			s_soaks = Hash.new{|hash, key| 0}
			input_soaks = table[:text_2].split(',')
			input_soaks.each do |i_soak|
				i_soak = i_soak.split('=')
				s_soaks[i_soak[0].strip.to_sym] = i_soak[1].strip.to_i
			end

			s_res = Hash.new{|hash, key| 0}
			input_res = table[:text_3].split(',')
			input_res.each do |i_res|
				i_res = i_res.split('=')
				s_res[i_res[0].strip.to_sym] = i_res[1].strip.to_i
			end

			avoidance = {generic: table[:text_4].to_i, close: table[:text_5].to_i, ranged: table[:text_6].to_i}

			if table[:text_1] == '' || (parent.respond_to?(:name) && table[:text_1] == parent.name)
				['Armour', nil, s_soaks, s_res, avoidance, table[:select_1].to_sym]
			else
				['Armour', table[:text_1], s_soaks, s_res, avoidance, table[:select_1].to_sym]
			end
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					                             show: ['text_1', 'text_2', 'text_3', 'text_4', 'text_5', 'text_6', 'select_1'],
					                             labels: {text_1: 'Name', text_2: 'Soaks (comma separated) eg. slashing=1,holy=2,unholy=2 - Supported types: ' + DamageType::LIST.join(','), text_3: 'Resistances (format as above) eg. slashing=100,holy=50', text_4: 'Dodge % vs all attacks', text_5: 'Hit chance penalty for close combat attackers', text_6: 'Hit chance penalty for ranged attackers'},
					                             options: {select_1: DefenceType::APPLICATION},
					                             values: {text_1: '', text_2: '', text_3: '', text_4: '', text_5: '', text_6: '', select_1: DefenceType::BONUS_SOAK}
			                             })
		end

	end
end