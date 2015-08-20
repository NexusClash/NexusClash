module IndefiniteArticle

	def a_or_an
		%w(a e i o u).include?(self.name[0].downcase) ? 'an' : 'a'
	end

end