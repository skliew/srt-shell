# SRT::Shell

An interactive shell to retime SRT files.

## Installation

For now you can only install this by cloning the repo, and then run the following commands:

```shell
bundle install
rake install
```
## Usage

Start the shell with the command:

```shell
srt-shell
```

You could also optionally pass in an SRT file's path as an argument:
```shell
srt-shell file.srt
```

## Commands

In the shell, the commands available will be shown with the 'help' command:
```shell
help
```

#### load '[filename]'
Load an SRT file.

### exit
Exit the shell

###### The following commands can only be used when we already have an SRT file loaded.
###### Do note that all indexes start from 1, not 0.

#### interval [time in ms]
This would scan the SRT file for time gaps larger than the given time in ms. This is useful to search for indexes to be used with the time-shifting commands.

#### upshift|u [index] [time in ms]
Rewind the given time in ms for lines from index onwards.

#### forward|f [index] [time in ms]
Forward the given time in ms for lines from index onwards.

#### remove [index]
Remove line with the given index

#### save
Save (overwrite) the SRT file.

#### search [word]
Search for the given word in the SRT file and print out the entries that contain the word.

## Contributing

1. Fork it ( https://github.com/darkgrin/srt-shell/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
