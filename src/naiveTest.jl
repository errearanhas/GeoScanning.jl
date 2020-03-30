using GeoScanning
# using NearestNeighbors

data = rand(3, 10^2)
newdata = GeoScanning.OrderedDict(:R=>data[1,:], :G=>data[2,:], :B=>data[3,:])
src = GeoScanning.RegularGridData{Float64}(newdata)

task = GeoScanning.ClusteringTask((:R,:G,:B), :label)
problem = GeoScanning.LearningProblem(src, src, task)

solver = GeoScanning.GeoSCAN(0.2, 2)

solution = GeoScanning.solve(problem, solver)
