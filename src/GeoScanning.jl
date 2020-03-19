# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoScanning

using GeoStatsBase: LearningProblem, AbstractLearningSolver
import Distances
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

  D = calcDistances(problem)

  # preparing variables
  n = size(D, 1) # assuming D as a square distance matrix (n_samples by n_samples)
  visitseq = 1:n # sequence created to index all points
  counts = Int[] # array to store quantity of points in each cluster
  assignments = zeros(Int, n) # cluster assignment vector
  visited = zeros(Bool, n) # array indicating visited points
  C = 0 # variable to mark cluster indexes

  # main loop
  for p in visitseq
      if assignments[p] == 0 && !visited[p]
          neighbs = epsRegionCheck(D, p, eps)
          if length(neighbs) >= minpts
          countPoints = expandCluster!(problem, C, p, neighbs, eps, minpts, assignments, visited)
          push!(counts, countPoints)
          end
          visited[p] = true
      end
  end
end


# function to check if point is a core point (and count number of points in eps-neighborhood)
function epsRegionCheck(problem::LearningProblem, p::Int, solver::GeoSCAN)
  D = calcDistances(problem)
  eps = solver.eps
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


function calcDistances(problem::LearningProblem)
  tdata = targetdata(problem)
  vars  = collect(keys(variables(tdata))) # temporary hack
  npts  = npoints(tdata)
  F = tdata[1:npts,vars] # feature matrix
  D = pairwise(Euclidean(), F, dims=2) # D::AbstractData representing distance matrix
end


function expandCluster!(problem::LearningProblem, C, p, neighbs, eps, minpts, assignments, visited)
    D = calcDistances(problem)
    assignments[p] = C
    countPoints = 1
    while !isempty(neighbs)
        q = popfirst!(neighbs)
        if !visited[q]
            q_neighbs = epsRegionCheck(D, q, eps)
            if length(q_neighbs) >= minpts
                for j in q_neighbs
                    if assignments[j] == 0
                        push!(neighbs, j) # add points in q neighborhood to p neighborhood
                    end
                end
            end
            visited[q] = true
        end
        if assignments[q] == 0
            assignments[q] = C
            countPoints += 1
        end
    end
    countPoints
end

end # module
