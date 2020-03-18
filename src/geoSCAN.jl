"""
GeoSCAN(eps, minpts)
"""
struct GeoSCAN{T<:Real} <: AbstractLearningSolver
  eps::T
  minpts::Int
end

function solve(problem::LearningProblem, solver::GeoSCAN)
end
