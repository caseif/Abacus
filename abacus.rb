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

        opts.on("-c", "--source PATH", "Path to generated C source file") do |c|
            options[:source] = c
        end

        opts.on("-i", "--input PATH", "Path to input file") do |i|
            options[:input] = i
        end
    end.parse!

    Kernel.abort "Input path is required (-i, --input)" if options[:input].nil? and (ARGV.empty? or ARGV[0].empty?)

    options
end

def get_file_id(in_file)
    file_name = File.basename in_file

    file_id = file_name.upcase.gsub(/[^A-Z0-9_]/, "_")

    file_id = '_' + file_id if file_id[0] =~ /[0-9]/

    file_id
end

def gen_header(in_file, h_path)
    file_id = get_file_id in_file

    out_file = File.open(h_path, "w+")

    out_file.puts "#pragma once"
    out_file.puts ""
    out_file.puts "#include <stddef.h>"
    out_file.puts ""
    out_file.puts "extern const unsigned char #{file_id}_SRC[];"
    out_file.puts "extern const size_t #{file_id}_LEN;"

    out_file.close
end

def gen_source(in_file, c_path)
    file_id = get_file_id in_file
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

def gen_output(h_path, c_path, in_path)
    h_path = "#{h_path}/#{File.basename in_path}.h" if File.directory? h_path
    c_path = "#{c_path}/#{File.basename in_path}.c" if File.directory? c_path

    h_path = in_path + ".h" if h_path.nil?
    c_path = in_path + ".c" if c_path.nil?

    Kernel.abort "Input path does not point to a file" unless File.file? in_path

    Kernel.abort "Header path exists and is not a regular file" if File.exist? h_path and not File.file? h_path

    Kernel.abort "Source path exists and is not a regular file" if File.exist? c_path and not File.file? c_path

    in_file = File.open(in_path, "rb")

    gen_header(in_file, h_path)
    gen_source(in_file, c_path)
end

Kernel.abort "Buffer size must be multiple of bytes-per-line" if BUFFER_SIZE % BYTES_PER_LINE != 0

args = parse_args

in_path = args[:input] || ARGV[0]

gen_output(args[:header]&.strip, args[:source]&.strip, in_path.strip)
