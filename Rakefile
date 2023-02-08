desc "Launch the app on fly.io"
task :launch_on_fly do
  require "securerandom"
  require "shellwords"

  flyctl = "flyctl"

  unless system(Shellwords.shelljoin(["which", flyctl]) + " > /dev/null")
    puts "Could not find #{flyctl} in $PATH"
    exit 1
  end

  system(flyctl, "launch", "--copy-config", "--no-deploy") or begin
    puts "Could not launch app!"
    exit 1
  end

  system(
    Shellwords.shelljoin([
      flyctl, "secrets", "set",
      "MAYU_SECRET_KEY=#{SecureRandom.alphanumeric(128)}"
    ]) + " > /dev/null"
  ) or begin
    puts "Could not set secret key!"
    exit 1
  end

  if ask?("Do you want to deploy now?")
    puts "Deploying app"
    puts

    system(flyctl, "deploy")
  else
    puts <<~EOF

      To deploy the app, type:

      #{flyctl} deploy
    EOF
  end
end

def ask?(question)
  require "io/console"

  loop do
    $stdout.print "#{question.strip} (y/n) "
    $stdout.flush

    case $stdin.getch.downcase
    when "y"
      puts
      return true
    when "n"
      puts
      return false
    end

    puts
  end
end
