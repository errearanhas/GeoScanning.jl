# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoScanning

using GeoStatsBase
using Distances
using NearestNeighbors

import GeoStatsBase: solve

export GeoSCAN

"""
GeoSCAN(eps, minpts)
"""
struct GeoSCAN{T<:Real} <: AbstractLearningSolver
  eps::T # the radius of a point neighborhood
  minpts::Int # the minimum number of points in neighborhood to mark a point as a core point.
end


function solve(problem::LearningProblem, solver::GeoSCAN)
  eps = solver.eps
  minpts = solver.minpts

  @assert eps > 0.0 "eps must be a positive value"
  @assert minpts > 0 "minpts must be a positive integer"

  data = targetdata(problem)
  vars  = collect(keys(variables(data)))
  npts  = npoints(data)
  tdata = data[1:npts, vars]'

  kdtree = KDTree(tdata)

  # preparing variables
  n = size(tdata, 2) # assuming D as (n_features by n_samples)
  visitseq = 1:n # sequence created to index all points
  counts = Int[] # array to store quantity of points in each cluster
  assignments = zeros(Int, n) # cluster assignment vector
  visited = zeros(Bool, n) # array indicating visited points
  C = 0 # variable to mark cluster indexes

  # main loop
  for p in visitseq
    if assignments[p] == 0 && !visited[p]
      point = tdata[:,p]
      neighbs = epsRegionCheck(kdtree, point, eps)
      if length(neighbs) >= minpts
        C += 1
        assignments[p] = C
        countPoints = expandCluster!(tdata, kdtree, p, C, neighbs, eps, minpts, assignments, visited)
        push!(counts, countPoints)
        visited[p] = true
      else
        assignments[p] = -1 # marking point as noise
      end
    end
  end
  return assignments, counts
end


# function to count number of points in eps-neighborhood
function epsRegionCheck(kdtree, point, eps)
  idxs = inrange(kdtree, point, eps, true) # indexes of points in eps-neighborhood of p
end


function expandCluster!(tdata, kdtree, p, C, neighbs, eps, minpts, assignments, visited)
  countPoints = 1
  while !isempty(neighbs)
    q = pop!(neighbs)
    if !visited[q]
      visited[q] = true
      point = tdata[:,p]
      q_neighbs = epsRegionCheck(kdtree, point, eps)
      if length(q_neighbs) >= minpts
        for j in q_neighbs
          if assignments[j] == 0 || assignments[j] == -1 # check if point is unlabeled or noise
            push!(neighbs, j) # add points in q neighborhood to p neighborhood
          end
        end
      end
    end
    if assignments[q] == 0
      assignments[q] = C
      countPoints += 1
    end
  end
  countPoints
end

end # module
