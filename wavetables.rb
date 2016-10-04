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
elsif ARGV.size < 3
  $stderr.puts <<-END
  Usage: ruby wavetables.rb file1.wav file2.wav outfilename
  END
  exit 1
else
  missing_files = ARGV.first(2).select {|f| !File.file?(f) }
  unless missing_files.empty?
    $stderr.puts <<-END
      Missing files: #{missing_files.join(", ")}
    END
    exit 1
  end

  file1 = ARGV[0]
  file2 = ARGV[1]
  outfilename = ARGV[2]
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
  size = $1
  outfile = "#{wt_dir}/#{outfilename}_#{size}.wav"
  count = 0
  until !File.file?(outfile)
    count += 1
    outfile = "#{wt_dir}/#{outfilename}#{count}_#{size}.wav"
  end
  `sfedit join #{interpolations_dir}/output*.wav #{outfile}  -w0`
  puts "File written to #{outfile}"
end
