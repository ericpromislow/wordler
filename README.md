# The Impatient Developer's Guide to Winning at Wordle

If you don't care about Wordle, think Ruby is a jewel or a type of jungle fruit, and curl is something you do to your hair, this might not be the right document for you.

The goal here is to lower the average number of guesses you need to get the Wordle of the day. As you can tell, we're using computers. If you prefer to solve these things on your own, please be my guest. I won't be offended. Although what we're doing here isn't cheating as much as just using technology to delve into the amazing nuances of the English language. Yeah, right.

First, make yourself a directory you don't mind filling up with random files.

Next, you need to grab the list of five-letter words Wordle
uses. Fortunately, I have you covered. You can get it by running

```
$ curl -kL https://www.kondozier.com/wordle-words.txt  > wordle-words.txt
```

It's just a sorted list of 2,315 5-letter English words. If Wordle starts using a different word list, someone let me know and I'll update it. Or you can get it from the source, but with this warning: the list is a shuffled list of the words, and when Wordle says "Wordle 209", it means that day's puzzle is for the 210th word in the list (I assume it's just indexing into a JavaScript array). The next day's will be word #210, the next word in that array. If you look, you no longer need to read the rest of this document. But not everyone will appreciate you peppering their feeds with single-guess results. Fortunately for me, I grabbed the list and immediately sorted it alphabetically before I could see what was going on.

Alright, next you need to set yourself up with a program that will help you analyze the language English language in all its marvelous subtleties:

```
$ cat > show-frequent-letters <<'EOF'
#!/usr/bin/env ruby

require 'pp'
require 'set'

filename = ARGV[0]
existingLetters = Set.new((ARGV[1] || '').split(''))

words = IO.read(filename).split('\n')
letters = Hash.new(0)
words.each do |word|
  Set.new(word.split('')).difference(existingLetters).entries.each {
    |c| letters[c] += 1
  }
end

pp letters.sort{|v1, v2| v2[1] <=> v1[1]}
EOF
```

And then make it executable:
```
$ chmod +x show-frequent-letters
```

This could be fancier, but we're doing borderline cheating here, no point complaining about corner-cutting.
This program prints out the list of the most commonly-used letters that span a set of words, and this is how we're going to start wordling:

```
$ ./show-frequent-letters wordle-words.txt | head -n 10
```

You should get output like this:
```
[["e", 1056],
 ["a", 909],
 ["r", 837],
 ["o", 673],
 ["t", 667],
 ["l", 648],
 ["i", 647],
 ["s", 618],
 ["n", 550],
 ["u", 457],
```

Of the 2,315 words in the list, 1,056 of them contain at least one `e`, 909 at least one `a`, and so on. A good heuristic is that a word comprising the most common letters is more likely to give a large number of hits than some other word. With the technique I'm about to show you, misses are also good. But a hit eliminates many more letters than a miss, so let's go with that. Are there any words that are made up of those top five? I can't think of one off the top of my head, but let's use technology!

```
$ cat wordle-words.txt | grep -vE -e-v -e '[^earot]'
```

I normally don't `cat` files into commands, but we're going to be doing lots of command-line messing around here, so this makes sense. And this command gives this output:

```
aorta
eater
error
otter
rarer
retro
rotor
tarot
terra
treat
```

Unfortunately, it looks like all of them have a repeated letter, which strikes me as a waste for a first guess. We could go over the list manually to make sure about that, but we've got a computer here (and if you're following along here, you must have one and aren't reading this on a page of paper your Aunt Sallie printed off and mailed to you). (And needless to say, I'm assuming you've got a reasonable command-line at hand.)

So let's write ourselves another program:
```
cat > remove-words-with-duplicates << 'EOF'
#!/usr/bin/env ruby

require 'set'

ARGF.each do |word|
  puts word if Set.new(word.split('')).entries.length === word.length
end
EOF
```

And rerun the program:

```
cat wordle-words.txt | grep -v -e '[^earot]' | ./remove-words-with-duplicates
```

Everyone here knows grep, right? We only want to see words that are made up of any combination of our five favorite letters. The expressions and commands will get a little more complicated as we go, but if you figure out what's going on with each step the progression should be easy, if not even a bit fun-filled.

No output. What if we also allow `l`s? Let's rerun the above command-line. There are three ways to make small changes to command-lines like this:

1. Use bash history. In this case, typing `^rot^rotl` will do it (`^rot^&l^` if you want to be a hotshot).

2. Edit the command. Press `up-arrow` or `ctrl-p` to highlight that line, and then type `Ctrl-X Ctrl-E` (at least on bash in iTerm -- what other setups do devs have these days?). Voila: you're editing that command-line in your standard editor. Make the changes, save, and press return.

3. Up-arrow, and then lots of left-arrows to get to the position. May I recommend learning one of the above steps?

Anyway, here's the output I get now:

```
$ cat wordle-words.txt | grep -v -e '[^earotl]' | ./remove-words-with-duplicates
alert
alter
later
```

