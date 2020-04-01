using Makie
using GeoScanning
using Images


function image_handling(img::AbstractArray)
  imgArray = Float64.(channelview(Images.RGB.(img)))
  r = vec(imgArray[1,:,:])
  g = vec(imgArray[2,:,:])
  b = vec(imgArray[2,:,:])
  (r, g, b, imgArray)
end


function geoscan_dbscan(img::AbstractArray, eps::Real, minpts::Int, sampleSize::Int)
  sample = rand(img, sampleSize)
  r, g, b, X = image_handling(sample)
  newdata = GeoScanning.OrderedDict(:R=>r, :G=>g, :B=>b)

  targ = GeoScanning.RegularGridData{Float64}(newdata)
  task = GeoScanning.ClusteringTask((:R,:G,:B), :label)
  problem = GeoScanning.LearningProblem(targ, targ, task)
  solver = GeoScanning.GeoSCAN(eps, minpts)

  solution = GeoScanning.solve(problem, solver)
  labels = solution[1]

  (sample, X, labels)
end


function makie_plot(img, sample, X, labels)
  s1 = Makie.scatter(X[1,:], X[2,:], X[3,:], markersize = 0.01, color = labels)
  s2=Scene()
  s2.camera = s1.camera
  Makie.scatter!(s2, X[1,:], X[2,:], X[3,:], markersize = 0.01, color = sample)
  cs1 = cameracontrols(s1)
  cs2 = cameracontrols(s2)
  cs1.rotationspeed[] = cs2.rotationspeed[] = 0.01
  h = image(img, scale_plot = false)
  vbox(s1, s2, h)
end


img = Images.load("src/images/mauritania.jpg")
Makie.image(img, scale_plot = false)

sample, X, labels = geoscan_dbscan(img, 0.05, 2, 5000)
makie_plot(img, sample, X, labels)
