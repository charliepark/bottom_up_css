# SETUP
ORIGIN_FILE = ARGV[0] || 'your_stylesheet.css'
DESTINATION_FILE = "parsed_"+ORIGIN_FILE
testing = false

class String
  def add_colons_to_all_attributes
    gsub("}",";}")
  end

  def clean
    eliminate_extra_spaces
    .put_all_attributes_on_one_line
    .add_colons_to_all_attributes
    .eliminate_extra_spaces
    .put_correct_spaces_around_all_punctuation
    .eliminate_extra_colons
    .drop_close_bracket
  end

  def drop_close_bracket
    gsub("}","")
  end

  def eliminate_extra_colons
    gsub(";;",";")
  end

  def eliminate_extra_spaces
    gsub(/[ *\t*\f*][ *\t*\f*]/," ").gsub(/[ *\t*\f*]/," ")
  end

  def put_all_attributes_on_one_line
    gsub(";\n",";")
  end
  
  def put_correct_spaces_around_all_punctuation
    gsub(/\s*:\s*/, ":").gsub(/\s*;\s*/, ";").gsub(/\s*}\s*/, "}")
  end

end

def clean_the_attributes_and_stick_them_in_a_hash
  @hash_of_tags_and_attributes = {}
  @array_of_attributes.each do |attribute|
    tags_and_attributes = attribute.clean.split("{")
    tags = tags_and_attributes[0].split(/\s*,\s*/)
    @attributes = []
    if tags_and_attributes[1]
      @attributes << tags_and_attributes[1].gsub("\n","").split(";").sort.join(';')+";"
    else
      @attributes << ""
    end
    tags.each do |tag|
      tag = tag.strip
      if @hash_of_tags_and_attributes[tag]
        @hash_of_tags_and_attributes[tag] += @attributes
      else
        @hash_of_tags_and_attributes[tag] = @attributes
      end
    end
  end
end

def compress_multiline_attributes
  @array_of_attributes = []
  @array_of_lines.each do |line|
    if line.include?("{")
      @array_of_attributes << line
    elsif line.include?("/*")
      @array_of_attributes << line
    else
      @array_of_attributes[-1] << line
    end
  end
end

def divide_the_arrays_of_tags_and_attributes_into_tag_id_and_class_sections
  @tags = []
  @ids = []
  @classes = []
  @array_of_all_tags_in_file.each do |tag_and_attributes|
    if tag_and_attributes[0][0,1] == "#"
      @ids << tag_and_attributes
    elsif tag_and_attributes[0][0,1] == "."
      @classes << tag_and_attributes
    else 
      @tags << tag_and_attributes
    end
  end
end

def insert_blank_lines_between_tag_sections
  @last_ultimate_tag = ""
  @array_of_all_tags_in_file.each_with_index do |e, i|
    @current_ultimate_tag = e[1].split(" ")[0].gsub('zz.','.').gsub('zy#','#')
    if @current_ultimate_tag != @last_ultimate_tag and @current_ultimate_tag[0,1] != "." and @current_ultimate_tag[0,1] != "#"
      @array_of_all_tags_in_file.insert(i, ["\n", "", ""] )
    end
    @last_ultimate_tag = @current_ultimate_tag
  end
end

def make_sure_all_comments_in_css_file_start_on_new_lines
  @array_of_lines.each_with_index do |e, i|
    if @array_of_lines[i].include?"/*"
      @array_of_lines[i] = @array_of_lines[i].split("/*")
      @array_of_lines[i][1] = "/*"+@array_of_lines[i][1]
    end
  end
  @array_of_lines = @array_of_lines.flatten
end

def open_the_destination_file_in_write_mode
  @destination = File.open(DESTINATION_FILE, "w")
end

def push_the_raw_css_into_an_array_of_lines
  @array_of_lines = File.open(ORIGIN_FILE, "r").readlines
end

def remove_comment_lines
  @array_of_attributes.delete_if { |e| e.include?"/*" }
end

def remove_empty_lines
  @array_of_all_tags_in_file.delete_if { |e| e[2] == ""}
end

def save_and_close_the_destination_file
  @destination.close
end

def sort_and_compress_attributes
  @hash_of_tags_and_attributes.each do |key, value|
    @hash_of_tags_and_attributes[key] = value.join(';').gsub(';;',';').split(';').sort_by{|e| e.split(':')[0]}.join(';')
  end
end

def sort_the_hash_of_tags_and_attributes
  @array_of_all_tags_in_file = []
  @hash_of_tags_and_attributes.sort.each do |key, value|
    reversed_cascade = key.split(' ').reverse.join(' ')#.gsub('.','zz.').gsub('#','zy#')
    @array_of_all_tags_in_file << [key, reversed_cascade, value]
  end
  @array_of_all_tags_in_file = @array_of_all_tags_in_file.sort_by {|a| a[1]}
  @hash_of_tags_and_attributes = @hash_of_tags_and_attributes.sort
  # at this point, @hash_of_tags_and_attributes is an Array
end

def write_other_loggy_stuff_for_testing
  @sorted_array = @array_of_all_tags_in_file.sort_by {|a| a[1]}
  @destination.write "\n\n@sorted_array\n"
  @destination.write @sorted_array.to_s + "\n"

  @sorted_array.each do |array|
    @destination.write array.join(';') + "\n\n"
  end

  @destination.write "\n\n@array_of_all_tags_in_file\n"
  @array_of_all_tags_in_file.each do |line|
    @destination.write line.to_s + "\n"
  end

  @destination.write "\n\n@tags\n"
  @tags.each do |line|
    @destination.write line.to_s + "\n"
  end

  @destination.write "\n\n@ids\n"
  @ids.each do |line|
    @destination.write line.to_s + "\n"
  end

  @destination.write "\n\n@classes\n"
  @classes.each do |line|
    @destination.write line.to_s + "\n"
  end
end

def write_the_final_line_to_the_file
  @array_of_all_tags_in_file.each_with_index do |e, i|
    @destination.write "/* unspecified IDs and classes */\n" if i == 0
    if e[1].split(' ').length == 1 and e[1].include?(".") == false and e[1].include?(":") == false and e[1].include?("#") == false
      @destination.write "\n/* "+e[1]+" */\n"
    end
    @destination.write e[0] + "{" + e[2] +"}\n"
  end
end

# THE PROCESS
push_the_raw_css_into_an_array_of_lines
make_sure_all_comments_in_css_file_start_on_new_lines
compress_multiline_attributes
remove_comment_lines
clean_the_attributes_and_stick_them_in_a_hash
sort_and_compress_attributes
sort_the_hash_of_tags_and_attributes
divide_the_arrays_of_tags_and_attributes_into_tag_id_and_class_sections
remove_empty_lines
open_the_destination_file_in_write_mode
write_the_final_line_to_the_file
write_other_loggy_stuff_for_testing if testing
save_and_close_the_destination_file
