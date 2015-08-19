# -*- coding: utf-8 -*-

require "needleman_wunsch_aligner/example_paragraph_and_sentence_aligner"
require "needleman_wunsch_aligner/version"

# Finds the optimal alignment of two sequences using the Needleman-Wunsch algorithm.
# This basic implementation works with any Ruby object and just looks at object
# identity for the scoring algorithm.
#
# See ExampleParagraphAndSentenceAligner for an example of a more sophisticated
# scoring algorithm.
class NeedlemanWunschAligner

  # @param left_seq [Array<Object>] sequence drawn at left of matrix
  # @param top_seq [Array<Object>] sequence drawn at top of matrix
  def initialize(left_seq, top_seq)
    @left_seq = left_seq
    @top_seq = top_seq
  end

  # Returns two arrays that represent the optimal alignment.
  def get_optimal_alignment
    @get_optimal_alignment ||= (
      construct_score_matrix_and_traceback_matrix
      compute_optimal_alignment
    )
  end

  # This is a basic implementation of the scoring algorithm. See
  # ExampleParagraphAndSentenceAligner for a more complex scoring function.
  # @param left_el [Object]
  # @param top_el [Object]
  # @return [Numeric]
  def compute_score(left_el, top_el)
    left_el == top_el ? 1 : -3
  end

  # Returns the default penalty for a gap.
  # @return [Numeric]
  def default_gap_penalty
    -1
  end

  # Returns a sequence element to indicate a gap. Needs to be compatible with
  # other sequence elements and your scoring function.
  # @return [Object]
  def gap_indicator
    nil
  end

  # Returns a string representation of the optimal alignment in two columns.
  # @param col_width [Integer, optional] max width of each col in chars
  # @return [String]
  def inspect_alignment(col_width = 20)
    aligned_left_seq, aligned_top_seq = get_optimal_alignment
    s = []
    aligned_left_seq.each_with_index do |left_el, idx|
      top_el = aligned_top_seq[idx]
      delimiter = if elements_are_equal_for_inspection(top_el, left_el)
        '=' # match
      elsif gap_indicator == top_el
        '-' # delete
      elsif gap_indicator == left_el
        '+' # insert
      else
        '!' # mismatch
      end
      s << [
        element_for_inspection_display(left_el, col_width).rjust(col_width),
        element_for_inspection_display(top_el, col_width).ljust(col_width),
      ].join("  #{ delimiter }  ")
    end
    s.join("\n")
  end

  # Returns string representation of either the score or the traceback matrix.
  # @param which_matrix [Symbol] one of :traceback or :score
  # @param col_width [Integer, optional], defaults to 3
  # @return [String]
  def inspect_matrix(which_matrix, col_width = 3)
    get_optimal_alignment  # make sure we have computed the matrices
    the_matrix = case which_matrix
    when :traceback
      @traceback_matrix
    when :score
      @score_matrix
    else
      raise "Handle this: #{ which_matrix.inspect }"
    end

    s = ''
    s << 'left_seq = ' + @left_seq.join + "\n"
    s << 'top_seq = ' + @top_seq.join + "\n"
    s <<  "\n"
    # Header row
    s << ' ' * 2 * col_width
    @top_seq.each_index { |e| s << @top_seq[e].to_s.rjust(col_width) }
    s << "\n"

    traverse_score_matrix do |row, col|
      if 0 == col and 0 == row
        # first column in first row
        s << ' '.rjust(col_width)
      elsif 0 == col
        # first col in subsequent rows
        s << @left_seq[row - 1].to_s.rjust(col_width)
      end
      # subsequent cells
      s << the_matrix[row][col].to_s.rjust(col_width)
      # finalize row
      s << "\n" if col == the_matrix[row].length - 1
    end
    s
  end

  # Transforms element to an object that can be used for display when inspecting
  # an alignment
  # @params element [Object]
  # @return [Object]
  def element_for_inspection_display(element, col_width = nil)
    r = case element
    when String
      element
    else
      element.inspect
    end
    col_width ? r[0...col_width] : r
  end

  # Returns true if top_el and left_el are considered equal for inspection
  # purposes
  # @params top_el [Object]
  # @params left_el [Object]
  # @return [Boolean]
  def elements_are_equal_for_inspection(top_el, left_el)
    top_el == left_el
  end

protected

  def construct_score_matrix_and_traceback_matrix
    initialize_score_matrix_and_traceback_matrix
    traverse_score_matrix do |row, col|
      if 0 == row && 0 == col # top left cell
        @score_matrix[0][0] = 0
        @traceback_matrix[0][0] = 'x'
      elsif 0 == row # first row
        @score_matrix[0][col] = col * default_gap_penalty
        @traceback_matrix[0][col] = '←'
      elsif 0 == col # first col
        @score_matrix[row][0] = row * default_gap_penalty
        @traceback_matrix[row][0] = '↑'
      else # other cells
        # compute scores
        from_top = @score_matrix[row-1][col] + default_gap_penalty
        from_left = @score_matrix[row][col-1] + default_gap_penalty
        # @left_seq and @top_seq are off by 1 because we added cells for gaps in the matrix
        from_top_left = @score_matrix[row-1][col-1] + compute_score(@left_seq[row-1], @top_seq[col-1])

        # find max score and direction
        max, direction = [from_top_left, '⬉']
        max, direction = [from_top, '↑']  if from_top > max
        max, direction = [from_left, '←']  if from_left > max

        @score_matrix[row][col] = max
        @traceback_matrix[row][col] = direction
      end
    end
  end

  def compute_optimal_alignment
    row = @score_matrix.length-1
    col = @score_matrix[0].length-1
    left = Array.new
    top = Array.new
    while row > 0 or col > 0
      case @traceback_matrix[row][col]
      when '⬉'
        left.push(@left_seq[row-1])
        top.push(@top_seq[col-1])
        row -= 1
        col -= 1
      when '←'
        left.push(gap_indicator)
        top.push @top_seq[col-1]
        col -= 1
      when '↑'
        left.push @left_seq[row-1]
        top.push(gap_indicator)
        row -= 1
      else
        raise "Handle this"
      end
    end
    [left.reverse, top.reverse]
  end

  def traverse_score_matrix
    @score_matrix.each_index do |row|
      @score_matrix[row].each_index do |col|
        yield(row, col)
      end
    end
  end

  def initialize_score_matrix_and_traceback_matrix
    @score_matrix = Array.new(@left_seq.length + 1)
    @traceback_matrix = Array.new(@left_seq.length + 1)

    @score_matrix.each_index do |row|
      @score_matrix[row] = Array.new(@top_seq.length + 1)
      @traceback_matrix[row] = Array.new(@top_seq.length + 1)
    end
  end

end
