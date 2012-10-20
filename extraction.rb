def extraction(input_file)
	require 'stemmify'
	stop_words = open( 'stop_words.txt', 'rb' ).read
	extracted_file = Array.new
	downcase_file = input_file.downcase
	tokenized_file = downcase_file.split(/\W+/)
	tokenized_file.each { |token|
		if !stop_words.include?token
			extracted_file << token.stem
		end
	}
	return extracted_file
end