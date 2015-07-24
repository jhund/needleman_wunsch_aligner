# -*- coding: utf-8 -*-

require 'spec_helper'
require 'needleman_wunsch_aligner'
require 'needleman_wunsch_aligner/example_paragraph_and_sentence_aligner'
require 'pp'

class NeedlemanWunschAligner

  # Container for test data
  class TestData

    def self.sequence_a
      [
        { type: :paragraph, id: 1 },
        { type: :sentence, id: nil },
        { type: :sentence, id: nil },
        { type: :sentence, id: nil },
        { type: :paragraph, id: 2 },
        { type: :sentence, id: nil },
        { type: :sentence, id: nil },
        { type: :paragraph, id: 3 },
        { type: :sentence, id: nil },
        { type: :sentence, id: nil },
        { type: :sentence, id: nil },
        { type: :sentence, id: nil },
      ]
    end

    def self.sequence_b
      [
        { type: :paragraph, id: nil },
        { type: :sentence, id: nil },
        { type: :paragraph, id: 1 },
        { type: :sentence, id: nil },
        { type: :sentence, id: nil },
        { type: :paragraph, id: 2 },
        { type: :sentence, id: nil },
        { type: :sentence, id: nil },
        { type: :sentence, id: nil },
        { type: :sentence, id: nil },
        { type: :paragraph, id: 3 },
        { type: :sentence, id: nil },
        { type: :sentence, id: nil },
        { type: :sentence, id: nil },
      ]
    end

    def self.optimal_alignment
      [
        [
          { type: :gap },
          { type: :gap },
          { type: :paragraph, id: 1 },
          { type: :sentence, id: nil },
          { type: :sentence, id: nil },
          { type: :sentence, id: nil },
          { type: :paragraph, id: 2 },
          { type: :gap },
          { type: :gap },
          { type: :sentence, id: nil },
          { type: :sentence, id: nil },
          { type: :paragraph, id: 3 },
          { type: :sentence, id: nil },
          { type: :sentence, id: nil },
          { type: :sentence, id: nil },
          { type: :sentence, id: nil },
        ],
        [
          { type: :paragraph, id: nil },
          { type: :sentence, id: nil },
          { type: :paragraph, id: 1 },
          { type: :gap },
          { type: :sentence, id: nil },
          { type: :sentence, id: nil },
          { type: :paragraph, id: 2 },
          { type: :sentence, id: nil },
          { type: :sentence, id: nil },
          { type: :sentence, id: nil },
          { type: :sentence, id: nil },
          { type: :paragraph, id: 3 },
          { type: :gap },
          { type: :sentence, id: nil },
          { type: :sentence, id: nil },
          { type: :sentence, id: nil },
        ]
      ]
    end

  end

  describe ExampleParagraphAndSentenceAligner do

    let(:sequence_a){ TestData.sequence_a }
    let(:sequence_b){ TestData.sequence_b }
    let(:optimal_alignment){ TestData.optimal_alignment }
    let(:aligner){ ExampleParagraphAndSentenceAligner.new(sequence_a, sequence_b) }

    describe "#get_optimal_alignment" do

      it "returns the optimal_alignment" do
        r = aligner.get_optimal_alignment
        r.must_equal(optimal_alignment)
      end

    end

    describe "#compute_score" do

      # Test matrix:
      #         p/1   p/2   p/nil s/a   s/b   s/nil
      #  p/1    25    -25   -25   -250  -250  -250
      #  p/2          25    -25   -250  -250  -250
      #  p/nil              25    -250  -250  -250
      #  s/a                      10    -10   -10
      #  s/b                            10    -10
      #  s/nil                                10

      [
        [{ type: :paragraph, id: 1 }, { type: :paragraph, id: 1 }, 25],
        [{ type: :paragraph, id: 1 }, { type: :paragraph, id: 2 }, -25],
        [{ type: :paragraph, id: 1 }, { type: :paragraph, id: nil }, -25],
        [{ type: :paragraph, id: 1 }, { type: :sentence, id: :a }, -250],
        [{ type: :paragraph, id: 1 }, { type: :sentence, id: :b }, -250],
        [{ type: :paragraph, id: 1 }, { type: :sentence, id: nil }, -250],

        [{ type: :paragraph, id: 2 }, { type: :paragraph, id: 2 }, 25],
        [{ type: :paragraph, id: 2 }, { type: :paragraph, id: nil }, -25],
        [{ type: :paragraph, id: 2 }, { type: :sentence, id: :a }, -250],
        [{ type: :paragraph, id: 2 }, { type: :sentence, id: :b }, -250],
        [{ type: :paragraph, id: 2 }, { type: :sentence, id: nil }, -250],

        [{ type: :paragraph, id: nil }, { type: :paragraph, id: nil }, 25],
        [{ type: :paragraph, id: nil }, { type: :sentence, id: :a }, -250],
        [{ type: :paragraph, id: nil }, { type: :sentence, id: :b }, -250],
        [{ type: :paragraph, id: nil }, { type: :sentence, id: nil }, -250],

        [{ type: :sentence, id: :a }, { type: :sentence, id: :a }, 10],
        [{ type: :sentence, id: :a }, { type: :sentence, id: :b }, -10],
        [{ type: :sentence, id: :a }, { type: :sentence, id: nil }, -10],

        [{ type: :sentence, id: :b }, { type: :sentence, id: :b }, 10],
        [{ type: :sentence, id: :b }, { type: :sentence, id: nil }, -10],

        [{ type: :sentence, id: nil }, { type: :sentence, id: nil }, 10],
      ].each do |(left_el, right_el, xpect)|

        it "handles #{ left_el.inspect }:#{ right_el.inspect }" do
          aligner.send(:compute_score, left_el, right_el).must_equal(xpect)
        end

      end
    end

    describe "#default_gap_penalty" do

      it 'returns the expected value' do
        aligner.send(:default_gap_penalty).must_equal(-10)
      end

    end

  end
end
