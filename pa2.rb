require_relative 'extraction'
require_relative 'similarity'
#-------------------------------
# two options:
# 1) FOLDER cosine file_1 file_2
# 2) FOLDER mkdic
#-------------------------------
INPUT_FOLDER = ARGV.shift
option = ARGV.shift
#ARGV => ["option", "folder", "file1", "file2"]
if option.downcase == "cosine"
	arr = Array.new
	begin
		ARGV.each{|x|
		  h = Hash.new
		  f = File.open( INPUT_FOLDER + "_tfidf/" + x, "r")
		  line = f.gets
		  while (line = f.gets)
		    a,b = line.split("\t")	#a = t_index; b = tf-idf
		    h[a] = b.gsub(/\n/, "").to_f
		  end
		  arr << h
		}
	rescue => err
	  puts "Exception: #{err}"
	  puts "You can try to mkdic {TEXT_FOLDER} first or check whether the file does exist."
	  err
	end
	puts "-------------------------------------"
	puts "similarity = " + cosine(arr[0], arr[1]).to_s
	puts "-------------------------------------"

elsif option.downcase == "mkdic"

	require 'rubygems'
	require 'tf_idf'
	OUTPUT_FOLDER = INPUT_FOLDER + "_tfidf"
	begin
		Dir::mkdir(OUTPUT_FOLDER)
		dictionary = Array.new
		tfidf_files = Array.new
		tfidf_files_index = Array.new
		extracted_files_array = Array.new
		df = 0

		Dir.foreach(INPUT_FOLDER + '/') do |document|
		  next if document == '.' or document == '..'
		  f = open(INPUT_FOLDER + '/' + document, 'rb').read
		  extracted_file = extraction(f).sort.uniq
		  #extracted_file => array
		  extracted_file.each {|term|
		    is_exist = false
		    dictionary.each{|x| 
		      if x["term"] == term
		        is_exist = true
		        x["df"] = x["df"] + 1
		        break
		      end
		    }
		    if is_exist == false
		      dictionary_term_hash = Hash.new()
		      dictionary_term_hash["t_index"] = 1
		      dictionary_term_hash["term"] = term
		      dictionary_term_hash["df"] = 1
		      dictionary << dictionary_term_hash
		    end
		  }
		  extracted_files_array << extracted_file
		  tfidf_files_index << document
		  puts "load file: " + document.to_s
		end

		a = TfIdf.new(extracted_files_array)
		tfidf_files = a.tf_idf

		dictionary.sort_by! {|x| x["term"]}
		f = File.open(INPUT_FOLDER + "_tfidf/_dictionary.txt", "a")
		f.write("t_index\tterm\tdf\n")
		i = 0
		dictionary.each { |e|
		  e["t_index"] = i
		  f.write( e["t_index"].to_s + "\t" + e["term"].to_s + "\t" + e["df"].to_s + "\n" )
		  i = i + 1
		}
		f.close()

		# tf-idf unit vector
		i = 0
		tfidf_files.each{|tfidf_file|
		  f = File.open( OUTPUT_FOLDER + "/" + tfidf_files_index[i].to_s, "a") 
		  f.write("t_index\ttf-idf\n")
		  dictionary.each{|d|
		    if tfidf_file.has_key?(d["term"])
		      t_index = d["t_index"]
		      f.write(t_index.to_s + "\t" + tfidf_file[d["term"]].to_s + "\n")
		    end
		  }
		  f.close()
		  i = i + 1
		}
	rescue
		puts "the directory already has a dictionary"
	end
end