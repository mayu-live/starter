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
  system("bundle", "binstubs", "mayu-live")
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
  puts <<~EOF
  It seems like everything worked!
  Now run the following command:

      bin/mayu dev

  And then browse to https://localhost:9292/
  EOF
end
