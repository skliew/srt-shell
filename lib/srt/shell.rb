# encoding: utf-8
require 'srt/shell/version'
require 'srt'

module SRT
  class Shell
    SAVE_HOOK_FILE = ::File.expand_path('~/.srt_shell_hook')
    BOM_STRING = "\xEF\xBB\xBF"
    BOM_REGEX = /#{BOM_STRING}/
    USAGE_MSG = <<USAGE
Usage: #{$0} [SRT_FILENAME]
    Commands:
        EX: load 'SRT_FILENAME'
        EX: interval 90
        EX: upshift|u 50 5000
        EX: forward|f 50 5000
        EX: remove 50
        EX: save
        EX: show|s 50
        EX: search TERM
        EX: help|h
        EX: exit
USAGE

    def initialize(path = nil, save_hook=SAVE_HOOK_FILE)
      @file, @path = nil, nil
      @bom = false
      load_path(path) if path
      @save_hook = ::File.exists?(save_hook) ? save_hook : nil
    end

    def load_path(path)
      path = ::File.expand_path(path)
      @path = path

      # Test if file contains BOM
      ::File.open(path) do |file|
        lines = file.read.split("\n")
        unless lines.empty?
          if lines[0].match(BOM_REGEX)
            lines[0].sub!(BOM_REGEX, '')
            @bom = true
          end
          @file = SRT::File.parse(lines.join("\n"))
        else
          raise ArgumentError, 'Invalid SRT file'
        end
      end
      self
    end

    def show(index)
      check_index(index)
      puts @file.lines[index - 1].to_s + "\n"
    rescue IndexError => error
      puts error.message
    end

    def timeshift(index, timecode)
      check_index(index)
      if time = Parser.timespan(timecode)
        @file.lines[index-1..-1].each do |line|
          line.start_time += time
          line.end_time += time
        end
      else
        puts "Invalid timeshift input (#{index}, #{timecode})"
      end
      show(index)
    rescue IndexError => error
      puts error.message
    end

    def rewind(index, time)
      timeshift(index, "-#{time}ms")
    end

    def forward(index, time)
      timeshift(index, "+#{time}ms")
    end

    def scan_interval(input_time)
      unless time = Parser.timespan("#{input_time}ms")
        puts "Invalid time used #{input_time}"
        return
      end
      end_time = 0
      result = []
      @file.lines.each do |line|
        interval = line.start_time - end_time
        if interval >= time
          result << "index: #{line.sequence} time: #{line.time_str} gap: #{interval}"
        end
        end_time = line.end_time
      end
      puts result.join("\n")
    end

    def remove(index)
      check_index(index)
      index -= 1
      @file.lines.delete_at(index)
      @file.lines[index..-1].each do |line|
        line.sequence -= 1
      end
    rescue IndexError => error
      puts error.message
    end

    def search(term)
      result = []
      @file.lines.each do |line|
        if line.text.find { |text| text[term] }
          result << line.to_s
        end
      end
      puts result.join("\n") + "\n"
    end

    def show_all
      puts @file
    end

    def save(path=@path)
      ::File.open(path, 'w') do |file|
        file.print BOM_STRING if @bom
        file.print @file.to_s.split("\n").join("\r\n"), "\r\n\r\n"
      end
      if @save_hook
        output = `sh #{@save_hook}`
        puts output unless output.empty?
      end
    end

    def eval_command(cmd)
      case cmd
      when /^\s*(?:help|h)\s*$/
        puts USAGE_MSG
        return
      when /^\s*exit\s*$/
        exit 0
      when /^\s*load\s+\'?([^']+)\'?\s*$/
        load_path($1)
        return
      end

      if @file
        case cmd
        when /^\s*(?:show|s)\s+(\d+)\s*$/
          show($1.to_i)
        when /^\s*(?:showall)\s*$/
          show_all
        when /^\s*interval\s+(\d+)\s*$/
          scan_interval($1.to_i)
        when /^\s*(?:u|rewind)\s+(\d+)\s+(\d+)\s*$/
          rewind($1.to_i, $2.to_i)
        when /^\s*(?:f|forward)\s+(\d+)\s+(\d+)\s*$/
          forward($1.to_i, $2.to_i)
        when /^\s*(?:remove)\s+(\d+)\s*$/
          remove($1.to_i)
        when /^\s*save\s*$/
          save
        when /^\s*search\s*(.*)$/
          search($1)
        else
          puts "Invalid command"
        end
      else
        puts "File is not loaded. Load a file using the 'load' command"
      end
    end

    private

    def check_index(index)
      if index < 1
        raise IndexError, "Invalid index given, index must be more than 0"
      end
    end
  end
end
