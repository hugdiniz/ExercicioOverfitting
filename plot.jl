using PyPlot
const plt = PyPlot

function plotFigure(numero)
  paths = readdir("csv/")
  pathsFigure1 = paths[find(x->contains(x,string(numero,".csv")),paths)]

  figure1 = -1
  for pathFigure1 in pathsFigure1
    if figure1 == -1
      figure1 = readcsv(string("csv/",pathFigure1))
    else
      figure1 = figure1 + readcsv(string("csv/",pathFigure1))
    end
  end
  figure1 = figure1 / length(pathsFigure1)
  plt.imshow(figure1, cmap="jet", interpolation="gaussian", origin="lower", vmin=-0.2, vmax=0.2, extent=[20,130,0,100], aspect="auto")
  plt.colorbar()

end
