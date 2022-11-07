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

        rake setup_fly
  EOF
end

desc "Set up app for deployment on fly.io"
task :setup_fly do
  fly_toml = "fly.toml"
  fly_cmd = "flyctl"

  if File.exist?(fly_toml)
    puts "\e[1mfly.toml\e[0m already exists!"
    exit 1
  end

  require "shellwords"

  unless system(Shellwords.shelljoin(["which", fly_cmd]) + " > /dev/null")
    puts "Could not find #{fly_cmd} in $PATH"
    exit 1
  end

  require "bundler/setup"

  full_gem_path = Gem.loaded_specs.fetch('mayu-live') do
    puts <<~EOF
      Could not find gem location for mayu-live

      Did you run \e[1mrake setup\e[0m first?
    EOF
    exit 1
  end.full_gem_path

  unless File.exist?(File.join(full_gem_path, "lib", "mayu", "client", "dist", "entries.json"))
    puts <<~EOF
      It seems like the mayu browser runtime has not been built.

      Did you run \e[1mrake setup\e[0m first?
    EOF
    exit 1
  end

  require "json"
  require "securerandom"

  puts "Creating app..."

  output = `#{Shellwords.shelljoin([fly_cmd, "apps", "create", "--generate-name", "--json"])}`

  unless $?.success?
    puts "Could not create fly app!"
    exit 1
  end

  app_name = JSON.parse(output).fetch("ID") do
    puts "Could not get ID from `#{fly_cmd} apps create` output"
    exit 1
  end

  puts
  puts "\e[1m#{fly_toml}\e[0m will now be written for app \e[1m#{app_name}\e[0m"

  File.write(
    fly_toml,
    File.read(".fly.template.toml").gsub("YOUR_APP_NAME", app_name)
  )

  puts
  puts "Setting MAYU_SECRET_KEY to something long and random..."

  system(
    Shellwords.shelljoin([
      fly_cmd, "secrets", "set",
      "-a", app_name,
      "MAYU_SECRET_KEY=#{SecureRandom.alphanumeric(128)}"
    ]) + " > /dev/null"
  ) or begin
    puts "Could not set secret key!"
    exit 1
  end

  puts

  if ask?("Do you want to deploy now?")
    puts "Deploying app \e[1m\e[0m"
    puts

    system(fly_cmd, "deploy", "--detach") or begin
      puts "Deployment failed!"
      exit 1
    end

    puts

    puts <<~EOF
      The app was deployed to \e[1;34mhttps://#{app_name}.fly.dev/\e[0m

      To view app status, type:

          \e[31m#{fly_cmd} status -a #{app_name} --watch\e[0m
    EOF
  else
    puts
    puts <<~EOF
      To deploy the app, type:

          #{fly_cmd} deploy
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
