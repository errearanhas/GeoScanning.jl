# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoScanning

using GeoStatsBase
using NearestNeighbors

import GeoStatsBase: solve

export GeoSCAN

"""
GeoSCAN(eps, minpts)
"""
struct GeoSCAN{T<:Real} <: AbstractLearningSolver
  eps::T # radius of a point neighborhood
  minpts::Int # minimum number of points in neighborhood to mark a point as a core point.
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
  DB = 1:npts # sequence created to index all database points
  label = zeros(Int, npts) # cluster label assignment vector
  C = 0 # variable to mark cluster indexes

  # main loop
  for p in DB
    if label[p] != 0 # checking if there is a cluster label assigned to the point
      continue
    end
    neighbs = RangeQuery(kdtree, p, eps, tdata)
    if length(neighbs) < minpts
      label[p] = -1 # marking point as noise
      continue
    end
    C += 1
    label[p] = C
    deleteat!(neighbs, neighbs .== p)
    while !isempty(neighbs)
      q = pop!(neighbs)
      if label[q] == -1
        label[q] = C
      end
      if label[q] !== 0
        continue
      end
      q_neighbs = RangeQuery(kdtree, q, eps, tdata)
      label[q] = C
      if length(q_neighbs) < minpts
        continue
      end
      for j in q_neighbs
        push!(neighbs, j)
      end
    end
  end
  @assert length(label) == npts "number of assigned points must be equal to the total number of data points"
  return label
end


# function to get indexes of points in eps-neighborhood
function RangeQuery(kdtree, p, eps, tdata)
  point = tdata[:,p]
  idxs = inrange(kdtree, point, eps, true) # indexes of points in eps-neighborhood of p
end

end # module
