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
    construct_score_matrix_and_traceback_matrix
    compute_optimal_alignment
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

  # Prints the optimal alignment.
  # @param col_width [Integer, optional] max width of each col in chars
  def print_alignment(col_width = 20)
    aligned_left_seq, aligned_top_seq = get_optimal_alignment
    puts
    aligned_left_seq.each_with_index do |ls_el, idx|
      rs_el = aligned_top_seq[idx]
      puts [
        ls_el.inspect[0..col_width].rjust(col_width),
        rs_el.inspect[0..col_width].ljust(col_width),
      ].join(' | ')
    end
  end

  # Prints either the score or the traceback matrix as table.
  # @param which_matrix [Symbol] one of :traceback or :score
  # @param col_width [Integer, optional], defaults to 3
  def print_as_table(which_matrix, col_width = 3)
    get_optimal_alignment  if @score_matrix.nil?
    the_matrix = case which_matrix
    when :traceback
      @traceback_matrix
    when :score
      @score_matrix
    else
      raise "Handle this: #{ which_matrix.inspect }"
    end

    puts
    puts 'left_seq = ' + @left_seq.join
    puts 'top_seq = ' + @top_seq.join
    puts
    print ' ' * 2 * col_width

    # Print header row
    @top_seq.each_index { |e| print(@top_seq[e].to_s.rjust(col_width)) }

    puts ''
    traverse_score_matrix do |row, col|
      if 0 == col and 0 == row
        # first column in first row
        print ' '.rjust(col_width)
      elsif 0 == col
        # first col in subsequent rows
        print @left_seq[row - 1].to_s.rjust(col_width)
      end
      print the_matrix[row][col].to_s.rjust(col_width)
      puts '' if col == the_matrix[row].length - 1
    end
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
      if @traceback_matrix[row][col] == '⬉'
        left.push(@left_seq[row-1])
        top.push(@top_seq[col-1])
        row -= 1
        col -= 1
      elsif @traceback_matrix[row][col] == '←'
        left.push(gap_indicator)
        top.push @top_seq[col-1]
        col -= 1
      elsif @traceback_matrix[row][col] == '↑'
        left.push @left_seq[row-1]
        top.push(gap_indicator)
        row -= 1
      else
        puts "something strange happened" # this shouldn't happen
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
