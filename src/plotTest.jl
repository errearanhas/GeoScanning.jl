using Makie
using Images
using GeoScanning


img = Images.load("src/images/mauritania.jpg")


function image_handling(img)
  Imag = Float64.(channelview(RGB.(img)))
  r = vec(Imag[1,:,:])
  g = vec(Imag[2,:,:])
  b = vec(Imag[2,:,:])
  (r,g,b,Imag)
end


function geoscan_dbscan(img::AbstractArray, eps::Real, minpts::Int)
  sample = rand(img, 57)
  r,g,b,X = image_handling(sample)
  newdata = GeoScanning.OrderedDict(:R=>r, :G=>g, :B=>b)

  src = GeoScanning.RegularGridData{Float64}(newdata)
  task = GeoScanning.ClusteringTask((:R,:G,:B), :label)
  problem = GeoScanning.LearningProblem(src, src, task)
  solver = GeoScanning.GeoSCAN(eps, minpts)

  solution = GeoScanning.solve(problem, solver)
  labels = solution[1]

  sample, X, labels
end


sample, X, labels = geoscan_dbscan(img, 2.0, 2)


function makie_plot(img, sample, X, labels)
  s1 = Makie.scatter(X[1,:], X[2,:], X[3,:], markersize = 0.1, color = labels)
  s2=Scene()
  s2.camera = s1.camera
  Makie.scatter!(s2, X[1,:], X[2,:], X[3,:], markersize = 0.1, color = sample)
  cs1 = cameracontrols(s1)
  cs2 = cameracontrols(s2)
  cs1.rotationspeed[] = cs2.rotationspeed[] = 0.01
  h = image(img)
  vbox(s1, s2, h)
end


function feature_space_dbscan(img::AbstractArray)
  sample, X, labels = geoscan_dbscan(img, 2.0, 2)
  makie_plot(img, sample, X, labels)
end


feature_space_dbscan(img)
