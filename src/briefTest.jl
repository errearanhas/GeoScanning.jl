using Revise
using GeoScanning

data = rand(3, 10^10)
newdata = GeoScanning.OrderedDict(:R=>data[1,:], :G=>data[2,:], :B=>data[3,:])

src = GeoScanning.RegularGridData{Float64}(newdata)
task = GeoScanning.ClusteringTask((:R,:G,:B), :label)
problem = GeoScanning.LearningProblem(src, src, task)
solver = GeoScanning.GeoSCAN(0.01, 1)

solution = GeoScanning.solve(problem, solver)

labels = solution[1]
count = solution[2]
