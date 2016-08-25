function generatorPoints(qtd,noiseLevel,qf)
  coeficientes = randn(qf+1)
  k = 0
  for l = 1:qf+1
    k = k + (coeficientes[l]^2) / (2 * l + 1)
  end
  coeficienteNormalizados = coeficientes / sqrt(2*k)

  xs = sort([generateXPoint() for i=1:qtd])
  ys = [generateYPoint(x,noiseLevel,qf,coeficienteNormalizados) for x in xs]
  return xs,ys,coeficienteNormalizados
end

function generateXPoint()
  return -1 + rand()*(2)
end

function generateYPoint(x,noiseLevel,qf,coeficienteNormalizados)
  f = sum([coeficienteNormalizados[i] * iterativeLegendre(i -1,x) for i in 1:(qf+1)])
  return f + sqrt(noiseLevel) * (rand(Bool) ? 1:-1)  * rand()
end

 function iterativeLegendre(qf,x)
  if qf==0
      return one(x)
  elseif qf==1
      return(x)
  end
  p = 0
  p0 = one(x)
  p1 = x

  for i = 2:qf
      p = ((2*i - 1) / i ) * x * p1 - ((i-1)/ i) * p0
      p0 = p1
      p1 = p
  end

  return p
end

function generatorPoints(qtd)
  xs = sort([generateXPoint() for i=1:qtd])
  ys = [generateYPoint(x) for x in xs]
  return xs,ys
end

function regressionAndErrorCalcLegendreFunction(numberPointsTrain,coeficienteNormalizados,x,y,hipotese,qf)
  e2 = 0;
  X2 = ones((numberPointsTrain,hipotese+1))
  for l = 1:numberPointsTrain
    for m = 2:hipotese+1
      X2[l,m] = iterativeLegendre(m-1,x[l])
    end
  end
  w2 = pinv(X2) * y

  a1 = 0
  b1 = 0
  for l = 1:max(hipotese+1,qf+1)
    if l > qf+1
      a1 = 0
    else
      a1 = coeficienteNormalizados[l]
    end

    if l > hipotese+1
      b1 = 0
    else
      b1 = w2[l]
    end
    e2 = e2 + ( ( (a1 - b1)^2 ) / (2 * l + 1) )
  end
  return e2
end
