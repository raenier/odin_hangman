class Player
  def give_guest_letter
    puts "Enter letter: "
    input = gets.chomp
    return give_guest_letter if input.length > 1 || input_num?(input)
    input.downcase
  end

  private

  def input_num?(input)
    true if Float(input) rescue false
  end
end