Only two vowels, but those are all frequently used letters, so why not. Before I wrote this program I used to start with the word `raise`, but it turns out that when you don't include regular plurals, `s` drops in the rank of most used letters. Until Wordle starts including the plural form of all regular nouns that end in a consonant, I'll start using one of the above three words.

Now just for a moment, let's pretend we're the Wordlemaster, and we have to pick the word of the day:

```
$ cat wordle-words.txt | gshuf -n 1
mason
```

(See why I'm leaving that `cat` thing at the start of the line?). 

But our common-letter word-picker found three words; are we always going to try the same one? Of course not, we have `gshuf` to smash things around a bit:

```
$ cat wordle-words.txt | grep -v -e '[^earotl]' | ./remove-words-with-duplicates  | gshuf -n 1
alter
```

So Wordle would say something like this:

```
M A S O N`
A L T E R
w . . . .
```

I'm using mastermind terminology here: `.` indicates a miss, `b` indicates a hit, and `w` indicates the letter goes somewhere else (and I think if a word has a repeated letter, only the first wrong position will get a `w`).

So now we can use our command-line skills to find out how many words match what we now know:

```
$ cat wordle-words.txt | grep -v -e '[lter]' | grep '[^a]....' | grep a > guesses.txt ; wc guesses.txt
     110     110     660 guesses.txt
```

Unfortunately our gambit didn't eliminate enough of the words. But we can do the same thing with this list that we did with the first:

```
./show-frequent-letters guesses.txt  | head -n 10
[["a", 110],
 ["n", 40],
 ["s", 39],
 ["c", 37],
 ["y", 36],
 ["m", 34],
 ["o", 25],
 ["h", 23],
 ["i", 21],
 ["d", 18],
```

We don't care about seeing the letter 'a', because it's a known member of the word. So a slight rerun will take care of it:

```
./show-frequent-letters guesses.txt a  | head -n 10
[["n", 40],
 ["s", 39],
 ["c", 37],
 ["y", 36],
 ["m", 34],
 ["o", 25],
 ["h", 23],
 ["i", 21],
 ["d", 18],
 ["p", 17],
```

Now we want to hit as many words as possible with our next guess. Let's try the five most popular letters from the above list:

```
$ cat wordle-words.txt | grep n | grep s | grep c | grep y | grep m
<nothing>
$ cat wordle-words.txt | grep n | grep s | grep c | grep y
<still nothing>
$ cat wordle-words.txt | grep n | grep s | grep c
scion
snack
snuck
sonic
```

Those look good. We use `gshuf -n 1` and pick `snuck`.

Round 2

```
A L T E R
w . . . .

M A S O N
S N U C K
w w . . .
```

Two new letters, but in incorrect positions, so let's see what grep says now:

```
$ cat wordle-words.txt | grep -v -e '[lternuck]' | grep '[^as][^n]...' | grep a  | grep s | grep n > guesses.txt ; wc guesses.txt
      3       3      18 guesses.txt
$ cat guesses.txt
basin
mason
pansy
```

Shh, don't tell anyone what the secret word is. We've made two guesses, and can either settle for at worst 5, or guarantee 4. This doc is all about going for the guess on the 4th word. We need to figure out a word that will narrow down the choice to exactly one hit. Well, a word with `b` in position 1, an `m` in another position, and none of the letters in `pansy` will do just this. Is there such a word?

```
$ cat wordle-words.txt | grep 'b....' | grep m | grep -v '[pansy]' > final-guesses.txt ; wc final-guesses.txt
      4       4      24 final-guesses.txt
$ cat final-guesses.txt
biome
bloom
broom
buxom
$ !! | gshuf -n 1
biome
```

OK, let's try guess # 3:

```
A L T E R
w . . . .

S N U C K
w w . . .

M A S O N
B I O M E
. . w w .
```

Only one of those three words had an `M`. Let's try it:

```
M A S O N
M A S O N
b b b b b
```

I actually lied earlier on. The secret word I picked at random was actually `tower`, but look what happens here:
```
T O W E R
A L T E R
. . w b b
$ cat wordle-words.txt | grep -v -e '[al]' | grep '..[^t]er' | grep t
ether
other
steer
tiger
timer
tower
truer
tuber
```

You can do this one by sight. Is the other vowel an 'o', an 'i', another 'e', or a 'u'? 
```
$ cat wordle-words.txt | grep i | grep o | grep u
audio
curio
opium
union
$ !! | gshuf -n 1
audio
```

So guess #2 would be:
```
A L T E R
. . w b b

T O W E R
A U D I O
. . . . w
```

And then:
```
$ cat wordle-words.txt | grep -v -e '[aludi]' | grep '..[^t]er' | grep t | grep o
other
tower
$ !! | gshuf -n 1
other
```

Well, we were a bit unlucky, but plugging it in gives:

```
A L T E R
. . w b b

A U D I O
. . . . w

T O W E R
O T H E R
w w . b b

```

And then we put in `tower`, and get it right on try #4.




