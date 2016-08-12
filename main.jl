using PyPlot
const plt = PyPlot

addprocs(3)
@everywhere include("generatorPoints.jl")
@everywhere include("legendreFunctions.jl")

@everywhere function polyfit(x, y, n)
  A = [ float(x[i])^p for i = 1:length(x), p = 0:n ]
  A \ y
end



@everywhere function findY(polynomial,x)
  return sum([polynomial[i]*(x^(i-1)) for i = 1:length(polynomial)])
end

@everywhere function execute(numberPointsTrain,noiseLevel,targetComplexity,numberPointsTest = 100)
  #legendre = Legendre(targetComplexity,noiseLevel)
  #x,y = legendre.generatorPoints(numberPointsTrain)

  x,y,coeficienteNormalizados = generatorPoints(numberPointsTrain,noiseLevel,targetComplexity)
  x = convert(Array{Float64}, x)
  y = convert(Array{Float64}, y)


  #eoutTwo = regressionAndErrorCalcLegendreType(numberPointsTrain,legendre,x,y,2)
  #eoutTen = regressionAndErrorCalcLegendreType(numberPointsTrain,legendre,x,y,10)

  eoutTwo = regressionAndErrorCalcLegendreFunction(numberPointsTrain,coeficienteNormalizados,x,y,2,targetComplexity)
  eoutTen = regressionAndErrorCalcLegendreFunction(numberPointsTrain,coeficienteNormalizados,x,y,10,targetComplexity)
  return eoutTen - eoutTwo
end

@everywhere function executeAll()

  targetComplexitys = 1:2:100
  noiseLevels = 0.0:0.05:2.0
  numberPointsTrains = 20:5:130
  executeRepetition = 10000
  figure2 = SharedArray(Float64, (length(targetComplexitys),length(numberPointsTrains)))
  x = 1

  @sync @parallel for targetComplexity in targetComplexitys
    y = 1
    for numberPointsTrain in numberPointsTrains
      figure2[x,y] = sum([execute(numberPointsTrain,0.1,targetComplexity) for i=1:executeRepetition])/executeRepetition
      y = y + 1
    end
    x = x + 1
  end
  #figure1 = SharedArray(Float64, (length(numberPointsTrains),length(noiseLevels)))
  #@parallel for noiseLevel in noiseLevels
  #  y = 1
  #  for numberPointsTrain in numberPointsTrains
  #    figure1[y,x] = execute(numberPointsTrain,noiseLevels,20)
  #    y = y + 1
  #  end
  #  x = x + 1
  #end


  println("Waiting ...")
  println("Writing...")
  writecsv("figure2.csv",figure2)
  #writecsv("figure1.csv",figure1)
  return figure2
  plt.imshow(figure2, cmap="jet", interpolation="gaussian", origin="lower", vmin=-0.2, vmax=0.2, extent=[20,130,0,2], aspect="auto")
  plt.colorbar()
  plt.show()

end




#figure1 = SharedArray(Float64, (length(numberPointsTrains),length(noiseLevels)))
#@parallel for noiseLevel in noiseLevels
#  y = 1
#  for numberPointsTrain in numberPointsTrains
#    figure1[y,x] = execute(numberPointsTrain,noiseLevels,20)
#    y = y + 1
#  end
#  x = x + 1
#end
#sum([execute(15,0.1,20) for i=1:1000])/1000

#@sync print("Writing ...")
#writecsv("figure2.csv",figure2)
#writecsv("figure1.csv",figure1)
#heatmap(numberPointsTrains,targetComplexitys,figure2,aspect_ratio=1)
