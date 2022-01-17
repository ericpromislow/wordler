# The Impatient Developer's Guide to Winning at Wordle

If you don't care about Wordle, think Ruby is a jewel or a type of jungle fruit, and curl is something you do to your hair, this might not be the right place for you.

The goal here is to lower the average number of guesses you need to get the Wordle of the day. As you can tell, we're using computers. If you prefer to solve these things on your own, please be my guest. I won't be offended. Although what we're doing here isn't cheating as much as just using technology to delve into the amazing nuances of the English language. Yeah, right.

First, go to your favorite directory for random git things and clone this repo. If that sentence didn't make much sense to you, find someone who can help you out, even over zoom. People like that are usually fine getting a beer, a cup of coffee, or a conference T-shirt (rare these days) if you're wondering how to reciprocate. So from here on, I'm going to assume you either know what you're doing, are collaborating with someone who does, or just skimming over the code parts to get an idea of what to do (that should sort of work).

Next, you need to grab the list of the five-letter words Wordle
uses. Fortunately, I have you covered. They're right here in `data/words.txt`.

It's just a sorted list of 2,315 5-letter English words. If Wordle starts using a different word list, someone let me know and I'll update it. Better still, file a PR. Careful if you wade into the source: the list is a shuffled list of the words, and when Wordle says "Wordle 209", it means that day's puzzle is for the 210th word in the list (I assume it's just indexing into a JavaScript array). The next day's will be word #210, the next word in that array. If you look, you no longer need to read the rest of this document. But not everyone will appreciate your peppering their feeds with single-guess results. Fortunately for me, I grabbed the list and immediately sorted it alphabetically before I could see what was going on.

Alright, next you need to set yourself up with a program that will help you analyze the English language in all its marvelous subtleties. Again, it's right here, in the `show-frequent-letters` Ruby program. It takes one required argument: the input file, and a second optional argument, any letters to not report. You'll see an example real soon.

This program prints out the list of the most commonly-used letters that span a set of words, and this is how we're going to start wordling. First, what are the most common hits in the word list? Not the most commonly used: for example, we only count the `b` in `abbey` once. 

```
$ ./show-frequent-letters data/words.txt | head -n 10
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
$ cat data/words.txt | grep -v '[^earot]'
```

I normally don't `cat` files into commands, but we're going to be messing around a lot with a  command-line that always starts with this file, so it makes sense. You can also do `< data/words.txt grep ...` if you're using a computer that charges you based on the number of characters you type.

And this command gives this output:

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

Either you know what `grep` does, or your collaborator does. If you're following option 3 above, don't worry too much about the actual syntax. Let's just say that `-V` and `[^...]` request match-failures, and everything else is looking for matches. But that list looks suspect -- I see too many repeated letters in most of the words. Are there any words that contain five different letters? Fortunately, there's yet another program in this repro that files out words with duplicate letters:

```
cat data/words.txt | grep -v -e '[^earot]' | ./remove-words-with-duplicates
```

*No output*.

Unfortunately, it looks like all of the words in this first set have a repeated letter, which strikes me as a waste for a first guess. What if we also allow `l`s? Let's rerun the above command-line. There are three ways to make small changes to command-lines like this:

1. Use bash history. In this case, typing `^rot^rotl` will do it (`^rot^&l^` if you want to be a hotshot).

2. Edit the command. Press `up-arrow` or `ctrl-p` to highlight that line, and then type `Ctrl-X Ctrl-E` (at least on bash in iTerm -- what other setups do devs have these days?). Voila: you're editing that command-line in your standard editor. Make the changes, save, and press return.

3. Up-arrow, and then lots of left-arrows to get to the position. May I recommend learning one of the above steps?

Anyway, here's the output I get now:

```
$ cat data/words.txt | grep -v -e '[^earotl]' | ./remove-words-with-duplicates
alert
alter
later
```

Only two vowels, but those are all frequently used letters, so why not. Before I wrote this program I used to start with the word `raise`, but it turns out that when you don't include regular plurals, `s` drops in the rank of most used letters. Until Wordle starts including the plural form of all regular nouns that end in a consonant, I'll keep starting with one of these words. In fact while this example uses `alter`, I think `later` is a better first guess, because about 25% of the words end in either `e?` or `r` (or both). And over twice as many words have an `a` in position 2 compared to position 1.

Now just for a moment, let's pretend we're the WordleMaster, and we have to pick the word of the day:

```
$ cat data/words.txt | gshuf -n 1
mason
```

See why I'm leaving that `cat` thing at the start of the line?

So Wordle would say something like this:

```
A  L  T  E  R
🟨 ⬛ ⬛ ⬛ ⬛
```

So now we can use our command-line skills to find out how many words match what we now know:

