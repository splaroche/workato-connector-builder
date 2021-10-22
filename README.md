# workato-connector-builder
A tool for building Workato Connectors from multiple hash files

## Introduction
When developing complex Workato connectors, it quickly becomes difficult to contain everything in one file.
`workato-connector-builder` allows you to break your connector into logical pieces that are then merged
back together for use in Workato.

`workato-connector-builder` does two things.  First it combines all the ruby files that contain a hash at the top level together.  Then it runs the combined hash through a validator to check if there are any non-Workato supported hash keys.  If issues are found when combining, you will be provided with the option to take the first or second option, or not include the key at all.  If issues are found at the validation step, you'll be given the option to include or not include the problem key.

## Installation
You can install `workato-connector-builder` from rubygems.org

## Usage
To build a connector from the ruby files in the current directory run:

`$ workato-connector-builder build ./ output_file.rb`

To ignore files, use the `--ignored-file=<filename>` option.  To ignore more than one file, add another `--ignored-file` option.

`$ workato-connector-builder build ./ output_file.rb --ignored-file=test.rb`

To ignore directories, use the `--ignored=dir=<folder>` option.  To ignore more than one directory, add another `--ignored-dir` option.

`$ workato-connector-builder build ./ output_file.rb --ignored-dir=test/`

To find command help, use:

`$ workato-connector-builder help build`
