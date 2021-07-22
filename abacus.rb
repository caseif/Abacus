#!/usr/bin/env ruby

# This script is released under the MIT License.

require 'optparse'

BUFFER_SIZE = 4096
BYTES_PER_LINE = 16

def parse_args()
    options = {}

    OptionParser.new do |opts|
        opts.banner = "Usage: abacus.rb [options]"

        opts.on("-h", "--header PATH", "Path to generated header file") do |h|
            options[:header] = h
        end

        opts.on("-s", "--source PATH", "Path to generated C source file") do |c|
            options[:source] = c
        end

        opts.on("-i", "--input PATH", "Path to input file") do |i|
            options[:input] = i
        end

        opts.on("-n", "--name NAME", "Name of input file (including extension)") do |n|
            options[:name] = n
        end
    end.parse!

    options[:input] = ARGV[0] if options[:input].nil? and not ARGV.empty? and not ARGV[0].empty?

    Kernel.abort "Input path is required when generating source file" if not options[:source].nil? and options[:input].nil?
    Kernel.abort "Either input path or name must be provided" if options[:name].nil? and options[:input].nil?
    Kernel.abort "Header and/or source path must be provided" if options[:header].nil? and options[:source].nil?

    return options
end

def get_file_id(file_name)
    file_id = file_name.upcase.gsub(/[^A-Z0-9_]/, "_")

    file_id = '_' + file_id if file_id[0] =~ /[0-9]/

    return file_id
end

def gen_header(file_name, h_path)
    file_id = get_file_id file_name

    out_file = File.open(h_path, "w+")

    out_file.puts '#pragma once'
    out_file.puts ''
    out_file.puts '#include <stddef.h>'
    out_file.puts ''
    out_file.puts '#ifdef __cplusplus'
    out_file.puts 'extern "C" {'
    out_file.puts '#endif'
    out_file.puts ''
    out_file.puts "extern const unsigned char #{file_id}_SRC[];"
    out_file.puts "extern const size_t #{file_id}_LEN;"
    out_file.puts ''
    out_file.puts '#ifdef __cplusplus'
    out_file.puts '}'
    out_file.puts '#endif'

    out_file.close
end

def gen_source(file_name, in_file, c_path)
    file_id = get_file_id file_name
    file_len = in_file.size

    out_file = File.open(c_path, "w+")

    out_file.puts "#include <stddef.h>"
    out_file.puts ""
    out_file.puts "const unsigned char #{file_id}_SRC[] = {"

    off = 0
    while not in_file.eof?
        buf = in_file.read(BUFFER_SIZE)
        off += BUFFER_SIZE

        (0...buf.size).step(BYTES_PER_LINE) { |i|
            line_bytes = buf[i...[i + BYTES_PER_LINE, buf.size].min]
            out_line = "    "

            out_line += line_bytes.chars.map { |b|
                "0x%02X" % b.ord
            }.join(", ")

            out_line += "," unless in_file.eof? and i + BYTES_PER_LINE >= buf.size

            out_file.puts out_line
        }
    end

    out_file.puts "};"
    out_file.puts "const size_t #{file_id}_LEN = #{file_len};"

    out_file.close
end

def gen_output(h_path, c_path, in_path, in_name)
    file_name = in_name || in_path.split('/')[-1]

    full_h_path = "#{h_path}/#{file_name}.h" if not h_path.nil? and File.directory? h_path
    full_c_path = "#{c_path}/#{file_name}.c" if not c_path.nil? and File.directory? c_path

    Kernel.abort "Input path does not point to a file" unless in_path.nil? or File.file? in_path

    Kernel.abort "Header path exists and is not a regular file" if not full_h_path.nil? and File.exist? full_h_path and
            not File.file? full_h_path

    Kernel.abort "Source path exists and is not a regular file" if not full_c_path.nil? and File.exist? full_c_path and
            not File.file? full_c_path

    gen_header(file_name, full_h_path) if not full_h_path.nil?
    gen_source(file_name, File.open(in_path, "rb"), full_c_path) if not full_c_path.nil?
end

Kernel.abort "Buffer size must be multiple of bytes-per-line" if BUFFER_SIZE % BYTES_PER_LINE != 0

args = parse_args

gen_output(args[:header]&.strip, args[:source]&.strip, args[:input]&.strip, args[:name]&.strip)
