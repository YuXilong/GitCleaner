# frozen_string_literal: true

require_relative "GitCleaner/version"
require 'runner'

cleaner = Runner.new(ARGV)
cleaner.run