```
$ cat data/words.txt | grep -v -e '[lter]' | grep '[^a]....' | grep a > guesses.txt ; wc guesses.txt
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
$ cat data/words.txt | grep n | grep s | grep c | grep y | grep m
<nothing>
$ cat data/words.txt | grep n | grep s | grep c | grep y
<still nothing>
$ cat data/words.txt | grep n | grep s | grep c
scion
snack
snuck
sonic
```

Almost good, but `snack` is a waste because we already know about 'a's.  So let's modify a recent command-line like so:

```
cat data/words.txt | grep -v -e '[alter]' | grep n | grep s | grep c | tee /dev/tty | gshuf -n 1
scion
snuck
sonic
snuck
```

The word `snuck` appears twice because that's the one `gshuf` picked for us. With this word, wordle would now read like:

```
A  L  T  E R
🟨 ⬛ ⬛ ⬛ ⬛
S  N  U  C K
🟨 🟨 ⬛ ⬛ ⬛
```


Three yellows in two guesses. That's hard for a human to reason about. Let's see what the computer does with it:

```
$ cat data/words.txt | grep -v -e '[lteruck]' | grep '[^as][^n]...' | grep a  | grep s | grep n > guesses.txt ; wc guesses.txt
      3       3      18 guesses.txt
$ cat guesses.txt
basin
mason
pansy
```

We've made 2 guesses, and can either settle for at worst 5, but we're all about getting it by 4 here at wordler. We need to figure out a word that will narrow down the choice to exactly one hit. Well, a word with `b` in position 1, an `m` in another position, and none of the letters in `pansy` will do just this. Maybe you can come up of one, but I had to use the computer:

```
$ cat data/words.txt | grep 'b....' | grep m | grep -v '[pansy]'
biome
bloom
broom
buxom
$ !! | gshuf -n 1
biome
```

OK, let's try guess # 3:

```
A  L  T  E  R
🟨 ⬛ ⬛ ⬛ ⬛
S  N  U  C  K
🟨 🟨 ⬛ ⬛ ⬛
B  I  O  M  E
⬛ ⬛ 🟨 🟨 ⬛
```

Only one of those three words (`basin`, `mason`, and `pansy`) have an `m`. Let's try it:

```
A  L  T  E  R 
🟨 ⬛ ⬛ ⬛ ⬛
S  N  U  C  K
🟨 🟨 ⬛ ⬛ ⬛
B  I  O  M  E
⬛ ⬛ 🟨 🟨 ⬛
M  A  S  O  N
🟩 🟩 🟩 🟩 🟩
```

I actually lied earlier on. The secret word I picked at random was actually `tower`, but look what happens here:

```
A  L  T  E  R 
⬛ ⬛ 🟨 🟩 🟩

$ cat data/words.txt | grep -v -e '[al]' | grep '..[^t]er' | grep t
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
$ cat data/words.txt | grep -v '[al]' | grep i | grep o | grep u
curio
opium
union
```

Let's try tightening up the list by ignoring letters we already know about:

```
cat data/words.txt | grep -v '[alter]' | grep i | grep o | grep u
opium
```

So guess #2 would be:
```
A  L  T  E  R
⬛ ⬛ 🟨 🟩 🟩
O  P  I  U  M
🟨 ⬛ ⬛ ⬛ ⬛
```

And then:
```
$ cat data/words.txt | grep -v -e '[alpium]' | grep '[^o].[^t]er' | grep t | grep o
tower
```

Plugging it in gives:

```
A  L  T  E  R
⬛ ⬛ 🟨 🟩 🟩
O  P  I  U  M
🟨 ⬛ ⬛ ⬛ ⬛
T  O  W  E  R
🟩 🟩 🟩 🟩 🟩

```

## Strategy

Here's what I actually do, so I don't have to bother running grep and all that:

1. The first word is always `LATER`. Those are 5 of the 6 most frequent appearances. And it's better than `ALERT` or `ALTER` because the `A` is in a better position, and more words end in `ER`.
2. If there are no vowels, try `NOISY`, `OPIUM`, or `PIOUS`. The selected consonants from the first word would normally favor one of these, but we're trying to solve this without running commands.
3. If you hit both vowels, `NYMPH`. This is way better than any other word.
4. If you hit just one of the vowels and only want to memorize one more word, it's `SCION`.
5. But if you hit the `E` only and don't think `SCION` will tell you much, `DISCO` is your backup word. Keep in mind that while `N` appears in about 50% more words than `D`, the margin narrows when the word also has an `E`. Bayes at work.
6. If you hit the `A` but not the `E`, `MINUS` works well. 

At this point much of the time you'll have enough clues to figure out the word on your third guess. If not, this is where running the above `grep` command is helpful to show which words still fit. You're in luck if there's only one. If there are two, it's a coin-flip. If it's three, you can probably pick one of them such that if it's wrong, the clues will pick the one of the other two. With more, you'll need to come up with a word **that's in the word list** that will eliminate as many candidates as possible.


