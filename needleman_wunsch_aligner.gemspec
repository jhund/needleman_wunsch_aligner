# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'needleman_wunsch_aligner/version'

Gem::Specification.new do |spec|
  spec.name          = "needleman_wunsch_aligner"
  spec.version       = NeedlemanWunschAligner::VERSION
  spec.authors       = ["Jo Hund"]
  spec.email         = ["jhund@clearcove.ca"]
  spec.summary       = %q{Find the optimal alignment of two sequences of Ruby Objects.}
  spec.homepage      = "https://github.com/jhund/needleman_wunsch_aligner"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
