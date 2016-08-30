### 1.1.0

* Changed #compute_score method params: Added row and column index for performance optimizations where I may not want to compute scores for the entire matrix, but only for a narrow band around the diagonal. The width of the band is determined by the maximum expected alignment offset.

### 1.0.4

* Added overridable methods for `#inspect_alignment`

### 1.0.3

* Improved #inspect_alignment output.

### 1.0.2

* Memoized computation of optimal alignment for better performance.

### 1.0.1

* Added travis CI integration.
* Fixed UTF-8 encoding issues for Ruby 1.9.
* Added minitest Gem for Ruby 2.2.
* Updated documentation.
* Changed return value of inspect methods.

# 1.0.0

Initial release
