require_relative 'player'
require 'awesome_print'

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
    puts 'Start game? Y/N:'
    return if gets.chomp.downcase != 'y'


    self.guest_word = get_random_word(File.open('assets/words.txt','r')).split('')
    self.correct_guesses = Array.new(guest_word.length, '_')
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
    p remaining_turns
    p used_letters
    p correct_guesses.join(' ')
  end
end
