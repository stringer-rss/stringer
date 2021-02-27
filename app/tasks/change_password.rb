require "io/console"

require_relative "../commands/users/change_user_password"

class ChangePassword
  def initialize(command = ChangeUserPassword.new, output: $stdout, input: $stdin)
    @command = command
    @output = output
    @input = input
  end

  def change_password
    while (password = ask_password) != ask_confirmation
      @output.puts "The confirmation doesn't match the password. Please try again."
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
    @output.print(question)
    user_input = $stdin.noecho { @input.gets }.chomp
    @output.puts
    user_input
  end
end
