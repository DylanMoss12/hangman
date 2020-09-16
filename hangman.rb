require 'pry'
require 'json'
class Game
  def initialize
    puts 'Would you like to resume from a save? (yes/no)'
    answer = false
    while answer == false
      response = gets.chomp.downcase
      if response == 'yes' || response == 'no'
        answer = true
      else
        puts 'Please answer yes or no'
      end
    end
    if response == 'yes'
      get_from_save
      @win = false
      print "\n \n"
      print_array(@hidden_word)
      print "\n"
      print "Used Letters: "
      print_array_spaces(@used_letters) 
      print "\n"
      print "Lives: #{@lives} \n"
    else
      puts 'What is your name?'
      @name = gets.chomp
      @used_letters = []
      @lives = 7
      @win = false
      random_word
      line_creator
    end
  end

  def random_word
    length = false
    while length == false
      num = rand(1..61406)
      lines = File.readlines("5desk.txt")
      word = lines[num].chomp
      if word.length > 4 && word.length < 13
        length = true
      end
    end
    @word = word
  end

  def line_creator
    @length = @word.length
    @hidden_word = Array.new(@length, '_')
  end

  def get_guess
    input = false
    while input == false
      print 'Pick a letter: '
      letter = gets.chomp.downcase
      if letter == 'save'
        save_to_file
      elsif letter.length == 1 && letter.match(/[a-z]/) && !@used_letters.include?(letter)
        @guess = letter
        input = true
      else
        puts 'This is not an available letter'
      end
    end
  end

  def checker
    locations = []
    if @word.include?(@guess)
      i = -1
      while i = @word.index("#{@guess}", i + 1)
        locations << i
      end
      length = locations.length
      j = 0
      while j < length
        @hidden_word[locations[j]] = @guess
        j += 1
      end
    else
      @lives -= 1
    end
    @used_letters << @guess
  end

  def win_check
    if !@hidden_word.include?('_')
      @win = true
    else
      @win = false
    end
  end

  def print_array(array)
    length = array.length
    i = 0
    while i < length
      print array[i]
      i += 1
    end
  end

  def print_array_spaces(array)
    length = array.length
    i = 0
    while i < length
      print array[i], " "
      i += 1
    end
  end

  def play
    while @win == false && @lives > 0
      get_guess
      print "\n \n"
      checker
      win_check
      print_array(@hidden_word)
      print "\n"
      print "Used Letters: "
      print_array_spaces(@used_letters) 
      print "\n"
      print "Lives: #{@lives} \n"
    end
    if @win == false
      puts "You lost, the word was #{@word}."
    else
      puts "Yay #{@name}, you guessed the word!"
    end
  end

  def save_to_file
    @serialize_hash = {
      name: @name,
      word: @word,
      hidden_word: @hidden_word,
      used_letters: @used_letters,
      lives: @lives
    }
    saved_file = File.open('saved_file.txt', 'w')
    saved_file.puts(@serialize_hash.to_json)
    saved_file.close
  end

  def get_from_save
    saved_file = File.open('saved_file.txt').read
    hash = JSON.parse(saved_file)
    @name = hash['name']
    @word = hash['word']
    @hidden_word = hash['hidden_word']
    @used_letters = hash['used_letters']
    @lives = hash['lives']
  end
end

game = Game.new
game.play