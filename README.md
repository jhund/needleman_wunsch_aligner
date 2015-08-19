# Needleman Wunsch Aligner

This gem finds the optimal alignment of two sequences of any kind of Ruby Objects. You can implement sophisticated scoring functions, using any of the Objects’ attributes.

The [Needleman-Wunsch algorithm](https://en.wikipedia.org/wiki/Needleman%E2%80%93Wunsch_algorithm) is typically used in bioinformatics to align protein or nucleotide sequences, however it works really well for any kind of sequence. I have used this gem to align paragraphs and sentences of pairs of bilingual texts.

Given two sequences

    seq1 = 'GCATGCU'
    seq2 = 'GATTACA'

The algorithm will find the optimal alignment based on a scoring function you specify:

    GCATG-CU
    =+==!-=!
    G-ATTACA

Meaning of the symbols:

    = Match
    ! Mismatch
    + Insert
    - Deletion

Insert and Deletion are usually grouped together as `IndDel`.

## Installation

Add this line to your application's Gemfile:

    gem 'needleman_wunsch_aligner'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install needleman_wunsch_aligner

## Usage

Instantiate a new aligner with the two sequences and compute the optimal alignment:

    require 'needleman_wunsch_aligner'

    aligner = NeedlemanWunschAligner.new([1,2,3], [2,3,4])
    aligner.get_optimal_alignment
    # => [[1, 2, 3, nil], [nil, 2, 3, 4]]

Inspect the alignment:

    puts aligner.inspect_alignment

    # =>   1 | nil
           2 | 2
           3 | 3
         nil | 4

Inspect the score table:

    puts aligner.inspect_matrix(:score)
    # =>            2   3   4
                0  -1  -2  -3
            1  -1  -2  -3  -4
            2  -2   0  -1  -2
            3  -3  -1   1   0

Inspect the traceback table:

    puts aligner.inspect_matrix(:traceback)
    # =>            2   3   4
                x   ←   ←   ←
            1   ↑   ↑   ↑   ↑
            2   ↑   ⬉   ←   ←
            3   ↑   ↑   ⬉   ←

## Customization

The gem comes with a very basic scoring function. You can implement much more
sophisticated ones by subclassing the `NeedlemanWunschAligner` class and overriding the following instance methods:

* `compute_score`
* `default_gap_penalty`
* `gap_indicator`

Please see `NeedlemanWunschAligner::ExampleParagraphAndSentenceAligner` for an
example.

You can also override these methods which are related to `#inspect_alignment`:

* `element_for_inspection_display`
* `elements_are_equal_for_inspection`

## Contributing

1. Fork it ( https://github.com/jhund/needleman_wunsch_aligner/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Resources

* [Source code (github)](https://github.com/jhund/needleman_wunsch_aligner)
* [Issues](https://github.com/jhund/needleman_wunsch_aligner/issues)
* [Rubygems.org](http://rubygems.org/gems/needleman_wunsch_aligner)

[![Build Status](https://travis-ci.org/jhund/needleman_wunsch_aligner.svg?branch=master)](https://travis-ci.org/jhund/needleman_wunsch_aligner)

### License

[MIT licensed](https://github.com/jhund/needleman_wunsch_aligner/blob/master/LICENSE.txt).

### Copyright

Copyright (c) 2015 Jo Hund. See [(MIT) LICENSE](https://github.com/jhund/needleman_wunsch_aligner/blob/master/LICENSE.txt) for details.
