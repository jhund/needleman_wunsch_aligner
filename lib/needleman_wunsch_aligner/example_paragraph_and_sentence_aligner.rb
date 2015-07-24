class NeedlemanWunschAligner
  class ExampleParagraphAndSentenceAligner < NeedlemanWunschAligner

    # Get score for alignment pair of paragraphs and sentences. Aligner prioritizes
    # alignment of paragraphs over that of sentences.
    #
    #         p/1   p/2   p/nil s/a   s/b   s/nil
    #  p/1    25    -25   -25   -250  -250  -250
    #  p/2          25    -25   -250  -250  -250
    #  p/nil              25    -250  -250  -250
    #  s/a                      10    -10   -10
    #  s/b                            10    -10
    #  s/nil                                10
    #
    # param left_el [Hash]
    # param top_el [Hash]
    # return [Integer]
    def compute_score(left_el, top_el)
      score = 0
      if left_el[:type] == top_el[:type]
        # Match on type (paragraph vs. sentence)
        case left_el[:type]
        when :paragraph
          score += left_el[:id] == top_el[:id] ? 25 : -25
        when :sentence
          score += left_el[:id] == top_el[:id] ? 10 : -10
        else
          raise "Handle this: #{ [left_el, top_el].inspect }"
        end
      elsif [left_el, top_el].any? { |e| :paragraph == e[:type] }
        # Difference in type, one is :paragraph. This is more significant
        # than sentences.
        score += -250
      else
        raise "Handle this: #{ [left_el, top_el].inspect }"
      end
      score
    end

    def default_gap_penalty
      -10
    end

    def gap_indicator
      { type: :gap }
    end

  end
end
