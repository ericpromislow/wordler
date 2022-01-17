
words = {}
ptn = /^(\w+) x (\w+) => (\w+)/

ARGF.each do |word|
  m = ptn.match(word)
  if m
    if !words[m[3]]
      words[m[3]] = []
    end
    words[m[3]] << [m[1], m[2]]
  end
end

words.each do |key, values|
  value = values.sample
  puts "#{value[0]} x #{value[1]} => #{key}"
end
