require "highline"
require_relative "../commands/users/change_user_password"

class ChangePassword
  def initialize(ui = HighLine.new, command = ChangeUserPassword.new)
    @ui      = ui
    @command = command
  end

  def change_password
    while (password = ask_password) != (confirmation = ask_confirmation)
      @ui.say "The confirmation doesn't match the password. Please try again."
    end
    @command.change_user_password(password)
  end

  private
  def ask_password
    ask_hidden("New password: ") do |q|
      q.validate = /\A.+\Z/
      q.responses[:not_valid] = "The password can't be blank."
    end
  end

  def ask_confirmation
    ask_hidden("Confirmation: ")
  end

  def ask_hidden(question)
    @ui.ask(question) do |q|
      q.echo = "*"
      yield(q) if block_given?
    end
  end
end
