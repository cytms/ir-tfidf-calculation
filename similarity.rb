#h1 and h2 are t_index-idf Hash
def cosine(h1, h2)
	temp = 0
	temp_h1 = 0
	h1.each{|key, value|
		if h2.include?(key)
			temp = value * h2[key] + temp
		end
		temp_h1 = value * value + temp_h1
	}

	temp_h2 = 0
	h2.each{|key, value|
		temp_h2 = value * value + temp_h2
	}
	result = temp / (Math.sqrt(temp_h1) * Math.sqrt(temp_h1))
	return result
end