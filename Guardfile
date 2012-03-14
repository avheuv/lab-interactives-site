ignore_paths 'bin', 'examples', 'lab', 'node_modules'

# FireSass allows Firebug to display the original Sass filename
# and line number of Sass-generated CSS styles
# https://github.com/nex3/firesass
FIRESASS = false

system("make")
puts <<HEREDOC

ready ...

HEREDOC

def command(cmd)
  puts cmd
  system(cmd)
end

require './src/bourbon/lib/bourbon.rb'

guard 'sass',         :input => 'src/examples', :output => 'dist/examples', :all_on_start => false
guard 'coffeescript', :input => 'src/examples', :output => 'dist/examples', :all_on_start => false
guard 'haml',         :input => 'src', :output => 'dist', :all_on_start => false do
  watch %r{^src.+(\.html\.haml)}
end

guard 'haml',         :input => 'test', :output => 'test', :all_on_start => false do
  watch %r{^test.+(\.html\.haml)}
end

guard 'shell' do
  watch(%r{(src\/lab\/.+)|(src\/md-engine\/.+)}) do |match|
    puts match[0]
    puts "re-generating javascript libraries and css resources for these libraries ..."
    command("make")
    command("make test")
  end
  watch("src/index.sass") do
    command("bin/sass -r ./src/bourbon/lib/bourbon.rb src/index.sass dist/index.css")
  end
  watch(%r{test\/.+\.js$}) do
    system("make test")
  end
  watch(%r{^(src/examples/[^.].+)$}) do |match|
    unless match[0][/(\.haml)|(\.sass)|(\.coffee)|(^\..+)$/]
      source_path = match[0]
      destination_path = 'dist/' + source_path[/src\/(.+?)$/, 1]
      command("cp -f #{source_path} #{destination_path}")
    end
  end
  watch(%r{^(src/resources/.+)$}) do |match|
    source_path = match[0]
    destination_path = "dist/#{source_path}"
    command("cp -f #{source_path} #{destination_path}")
  end
  watch(%r{^src/(tests/.+)$}) do |match|
    source_path = match[0]
    destination_path = "dist/#{match[1]}"
    command("cp -f #{source_path} #{destination_path}")
  end
end

# , :api_version => '1.6', :port => '35728'
guard 'livereload' do
  watch(%r{(dist/).+\.(css|js|html)})
end

guard 'markdown', :kram_ops => { :toc_levels => [2,3,4,5] } do
  watch("readme.md") do |m|
    "readme.md|dist/readme.html|src/layouts/readme.html.erb"
  end
  watch("license.md") do |m|
    "license.md|dist/license.html|src/layouts/license.html.erb"
  end
end
