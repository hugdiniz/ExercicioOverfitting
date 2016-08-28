
#include("generatorPoints.jl")
include("legendreFunctions.jl")

function findY(polynomial,x)
  return sum([polynomial[i]*(x^(i-1)) for i = 1:length(polynomial)])
end

function execute(numberPointsTrain,noiseLevel,targetComplexity,numberPointsTest = 100)
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

function executeAndWrite(executeRepetition = 100)

  targetComplexitys = 1:2:100
  noiseLevels = 0.0:0.05:2.0
  numberPointsTrains = 20:5:130
  figure2 = SharedArray(Float64, (length(targetComplexitys),length(numberPointsTrains)))
  x = 1
  for targetComplexity in targetComplexitys
    y = 1
    for numberPointsTrain in numberPointsTrains
      figure2[x,y] = sum([execute(numberPointsTrain,0.1,targetComplexity) for i=1:executeRepetition])/executeRepetition
      y = y + 1
    end
    x = x + 1
  end

  figure1 = SharedArray(Float64, (length(noiseLevels),length(numberPointsTrains)))
  x = 1
  for noiseLevel in noiseLevels
    y = 1
    for numberPointsTrain in numberPointsTrains
      figure1[x,y] = sum([execute(numberPointsTrain,noiseLevel,20) for i=1:executeRepetition])/executeRepetition
      y = y + 1
    end
    x = x + 1
  end
  nameCSV = string(round(Int64,rand()*10000000000),round(Int64,rand()*10000000000))
  println("Writing...")
  nameCSVFigura1 = string("csv/",nameCSV,"_figure1.csv")
  writecsv(nameCSVFigura1,figure1)
  nameCSVFigura2 = string("csv/",nameCSV,"_figure2.csv")
  writecsv(nameCSVFigura2,figure2)
end


@everywhere function executeAllIteration(iterationMax = 100, executeRepetition = 1000)
  for i in 1:iterationMax
    executeAndWrite(executeRepetition)
  end
end


#plt.imshow(figure2, cmap="jet", interpolation="gaussian", origin="lower", vmin=-0.2, vmax=0.2, extent=[20,130,0,100], aspect="auto")
#plt.colorbar()
#plt.show()
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
