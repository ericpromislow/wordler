
require 'set'
factor = 5

words = IO.read('data/words.txt').split("\n")

num_pairs = words.size * (words.size - 1) / 2;
secs_per_hour = 3600;
wait_time = (12.0 * secs_per_hour) / num_pairs;
i = 0
words[0...-1].each_with_index do | word1, index |
  words[index+1..-1].each do |word2|
    i += 1
    print '.' if i % (10 * factor) == 0
    puts if i % (factor * 750) == 0
    # next if (Set.new(word1.split('')) & Set.new(word2.split)).length >= 2
    results = `cat data/words.txt | grep -v -e '[#{word1}#{word2}]'`
    # len = results.split("\n").length
    if results.split("\n").length == 1
      i = 0
      puts "\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
      puts "#{word1} x #{word2} => #{results}"
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    end
    sleep wait_time
  end
  print '@'
end
    
