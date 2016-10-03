require "fileutils"

if ENV['random']
  random_dir = File.expand_path ENV['random']
  unless File.directory?(random_dir)
    $stderr.puts "Unable to find source directory #{random_dir}"
    exit 1
  end
  candidates = Dir[random_dir + "/**/*.wav"].shuffle
  unless candidates.size > 1
    $stderr.puts "Source directory #{random_dir} must have at least 2 audio files"
    exit 1
  end
  file1 = candidates[0]
  file2 = candidates[1]

  outfilename = ARGV[0]
  unless outfilename
    $stderr.puts "Please pass in an output file name"
    exit 1
  end
elsif ARGV.size < 2
  $stderr.puts <<-END
  Please pass in at least two audio files.
  Example: ruby wavetables.rb file1 file2
  END
  exit 1
else
  missing_files = ARGV.select {|f| !File.file?(f) }
  unless missing_files.empty?
    $stderr.puts <<-END
      Missing files: #{missing_files.join(", ")}
    END
    exit 1
  end

  file1 = ARGV[0]
  file2 = ARGV[1]
end

gen_dir = "_gen"
FileUtils.mkdir(gen_dir) unless File.directory?(gen_dir)
interpolations_dir = "#{gen_dir}/interpolations"
FileUtils.rm_rf interpolations_dir
FileUtils.mkdir_p interpolations_dir
wt_dir = "#{gen_dir}/wavetables"
FileUtils.mkdir(wt_dir) unless File.directory?(wt_dir)
`submix inbetween 1 "#{file1}" "#{file2}" #{interpolations_dir}/output 128`
if `sndinfo props #{interpolations_dir}/output001.wav` =~ /^samples\:.* (\d+)$/
  outfilename ||= "wt"
  outfile = "#{wt_dir}/#{outfilename}_#{$1}.wav"
  if File.file?(outfile)
    $stderr.puts "Unable to create #{outfile}: file already exists"
    exit 1
  end
  `sfedit join #{interpolations_dir}/output*.wav #{outfile}  -w0`
  puts "File written to #{outfile}"
end
