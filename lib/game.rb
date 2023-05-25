require_relative 'player'
require 'awesome_print'
require 'json'
require 'Date'

class Game
  attr_accessor :guest_word, :player, :used_letters, :remaining_turns, :correct_guesses
  def initialize
    @guest_word = []
    @correct_guesses = []
    @used_letters = []
    @remaining_turns = 7
    @player = Player.new
  end

  def start
    #ask user if he wants to start
    puts 'Load(L) or Start new game(Y)? L/Y/N:'
    userchoice = gets.chomp.downcase
    return unless ['y', 'l'].include? userchoice

    userchoice == 'l' ? loadgame : new_game
    p guest_word #remove after finishing

    until remaining_turns < 1 || guest_word == correct_guesses
      player_guess = player.give_guest_letter
      if correct_letter_guess?(player_guess)
        update_revealed_letters(player_guess)
      else
        self.remaining_turns -= 1
      end
      used_letters << player_guess

      update_display
      save_game? ? break : next
    end
  end

  private

  def get_random_word(file)
    #filter only five to seven words
    chomped = file.readlines.map(&:chomp)
    filtered_words = chomped.select{|line| line.chomp.length > 4}

    random_word = filtered_words[rand(0..filtered_words.length-1)].downcase
  end

  def correct_letter_guess?(guest_letter)
    return false if used_letters.include?(guest_letter)
    (guest_word.include? guest_letter) ? true : false
  end

  def update_revealed_letters(guest_letter)
    guest_word.each_with_index do |letter, index|
      self.correct_guesses[index] = guest_letter if (letter == guest_letter)
    end
  end

  def update_display
    system('clear') || system('cls')
    display_hangman(remaining_turns)
    p correct_guesses.join(' ')
  end

  def display_hangman(remaining_turns)
    return if remaining_turns == 7
    stickman = [" |-----~\\|-\n"," O\n", "/", "|", "\\\n", "/", " \\\n"]

    displayindex = 7 - remaining_turns

    puts stickman.slice(0, displayindex).join()
  end

  def save_game?
    return if remaining_turns < 1
    p 'Do you want to save here?'
    return false if gets.chomp.downcase != 'y'

    save_to_file(DateTime.now.strftime('%y-%h-%d_%H:%M'))
    true
  end

  def save_to_file(filename)
    Dir.mkdir('saved_games') unless Dir.exists?('saved_games')

    File.open("saved_games/#{filename}", 'w') do |file|
      file <<
        { guest_word: guest_word,
          correct_guesses: correct_guesses,
          used_letters: used_letters,
          remaining_turns: remaining_turns
        }.to_json
    end
  end

  def loadgame
    saved_games = Dir['saved_games/*']
    return new_game if saved_games.empty?

    p "Choose your saved game, enter corresponding number:"
    saved_games.each_with_index do |saved, index|
      p "#{index + 1}: #{saved.split('/').last}"
    end
    userinput = gets.chomp.to_i
    filename = saved_games[userinput - 1]

    File.open(filename, 'r') do |file|
      parsed = JSON.parse(file.readline)
      self.guest_word = parsed["guest_word"]
      self.correct_guesses = parsed["correct_guesses"]
      self.used_letters = parsed["used_letters"]
      self.remaining_turns = parsed["remaining_turns"]
    end
  end

  def new_game
    p "Starting a NEW GAME!"
    self.guest_word = get_random_word(File.open('assets/words.txt','r')).split('')
    self.correct_guesses = Array.new(guest_word.length, '_')
  end
end
