# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

#     Reference
#     ----------
#     Ester, M., H. P. Kriegel, J. Sander, and X. Xu, "A Density-Based
#     Algorithm for Discovering Clusters in Large Spatial Databases with Noise".
#     In: Proceedings of the 2nd International Conference on Knowledge Discovery
#     and Data Mining, Portland, OR, AAAI Press, pp. 226-231. 1996

module GeoScanning

import GeoStatsBase
export GeoSCAN

"""
GeoSCAN(eps, minpts)
"""
struct GeoSCAN{T<:Real} <: AbstractLearningSolver
  eps::T # the radius of a point neighborhood
  minpts::Int # the minimum number of points in neighborhood to mark a point as a core point.
end

function solve(problem::LearningProblem, solver::GeoSCAN)
end # module


function GeoSCAN(D::DenseMatrix{Real}, eps::Real, minpts::Int)
  @assert eps > 0.0 "eps must be a positive value"
  @assert minpts > 0 "minpts must be a positive integer"

# prepare
  n = size(D, 1) # assuming D as a square distance matrix (n_samples by n_samples)
  visitseq = 1:n # sequence created to index all points
  assignments = zeros(Int, n) # cluster assignment vector
  visited = zeros(Bool, n) # array indicating visited points
  C = 0 # variable to mark cluster indexes

  # main loop
  for p in visitseq
      if assignments[p] == 0 && !visited[p]
          visited[p] = true
          neighbs = eps_region_check(D, p, eps)
          if length(neighbs) >= minpts



          end
      end
  end
end


function eps_region_check(D::DenseMatrix{Float64}, p::Int, eps::Real)
    n = size(D,1)
    neighbs = Int[]
    distances = view(D,:,p) # array of distances of all points wrt point p
    for i = 1:n
        if distances[i] < eps
            push!(neighbs, i)
        end
    end
    neighbs # indexes of points in eps-neighborhood of p
end
