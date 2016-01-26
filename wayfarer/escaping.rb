module Wayfarer

	# http://stackoverflow.com/a/22090177/798680

	UNESCAPES = {
			'a' => "\x07", 'b' => "\x08", 't' => "\x09",
			'n' => "\x0a", 'v' => "\x0b", 'f' => "\x0c",
			'r' => "\x0d", 'e' => "\x1b", "\\\\" => "\x5c",
			"\"" => "\x22", "'" => "\x27"
	}

	def self.json_unescape(str)
		# Escape all the things
		str.gsub(/\\(?:([#{UNESCAPES.keys.join}])|u([\da-fA-F]{4}))|\\0?x([\da-fA-F]{2})/) {
			if $1
				if $1 == '\\' then '\\' else UNESCAPES[$1] end
			elsif $2 # escape \u0000 unicode
				["#$2".hex].pack('U*')
			elsif $3 # escape \0xff or \xff
				[$3].pack('H2')
			end
		}
	end

end