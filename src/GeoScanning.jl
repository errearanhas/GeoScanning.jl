# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

module GeoScanning

import GeoStatsBase
export GeoSCAN

"""
GeoSCAN(eps, minpts)
"""
struct GeoSCAN{T<:Real} <: AbstractLearningSolver
  eps::T
  minpts::Int
end

function solve(problem::LearningProblem, solver::GeoSCAN)
end

end # module
