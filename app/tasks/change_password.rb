require "io/console"

require_relative "../commands/users/change_user_password"

class ChangePassword
  def initialize(command = ChangeUserPassword.new)
    @command = command
  end

  def change_password
    while (password = ask_password) != (confirmation = ask_confirmation)
      puts "The confirmation doesn't match the password. Please try again."
    end
    @command.change_user_password(password)
  end

  private

  def ask_password
    ask_hidden("New password: ")
  end

  def ask_confirmation
    ask_hidden("Confirmation: ")
  end

  def ask_hidden(question)
    print(question)
    input = STDIN.noecho(&:gets).chomp
    puts
    input
  end
end
