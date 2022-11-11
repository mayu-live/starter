desc "Set up mayu-live for development"
task setup: [
  :bundle_update,
  :bundle_binstubs,
  :build_js,
  :create_asset_dir,
  :print_instructions,
]

task :bundle_update do
  system("bundle", "update", "mayu-live")
end

task :bundle_binstubs do
  system("bundle", "binstubs", "--force", "mayu-live")
end

task :build_js do
  require "bundler/setup"
  gem_path = Gem.loaded_specs.fetch('mayu-live').full_gem_path

  Dir.chdir(File.join(gem_path)) do
    system("npm install") or
      raise "Could not install dependencies"
    system("npm -w lib/mayu/client run build:production") or
      raise "Could not build browser runtime"
  end
end

task :create_asset_dir do
  FileUtils.mkdir_p(".assets")
end

task :print_instructions do
  puts "\e[92m#{<<~EOF}\e[0m"
    It seems like everything worked!
    Now run the following command:

        bin/mayu dev

    And then browse to https://localhost:9292/

    If you want to set up the app for deployment,
    run the following command:

        rake launch_on_fly
  EOF
end

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
